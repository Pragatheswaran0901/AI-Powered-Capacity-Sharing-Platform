from typing import List, Optional
from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.company import Company
from app.models.machine import Machine
from app.schemas.company import CompanyOut, IndustryOut

router = APIRouter()


@router.get("/", response_model=List[CompanyOut])
def get_companies(
    city: Optional[str] = Query(None, description="Filter by city e.g. Coimbatore or Tiruppur"),
    industry: Optional[str] = Query(None, description="Filter by industrial category"),
    search: Optional[str] = Query(None, description="Search company name, address or id"),
    db: Session = Depends(get_db),
):
    """
    List registered industrial companies and production facilities from the master 49-company dataset.
    """
    query = db.query(Company)

    if city:
        query = query.filter(Company.city.ilike(f"%{city.strip()}%"))

    if industry:
        query = query.filter(Company.industry.ilike(f"%{industry.strip()}%"))

    if search:
        s = f"%{search.strip()}%"
        query = query.filter(
            (Company.name.ilike(s)) |
            (Company.id.ilike(s)) |
            (Company.address.ilike(s)) |
            (Company.industry.ilike(s))
        )

    companies = query.order_by(Company.id.asc()).all()

    # Enrich with machine count
    result = []
    for c in companies:
        m_count = db.query(Machine).filter(Machine.company_id == c.id).count()
        out = CompanyOut(
            id=c.id,
            name=c.name,
            city=c.city,
            state=c.state,
            address=c.address,
            latitude=c.latitude,
            longitude=c.longitude,
            industry=c.industry,
            google_maps_link=c.google_maps_link,
            created_at=c.created_at,
            machine_count=m_count,
        )
        result.append(out)

    return result


@router.get("/industries", response_model=List[IndustryOut])
def get_industries(db: Session = Depends(get_db)):
    """
    Get all 33 distinct manufacturing industries from the master industrial dataset,
    along with company counts and geographic distribution (Coimbatore vs Tiruppur).
    """
    companies = db.query(Company).all()

    industries_map = {}
    for c in companies:
        ind = c.industry
        if ind not in industries_map:
            industries_map[ind] = {"total": 0, "cities": {}}
        industries_map[ind]["total"] += 1
        industries_map[ind]["cities"][c.city] = industries_map[ind]["cities"].get(c.city, 0) + 1

    result = []
    for ind in sorted(industries_map.keys()):
        result.append(IndustryOut(
            industry=ind,
            company_count=industries_map[ind]["total"],
            city_breakdown=industries_map[ind]["cities"],
        ))

    return result


@router.get("/{company_id}", response_model=CompanyOut)
def get_company(company_id: str, db: Session = Depends(get_db)):
    """
    Get specific company location details by company_id (e.g. CBE001, TPR001).
    """
    c = db.query(Company).filter(Company.id == company_id).first()
    if not c:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Company '{company_id}' not found in industrial dataset.",
        )

    m_count = db.query(Machine).filter(Machine.company_id == c.id).count()
    return CompanyOut(
        id=c.id,
        name=c.name,
        city=c.city,
        state=c.state,
        address=c.address,
        latitude=c.latitude,
        longitude=c.longitude,
        industry=c.industry,
        google_maps_link=c.google_maps_link,
        created_at=c.created_at,
        machine_count=m_count,
    )
