from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models import Machine, MachineCapability, MSME, User, Review
from ..schemas import MachineResponse, MachineCreate
from ..auth import get_current_user

router = APIRouter(prefix="/machines", tags=["Machines"])

def format_machine_response(machine: Machine, db: Session) -> dict:
    msme = db.query(MSME).filter(MSME.id == machine.msme_id).first()
    reviews = db.query(Review).filter(Review.reviewed_msme_id == machine.msme_id).all()
    avg_rating = round(sum(r.rating for r in reviews) / len(reviews), 1) if reviews else 4.8
    
    return {
        "id": machine.id,
        "msme_id": machine.msme_id,
        "msme_name": msme.company_name if msme else "MSME Partner",
        "msme_city": msme.city if msme else machine.location,
        "machine_name": machine.machine_name,
        "machine_type": machine.machine_type,
        "manufacturer": machine.manufacturer,
        "model": machine.model,
        "year": machine.year,
        "description": machine.description,
        "hourly_rate": machine.hourly_rate,
        "minimum_booking_hours": machine.minimum_booking_hours,
        "location": machine.location,
        "latitude": machine.latitude,
        "longitude": machine.longitude,
        "operator_available": machine.operator_available,
        "verification_status": machine.verification_status,
        "created_at": machine.created_at,
        "capabilities": machine.capabilities,
        "avg_rating": avg_rating,
        "jobs_completed": 12 + machine.id
    }

@router.get("", response_model=List[MachineResponse])
def list_machines(
    city: Optional[str] = None,
    machine_type: Optional[str] = None,
    process: Optional[str] = None,
    material: Optional[str] = None,
    verified_only: bool = False,
    db: Session = Depends(get_db)
):
    query = db.query(Machine)
    if verified_only:
        query = query.filter(Machine.verification_status == "verified")
    if city:
        query = query.filter(Machine.location.ilike(f"%{city}%"))
    if machine_type:
        query = query.filter(Machine.machine_type.ilike(f"%{machine_type}%"))
        
    machines = query.all()
    
    if material or process:
        filtered = []
        for m in machines:
            match_p = True
            match_m = True
            if process:
                match_p = any(process.lower() in cap.process.lower() for cap in m.capabilities) or process.lower() in m.machine_type.lower()
            if material:
                match_m = any(material.lower() in cap.material.lower() for cap in m.capabilities)
            if match_p and match_m:
                filtered.append(m)
        machines = filtered

    return [format_machine_response(m, db) for m in machines]

@router.get("/{machine_id}", response_model=MachineResponse)
def get_machine(machine_id: int, db: Session = Depends(get_db)):
    machine = db.query(Machine).filter(Machine.id == machine_id).first()
    if not machine:
        raise HTTPException(status_code=404, detail="Machine not found")
    return format_machine_response(machine, db)

@router.post("", response_model=MachineResponse)
def create_machine(machine_data: MachineCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    msme = db.query(MSME).filter(MSME.owner_user_id == current_user.id).first()
    if not msme:
        raise HTTPException(status_code=400, detail="User must register an MSME before adding machines")
        
    capabilities_input = machine_data.capabilities
    machine_dict = machine_data.model_dump(exclude={"capabilities"})
    
    new_machine = Machine(
        msme_id=msme.id,
        verification_status="verified", # Auto-verify for demo convenience
        **machine_dict
    )
    db.add(new_machine)
    db.commit()
    db.refresh(new_machine)
    
    for cap in capabilities_input:
        c_obj = MachineCapability(
            machine_id=new_machine.id,
            **cap.model_dump()
        )
        db.add(c_obj)
    db.commit()
    db.refresh(new_machine)
    
    return format_machine_response(new_machine, db)
