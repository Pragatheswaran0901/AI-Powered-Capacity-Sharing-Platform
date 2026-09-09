from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Requirement, MSME, User, Match
from ..schemas import RequirementCreate, RequirementResponse, NLRequirementRequest, NLRequirementResponse, MatchResult
from ..auth import get_current_user
from ..nl_parser import parse_natural_language_requirement
from ..matching import match_requirement_to_machines

router = APIRouter(prefix="/requirements", tags=["Requirements"])

@router.post("/parse-nl", response_model=NLRequirementResponse)
def parse_nl_prompt(request: NLRequirementRequest):
    """Natural Language Assistant to parse requirement query string."""
    parsed = parse_natural_language_requirement(request.prompt)
    return parsed

@router.get("", response_model=List[RequirementResponse])
def list_requirements(db: Session = Depends(get_db)):
    reqs = db.query(Requirement).order_by(Requirement.created_at.desc()).all()
    results = []
    for r in reqs:
        msme = db.query(MSME).filter(MSME.id == r.seeker_msme_id).first()
        results.append({
            "id": r.id,
            "seeker_msme_id": r.seeker_msme_id,
            "seeker_company_name": msme.company_name if msme else "Seeker MSME",
            "title": r.title,
            "description": r.description,
            "process": r.process,
            "material": r.material,
            "quantity": r.quantity,
            "deadline": r.deadline,
            "budget": r.budget,
            "preferred_city": r.preferred_city,
            "latitude": r.latitude,
            "longitude": r.longitude,
            "status": r.status,
            "created_at": r.created_at
        })
    return results

@router.post("", response_model=RequirementResponse)
def create_requirement(req_data: RequirementCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    msme = db.query(MSME).filter(MSME.owner_user_id == current_user.id).first()
    if not msme:
        # Auto-create demo Seeker MSME if missing
        msme = MSME(
            owner_user_id=current_user.id,
            company_name=f"{current_user.name} Engineering Works",
            business_type="Manufacturing Seeker",
            city=req_data.preferred_city or "Coimbatore",
            district=req_data.preferred_city or "Coimbatore",
            state="Tamil Nadu",
            verification_status="verified"
        )
        db.add(msme)
        db.commit()
        db.refresh(msme)
        
    new_req = Requirement(
        seeker_msme_id=msme.id,
        **req_data.model_dump()
    )
    db.add(new_req)
    db.commit()
    db.refresh(new_req)
    
    return {
        "id": new_req.id,
        "seeker_msme_id": new_req.seeker_msme_id,
        "seeker_company_name": msme.company_name,
        "title": new_req.title,
        "description": new_req.description,
        "process": new_req.process,
        "material": new_req.material,
        "quantity": new_req.quantity,
        "deadline": new_req.deadline,
        "budget": new_req.budget,
        "preferred_city": new_req.preferred_city,
        "latitude": new_req.latitude,
        "longitude": new_req.longitude,
        "status": new_req.status,
        "created_at": new_req.created_at
    }

@router.get("/{requirement_id}/matches", response_model=List[MatchResult])
def get_matches_for_requirement(requirement_id: int, db: Session = Depends(get_db)):
    req = db.query(Requirement).filter(Requirement.id == requirement_id).first()
    if not req:
        raise HTTPException(status_code=404, detail="Requirement not found")
        
    match_items = match_requirement_to_machines(req, db)
    
    formatted_results = []
    for item in match_items:
        m = item["machine"]
        msme = db.query(MSME).filter(MSME.id == m.msme_id).first()
        
        m_response = {
            "id": m.id,
            "msme_id": m.msme_id,
            "msme_name": msme.company_name if msme else "MSME Partner",
            "msme_city": msme.city if msme else m.location,
            "machine_name": m.machine_name,
            "machine_type": m.machine_type,
            "manufacturer": m.manufacturer,
            "model": m.model,
            "year": m.year,
            "description": m.description,
            "hourly_rate": m.hourly_rate,
            "minimum_booking_hours": m.minimum_booking_hours,
            "location": m.location,
            "latitude": m.latitude,
            "longitude": m.longitude,
            "operator_available": m.operator_available,
            "verification_status": m.verification_status,
            "created_at": m.created_at,
            "capabilities": m.capabilities,
            "avg_rating": 4.9 if "kovai" in (msme.company_name.lower() if msme else "") else 4.7,
            "jobs_completed": 15
        }
        
        formatted_results.append({
            "match_id": None,
            "machine": m_response,
            "capability_score": item["capability_score"],
            "availability_score": item["availability_score"],
            "distance_score": item["distance_score"],
            "cost_score": item["cost_score"],
            "reliability_score": item["reliability_score"],
            "total_score": item["total_score"],
            "match_percentage": item["match_percentage"],
            "distance_km": item["distance_km"]
        })
        
    return formatted_results
