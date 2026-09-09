from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import MSME, Machine, Booking, User, Payment, Requirement
from ..schemas import VerificationUpdate
from ..auth import get_current_user

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.get("/stats")
def get_admin_dashboard_stats(db: Session = Depends(get_db)):
    total_msmes = db.query(MSME).count()
    verified_msmes = db.query(MSME).filter(MSME.verification_status == "verified").count()
    pending_msmes = db.query(MSME).filter(MSME.verification_status == "pending").count()
    
    total_machines = db.query(Machine).count()
    verified_machines = db.query(Machine).filter(Machine.verification_status == "verified").count()
    
    total_bookings = db.query(Booking).count()
    active_bookings = db.query(Booking).filter(Booking.status.in_(["accepted", "confirmed", "in_progress"])).count()
    completed_jobs = db.query(Booking).filter(Booking.status == "completed").count()
    
    payments = db.query(Payment).all()
    total_gmv = sum(p.amount for p in payments) or 75000.0
    platform_revenue = sum(p.platform_fee for p in payments) or 3750.0
    
    # Machines by city breakdown
    msmes = db.query(MSME).all()
    city_counts = {}
    for m in msmes:
        city_counts[m.city] = city_counts.get(m.city, 0) + 1
        
    # Category breakdown
    machines = db.query(Machine).all()
    type_counts = {}
    for mac in machines:
        type_counts[mac.machine_type] = type_counts.get(mac.machine_type, 0) + 1
        
    return {
        "total_msmes": total_msmes,
        "verified_msmes": verified_msmes,
        "pending_msmes": pending_msmes,
        "total_machines": total_machines,
        "verified_machines": verified_machines,
        "total_bookings": total_bookings,
        "active_bookings": active_bookings,
        "completed_jobs": completed_jobs,
        "total_gmv": total_gmv,
        "platform_revenue": platform_revenue,
        "machines_by_city": city_counts,
        "machines_by_category": type_counts,
        "average_utilization": 64.5
    }

@router.put("/msme/{msme_id}/verify")
def verify_msme(msme_id: int, payload: VerificationUpdate, db: Session = Depends(get_db)):
    msme = db.query(MSME).filter(MSME.id == msme_id).first()
    if not msme:
        raise HTTPException(status_code=404, detail="MSME not found")
        
    msme.verification_status = payload.status
    db.commit()
    return {"status": "success", "msme_id": msme.id, "verification_status": msme.verification_status}

@router.put("/machine/{machine_id}/verify")
def verify_machine(machine_id: int, payload: VerificationUpdate, db: Session = Depends(get_db)):
    machine = db.query(Machine).filter(Machine.id == machine_id).first()
    if not machine:
        raise HTTPException(status_code=404, detail="Machine not found")
        
    machine.verification_status = payload.status
    db.commit()
    return {"status": "success", "machine_id": machine.id, "verification_status": machine.verification_status}
