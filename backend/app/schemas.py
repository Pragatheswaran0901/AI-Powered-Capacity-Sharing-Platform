from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime

# Auth & User Schemas
class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: int
    name: str
    email: str
    role: str
    msme_id: Optional[int] = None
    company_name: Optional[str] = None

class UserBase(BaseModel):
    name: str
    email: EmailStr
    phone: Optional[str] = None
    role: str

class UserCreate(UserBase):
    password: str
    company_name: Optional[str] = None
    city: Optional[str] = "Coimbatore"

class UserResponse(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

# MSME Schemas
class MSMEBase(BaseModel):
    company_name: str
    business_type: str
    description: Optional[str] = None
    city: str
    district: str
    state: str = "Tamil Nadu"
    pincode: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class MSMECreate(MSMEBase):
    pass

class MSMEResponse(MSMEBase):
    id: int
    owner_user_id: int
    verification_status: str
    created_at: datetime

    class Config:
        from_attributes = True

# Capability Schema
class CapabilityBase(BaseModel):
    process: str
    material: str
    max_dimension: Optional[str] = None
    tolerance: Optional[str] = None
    capacity_description: Optional[str] = None

class CapabilityCreate(CapabilityBase):
    pass

class CapabilityResponse(CapabilityBase):
    id: int
    machine_id: int

    class Config:
        from_attributes = True

# Machine Schemas
class MachineBase(BaseModel):
    machine_name: str
    machine_type: str
    manufacturer: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    description: Optional[str] = None
    hourly_rate: float
    minimum_booking_hours: int = 1
    location: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    operator_available: bool = True

class MachineCreate(MachineBase):
    capabilities: List[CapabilityCreate] = []

class MachineResponse(MachineBase):
    id: int
    msme_id: int
    msme_name: Optional[str] = None
    msme_city: Optional[str] = None
    verification_status: str
    created_at: datetime
    capabilities: List[CapabilityResponse] = []
    avg_rating: Optional[float] = 4.8
    jobs_completed: Optional[int] = 12

    class Config:
        from_attributes = True

# Requirement Schemas
class RequirementBase(BaseModel):
    title: str
    description: Optional[str] = None
    process: str
    material: str
    quantity: int
    deadline: str
    budget: float
    preferred_city: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class RequirementCreate(RequirementBase):
    pass

class RequirementResponse(RequirementBase):
    id: int
    seeker_msme_id: int
    seeker_company_name: Optional[str] = None
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

# NL Requirement Parsing Schema
class NLRequirementRequest(BaseModel):
    prompt: str

class NLRequirementResponse(BaseModel):
    title: str
    description: str
    process: str
    material: str
    quantity: int
    deadline: str
    budget: float
    preferred_city: str

# Match Result Schema
class MatchResult(BaseModel):
    match_id: Optional[int] = None
    machine: MachineResponse
    capability_score: float
    availability_score: float
    distance_score: float
    cost_score: float
    reliability_score: float
    total_score: float
    match_percentage: int
    distance_km: float

# Booking Schemas
class BookingCreate(BaseModel):
    requirement_id: int
    machine_id: int
    booking_date: str
    start_time: str = "09:00"
    end_time: str = "17:00"
    quantity: int
    agreed_price: float

class BookingResponse(BaseModel):
    id: int
    requirement_id: int
    machine_id: int
    seeker_msme_id: int
    owner_msme_id: int
    machine_name: Optional[str] = None
    seeker_company_name: Optional[str] = None
    owner_company_name: Optional[str] = None
    booking_date: str
    start_time: str
    end_time: str
    quantity: int
    agreed_price: float
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

# Review Schemas
class ReviewCreate(BaseModel):
    booking_id: int
    rating: float
    quality_rating: float = 5.0
    reliability_rating: float = 5.0
    communication_rating: float = 5.0
    comment: Optional[str] = None

class ReviewResponse(BaseModel):
    id: int
    booking_id: int
    reviewer_id: int
    reviewer_name: Optional[str] = None
    reviewed_msme_id: int
    rating: float
    quality_rating: float
    reliability_rating: float
    communication_rating: float
    comment: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# Verification Update
class VerificationUpdate(BaseModel):
    status: str  # 'verified', 'rejected'
