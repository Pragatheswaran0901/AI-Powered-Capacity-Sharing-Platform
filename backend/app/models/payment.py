import uuid
import json
from datetime import datetime, timezone
from enum import Enum
from sqlalchemy import Column, String, Float, DateTime, Text, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from app.core.database import Base


class PaymentStatus(str, Enum):
    PENDING = "PENDING"
    ESCROW_HOLD = "ESCROW_HOLD"
    RELEASED_TO_PROVIDER = "RELEASED_TO_PROVIDER"
    REFUNDED = "REFUNDED"
    FAILED = "FAILED"


class Payment(Base):
    __tablename__ = "payments"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    booking_id = Column(String(36), ForeignKey("bookings.id", ondelete="CASCADE"), unique=True, nullable=False)
    transaction_id = Column(String(255), unique=True, index=True, nullable=False)
    provider = Column(String(50), default="escrow_simulated", nullable=False)
    amount = Column(Float, nullable=False)
    commission = Column(Float, nullable=False)
    provider_payout = Column(Float, nullable=False)
    status = Column(SQLEnum(PaymentStatus), default=PaymentStatus.PENDING, nullable=False)
    metadata_json = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    booking = relationship("Booking", back_populates="payment")

    @property
    def meta_dict(self):
        if not self.metadata_json:
            return {}
        try:
            return json.loads(self.metadata_json)
        except Exception:
            return {}
