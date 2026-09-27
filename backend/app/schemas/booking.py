from datetime import datetime, date
from typing import Optional, List
from pydantic import BaseModel, ConfigDict, Field
from app.models.booking import BookingStatus


class BookingCreate(BaseModel):
    requirement_id: str
    machine_id: str
    start_date: date
    end_date: date
    total_hours: float = Field(..., gt=0)
    notes: Optional[str] = None


class BookingStatusUpdate(BaseModel):
    status: BookingStatus
    notes: Optional[str] = None


class BookingOut(BaseModel):
    id: str
    requirement_id: str
    requirement_title: Optional[str] = None
    machine_id: str
    machine_name: Optional[str] = None
    seeker_id: str
    seeker_name: Optional[str] = None
    provider_id: str
    provider_name: Optional[str] = None
    business_name: Optional[str] = None
    status: BookingStatus
    start_date: date
    end_date: date
    total_hours: float
    unit_price: float
    total_amount: float
    commission_amount: float
    provider_payout: float
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class BookingDetail(BookingOut):
    escrow_status: Optional[str] = None
    has_review: bool = False
