import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, DateTime, Text, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship
from app.core.database import Base


class Review(Base):
    __tablename__ = "reviews"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    booking_id = Column(String(36), ForeignKey("bookings.id", ondelete="CASCADE"), nullable=False)
    reviewer_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    reviewee_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    rating = Column(Integer, nullable=False)
    review_text = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (
        CheckConstraint("rating >= 1 AND rating <= 5", name="rating_range_check"),
    )

    # Relationships
    booking = relationship("Booking", back_populates="reviews")
    reviewer = relationship("User", back_populates="reviews_given", foreign_keys=[reviewer_id])
    reviewee = relationship("User", back_populates="reviews_received", foreign_keys=[reviewee_id])
