from typing import Optional, List
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from app.models.booking import Booking, BookingStatus
from app.models.machine import Machine
from app.models.requirement import Requirement
from app.models.business import Business
from app.repositories.base import BaseRepository


class BookingRepository(BaseRepository[Booking]):
    def __init__(self, db: Session):
        super().__init__(Booking, db)

    def get_with_details(self, booking_id: str) -> Optional[Booking]:
        return (
            self.db.query(Booking)
            .options(
                joinedload(Booking.machine).joinedload(Machine.business),
                joinedload(Booking.requirement),
                joinedload(Booking.seeker),
                joinedload(Booking.provider),
                joinedload(Booking.payment),
                joinedload(Booking.reviews),
            )
            .filter(Booking.id == booking_id)
            .first()
        )

    def get_by_user(self, user_id: str) -> List[Booking]:
        return (
            self.db.query(Booking)
            .options(
                joinedload(Booking.machine).joinedload(Machine.business),
                joinedload(Booking.requirement),
                joinedload(Booking.seeker),
                joinedload(Booking.provider),
            )
            .filter((Booking.seeker_id == user_id) | (Booking.provider_id == user_id))
            .order_by(Booking.created_at.desc())
            .all()
        )

    def get_by_provider(self, provider_id: str) -> List[Booking]:
        return (
            self.db.query(Booking)
            .options(
                joinedload(Booking.machine).joinedload(Machine.business),
                joinedload(Booking.requirement),
                joinedload(Booking.seeker),
            )
            .filter(Booking.provider_id == provider_id)
            .order_by(Booking.created_at.desc())
            .all()
        )

    def count_bookings(self) -> int:
        return self.db.query(Booking).count()

    def count_completed(self) -> int:
        return self.db.query(Booking).filter(Booking.status == BookingStatus.COMPLETED).count()

    def total_gmv(self) -> float:
        val = self.db.query(func.sum(Booking.total_amount)).filter(
            Booking.status.in_([BookingStatus.CONFIRMED, BookingStatus.IN_PROGRESS, BookingStatus.COMPLETED])
        ).scalar()
        return float(val or 0.0)

    def total_commission(self) -> float:
        val = self.db.query(func.sum(Booking.commission_amount)).filter(
            Booking.status.in_([BookingStatus.CONFIRMED, BookingStatus.IN_PROGRESS, BookingStatus.COMPLETED])
        ).scalar()
        return float(val or 0.0)
