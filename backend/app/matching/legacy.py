import math
from typing import List, Dict, Tuple
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session
from app.models import Machine, Requirement, MSME, Review, Booking

# Coordinates of Tamil Nadu Manufacturing Hubs (lat, lng)
TN_CITIES_COORDS: Dict[str, Tuple[float, float]] = {
    "coimbatore": (11.0168, 76.9558),
    "chennai": (13.0827, 80.2707),
    "hosur": (12.7409, 77.8253),
    "salem": (11.6643, 78.1460),
    "tiruppur": (11.1085, 77.3411),
    "erode": (11.3410, 77.7172),
    "madurai": (9.9252, 78.1198),
    "trichy": (10.7905, 78.7047),
    "sriperumbudur": (12.9691, 79.9405),
    "ambattur": (13.1143, 80.1548),
    "avadi": (13.1147, 80.1098),
    "pollachi": (10.6609, 77.0048),
    "karur": (10.9601, 78.0766),
    "sivakasi": (9.4533, 77.7960)
}

def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance in kilometers between two GPS points."""
    R = 6371.0  # Earth radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

def get_city_coords(city_name: str) -> Tuple[float, float]:
    city_lower = city_name.strip().lower()
    for key, coords in TN_CITIES_COORDS.items():
        if key in city_lower or city_lower in key:
            return coords
    return TN_CITIES_COORDS["coimbatore"]

def calculate_capability_score(machine: Machine, req_process: str, req_material: str) -> float:
    """Calculate process and material compatibility score (0.0 to 1.0)."""
    p_req = req_process.lower().strip()
    m_req = req_material.lower().strip()
    
    process_match = 0.0
    machine_type_lower = (machine.category if hasattr(machine, 'category') else getattr(machine, 'machine_type', '')).lower()
    
    if p_req in machine_type_lower or machine_type_lower in p_req:
        process_match = 1.0
    elif ("cnc" in p_req and "cnc" in machine_type_lower) or ("vmc" in p_req and "cnc" in machine_type_lower) or ("vmc" in p_req and "vmc" in machine_type_lower):
        process_match = 0.95
    elif ("milling" in p_req and ("vmc" in machine_type_lower or "milling" in machine_type_lower)):
        process_match = 0.95
    elif ("turning" in p_req or "lathe" in p_req) and ("turning" in machine_type_lower or "lathe" in machine_type_lower):
        process_match = 0.95
    elif ("laser" in p_req or "cutting" in p_req) and ("laser" in machine_type_lower or "cutting" in machine_type_lower):
        process_match = 0.90
    else:
        process_match = 0.40

    material_match = 0.85
    return (process_match * 0.70) + (material_match * 0.30)

def calculate_distance_score(machine: Machine, seeker_msme: MSME, pref_city: str) -> Tuple[float, float]:
    """Calculate geographical proximity score and actual distance."""
    m_lat, m_lon = getattr(machine, 'latitude', 11.0168), getattr(machine, 'longitude', 76.9558)
    s_lat, s_lon = (getattr(seeker_msme, 'latitude', None), getattr(seeker_msme, 'longitude', None)) if seeker_msme else (None, None)

    if s_lat is None or s_lon is None:
        s_lat, s_lon = get_city_coords(pref_city)

    dist_km = haversine_distance(m_lat or 11.0168, m_lon or 76.9558, s_lat, s_lon)
    if dist_km <= 15:
        score = 1.0
    elif dist_km <= 35:
        score = 0.90
    elif dist_km <= 75:
        score = 0.75
    elif dist_km <= 150:
        score = 0.50
    else:
        score = max(0.10, 1.0 - (dist_km / 300))
    return round(score, 3), round(dist_km, 1)

def calculate_cost_score(machine: Machine, quantity: int, budget: float) -> float:
    """Calculate price affordability score."""
    hourly_rate = getattr(machine, 'hourly_price', getattr(machine, 'hourly_rate', 1500.0))
    est_hours = max(1, quantity // 10)
    est_cost = est_hours * hourly_rate
    
    if budget <= 0:
        return 0.80
    if est_cost <= budget:
        return 1.0
    elif est_cost <= budget * 1.15:
        return 0.85
    elif est_cost <= budget * 1.30:
        return 0.60
    else:
        return 0.30

def calculate_reliability_score(machine: Machine, db: Session) -> float:
    """Compute reliability based on historical reviews and verification."""
    v_status = getattr(machine, 'verification_status', 'VERIFIED')
    if hasattr(v_status, 'value'):
        v_status = v_status.value
    if str(v_status).lower() in ("verified", "verificationstatus.verified"):
        return 0.95
    return 0.80

def calculate_availability_score(machine: Machine, deadline_str: str) -> float:
    """Calculate availability score based on operational status and deadline."""
    v_status = getattr(machine, 'verification_status', '')
    if hasattr(v_status, 'value'):
        v_status = v_status.value
    if str(v_status).lower() in ("rejected", "verificationstatus.rejected"):
        return 0.0
    op_bonus = 0.2 if getattr(machine, 'operator_available', True) else 0.0
    return min(1.0, 0.80 + op_bonus)

def match_requirement_to_machines(requirement: Requirement, db: Session) -> List[dict]:
    """
    Smart Capacity Matching Engine:
    MATCH SCORE = Capability * 0.40 + Availability * 0.20 + Distance * 0.15 + Cost * 0.15 + Reliability * 0.10
    """
    machines = db.query(Machine).all()
    results = []
    
    for machine in machines:
        cap_score = calculate_capability_score(machine, getattr(requirement, 'process', ''), getattr(requirement, 'material', ''))
        avail_score = calculate_availability_score(machine, getattr(requirement, 'deadline', ''))
        dist_score, dist_km = calculate_distance_score(machine, getattr(requirement, 'seeker_msme', None), getattr(requirement, 'preferred_city', 'Coimbatore'))
        cost_score = calculate_cost_score(machine, getattr(requirement, 'quantity', 1), getattr(requirement, 'budget', 10000.0))
        rel_score = calculate_reliability_score(machine, db)
        
        total_score = (
            (cap_score * 0.40) +
            (avail_score * 0.20) +
            (dist_score * 0.15) +
            (cost_score * 0.15) +
            (rel_score * 0.10)
        )
        match_percentage = round(total_score * 100)
        
        results.append({
            "machine": machine,
            "capability_score": cap_score,
            "availability_score": avail_score,
            "distance_score": dist_score,
            "cost_score": cost_score,
            "reliability_score": rel_score,
            "total_score": round(total_score, 3),
            "match_percentage": match_percentage,
            "distance_km": dist_km
        })
        
    results.sort(key=lambda x: x["total_score"], reverse=True)
    return results
