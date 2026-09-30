from datetime import date
from typing import Tuple, List, Optional
from app.models.requirement import Requirement
from app.models.machine import Machine, MachineStatus
from app.models.business import VerificationStatus
from app.matching.distance import haversine_distance_km, resolve_coordinates


# Weights as defined in product specification
WEIGHT_CAPABILITY = 0.40
WEIGHT_AVAILABILITY = 0.20
WEIGHT_DISTANCE = 0.15
WEIGHT_COST = 0.15
WEIGHT_RELIABILITY = 0.10


def calculate_capability_score(requirement: Requirement, machine: Machine) -> Tuple[float, List[str]]:
    """
    Capability match (40% total weight):
    - Process match: 60%
    - Material match: 25%
    - Tolerance / dimensions: 15%
    """
    reasons = []
    req_proc = requirement.process.lower()
    req_mat = requirement.material.lower()

    # Process evaluation
    process_score = 0.0
    exact_process = False
    for cap in machine.capabilities:
        cap_proc = cap.process.lower()
        if req_proc == cap_proc or req_proc in cap_proc or cap_proc in req_proc:
            process_score = 1.0
            exact_process = True
            break
        elif any(token in cap_proc for token in req_proc.split()):
            process_score = max(process_score, 0.75)

    if exact_process:
        reasons.append(f"Exact manufacturing process match ({requirement.process})")
    elif process_score > 0:
        reasons.append(f"Compatible manufacturing process ({machine.category})")
    else:
        # Check machine category directly
        if req_proc in machine.category.lower() or machine.category.lower() in req_proc:
            process_score = 0.85
            reasons.append(f"Machine category aligns with required process ({machine.category})")
        else:
            reasons.append(f"Process mismatch ({requirement.process} vs {machine.category})")

    # Material evaluation
    material_score = 0.0
    matched_material = False
    for cap in machine.capabilities:
        cap_mat = cap.material.lower()
        if req_mat == cap_mat or req_mat in cap_mat or cap_mat in req_mat:
            material_score = 1.0
            matched_material = True
            break
        elif any(token in cap_mat for token in req_mat.split()):
            material_score = max(material_score, 0.6)

    if matched_material:
        reasons.append(f"Certified to machine {requirement.material}")
    elif material_score > 0:
        reasons.append(f"Supports related material alloy ({requirement.material})")
    else:
        # Default baseline if general metal/plastic machine
        material_score = 0.5
        reasons.append(f"General tooling compatible with {requirement.material}")

    # Tolerance evaluation
    tolerance_score = 1.0
    if requirement.tolerance_mm:
        # Check if precision tolerance string exists in machine
        if machine.precision_tolerance:
            try:
                prec_str = machine.precision_tolerance.replace("±", "").replace("+/-", "").replace("mm", "").strip()
                mach_tol = float(prec_str)
                if mach_tol <= requirement.tolerance_mm:
                    tolerance_score = 1.0
                    reasons.append(f"Precision tolerance {machine.precision_tolerance} meets required ±{requirement.tolerance_mm} mm")
                else:
                    tolerance_score = max(0.5, 1.0 - (mach_tol - requirement.tolerance_mm) / requirement.tolerance_mm)
            except Exception:
                tolerance_score = 0.9
        else:
            tolerance_score = 0.9

    total_cap = (process_score * 0.60) + (material_score * 0.25) + (tolerance_score * 0.15)
    return round(total_cap, 4), reasons


def calculate_availability_score(requirement: Requirement, machine: Machine) -> Tuple[float, List[str]]:
    """
    Availability match (20% total weight):
    Evaluates whether machine has unbooked operating capacity between required_date and delivery_deadline.
    """
    reasons = []
    req_start = requirement.required_date
    req_deadline = requirement.delivery_deadline

    # Basic date validity
    days_span = (req_deadline - req_start).days
    if days_span <= 0:
        days_span = 1

    # Check machine status
    if machine.status not in (MachineStatus.ACTIVE, MachineStatus.AVAILABLE):
        return 0.0, ["Machine is currently inactive or in scheduled maintenance"]

    # Check unblocked availability slots in range
    blocked_count = 0
    total_slots = 0
    for slot in machine.availabilities:
        if req_start <= slot.date <= req_deadline:
            total_slots += 1
            if not slot.is_available:
                blocked_count += 1

    if blocked_count > 0:
        avail_ratio = max(0.2, (total_slots - blocked_count) / max(1, total_slots))
        score = avail_ratio
        reasons.append(f"Partial schedule conflict: {blocked_count} blocked slots in required date window")
    else:
        score = 1.0
        reasons.append(f"Immediate capacity available between {req_start.strftime('%d %b')} and {req_deadline.strftime('%d %b')}")

    return round(score, 4), reasons


def calculate_distance_score(
    requirement: Requirement,
    machine: Machine,
    search_location: Optional[str] = None,
) -> Tuple[float, float, List[str]]:
    """
    Distance match (15% total weight):
    Calculates true Haversine distance between seeker coordinates and provider machine.
    """
    reasons = []
    if search_location:
        req_lat, req_lon = resolve_coordinates(search_location)
    else:
        req_lat = requirement.latitude
        req_lon = requirement.longitude
        if req_lat is None or req_lon is None:
            req_lat, req_lon = resolve_coordinates(requirement.preferred_location)

    dist_km = haversine_distance_km(req_lat, req_lon, machine.latitude, machine.longitude)
    max_dist = requirement.max_distance_km or 100.0

    if dist_km <= 10.0:
        score = 1.0
        reasons.append(f"Located {dist_km:.1f} km away in immediate industrial cluster")
    elif dist_km <= max_dist:
        decay = (dist_km - 10.0) / max(1.0, max_dist - 10.0)
        score = max(0.3, 1.0 - (0.7 * decay))
        reasons.append(f"Located {dist_km:.1f} km away (within preferred {max_dist:.0f} km radius)")
    else:
        score = max(0.1, 0.3 * (1.0 - min(1.0, (dist_km - max_dist) / max_dist)))
        reasons.append(f"Located {dist_km:.1f} km away (exceeds preferred radius)")

    return round(score, 4), dist_km, reasons


def calculate_cost_score(requirement: Requirement, machine: Machine) -> Tuple[float, float, List[str]]:
    """
    Cost match (15% total weight):
    Estimates total machining hours = max(1.0, quantity / throughput)
    Job Cost = max(min_job_value, hourly_price * hours)
    """
    reasons = []
    # Heuristic throughput estimate: 20 parts per hour for small/medium CNC, 50 parts for laser
    parts_per_hour = 25.0
    if "laser" in machine.category.lower():
        parts_per_hour = 60.0
    elif "milling" in machine.category.lower():
        parts_per_hour = 15.0

    est_hours = max(2.0, round(requirement.quantity / parts_per_hour, 1))
    est_cost = max(machine.min_job_value or 0.0, machine.hourly_price * est_hours)
    budget = requirement.budget

    if est_cost <= budget:
        score = 1.0
        reasons.append(f"Estimated cost ₹{est_cost:,.0f} (at ₹{machine.hourly_price:,.0f}/hr) fits your ₹{budget:,.0f} budget")
    else:
        overrun = (est_cost - budget) / budget
        if overrun <= 0.20:
            score = 1.0 - (2.5 * overrun)
            reasons.append(f"Estimated cost ₹{est_cost:,.0f} is slightly (+{overrun*100:.0f}%) over budget")
        elif overrun <= 0.40:
            score = max(0.2, 0.5 - overrun)
            reasons.append(f"Estimated cost ₹{est_cost:,.0f} exceeds budget by {overrun*100:.0f}%")
        else:
            score = 0.05
            reasons.append(f"Estimated cost ₹{est_cost:,.0f} significantly exceeds budget")

    return round(score, 4), est_cost, reasons


def calculate_reliability_score(machine: Machine, average_rating: float = 4.5, completed_jobs: int = 12) -> Tuple[float, List[str]]:
    """
    Reliability & trust match (10% total weight):
    - Normalized rating (50%)
    - Completed jobs volume (30%)
    - Verification status (20%)
    """
    reasons = []
    rating_score = min(1.0, average_rating / 5.0)
    jobs_score = min(1.0, completed_jobs / 20.0)
    verif_score = 1.0 if machine.verification_status == VerificationStatus.VERIFIED else 0.6

    total = (rating_score * 0.50) + (jobs_score * 0.30) + (verif_score * 0.20)

    if machine.verification_status == VerificationStatus.VERIFIED:
        reasons.append(f"Verified MSME with {average_rating:.1f}★ rating ({completed_jobs} completed jobs)")
    else:
        reasons.append(f"Provider rating {average_rating:.1f}★ with {completed_jobs} completed jobs")

    return round(total, 4), reasons
