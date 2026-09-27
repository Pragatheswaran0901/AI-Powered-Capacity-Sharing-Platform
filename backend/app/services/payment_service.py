import uuid
from typing import Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.payment import Payment, PaymentStatus
from app.models.booking import Booking
from app.schemas.payment import PaymentOut, PaymentIntentOut
from app.repositories.payment_repo import PaymentRepository
from app.repositories.booking_repo import BookingRepository


class PaymentService:
    def __init__(self, db: Session):
        self.db = db
        self.payment_repo = PaymentRepository(db)
        self.booking_repo = BookingRepository(db)

    def get_booking_payment(self, booking_id: str) -> Payment:
        p = self.payment_repo.get_by_booking_id(booking_id)
        if not p:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No payment record found for this booking")
        return p

    def create_payment_intent(self, user_id: str, booking_id: str) -> PaymentIntentOut:
        b = self.booking_repo.get(booking_id)
        if not b:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        if b.seeker_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to fund this booking")

        tx_id = f"TXN-ESCROW-{uuid.uuid4().hex[:10].upper()}"
        return PaymentIntentOut(
            transaction_id=tx_id,
            amount=b.total_amount,
            currency="INR",
            client_secret=f"pi_secret_{uuid.uuid4().hex}",
            escrow_account_reference="MACHHUNT-ICICI-ESCROW-0091",
            status="requires_payment_method",
        )
