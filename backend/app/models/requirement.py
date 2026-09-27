import uuid
from datetime import datetime, timezone, date
from enum import Enum
from sqlalchemy import (
    Column, String, Float, Integer, Boolean, DateTime, Date,
    Text, ForeignKey, Enum as SQLEnum
)
from sqlalchemy.orm import relationship
from app.core.database import Base


class RequirementStatus(str, Enum):
    OPEN = "OPEN"
    MATCHED = "MATCHED"
    BOOKED = "BOOKED"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"


class Requirement(Base):
    __tablename__ = "requirements"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    seeker_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    process = Column(String(100), nullable=False)  # e.g., CNC Milling, Laser Cutting
    material = Column(String(100), nullable=False)  # e.g., Aluminium 6061, Mild Steel
    quantity = Column(Integer, nullable=False)
    dimensions = Column(String(255), nullable=True)  # e.g., 150 x 80 x 25 mm
    tolerance_mm = Column(Float, nullable=True)  # e.g., 0.05 mm
    required_date = Column(Date, nullable=False)
    delivery_deadline = Column(Date, nullable=False)
    preferred_location = Column(String(255), nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    max_distance_km = Column(Float, default=100.0)
    budget = Column(Float, nullable=False)
    quality_requirements = Column(Text, nullable=True)
    operator_required = Column(Boolean, default=True)
    status = Column(SQLEnum(RequirementStatus), default=RequirementStatus.OPEN, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    seeker = relationship("User", back_populates="requirements", foreign_keys=[seeker_id])
    attachments = relationship("RequirementAttachment", back_populates="requirement", cascade="all, delete-orphan")
    matches = relationship("Match", back_populates="requirement", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="requirement")


class RequirementAttachment(Base):
    __tablename__ = "requirement_attachments"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    requirement_id = Column(String(36), ForeignKey("requirements.id", ondelete="CASCADE"), nullable=False)
    file_name = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=False)
    file_size = Column(Integer, nullable=True)  # bytes
    file_type = Column(String(100), nullable=True)  # PDF, STEP, DWG, PNG
    uploaded_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    requirement = relationship("Requirement", back_populates="attachments")
