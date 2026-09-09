from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models import MSME, User
from ..schemas import MSMEResponse, MSMECreate
from ..auth import get_current_user

router = APIRouter(prefix="/msmes", tags=["MSMEs"])

@router.get("", response_model=List[MSMEResponse])
def list_msmes(city: Optional[str] = None, verification: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(MSME)
    if city:
        query = query.filter(MSME.city.ilike(f"%{city}%"))
    if verification:
        query = query.filter(MSME.verification_status == verification)
    return query.all()

@router.get("/{msme_id}", response_model=MSMEResponse)
def get_msme(msme_id: int, db: Session = Depends(get_db)):
    msme = db.query(MSME).filter(MSME.id == msme_id).first()
    if not msme:
        raise HTTPException(status_code=404, detail="MSME not found")
    return msme

@router.post("", response_model=MSMEResponse)
def create_msme(msme_data: MSMECreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    existing = db.query(MSME).filter(MSME.owner_user_id == current_user.id).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already has a registered MSME")
        
    new_msme = MSME(
        owner_user_id=current_user.id,
        **msme_data.model_dump()
    )
    db.add(new_msme)
    db.commit()
    db.refresh(new_msme)
    return new_msme
