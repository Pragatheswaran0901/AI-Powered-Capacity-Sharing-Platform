import uuid
from datetime import datetime, timezone, date
from enum import Enum
from sqlalchemy import (
    Column, String, Float, DateTime, Date,
    Text, ForeignKey, Enum as SQLEnum
)
from sqlalchemy.orm import relationship
from app.core.database import Base


class BookingStatus(str, Enum):
    PENDING = "PENDING"
    ACCEPTED = "ACCEPTED"
    REJECTED = "REJECTED"
    CONFIRMED = "CONFIRMED"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"
    DISPUTED = "DISPUTED"


class Booking(Base):
    __tablename__ = "bookings"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    requirement_id = Column(String(36), ForeignKey("requirements.id"), nullable=False)
    machine_id = Column(String(36), ForeignKey("machines.id"), nullable=False)
    seeker_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    provider_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    status = Column(SQLEnum(BookingStatus), default=BookingStatus.PENDING, nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    total_hours = Column(Float, nullable=False)
    unit_price = Column(Float, nullable=False)
    total_amount = Column(Float, nullable=False)
    commission_amount = Column(Float, nullable=False)  # 5% platform commission
    provider_payout = Column(Float, nullable=False)    # 95% provider payout
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    requirement = relationship("Requirement", back_populates="bookings")
    machine = relationship("Machine", back_populates="bookings")
    seeker = relationship("User", back_populates="bookings_as_seeker", foreign_keys=[seeker_id])
    provider = relationship("User", back_populates="bookings_as_provider", foreign_keys=[provider_id])
    payment = relationship("Payment", back_populates="booking", uselist=False, cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="booking", cascade="all, delete-orphan")

    @property
    def requirement_title(self):
        return self.requirement.title if self.requirement else None

    @property
    def machine_name(self):
        return self.machine.name if self.machine else None

    @property
    def seeker_name(self):
        return self.seeker.full_name if self.seeker else None

    @property
    def provider_name(self):
        return self.provider.full_name if self.provider else None

    @property
    def business_name(self):
        if self.machine and self.machine.business:
            return self.machine.business.name
        return None

