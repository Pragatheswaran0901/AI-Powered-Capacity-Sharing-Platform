from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.match import MatchResultOut, ComparisonMatrixOut, CompareRequest
from app.services.matching_service import MatchingService

router = APIRouter()


@router.get("/requirement/{requirement_id}", response_model=List[MatchResultOut])
def get_matches_for_requirement(
    requirement_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Capacity Matching Engine:
    Evaluates candidate machines across 5 deterministic dimensions:
    - Capability match (40%)
    - Availability (20%)
    - Distance via Haversine (15%)
    - Cost vs Budget (15%)
    - Reliability & Trust (10%)
    Returns ranked recommendations with transparent explainability bullet points.
    """
    return MatchingService(db).find_matches_for_requirement(requirement_id)


@router.post("/compare", response_model=ComparisonMatrixOut)
def compare_candidate_machines(
    compare_in: CompareRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Generate a side-by-side comparison matrix of 2-3 shortlisted capacity options."""
    return MatchingService(db).compare_providers(compare_in)
