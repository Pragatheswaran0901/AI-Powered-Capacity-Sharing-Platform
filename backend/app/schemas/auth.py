from typing import Optional, List
from pydantic import BaseModel, EmailStr, Field
from app.models.user import UserRole


class RequestOTPSchema(BaseModel):
    email: EmailStr


class VerifyOTPSchema(BaseModel):
    email: EmailStr
    otp: str = Field(..., min_length=6, max_length=6, pattern=r"^\d{6}$", description="6-digit numeric OTP")


class OTPResponseSchema(BaseModel):
    message: str
    expires_in: int


class UserSummary(BaseModel):
    id: str
    email: str
    name: str
    role: str
    is_onboarded: bool = False
    business_id: Optional[str] = None


class AuthSessionOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserSummary


class OnboardingSchema(BaseModel):
    role: UserRole = Field(..., description="Must be SEEKER or PROVIDER")
    full_name: str = Field(..., min_length=2)
    phone: str = Field(..., min_length=10)
    business_name: str = Field(..., min_length=2)
    industry: str = Field(..., min_length=2)
    district: str = Field(..., min_length=2)
    state: str = Field(default="Tamil Nadu")
    pincode: str = Field(..., min_length=6)
    address: str = Field(..., min_length=5)
    description: Optional[str] = None
    gstin: Optional[str] = None
    machine_categories: Optional[List[str]] = None
    primary_processes: Optional[List[str]] = None


class UserRegisterSchema(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6, description="Minimum 6 characters")
    full_name: str = Field(..., min_length=2)
    phone: str = Field(..., min_length=10)
    role: UserRole = UserRole.SEEKER


class LoginSchema(BaseModel):
    email: EmailStr
    password: str


class TokenSchema(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: str
    role: str
    full_name: str
    business_id: Optional[str] = None
    is_onboarded: bool = True


class TokenRefreshSchema(BaseModel):
    refresh_token: str


class TokenPayload(BaseModel):
    sub: str
    role: str
    business_id: Optional[str] = None
    exp: int
    type: str
