from typing import Optional, List
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from app.models.review import Review
from app.models.user import User
from app.repositories.base import BaseRepository


class ReviewRepository(BaseRepository[Review]):
    def __init__(self, db: Session):
        super().__init__(Review, db)

    def get_by_reviewee(self, reviewee_id: str) -> List[Review]:
        return (
            self.db.query(Review)
            .options(joinedload(Review.reviewer))
            .filter(Review.reviewee_id == reviewee_id)
            .order_by(Review.created_at.desc())
            .all()
        )

    def get_by_booking(self, booking_id: str) -> List[Review]:
        return self.db.query(Review).filter(Review.booking_id == booking_id).all()

    def get_average_rating(self, reviewee_id: str) -> float:
        val = self.db.query(func.avg(Review.rating)).filter(Review.reviewee_id == reviewee_id).scalar()
        return round(float(val), 1) if val is not None else 4.5
