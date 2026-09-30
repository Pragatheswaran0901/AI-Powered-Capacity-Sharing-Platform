import json
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.requirement import Requirement, RequirementStatus
from app.models.machine import Machine, MachineStatus
from app.models.match import Match
from app.schemas.match import MatchResultOut, ComparisonMatrixOut, CompareRequest
from app.repositories.requirement_repo import RequirementRepository
from app.repositories.machine_repo import MachineRepository
from app.repositories.review_repo import ReviewRepository
from app.matching.engine import matching_engine


class MatchingService:
    def __init__(self, db: Session):
        self.db = db
        self.req_repo = RequirementRepository(db)
        self.machine_repo = MachineRepository(db)
        self.review_repo = ReviewRepository(db)

    def find_matches_for_requirement(
        self,
        requirement_id: str,
        location: Optional[str] = None,
    ) -> List[MatchResultOut]:
        requirement = self.req_repo.get(requirement_id)
        if not requirement:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Requirement not found")

        # Gather active candidate machines (excluding seeker's own machines)
        candidates = self.machine_repo.search_active_machines(
            location=location,
            exclude_user_id=requirement.seeker_id,
        )
        if not candidates:
            return []

        # Build ratings and completed jobs maps for accuracy
        ratings_map = {}
        for c in candidates:
            if c.business:
                ratings_map[str(c.business.id)] = self.review_repo.get_average_rating(str(c.business.user_id))

        # Rank matches via matching engine
        search_loc = location or requirement.preferred_location
        ranked = matching_engine.rank_matches(
            requirement,
            candidates,
            ratings_map=ratings_map,
            search_location=search_loc,
        )

        # Persist matches into the database for auditability and caching
        db_matches = []
        for r in ranked:
            db_m = Match(
                requirement_id=requirement.id,
                machine_id=r.machine_id,
                overall_score=r.overall_score,
                capability_score=r.score_breakdown.capability_score,
                availability_score=r.score_breakdown.availability_score,
                distance_score=r.score_breakdown.distance_score,
                cost_score=r.score_breakdown.cost_score,
                reliability_score=r.score_breakdown.reliability_score,
                match_reasons=json.dumps(r.match_reasons),
            )
            db_matches.append(db_m)

        self.req_repo.save_matches(requirement.id, db_matches)

        # Update requirement status if open
        if requirement.status == RequirementStatus.OPEN and ranked:
            requirement.status = RequirementStatus.MATCHED
            self.req_repo.update(requirement)

        return ranked

    def compare_providers(self, compare_in: CompareRequest) -> ComparisonMatrixOut:
        requirement = self.req_repo.get(compare_in.requirement_id)
        if not requirement:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Requirement not found")

        selected_machines = []
        for mid in compare_in.machine_ids:
            m = self.machine_repo.get_with_details(mid)
            if m:
                selected_machines.append(m)

        if not selected_machines:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No valid machines found for comparison")

        return matching_engine.generate_comparison_matrix(requirement, selected_machines)
