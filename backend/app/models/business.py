import uuid
from datetime import datetime, timezone
from enum import Enum
from sqlalchemy import Column, String, Float, DateTime, Text, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from app.core.database import Base


class VerificationStatus(str, Enum):
    PENDING = "PENDING"
    VERIFIED = "VERIFIED"
    REJECTED = "REJECTED"


class Business(Base):
    __tablename__ = "businesses"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    name = Column(String(255), nullable=False)
    owner_name = Column(String(255), nullable=False)
    phone = Column(String(30), nullable=False)
    email = Column(String(255), nullable=False)
    gstin = Column(String(30), unique=True, index=True, nullable=True)
    registration_number = Column(String(100), nullable=True)
    industry = Column(String(100), nullable=False)
    address = Column(Text, nullable=False)
    district = Column(String(100), nullable=False, index=True)
    state = Column(String(100), nullable=False, default="Tamil Nadu")
    pincode = Column(String(20), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    description = Column(Text, nullable=True)
    verification_status = Column(SQLEnum(VerificationStatus), default=VerificationStatus.PENDING, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    user = relationship("User", back_populates="business")
    machines = relationship("Machine", back_populates="business", cascade="all, delete-orphan")
    documents = relationship("BusinessDocument", back_populates="business", cascade="all, delete-orphan")


class BusinessDocument(Base):
    __tablename__ = "business_documents"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    business_id = Column(String(36), ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False)
    document_type = Column(String(100), nullable=False)  # GSTIN_CERT, UDYAM_CERT, FACTORY_LICENSE
    file_path = Column(String(500), nullable=False)
    verification_status = Column(SQLEnum(VerificationStatus), default=VerificationStatus.PENDING, nullable=False)
    uploaded_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    business = relationship("Business", back_populates="documents")


# Backwards-compatibility alias for MSME
MSME = Business
