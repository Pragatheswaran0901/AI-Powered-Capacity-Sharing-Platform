from datetime import datetime
from typing import List, Optional, Dict, Any
from pydantic import BaseModel
from app.schemas.machine import MachineOut


class MatchScoreBreakdown(BaseModel):
    capability_score: float
    availability_score: float
    distance_score: float
    cost_score: float
    reliability_score: float
    distance_km: float
    estimated_cost: float


class MatchResultOut(BaseModel):
    match_id: Optional[str] = None
    machine_id: str
    business_id: str
    business_name: str
    machine_name: str
    machine_category: str
    manufacturer: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    location_address: str
    hourly_price: float
    overall_score: float  # 0.0 to 1.0 (or percentage 0 to 100)
    match_percentage: int
    score_breakdown: MatchScoreBreakdown
    match_reasons: List[str]
    photos: List[str] = []
    capabilities: List[Dict[str, Any]] = []
    operator_available: bool = True
    status: str = "ACTIVE"
    average_rating: float = 4.5
    completed_jobs: int = 0
    verification_status: str = "VERIFIED"
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    company_id: Optional[str] = None
    company_name: Optional[str] = None
    industry: Optional[str] = None
    google_maps_link: Optional[str] = None
    city: Optional[str] = None


class CompareRequest(BaseModel):
    requirement_id: str
    machine_ids: List[str]


class ComparisonMatrixItem(BaseModel):
    machine_id: str
    machine_name: str
    business_name: str
    category: str
    hourly_price: float
    match_percentage: int
    distance_km: float
    estimated_cost: float
    tolerance: str
    dimensions: str
    rating: float
    verification_status: str
    key_reasons: List[str]


class ComparisonMatrixOut(BaseModel):
    requirement_id: str
    requirement_title: str
    items: List[ComparisonMatrixItem]
