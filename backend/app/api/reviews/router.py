from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.review import ReviewCreate, ReviewOut
from app.services.review_service import ReviewService

router = APIRouter()


@router.post("/", response_model=ReviewOut, status_code=status.HTTP_201_CREATED)
def submit_review(
    review_in: ReviewCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Submit post-completion rating (1-5 stars) and feedback."""
    r = ReviewService(db).create_review(current_user.id, review_in)
    return ReviewOut(
        id=r.id,
        booking_id=r.booking_id,
        reviewer_id=r.reviewer_id,
        reviewer_name=current_user.full_name,
        reviewee_id=r.reviewee_id,
        rating=r.rating,
        review_text=r.review_text,
        created_at=r.created_at,
    )


@router.get("/business/{business_id}", response_model=List[ReviewOut])
def get_business_reviews(
    business_id: str,
    db: Session = Depends(get_db),
):
    """Retrieve verified review history for an MSME."""
    reviews = ReviewService(db).get_business_reviews(business_id)
    return [
        ReviewOut(
            id=r.id,
            booking_id=r.booking_id,
            reviewer_id=r.reviewer_id,
            reviewer_name=r.reviewer.full_name if r.reviewer else "Anonymous",
            reviewee_id=r.reviewee_id,
            rating=r.rating,
            review_text=r.review_text,
            created_at=r.created_at,
        )
        for r in reviews
    ]
