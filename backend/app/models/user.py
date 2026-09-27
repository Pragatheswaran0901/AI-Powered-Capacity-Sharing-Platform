import uuid
from datetime import datetime, timezone
from enum import Enum
from sqlalchemy import Column, String, Boolean, DateTime, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import relationship
from app.core.database import Base


class UserRole(str, Enum):
    PROVIDER = "PROVIDER"
    SEEKER = "SEEKER"
    ADMIN = "ADMIN"


class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=True)
    full_name = Column(String(255), nullable=True, default="")
    phone = Column(String(30), nullable=True, default="")
    role = Column(SQLEnum(UserRole), default=UserRole.SEEKER, nullable=False)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    email_verified = Column(Boolean, default=False, nullable=False)
    authentication_provider = Column(String(50), default="email_otp", nullable=False)
    last_login_at = Column(DateTime, nullable=True)
    is_onboarded = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    business = relationship("Business", back_populates="user", uselist=False, cascade="all, delete-orphan")
    requirements = relationship("Requirement", back_populates="seeker", cascade="all, delete-orphan", foreign_keys="Requirement.seeker_id")
    bookings_as_seeker = relationship("Booking", back_populates="seeker", foreign_keys="Booking.seeker_id")
    bookings_as_provider = relationship("Booking", back_populates="provider", foreign_keys="Booking.provider_id")
    reviews_given = relationship("Review", back_populates="reviewer", foreign_keys="Review.reviewer_id")
    reviews_received = relationship("Review", back_populates="reviewee", foreign_keys="Review.reviewee_id")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")
