import json
from datetime import datetime, date, time
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.machine import MachineStatus
from app.models.business import VerificationStatus


class CapabilityBase(BaseModel):
    process: str
    material: str
    min_tolerance_mm: Optional[float] = None
    max_dimension_x: Optional[float] = None
    max_dimension_y: Optional[float] = None
    max_dimension_z: Optional[float] = None


class CapabilityCreate(CapabilityBase):
    pass


class CapabilityOut(CapabilityBase):
    id: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class AvailabilityBase(BaseModel):
    date: date
    start_time: time = time(9, 0)
    end_time: time = time(18, 0)
    is_available: bool = True
    reason: Optional[str] = "Available Working Hours"


class AvailabilityCreate(AvailabilityBase):
    pass


class AvailabilityBatchCreate(BaseModel):
    slots: List[AvailabilityCreate]


class AvailabilityOut(AvailabilityBase):
    id: str
    booking_id: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class MachineBase(BaseModel):
    name: str = Field(..., min_length=2)
    category: str
    manufacturer: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    description: Optional[str] = None
    dimensions_capacity: Optional[str] = None
    precision_tolerance: Optional[str] = None
    operating_parameters: Optional[Dict[str, Any]] = None
    hourly_price: float = Field(..., gt=0)
    min_job_value: float = Field(default=0.0, ge=0)
    operator_available: bool = True
    location_address: str
    latitude: float
    longitude: float
    photos: Optional[List[str]] = []

    @field_validator("operating_parameters", mode="before")
    @classmethod
    def parse_params(cls, v):
        if isinstance(v, str):
            try:
                return json.loads(v)
            except Exception:
                return {}
        return v or {}

    @field_validator("photos", mode="before")
    @classmethod
    def parse_photos(cls, v):
        if isinstance(v, str):
            try:
                return json.loads(v)
            except Exception:
                return []
        return v or []


class MachineCreate(MachineBase):
    capabilities: List[CapabilityCreate] = []


class MachineUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    manufacturer: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    description: Optional[str] = None
    dimensions_capacity: Optional[str] = None
    precision_tolerance: Optional[str] = None
    operating_parameters: Optional[Dict[str, Any]] = None
    hourly_price: Optional[float] = None
    min_job_value: Optional[float] = None
    operator_available: Optional[bool] = None
    location_address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    photos: Optional[List[str]] = None
    status: Optional[MachineStatus] = None


class MachineOut(MachineBase):
    id: str
    business_id: str
    business_name: Optional[str] = None
    status: MachineStatus
    verification_status: VerificationStatus
    created_at: datetime
    updated_at: datetime
    capabilities: List[CapabilityOut] = []

    model_config = ConfigDict(from_attributes=True)


class MachineDetail(MachineOut):
    availabilities: List[AvailabilityOut] = []
    average_rating: float = 4.5
    completed_jobs: int = 0
