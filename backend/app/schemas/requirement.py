from datetime import datetime, date
from typing import Optional, List
from pydantic import BaseModel, ConfigDict, Field
from app.models.requirement import RequirementStatus


class AttachmentOut(BaseModel):
    id: str
    file_name: str
    file_path: str
    file_size: Optional[int] = None
    file_type: Optional[str] = None
    uploaded_at: datetime

    model_config = ConfigDict(from_attributes=True)


class RequirementBase(BaseModel):
    title: str = Field(..., min_length=3)
    description: str
    process: str  # CNC Milling, Turning, Laser Cutting, etc.
    material: str
    quantity: int = Field(..., gt=0)
    dimensions: Optional[str] = None
    tolerance_mm: Optional[float] = None
    required_date: date
    delivery_deadline: date
    preferred_location: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    max_distance_km: float = 100.0
    budget: float = Field(..., gt=0)
    quality_requirements: Optional[str] = None
    operator_required: bool = True


class RequirementCreate(RequirementBase):
    pass


class RequirementUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    process: Optional[str] = None
    material: Optional[str] = None
    quantity: Optional[int] = None
    dimensions: Optional[str] = None
    tolerance_mm: Optional[float] = None
    required_date: Optional[date] = None
    delivery_deadline: Optional[date] = None
    preferred_location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    max_distance_km: Optional[float] = None
    budget: Optional[float] = None
    quality_requirements: Optional[str] = None
    operator_required: Optional[bool] = None
    status: Optional[RequirementStatus] = None


class RequirementOut(RequirementBase):
    id: str
    seeker_id: str
    seeker_name: Optional[str] = None
    status: RequirementStatus
    created_at: datetime
    updated_at: datetime
    attachments: List[AttachmentOut] = []

    model_config = ConfigDict(from_attributes=True)


class RequirementDetail(RequirementOut):
    matched_count: int = 0


# AI Natural Language Interpretation Schema
class NaturalLanguageQuery(BaseModel):
    prompt: str = Field(..., min_length=5)


class InterpretedRequirement(BaseModel):
    title: str
    process: str
    material: str
    quantity: int
    dimensions: Optional[str] = None
    tolerance_mm: Optional[float] = None
    deadline_days: int
    preferred_location: str
    estimated_budget: float
    confidence_score: float = Field(default=0.9, ge=0.0, le=1.0)
    extracted_entities: dict = {}
