from datetime import date, timedelta
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.machine import Machine, MachineAvailability, MachineStatus
from app.schemas.machine import AvailabilityBatchCreate, AvailabilityOut
from app.repositories.machine_repo import MachineRepository
from app.repositories.business_repo import BusinessRepository


class AvailabilityService:
    def __init__(self, db: Session):
        self.db = db
        self.machine_repo = MachineRepository(db)
        self.biz_repo = BusinessRepository(db)

    def set_machine_availability(
        self,
        user_id: str,
        machine_id: str,
        batch_in: AvailabilityBatchCreate,
    ) -> List[MachineAvailability]:
        machine = self.machine_repo.get(machine_id)
        if not machine:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Machine not found")

        biz = self.biz_repo.get_by_user_id(user_id)
        if not biz or machine.business_id != biz.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to edit this machine's schedule")

        saved_slots = []
        for slot_in in batch_in.slots:
            slot = MachineAvailability(
                machine_id=machine_id,
                date=slot_in.date,
                start_time=slot_in.start_time,
                end_time=slot_in.end_time,
                is_available=slot_in.is_available,
                reason=slot_in.reason,
            )
            saved = self.machine_repo.add_or_update_availability(slot)
            saved_slots.append(saved)

        return saved_slots

    def get_machine_availability(
        self,
        machine_id: str,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
    ) -> List[MachineAvailability]:
        if not start_date:
            start_date = date.today()
        if not end_date:
            end_date = start_date + timedelta(days=30)

        return self.machine_repo.get_availabilities(machine_id, start_date, end_date)

    def verify_no_double_booking(self, machine_id: str, start_date: date, end_date: date) -> bool:
        """
        Enforce server-side double-booking prevention.
        Raises 409 Conflict if machine capacity is not open.
        """
        is_free = self.machine_repo.check_is_available_range(machine_id, start_date, end_date)
        if not is_free:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Machine {machine_id} has existing bookings or maintenance between {start_date} and {end_date}."
            )
        return True
