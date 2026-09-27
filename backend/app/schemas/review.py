from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class ReviewCreate(BaseModel):
    booking_id: str
    rating: int = Field(..., ge=1, le=5)
    review_text: Optional[str] = None


class ReviewOut(BaseModel):
    id: str
    booking_id: str
    reviewer_id: str
    reviewer_name: Optional[str] = None
    reviewee_id: str
    rating: int
    review_text: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
