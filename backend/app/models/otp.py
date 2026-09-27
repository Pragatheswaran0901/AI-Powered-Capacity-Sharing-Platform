import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Boolean, DateTime
from app.core.database import Base


class EmailOTPCode(Base):
    __tablename__ = "email_otp_codes"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String(255), index=True, nullable=False)
    otp_hash = Column(String(255), nullable=False)
    expires_at = Column(DateTime, index=True, nullable=False)
    attempts = Column(Integer, default=0, nullable=False)
    verified_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, index=True, default=lambda: datetime.now(timezone.utc), nullable=False)
    request_ip = Column(String(100), nullable=True)
    consumed = Column(Boolean, default=False, nullable=False)
