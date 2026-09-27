import uuid
from datetime import datetime, timezone, time, date
from enum import Enum
import json
from sqlalchemy import (
    Column, String, Float, Integer, Boolean, DateTime, Date, Time,
    Text, ForeignKey, Enum as SQLEnum
)
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.models.business import VerificationStatus


class MachineStatus(str, Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"


class Machine(Base):
    __tablename__ = "machines"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    business_id = Column(String(36), ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    category = Column(String(100), nullable=False)  # CNC Milling, CNC Lathe, Laser Cutting, VMC, EDM, etc.
    manufacturer = Column(String(100), nullable=True)
    model = Column(String(100), nullable=True)
    year = Column(Integer, nullable=True)
    description = Column(Text, nullable=True)
    dimensions_capacity = Column(String(255), nullable=True)  # e.g., 1000 x 600 x 500 mm
    precision_tolerance = Column(String(100), nullable=True)  # e.g., ±0.01 mm
    operating_parameters = Column(Text, nullable=True)  # JSON-encoded dict of extra specs (spindle RPM, laser watts)
    hourly_price = Column(Float, nullable=False)
    min_job_value = Column(Float, default=0.0)
    operator_available = Column(Boolean, default=True)
    location_address = Column(Text, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    photos = Column(Text, nullable=True)  # JSON-encoded list of image URLs
    status = Column(SQLEnum(MachineStatus), default=MachineStatus.ACTIVE, nullable=False)
    verification_status = Column(SQLEnum(VerificationStatus), default=VerificationStatus.PENDING, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    business = relationship("Business", back_populates="machines")
    capabilities = relationship("MachineCapability", back_populates="machine", cascade="all, delete-orphan")
    availabilities = relationship("MachineAvailability", back_populates="machine", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="machine")
    matches = relationship("Match", back_populates="machine")

    @property
    def photo_list(self):
        if not self.photos:
            return []
        try:
            return json.loads(self.photos)
        except Exception:
            return []

    @property
    def params_dict(self):
        if not self.operating_parameters:
            return {}
        try:
            return json.loads(self.operating_parameters)
        except Exception:
            return {}


class MachineCapability(Base):
    __tablename__ = "machine_capabilities"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    machine_id = Column(String(36), ForeignKey("machines.id", ondelete="CASCADE"), nullable=False)
    process = Column(String(100), nullable=False)  # CNC Milling, Turning, Laser Cutting, etc.
    material = Column(String(100), nullable=False)  # Aluminium, Stainless Steel, Brass, etc.
    min_tolerance_mm = Column(Float, nullable=True)  # e.g., 0.01 mm
    max_dimension_x = Column(Float, nullable=True)
    max_dimension_y = Column(Float, nullable=True)
    max_dimension_z = Column(Float, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    machine = relationship("Machine", back_populates="capabilities")


class MachineAvailability(Base):
    __tablename__ = "machine_availabilities"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    machine_id = Column(String(36), ForeignKey("machines.id", ondelete="CASCADE"), nullable=False)
    date = Column(Date, nullable=False, index=True)
    start_time = Column(Time, nullable=False, default=time(9, 0))
    end_time = Column(Time, nullable=False, default=time(18, 0))
    is_available = Column(Boolean, default=True, nullable=False)
    reason = Column(String(255), nullable=True)  # 'Available Working Hours', 'Maintenance', 'Booked'
    booking_id = Column(String(36), ForeignKey("bookings.id", ondelete="SET NULL"), nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    machine = relationship("Machine", back_populates="availabilities")
    booking = relationship("Booking", foreign_keys=[booking_id])
