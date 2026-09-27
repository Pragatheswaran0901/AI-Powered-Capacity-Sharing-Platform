from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.requirement import (
    RequirementCreate, RequirementOut, RequirementDetail,
    NaturalLanguageQuery, InterpretedRequirement
)
from app.services.requirement_service import RequirementService
from app.services.ai_service import ai_service

router = APIRouter()


@router.post("/parse-nl", response_model=InterpretedRequirement)
def parse_natural_language_prompt(
    query: NaturalLanguageQuery,
    current_user: User = Depends(get_current_user),
):
    """
    AI Service: Converts unstructured natural language requirement into structured parameters.
    Output is validated against Pydantic schema before client confirmation.
    """
    return ai_service.parse_natural_language_requirement(query.prompt)


@router.post("/", response_model=RequirementOut, status_code=status.HTTP_201_CREATED)
def create_requirement(
    req_in: RequirementCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Submit a structured manufacturing capacity requirement."""
    req = RequirementService(db).create_requirement(current_user.id, req_in)
    return req


@router.get("/my", response_model=List[RequirementOut])
def get_my_requirements(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get all capacity requirements posted by the authenticated seeker."""
    return RequirementService(db).get_my_requirements(current_user.id)


@router.get("/{requirement_id}", response_model=RequirementDetail)
def get_requirement_detail(
    requirement_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Inspect capacity requirement specifications and match status."""
    req = RequirementService(db).get_requirement(requirement_id)
    return RequirementDetail(
        id=req.id,
        seeker_id=req.seeker_id,
        seeker_name=req.seeker.full_name if req.seeker else None,
        title=req.title,
        description=req.description,
        process=req.process,
        material=req.material,
        quantity=req.quantity,
        dimensions=req.dimensions,
        tolerance_mm=req.tolerance_mm,
        required_date=req.required_date,
        delivery_deadline=req.delivery_deadline,
        preferred_location=req.preferred_location,
        latitude=req.latitude,
        longitude=req.longitude,
        max_distance_km=req.max_distance_km,
        budget=req.budget,
        quality_requirements=req.quality_requirements,
        operator_required=req.operator_required,
        status=req.status,
        created_at=req.created_at,
        updated_at=req.updated_at,
        attachments=req.attachments,
        matched_count=len(req.matches),
    )
