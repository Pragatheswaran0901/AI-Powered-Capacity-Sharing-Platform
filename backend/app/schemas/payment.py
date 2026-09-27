from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, ConfigDict
from app.models.payment import PaymentStatus


class PaymentCreate(BaseModel):
    booking_id: str
    payment_method: str = "UPI / Escrow"


class PaymentOut(BaseModel):
    id: str
    booking_id: str
    transaction_id: str
    provider: str
    amount: float
    commission: float
    provider_payout: float
    status: PaymentStatus
    metadata: Optional[Dict[str, Any]] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class PaymentIntentOut(BaseModel):
    transaction_id: str
    amount: float
    currency: str = "INR"
    client_secret: str
    escrow_account_reference: str
    status: str
