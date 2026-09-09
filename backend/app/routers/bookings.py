from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from ..database import get_db
from ..models import Booking, Requirement, Machine, MSME, User, Payment, Notification
from ..schemas import BookingCreate, BookingResponse
from ..auth import get_current_user

router = APIRouter(prefix="/bookings", tags=["Bookings"])

def format_booking_response(b: Booking, db: Session) -> dict:
    machine = db.query(Machine).filter(Machine.id == b.machine_id).first()
    seeker_msme = db.query(MSME).filter(MSME.id == b.seeker_msme_id).first()
    owner_msme = db.query(MSME).filter(MSME.id == b.owner_msme_id).first()
    
    return {
        "id": b.id,
        "requirement_id": b.requirement_id,
        "machine_id": b.machine_id,
        "seeker_msme_id": b.seeker_msme_id,
        "owner_msme_id": b.owner_msme_id,
        "machine_name": machine.machine_name if machine else "Machine",
        "seeker_company_name": seeker_msme.company_name if seeker_msme else "Seeker MSME",
        "owner_company_name": owner_msme.company_name if owner_msme else "Owner MSME",
        "booking_date": b.booking_date,
        "start_time": b.start_time,
        "end_time": b.end_time,
        "quantity": b.quantity,
        "agreed_price": b.agreed_price,
        "status": b.status,
        "created_at": b.created_at
    }

@router.get("", response_model=List[BookingResponse])
def list_bookings(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    msme = db.query(MSME).filter(MSME.owner_user_id == current_user.id).first()
    
    query = db.query(Booking)
    if current_user.role == "admin":
        pass  # Admin sees all
    elif msme:
        query = query.filter((Booking.seeker_msme_id == msme.id) | (Booking.owner_msme_id == msme.id))
    else:
        return []
        
    bookings = query.order_by(Booking.created_at.desc()).all()
    return [format_booking_response(b, db) for b in bookings]

@router.post("", response_model=BookingResponse)
def create_booking(booking_input: BookingCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    req = db.query(Requirement).filter(Requirement.id == booking_input.requirement_id).first()
    if not req:
        raise HTTPException(status_code=404, detail="Requirement not found")
        
    machine = db.query(Machine).filter(Machine.id == booking_input.machine_id).first()
    if not machine:
        raise HTTPException(status_code=404, detail="Machine not found")
        
    seeker_msme = db.query(MSME).filter(MSME.owner_user_id == current_user.id).first()
    if not seeker_msme:
        seeker_msme = db.query(MSME).filter(MSME.id == req.seeker_msme_id).first()
        
    owner_msme = db.query(MSME).filter(MSME.id == machine.msme_id).first()
    
    new_booking = Booking(
        requirement_id=req.id,
        machine_id=machine.id,
        seeker_msme_id=seeker_msme.id,
        owner_msme_id=owner_msme.id,
        booking_date=booking_input.booking_date,
        start_time=booking_input.start_time,
        end_time=booking_input.end_time,
        quantity=booking_input.quantity,
        agreed_price=booking_input.agreed_price,
        status="pending"
    )
    db.add(new_booking)
    req.status = "matched"
    db.commit()
    db.refresh(new_booking)
    
    # Notify machine owner
    owner_user = db.query(User).filter(User.id == owner_msme.owner_user_id).first()
    if owner_user:
        notif = Notification(
            user_id=owner_user.id,
            title="New Capacity Booking Request",
            message=f"{seeker_msme.company_name} requested booking for {machine.machine_name} (Qty: {booking_input.quantity}).",
            read=False
        )
        db.add(notif)
        db.commit()

    return format_booking_response(new_booking, db)

@router.put("/{booking_id}/status", response_model=BookingResponse)
def update_booking_status(booking_id: int, new_status: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
        
    booking.status = new_status
    if new_status == "confirmed" or new_status == "accepted":
        # Create payment record
        platform_fee = round(booking.agreed_price * 0.05, 2)
        p = db.query(Payment).filter(Payment.booking_id == booking.id).first()
        if not p:
            new_payment = Payment(
                booking_id=booking.id,
                amount=booking.agreed_price,
                platform_fee=platform_fee,
                status="completed",
                payment_reference=f"PAY_MH_TN_{int(datetime.utcnow().timestamp())}"
            )
            db.add(new_payment)
            
    db.commit()
    db.refresh(booking)
    return format_booking_response(booking, db)
