from typing import Optional
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.business import BusinessCreate, BusinessUpdate, BusinessOut
from app.services.business_service import BusinessService

router = APIRouter()


@router.post("/", response_model=BusinessOut, status_code=status.HTTP_201_CREATED)
def create_business(
    biz_in: BusinessCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Register MSME business profile for the current user."""
    return BusinessService(db).create_business(current_user.id, biz_in)


@router.get("/me", response_model=Optional[BusinessOut])
def get_my_business(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve the authenticated user's MSME profile."""
    biz = BusinessService(db).get_user_business(current_user.id)
    return biz


@router.put("/me", response_model=BusinessOut)
def update_my_business(
    update_in: BusinessUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update authenticated user's business details."""
    return BusinessService(db).update_business(current_user.id, update_in)


@router.get("/{business_id}", response_model=BusinessOut)
def get_public_business_profile(
    business_id: str,
    db: Session = Depends(get_db),
):
    """Public profile of an MSME with verification badges."""
    return BusinessService(db).get_public_profile(business_id)
