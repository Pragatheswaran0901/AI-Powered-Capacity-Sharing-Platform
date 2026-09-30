from typing import List, Dict, Any, Optional
from app.models.requirement import Requirement
from app.models.machine import Machine
from app.schemas.match import (
    MatchResultOut, MatchScoreBreakdown, ComparisonMatrixOut, ComparisonMatrixItem
)
from app.matching.scorer import (
    calculate_capability_score,
    calculate_availability_score,
    calculate_distance_score,
    calculate_cost_score,
    calculate_reliability_score,
    WEIGHT_CAPABILITY,
    WEIGHT_AVAILABILITY,
    WEIGHT_DISTANCE,
    WEIGHT_COST,
    WEIGHT_RELIABILITY,
)


class MatchingEngine:
    def __init__(self):
        pass

    def evaluate_machine(
        self,
        requirement: Requirement,
        machine: Machine,
        average_rating: float = 4.7,
        completed_jobs: int = 15,
        search_location: Optional[str] = None,
    ) -> MatchResultOut:
        # 1. Capability Score (40%)
        cap_score, cap_reasons = calculate_capability_score(requirement, machine)

        # 2. Availability Score (20%)
        avail_score, avail_reasons = calculate_availability_score(requirement, machine)

        # 3. Distance Score (15%)
        dist_score, dist_km, dist_reasons = calculate_distance_score(
            requirement, machine, search_location=search_location
        )

        # 4. Cost Score (15%)
        cost_score, est_cost, cost_reasons = calculate_cost_score(requirement, machine)

        # 5. Reliability Score (10%)
        rel_score, rel_reasons = calculate_reliability_score(machine, average_rating, completed_jobs)

        # Compute weighted overall score
        overall = (
            (cap_score * WEIGHT_CAPABILITY)
            + (avail_score * WEIGHT_AVAILABILITY)
            + (dist_score * WEIGHT_DISTANCE)
            + (cost_score * WEIGHT_COST)
            + (rel_score * WEIGHT_RELIABILITY)
        )
        match_percentage = min(99, max(15, round(overall * 100)))

        all_reasons = cap_reasons + avail_reasons + dist_reasons + cost_reasons + rel_reasons

        breakdown = MatchScoreBreakdown(
            capability_score=cap_score,
            availability_score=avail_score,
            distance_score=dist_score,
            cost_score=cost_score,
            reliability_score=rel_score,
            distance_km=dist_km,
            estimated_cost=est_cost,
        )

        biz_name = machine.business.name if machine.business else "MSME Partner"
        caps_out = [
            {
                "id": str(c.id),
                "process": c.process,
                "material": c.material,
                "min_tolerance_mm": c.min_tolerance_mm,
                "max_dimension_x": c.max_dimension_x,
                "max_dimension_y": c.max_dimension_y,
                "max_dimension_z": c.max_dimension_z,
            }
            for c in (machine.capabilities or [])
        ]

        return MatchResultOut(
            machine_id=str(machine.id),
            business_id=str(machine.business_id),
            business_name=biz_name,
            machine_name=machine.name,
            machine_category=machine.category,
            manufacturer=machine.manufacturer,
            model=machine.model,
            year=machine.year,
            location_address=machine.location_address,
            hourly_price=machine.hourly_price,
            overall_score=round(overall, 4),
            match_percentage=match_percentage,
            score_breakdown=breakdown,
            match_reasons=all_reasons,
            photos=machine.photo_list,
            capabilities=caps_out,
            operator_available=bool(machine.operator_available),
            status=machine.status.value if hasattr(machine.status, 'value') else str(machine.status),
            average_rating=average_rating,
            completed_jobs=completed_jobs,
            verification_status=machine.verification_status.value if hasattr(machine.verification_status, 'value') else str(machine.verification_status),
            latitude=machine.latitude,
            longitude=machine.longitude,
        )

    def rank_matches(
        self,
        requirement: Requirement,
        machines: List[Machine],
        ratings_map: Optional[Dict[str, float]] = None,
        jobs_map: Optional[Dict[str, int]] = None,
        search_location: Optional[str] = None,
    ) -> List[MatchResultOut]:
        results: List[MatchResultOut] = []
        ratings_map = ratings_map or {}
        jobs_map = jobs_map or {}

        for m in machines:
            rating = ratings_map.get(str(m.business_id), 4.7)
            jobs = jobs_map.get(str(m.business_id), 18)
            result = self.evaluate_machine(
                requirement,
                m,
                average_rating=rating,
                completed_jobs=jobs,
                search_location=search_location,
            )
            results.append(result)

        # Sort descending by overall match score
        results.sort(key=lambda x: x.overall_score, reverse=True)
        return results

    def generate_comparison_matrix(
        self,
        requirement: Requirement,
        machines: List[Machine],
    ) -> ComparisonMatrixOut:
        items: List[ComparisonMatrixItem] = []
        for m in machines:
            res = self.evaluate_machine(requirement, m)
            items.append(
                ComparisonMatrixItem(
                    machine_id=str(m.id),
                    machine_name=m.name,
                    business_name=m.business.name if m.business else "MSME Partner",
                    category=m.category,
                    hourly_price=m.hourly_price,
                    match_percentage=res.match_percentage,
                    distance_km=res.score_breakdown.distance_km,
                    estimated_cost=res.score_breakdown.estimated_cost,
                    tolerance=m.precision_tolerance or "Standard ±0.05 mm",
                    dimensions=m.dimensions_capacity or "Standard Envelope",
                    rating=res.average_rating,
                    verification_status=res.verification_status,
                    key_reasons=res.match_reasons[:3],
                )
            )

        return ComparisonMatrixOut(
            requirement_id=str(requirement.id),
            requirement_title=requirement.title,
            items=items,
        )


matching_engine = MatchingEngine()
