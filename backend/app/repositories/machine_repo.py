from datetime import date, time
from typing import Optional, List
from sqlalchemy import or_, and_
from sqlalchemy.orm import Session, joinedload
from app.models.company import Company
from app.models.machine import (
    Machine, MachineCapability, MachineAvailability, MachineStatus
)
from app.models.business import Business, VerificationStatus
from app.repositories.base import BaseRepository


class MachineRepository(BaseRepository[Machine]):
    def __init__(self, db: Session):
        super().__init__(Machine, db)

    def get_with_details(self, machine_id: str) -> Optional[Machine]:
        return (
            self.db.query(Machine)
            .options(
                joinedload(Machine.capabilities),
                joinedload(Machine.availabilities),
                joinedload(Machine.business),
                joinedload(Machine.company),
            )
            .filter(Machine.id == machine_id)
            .first()
        )

    def get_by_business_id(self, business_id: str) -> List[Machine]:
        return (
            self.db.query(Machine)
            .options(
                joinedload(Machine.capabilities),
                joinedload(Machine.availabilities),
                joinedload(Machine.business),
                joinedload(Machine.company),
            )
            .filter(Machine.business_id == business_id)
            .all()
        )

    def search_active_machines(
        self,
        category: Optional[str] = None,
        process: Optional[str] = None,
        material: Optional[str] = None,
        industry: Optional[str] = None,
        max_rate: Optional[float] = None,
        verified_only: bool = False,
        location: Optional[str] = None,
        exclude_user_id: Optional[str] = None,
    ) -> List[Machine]:
        query = (
            self.db.query(Machine)
            .options(
                joinedload(Machine.capabilities),
                joinedload(Machine.availabilities),
                joinedload(Machine.business),
                joinedload(Machine.company),
            )
            .filter(Machine.status.in_([MachineStatus.ACTIVE, MachineStatus.AVAILABLE]))
        )

        if exclude_user_id:
            query = query.filter(Machine.business.has(Business.user_id != exclude_user_id))

        if category:
            query = query.filter(Machine.category.ilike(f"%{category}%"))
        if max_rate:
            query = query.filter(Machine.hourly_price <= max_rate)
        if verified_only:
            query = query.filter(Machine.verification_status == VerificationStatus.VERIFIED)

        if industry:
            query = query.filter(
                or_(
                    Machine.category.ilike(f"%{industry}%"),
                    Machine.company.has(Company.industry.ilike(f"%{industry}%")),
                )
            )

        if location:
            loc_clean = location.strip().lower()
            if "tirup" in loc_clean:
                term = "%tirup%"
            elif "coimbatore" in loc_clean or "kovai" in loc_clean:
                term = "%coimbatore%"
            else:
                term = f"%{loc_clean}%"

            query = query.filter(
                or_(
                    and_(Machine.company_id.isnot(None), Machine.company.has(Company.city.ilike(term))),
                    and_(
                        Machine.company_id.is_(None),
                        or_(
                            Machine.location_address.ilike(term),
                            Machine.business.has(Business.district.ilike(term)),
                            Machine.business.has(Business.address.ilike(term)),
                        ),
                    ),
                )
            )

        machines = query.all()

        if process or material:
            filtered = []
            for m in machines:
                match_proc = True if not process else any(process.lower() in c.process.lower() for c in m.capabilities)
                match_mat = True if not material else any(material.lower() in c.material.lower() for c in m.capabilities)
                if match_proc and match_mat:
                    filtered.append(m)
            return filtered

        return machines

    def count_active(self) -> int:
        return (
            self.db.query(Machine)
            .filter(Machine.status.in_([MachineStatus.ACTIVE, MachineStatus.AVAILABLE]))
            .count()
        )

    # Capabilities
    def add_capability(self, capability: MachineCapability) -> MachineCapability:
        self.db.add(capability)
        self.db.commit()
        self.db.refresh(capability)
        return capability

    # Availability management
    def get_availabilities(self, machine_id: str, start_date: date, end_date: date) -> List[MachineAvailability]:
        return (
            self.db.query(MachineAvailability)
            .filter(
                MachineAvailability.machine_id == machine_id,
                MachineAvailability.date >= start_date,
                MachineAvailability.date <= end_date,
            )
            .order_by(MachineAvailability.date.asc(), MachineAvailability.start_time.asc())
            .all()
        )

    def add_or_update_availability(self, slot: MachineAvailability) -> MachineAvailability:
        existing = (
            self.db.query(MachineAvailability)
            .filter(
                MachineAvailability.machine_id == slot.machine_id,
                MachineAvailability.date == slot.date,
                MachineAvailability.start_time == slot.start_time,
            )
            .first()
        )
        if existing:
            existing.is_available = slot.is_available
            existing.reason = slot.reason
            existing.booking_id = slot.booking_id
            self.db.commit()
            self.db.refresh(existing)
            return existing
        else:
            self.db.add(slot)
            self.db.commit()
            self.db.refresh(slot)
            return slot

    def check_is_available_range(self, machine_id: str, start_date: date, end_date: date) -> bool:
        """
        Server-side double booking prevention check:
        Returns False if any day in the requested range is explicitly marked unavailable or booked.
        """
        blocked = (
            self.db.query(MachineAvailability)
            .filter(
                MachineAvailability.machine_id == machine_id,
                MachineAvailability.date >= start_date,
                MachineAvailability.date <= end_date,
                MachineAvailability.is_available == False,
            )
            .first()
        )
        return blocked is None
