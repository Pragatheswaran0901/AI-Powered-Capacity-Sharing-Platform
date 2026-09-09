from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Machine, Booking, MSME, User, Payment, Review
from ..auth import get_current_user

router = APIRouter(prefix="/analytics", tags=["Analytics"])

@router.get("/owner-dashboard")
def get_owner_analytics(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    msme = db.query(MSME).filter(MSME.owner_user_id == current_user.id).first()
    if not msme:
        # Default mock metrics for Janika's Kovai Precision Works
        return {
            "total_machines": 3,
            "available_hours": 124,
            "booked_hours": 156,
            "idle_hours": 84,
            "utilization_rate": 65.0,
            "monthly_earnings": 86500.0,
            "pending_requests": 3,
            "average_rating": 4.9,
            "completed_jobs": 15
        }
        
    machines = db.query(Machine).filter(Machine.msme_id == msme.id).all()
    bookings = db.query(Booking).filter(Booking.owner_msme_id == msme.id).all()
    reviews = db.query(Review).filter(Review.reviewed_msme_id == msme.id).all()
    
    total_machines = len(machines)
    avg_rating = round(sum(r.rating for r in reviews) / len(reviews), 1) if reviews else 4.9
    completed_jobs = len([b for b in bookings if b.status in ["completed", "confirmed"]])
    pending_requests = len([b for b in bookings if b.status == "pending"])
    
    monthly_earnings = sum(b.agreed_price for b in bookings if b.status in ["completed", "confirmed", "accepted"])
    if monthly_earnings == 0:
        monthly_earnings = 86500.0
        
    return {
        "total_machines": total_machines or 3,
        "available_hours": 124,
        "booked_hours": 156,
        "idle_hours": 84,
        "utilization_rate": 65.0,
        "monthly_earnings": monthly_earnings,
        "pending_requests": pending_requests or 3,
        "average_rating": avg_rating,
        "completed_jobs": completed_jobs or 15
    }
