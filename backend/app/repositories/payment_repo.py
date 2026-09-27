from typing import Optional
from sqlalchemy.orm import Session
from app.models.payment import Payment, PaymentStatus
from app.repositories.base import BaseRepository


class PaymentRepository(BaseRepository[Payment]):
    def __init__(self, db: Session):
        super().__init__(Payment, db)

    def get_by_booking_id(self, booking_id: str) -> Optional[Payment]:
        return self.db.query(Payment).filter(Payment.booking_id == booking_id).first()

    def get_by_transaction_id(self, tx_id: str) -> Optional[Payment]:
        return self.db.query(Payment).filter(Payment.transaction_id == tx_id).first()
