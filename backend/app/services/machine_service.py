import json
from typing import Optional, List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.machine import Machine, MachineCapability, MachineStatus
from app.models.business import Business, VerificationStatus
from app.schemas.machine import MachineCreate, MachineUpdate
from app.repositories.machine_repo import MachineRepository
from app.repositories.business_repo import BusinessRepository


class MachineService:
    def __init__(self, db: Session):
        self.db = db
        self.machine_repo = MachineRepository(db)
        self.biz_repo = BusinessRepository(db)

    def create_machine(self, user_id: str, machine_in: MachineCreate) -> Machine:
        biz = self.biz_repo.get_by_user_id(user_id)
        if not biz:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You must create a business profile before listing manufacturing machinery.",
            )

        new_machine = Machine(
            business_id=biz.id,
            name=machine_in.name,
            category=machine_in.category,
            manufacturer=machine_in.manufacturer,
            model=machine_in.model,
            year=machine_in.year,
            description=machine_in.description,
            dimensions_capacity=machine_in.dimensions_capacity,
            precision_tolerance=machine_in.precision_tolerance,
            operating_parameters=json.dumps(machine_in.operating_parameters) if machine_in.operating_parameters else None,
            hourly_price=machine_in.hourly_price,
            min_job_value=machine_in.min_job_value,
            operator_available=machine_in.operator_available,
            location_address=machine_in.location_address,
            latitude=machine_in.latitude,
            longitude=machine_in.longitude,
            photos=json.dumps(machine_in.photos) if machine_in.photos else None,
            status=MachineStatus.ACTIVE,
            verification_status=VerificationStatus.PENDING,
        )
        saved = self.machine_repo.create(new_machine)

        # Add initial capabilities
        for cap in machine_in.capabilities:
            c = MachineCapability(
                machine_id=saved.id,
                process=cap.process,
                material=cap.material,
                min_tolerance_mm=cap.min_tolerance_mm,
                max_dimension_x=cap.max_dimension_x,
                max_dimension_y=cap.max_dimension_y,
                max_dimension_z=cap.max_dimension_z,
            )
            self.machine_repo.add_capability(c)

        return self.machine_repo.get_with_details(saved.id)

    def get_my_machines(self, user_id: str) -> List[Machine]:
        biz = self.biz_repo.get_by_user_id(user_id)
        if not biz:
            return []
        return self.machine_repo.get_by_business_id(biz.id)

    def get_machine(self, machine_id: str) -> Machine:
        m = self.machine_repo.get_with_details(machine_id)
        if not m:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Machine listing not found.",
            )
        return m

    def update_machine(self, user_id: str, machine_id: str, update_in: MachineUpdate) -> Machine:
        m = self.machine_repo.get(machine_id)
        if not m:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Machine not found")

        biz = self.biz_repo.get_by_user_id(user_id)
        if not biz or m.business_id != biz.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to modify this machine")

        update_data = update_in.model_dump(exclude_unset=True)
        if "operating_parameters" in update_data and update_data["operating_parameters"] is not None:
            update_data["operating_parameters"] = json.dumps(update_data["operating_parameters"])
        if "photos" in update_data and update_data["photos"] is not None:
            update_data["photos"] = json.dumps(update_data["photos"])

        for k, v in update_data.items():
            setattr(m, k, v)

        return self.machine_repo.update(m)

    def delete_machine(self, user_id: str, machine_id: str):
        m = self.machine_repo.get(machine_id)
        if not m:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Machine not found")

        biz = self.biz_repo.get_by_user_id(user_id)
        if not biz or m.business_id != biz.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this machine")

        m.status = MachineStatus.INACTIVE
        self.machine_repo.update(m)
        return {"message": "Machine deactivated successfully."}

    def search_machines(
        self,
        category: Optional[str] = None,
        process: Optional[str] = None,
        material: Optional[str] = None,
        max_rate: Optional[float] = None,
        verified_only: bool = False,
    ) -> List[Machine]:
        return self.machine_repo.search_active_machines(
            category=category,
            process=process,
            material=material,
            max_rate=max_rate,
            verified_only=verified_only,
        )
