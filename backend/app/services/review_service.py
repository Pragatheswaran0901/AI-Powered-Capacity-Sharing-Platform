from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.review import Review
from app.models.booking import Booking, BookingStatus
from app.models.business import Business
from app.schemas.review import ReviewCreate
from app.repositories.review_repo import ReviewRepository
from app.repositories.booking_repo import BookingRepository
from app.repositories.business_repo import BusinessRepository


class ReviewService:
    def __init__(self, db: Session):
        self.db = db
        self.review_repo = ReviewRepository(db)
        self.booking_repo = BookingRepository(db)
        self.biz_repo = BusinessRepository(db)

    def create_review(self, reviewer_id: str, review_in: ReviewCreate) -> Review:
        b = self.booking_repo.get(review_in.booking_id)
        if not b:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")

        # Must be completed
        if b.status != BookingStatus.COMPLETED:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Can only review completed bookings")

        # Determine reviewee
        if reviewer_id == b.seeker_id:
            reviewee_id = b.provider_id
        elif reviewer_id == b.provider_id:
            reviewee_id = b.seeker_id
        else:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You were not a party in this booking")

        # Check for duplicate review by same reviewer for this booking
        existing = (
            self.db.query(Review)
            .filter(Review.booking_id == b.id, Review.reviewer_id == reviewer_id)
            .first()
        )
        if existing:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You have already reviewed this booking")

        review = Review(
            booking_id=b.id,
            reviewer_id=reviewer_id,
            reviewee_id=reviewee_id,
            rating=review_in.rating,
            review_text=review_in.review_text,
        )
        return self.review_repo.create(review)

    def get_business_reviews(self, business_id: str) -> List[Review]:
        biz = self.biz_repo.get(business_id)
        if not biz:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Business not found")
        return self.review_repo.get_by_reviewee(biz.user_id)
