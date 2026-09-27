from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.payment import PaymentOut, PaymentIntentOut
from app.services.payment_service import PaymentService

router = APIRouter()


@router.get("/booking/{booking_id}", response_model=PaymentOut)
def get_booking_payment_details(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve escrow payment status and transaction ledger."""
    p = PaymentService(db).get_booking_payment(booking_id)
    return PaymentOut(
        id=p.id,
        booking_id=p.booking_id,
        transaction_id=p.transaction_id,
        provider=p.provider,
        amount=p.amount,
        commission=p.commission,
        provider_payout=p.provider_payout,
        status=p.status,
        metadata=p.meta_dict,
        created_at=p.created_at,
        updated_at=p.updated_at,
    )


@router.post("/booking/{booking_id}/intent", response_model=PaymentIntentOut)
def create_payment_intent(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Initialize payment gateway intent adapter for escrow authorization."""
    return PaymentService(db).create_payment_intent(current_user.id, booking_id)
