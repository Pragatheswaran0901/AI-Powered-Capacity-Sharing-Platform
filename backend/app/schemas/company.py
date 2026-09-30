from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict


class CompanyBase(BaseModel):
    id: str  # company_id (e.g. CBE001, TPR001)
    name: str
    city: str
    state: str = "Tamil Nadu"
    address: str
    latitude: float
    longitude: float
    industry: str
    google_maps_link: str


class CompanyOut(CompanyBase):
    created_at: datetime
    machine_count: int = 0

    model_config = ConfigDict(from_attributes=True)


class IndustryOut(BaseModel):
    industry: str
    company_count: int
    city_breakdown: dict = {}
