from datetime import date
from typing import List, Optional
from fastapi import APIRouter, Depends, status, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user, get_current_user_optional, require_role
from app.models.user import User, UserRole
from app.schemas.machine import (
    MachineCreate, MachineUpdate, MachineOut, MachineDetail,
    AvailabilityBatchCreate, AvailabilityOut
)
from app.services.machine_service import MachineService
from app.services.availability_service import AvailabilityService

router = APIRouter()


@router.post("/", response_model=MachineDetail, status_code=status.HTTP_201_CREATED)
def create_machine(
    machine_in: MachineCreate,
    current_user: User = Depends(require_role(UserRole.PROVIDER)),
    db: Session = Depends(get_db),
):
    """List a new machine with technical specs, operating limits, and capabilities."""
    mach = MachineService(db).create_machine(current_user.id, machine_in)
    return mach


@router.get("/", response_model=List[MachineOut])
def search_machines(
    category: Optional[str] = Query(None, description="e.g. CNC Milling, Laser"),
    process: Optional[str] = Query(None, description="e.g. Turning, Milling"),
    material: Optional[str] = Query(None, description="e.g. Aluminium, Steel"),
    industry: Optional[str] = Query(None, description="Filter machines by industry"),
    max_rate: Optional[float] = Query(None, description="Maximum hourly rate in INR"),
    verified_only: bool = Query(False, description="Filter only verified machines"),
    location: Optional[str] = Query(None, description="Filter machines by location e.g. Coimbatore, Tiruppur"),
    exclude_user_id: Optional[str] = Query(None, description="Exclude machines belonging to this user"),
    current_user: Optional[User] = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    """Search and filter machines across the platform."""
    eff_exclude_user_id = exclude_user_id
    if not eff_exclude_user_id and current_user:
        eff_exclude_user_id = current_user.id

    return MachineService(db).search_machines(
        category=category,
        process=process,
        material=material,
        industry=industry,
        max_rate=max_rate,
        verified_only=verified_only,
        location=location,
        exclude_user_id=eff_exclude_user_id,
    )


@router.get("/my", response_model=List[MachineOut])
def get_my_machines(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get all machines owned by the authenticated provider."""
    return MachineService(db).get_my_machines(current_user.id)


@router.get("/{machine_id}", response_model=MachineDetail)
def get_machine_detail(
    machine_id: str,
    db: Session = Depends(get_db),
):
    """Get complete machine profile including capabilities and ratings."""
    return MachineService(db).get_machine(machine_id)


@router.put("/{machine_id}", response_model=MachineOut)
def update_machine(
    machine_id: str,
    update_in: MachineUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update machine parameters or status."""
    return MachineService(db).update_machine(current_user.id, machine_id, update_in)


@router.delete("/{machine_id}")
def delete_machine(
    machine_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Deactivate machine listing."""
    return MachineService(db).delete_machine(current_user.id, machine_id)


@router.post("/{machine_id}/availability", response_model=List[AvailabilityOut])
def set_machine_availability(
    machine_id: str,
    batch_in: AvailabilityBatchCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Define working hours, maintenance, and blocked dates for a machine."""
    return AvailabilityService(db).set_machine_availability(current_user.id, machine_id, batch_in)


@router.get("/{machine_id}/availability", response_model=List[AvailabilityOut])
def get_machine_availability(
    machine_id: str,
    start_date: Optional[date] = Query(None),
    end_date: Optional[date] = Query(None),
    db: Session = Depends(get_db),
):
    """Retrieve machine operational calendar within date window."""
    return AvailabilityService(db).get_machine_availability(machine_id, start_date, end_date)
