from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict, EmailStr, Field
from app.models.business import VerificationStatus


class BusinessBase(BaseModel):
    name: str = Field(..., min_length=2)
    owner_name: str = Field(..., min_length=2)
    phone: str = Field(..., min_length=10)
    email: EmailStr
    gstin: Optional[str] = None
    registration_number: Optional[str] = None
    industry: str
    address: str
    district: str
    state: str = "Tamil Nadu"
    pincode: str
    latitude: float
    longitude: float
    description: Optional[str] = None


class BusinessCreate(BusinessBase):
    pass


class BusinessUpdate(BaseModel):
    name: Optional[str] = None
    owner_name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    gstin: Optional[str] = None
    registration_number: Optional[str] = None
    industry: Optional[str] = None
    address: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    description: Optional[str] = None


class DocumentOut(BaseModel):
    id: str
    document_type: str
    file_path: str
    verification_status: VerificationStatus
    uploaded_at: datetime

    model_config = ConfigDict(from_attributes=True)


class BusinessOut(BusinessBase):
    id: str
    user_id: str
    verification_status: VerificationStatus
    created_at: datetime
    updated_at: datetime
    documents: List[DocumentOut] = []

    model_config = ConfigDict(from_attributes=True)
