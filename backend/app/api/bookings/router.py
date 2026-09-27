from typing import List, Optional
from fastapi import APIRouter, Depends, status, Body
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.booking import BookingCreate, BookingOut, BookingDetail
from app.services.booking_service import BookingService

router = APIRouter()


@router.post("/", response_model=BookingOut, status_code=status.HTTP_201_CREATED)
def request_booking(
    booking_in: BookingCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Initiate capacity booking request (Status: PENDING)."""
    return BookingService(db).create_booking_request(current_user.id, booking_in)


@router.get("/my", response_model=List[BookingOut])
def get_my_bookings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """List bookings where current user is either seeker or provider."""
    return BookingService(db).get_my_bookings(current_user.id)


@router.get("/{booking_id}", response_model=BookingDetail)
def get_booking(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Inspect full booking lifecycle status, escrow details, and reviews."""
    b = BookingService(db).get_booking(booking_id)
    escrow = b.payment.status.value if b.payment else None
    has_rev = any(r.reviewer_id == current_user.id for r in b.reviews)

    return BookingDetail(
        id=b.id,
        requirement_id=b.requirement_id,
        requirement_title=b.requirement.title if b.requirement else None,
        machine_id=b.machine_id,
        machine_name=b.machine.name if b.machine else None,
        seeker_id=b.seeker_id,
        seeker_name=b.seeker.full_name if b.seeker else None,
        provider_id=b.provider_id,
        provider_name=b.provider.full_name if b.provider else None,
        business_name=b.machine.business.name if (b.machine and b.machine.business) else None,
        status=b.status,
        start_date=b.start_date,
        end_date=b.end_date,
        total_hours=b.total_hours,
        unit_price=b.unit_price,
        total_amount=b.total_amount,
        commission_amount=b.commission_amount,
        provider_payout=b.provider_payout,
        notes=b.notes,
        created_at=b.created_at,
        updated_at=b.updated_at,
        escrow_status=escrow,
        has_review=has_rev,
    )


@router.post("/{booking_id}/accept", response_model=BookingOut)
def accept_booking(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Provider accepts capacity booking (Status: ACCEPTED)."""
    return BookingService(db).accept_booking(current_user.id, booking_id)


@router.post("/{booking_id}/reject", response_model=BookingOut)
def reject_booking(
    booking_id: str,
    reason: Optional[str] = Body(None, embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Provider declines capacity booking (Status: REJECTED)."""
    return BookingService(db).reject_booking(current_user.id, booking_id, reason)


@router.post("/{booking_id}/confirm", response_model=BookingOut)
def confirm_booking(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Seeker funds escrow and confirms booking (Status: CONFIRMED)."""
    return BookingService(db).confirm_booking(current_user.id, booking_id)


@router.post("/{booking_id}/start", response_model=BookingOut)
def start_production(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Provider commences machining operations (Status: IN_PROGRESS)."""
    return BookingService(db).start_production(current_user.id, booking_id)


@router.post("/{booking_id}/complete", response_model=BookingOut)
def complete_job(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Marks manufacturing complete and triggers escrow release (Status: COMPLETED)."""
    return BookingService(db).complete_job(current_user.id, booking_id)


@router.post("/{booking_id}/cancel", response_model=BookingOut)
def cancel_booking(
    booking_id: str,
    reason: Optional[str] = Body(None, embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Cancels booking and initiates refund if escrow held (Status: CANCELLED)."""
    return BookingService(db).cancel_booking(current_user.id, booking_id, reason)
