from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Review, Booking, User, MSME
from ..schemas import ReviewCreate, ReviewResponse
from ..auth import get_current_user

router = APIRouter(prefix="/reviews", tags=["Reviews"])

@router.get("", response_model=List[ReviewResponse])
def list_reviews(msme_id: int = None, db: Session = Depends(get_db)):
    query = db.query(Review)
    if msme_id:
        query = query.filter(Review.reviewed_msme_id == msme_id)
        
    reviews = query.order_by(Review.created_at.desc()).all()
    results = []
    for r in reviews:
        reviewer = db.query(User).filter(User.id == r.reviewer_id).first()
        results.append({
            "id": r.id,
            "booking_id": r.booking_id,
            "reviewer_id": r.reviewer_id,
            "reviewer_name": reviewer.name if reviewer else "Seeker User",
            "reviewed_msme_id": r.reviewed_msme_id,
            "rating": r.rating,
            "quality_rating": r.quality_rating,
            "reliability_rating": r.reliability_rating,
            "communication_rating": r.communication_rating,
            "comment": r.comment,
            "created_at": r.created_at
        })
    return results

@router.post("", response_model=ReviewResponse)
def create_review(review_input: ReviewCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    booking = db.query(Booking).filter(Booking.id == review_input.booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
        
    new_review = Review(
        booking_id=booking.id,
        reviewer_id=current_user.id,
        reviewed_msme_id=booking.owner_msme_id,
        rating=review_input.rating,
        quality_rating=review_input.quality_rating,
        reliability_rating=review_input.reliability_rating,
        communication_rating=review_input.communication_rating,
        comment=review_input.comment
    )
    db.add(new_review)
    booking.status = "completed"
    db.commit()
    db.refresh(new_review)
    
    return {
        "id": new_review.id,
        "booking_id": new_review.booking_id,
        "reviewer_id": new_review.reviewer_id,
        "reviewer_name": current_user.name,
        "reviewed_msme_id": new_review.reviewed_msme_id,
        "rating": new_review.rating,
        "quality_rating": new_review.quality_rating,
        "reliability_rating": new_review.reliability_rating,
        "communication_rating": new_review.communication_rating,
        "comment": new_review.comment,
        "created_at": new_review.created_at
    }
