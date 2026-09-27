import uuid
from typing import Optional, List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.booking import Booking, BookingStatus
from app.models.payment import Payment, PaymentStatus
from app.models.machine import Machine, MachineAvailability
from app.models.requirement import Requirement, RequirementStatus
from app.schemas.booking import BookingCreate
from app.repositories.booking_repo import BookingRepository
from app.repositories.machine_repo import MachineRepository
from app.repositories.requirement_repo import RequirementRepository
from app.repositories.payment_repo import PaymentRepository
from app.repositories.notification_repo import NotificationRepository
from app.models.notification import Notification


class BookingService:
    def __init__(self, db: Session):
        self.db = db
        self.booking_repo = BookingRepository(db)
        self.machine_repo = MachineRepository(db)
        self.req_repo = RequirementRepository(db)
        self.payment_repo = PaymentRepository(db)
        self.notif_repo = NotificationRepository(db)

    def create_booking_request(self, seeker_id: str, booking_in: BookingCreate) -> Booking:
        req = self.req_repo.get(booking_in.requirement_id)
        if not req:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Requirement not found")
        if req.seeker_id != seeker_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to book for this requirement")

        machine = self.machine_repo.get_with_details(booking_in.machine_id)
        if not machine:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Machine not found")

        provider_id = machine.business.user_id if machine.business else None
        if not provider_id:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Machine has no associated provider account")

        # Double booking check
        if not self.machine_repo.check_is_available_range(machine.id, booking_in.start_date, booking_in.end_date):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Machine is not available for the requested date window."
            )

        # Financial calculation
        unit_price = machine.hourly_price
        total_amount = max(machine.min_job_value or 0.0, unit_price * booking_in.total_hours)
        commission = round(total_amount * 0.05, 2)  # 5% platform commission
        provider_payout = round(total_amount - commission, 2)

        booking = Booking(
            requirement_id=req.id,
            machine_id=machine.id,
            seeker_id=seeker_id,
            provider_id=provider_id,
            status=BookingStatus.PENDING,
            start_date=booking_in.start_date,
            end_date=booking_in.end_date,
            total_hours=booking_in.total_hours,
            unit_price=unit_price,
            total_amount=total_amount,
            commission_amount=commission,
            provider_payout=provider_payout,
            notes=booking_in.notes,
        )
        saved = self.booking_repo.create(booking)

        # Update requirement status
        req.status = RequirementStatus.BOOKED
        self.req_repo.update(req)

        # Notify provider
        self.notif_repo.create(
            Notification(
                user_id=provider_id,
                title="New Capacity Booking Request",
                message=f"You received a capacity booking request for {machine.name} (₹{total_amount:,.0f}).",
                event_type="BOOKING_REQUESTED",
                reference_id=saved.id,
            )
        )

        return self.booking_repo.get_with_details(saved.id)

    def accept_booking(self, user_id: str, booking_id: str) -> Booking:
        b = self.booking_repo.get(booking_id)
        if not b:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        if b.provider_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the provider can accept this booking")
        if b.status != BookingStatus.PENDING:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Cannot accept booking in {b.status} state")

        b.status = BookingStatus.ACCEPTED
        self.booking_repo.update(b)

        # Notify seeker
        self.notif_repo.create(
            Notification(
                user_id=b.seeker_id,
                title="Booking Request Accepted!",
                message="Provider accepted your capacity request. Please authorize escrow payment to confirm.",
                event_type="BOOKING_ACCEPTED",
                reference_id=b.id,
            )
        )
        return self.booking_repo.get_with_details(b.id)

    def reject_booking(self, user_id: str, booking_id: str, reason: Optional[str] = None) -> Booking:
        b = self.booking_repo.get(booking_id)
        if not b:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        if b.provider_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the provider can reject this booking")
        if b.status != BookingStatus.PENDING:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Cannot reject booking in {b.status} state")

        b.status = BookingStatus.REJECTED
        if reason:
            b.notes = f"{b.notes or ''} [Rejected: {reason}]"
        self.booking_repo.update(b)

        self.notif_repo.create(
            Notification(
                user_id=b.seeker_id,
                title="Booking Request Declined",
                message="The provider was unable to accommodate your booking request at this time.",
                event_type="BOOKING_REJECTED",
                reference_id=b.id,
            )
        )
        return self.booking_repo.get_with_details(b.id)

    def confirm_booking(self, user_id: str, booking_id: str) -> Booking:
        b = self.booking_repo.get(booking_id)
        if not b:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        if b.seeker_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the seeker can confirm and authorize payment")
        if b.status != BookingStatus.ACCEPTED:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Booking must be ACCEPTED before confirmation (current: {b.status})")

        b.status = BookingStatus.CONFIRMED
        self.booking_repo.update(b)

        # Create Escrow Payment record
        tx_id = f"ESCROW-{uuid.uuid4().hex[:12].upper()}"
        payment = Payment(
            booking_id=b.id,
            transaction_id=tx_id,
            provider="escrow_simulated",
            amount=b.total_amount,
            commission=b.commission_amount,
            provider_payout=b.provider_payout,
            status=PaymentStatus.ESCROW_HOLD,
        )
        self.payment_repo.create(payment)

        # Lock machine calendar slots
        slot = MachineAvailability(
            machine_id=b.machine_id,
            date=b.start_date,
            is_available=False,
            reason=f"Booked (Job #{b.id[:8]})",
            booking_id=b.id,
        )
        self.machine_repo.add_or_update_availability(slot)

        # Notify provider
        self.notif_repo.create(
            Notification(
                user_id=b.provider_id,
                title="Booking Confirmed & Escrow Funded",
                message=f"Escrow payment of ₹{b.total_amount:,.0f} secured. You may commence production.",
                event_type="BOOKING_CONFIRMED",
                reference_id=b.id,
            )
        )
        return self.booking_repo.get_with_details(b.id)

    def start_production(self, user_id: str, booking_id: str) -> Booking:
        b = self.booking_repo.get(booking_id)
        if not b:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        if b.provider_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the provider can start production")
        if b.status != BookingStatus.CONFIRMED:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Booking must be CONFIRMED before starting (current: {b.status})")

        b.status = BookingStatus.IN_PROGRESS
        self.booking_repo.update(b)

        self.notif_repo.create(
            Notification(
                user_id=b.seeker_id,
                title="Production In Progress",
                message="The provider has loaded tooling and commenced manufacturing your parts.",
                event_type="JOB_STARTED",
                reference_id=b.id,
            )
        )
        return self.booking_repo.get_with_details(b.id)

    def complete_job(self, user_id: str, booking_id: str) -> Booking:
        b = self.booking_repo.get(booking_id)
        if not b:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        if user_id not in [b.seeker_id, b.provider_id]:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to complete this booking")
        if b.status not in [BookingStatus.IN_PROGRESS, BookingStatus.CONFIRMED]:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Booking cannot be completed from {b.status} state")

        b.status = BookingStatus.COMPLETED
        self.booking_repo.update(b)

        # Release escrow payment to provider
        payment = self.payment_repo.get_by_booking_id(b.id)
        if payment:
            payment.status = PaymentStatus.RELEASED_TO_PROVIDER
            self.payment_repo.update(payment)

        # Update requirement status
        req = self.req_repo.get(b.requirement_id)
        if req:
            req.status = RequirementStatus.COMPLETED
            self.req_repo.update(req)

        # Notify both parties
        self.notif_repo.create(
            Notification(
                user_id=b.seeker_id,
                title="Job Completed!",
                message="Manufacturing job completed and escrow released. Please leave a rating & review.",
                event_type="JOB_COMPLETED",
                reference_id=b.id,
            )
        )
        self.notif_repo.create(
            Notification(
                user_id=b.provider_id,
                title="Payout Released!",
                message=f"₹{b.provider_payout:,.0f} has been credited to your provider payout account.",
                event_type="PAYMENT_RELEASED",
                reference_id=b.id,
            )
        )
        return self.booking_repo.get_with_details(b.id)

    def cancel_booking(self, user_id: str, booking_id: str, reason: Optional[str] = None) -> Booking:
        b = self.booking_repo.get(booking_id)
        if not b:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        if user_id not in [b.seeker_id, b.provider_id]:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to cancel this booking")
        if b.status in [BookingStatus.COMPLETED, BookingStatus.CANCELLED]:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Cannot cancel a booking in {b.status} state")

        b.status = BookingStatus.CANCELLED
        self.booking_repo.update(b)

        # If escrow was held, refund seeker
        payment = self.payment_repo.get_by_booking_id(b.id)
        if payment and payment.status == PaymentStatus.ESCROW_HOLD:
            payment.status = PaymentStatus.REFUNDED
            self.payment_repo.update(payment)

        return self.booking_repo.get_with_details(b.id)

    def get_my_bookings(self, user_id: str) -> List[Booking]:
        return self.booking_repo.get_by_user(user_id)

    def get_booking(self, booking_id: str) -> Booking:
        b = self.booking_repo.get_with_details(booking_id)
        if not b:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
        return b
