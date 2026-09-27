from fastapi import APIRouter, Depends, Request, status, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.auth import (
    UserRegisterSchema, LoginSchema, TokenSchema, TokenRefreshSchema,
    RequestOTPSchema, VerifyOTPSchema, OTPResponseSchema, AuthSessionOut,
    OnboardingSchema
)
from app.schemas.user import UserOut
from app.services.auth_service import AuthService
from app.api.deps import get_current_user
from app.models.user import User

from app.core.config import settings

router = APIRouter()


@router.get(
    "/config",
    summary="Get active authentication configuration",
)
def get_auth_config():
    """Returns active authentication mode (demo or otp)."""
    return {
        "auth_mode": settings.AUTH_MODE,
        "email_from": settings.EMAIL_FROM,
        "otp_length": settings.OTP_LENGTH,
    }


@router.post(
    "/request-otp",
    response_model=OTPResponseSchema,
    status_code=status.HTTP_200_OK,
    summary="Request a 6-digit verification code via email",
    description="Generates a cryptographically secure 6-digit OTP, stores its HMAC hash, and delivers it via transactional email. Protected with rate limiting and account enumeration defenses.",
)
def request_otp(
    payload: RequestOTPSchema,
    request: Request,
    db: Session = Depends(get_db),
):
    ip = request.client.host if request.client else None
    return AuthService(db).request_otp(email=payload.email, request_ip=ip)


@router.post(
    "/resend-otp",
    response_model=OTPResponseSchema,
    status_code=status.HTTP_200_OK,
    summary="Resend a 6-digit verification code",
    description="Resends a fresh OTP after the 60-second cooldown period has elapsed.",
)
def resend_otp(
    payload: RequestOTPSchema,
    request: Request,
    db: Session = Depends(get_db),
):
    ip = request.client.host if request.client else None
    return AuthService(db).request_otp(email=payload.email, request_ip=ip)


@router.post(
    "/verify-otp",
    response_model=AuthSessionOut,
    status_code=status.HTTP_200_OK,
    summary="Verify email OTP and establish authenticated session",
    description="Validates single-use 6-digit OTP, creates new SEEKER account if not registered, marks email verified, and returns JWT access + refresh tokens.",
)
def verify_otp(
    payload: VerifyOTPSchema,
    db: Session = Depends(get_db),
):
    return AuthService(db).verify_otp(email=payload.email, otp=payload.otp)


@router.post(
    "/onboarding",
    response_model=AuthSessionOut,
    status_code=status.HTTP_200_OK,
    summary="Complete progressive MSME onboarding",
    description="Allows newly authenticated users to select their role (SEEKER or PROVIDER - ADMIN forbidden) and configure their business entity.",
)
def complete_onboarding(
    onboarding_in: OnboardingSchema,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return AuthService(db).complete_onboarding(user=current_user, onboarding_in=onboarding_in)


@router.post(
    "/login",
    response_model=TokenSchema,
    summary="Authenticate with email and password (Legacy / Seeded Accounts)",
)
def login(login_in: LoginSchema, db: Session = Depends(get_db)):
    """Backward-compatible password authentication for existing seeded accounts."""
    return AuthService(db).login(login_in)


@router.post(
    "/register",
    response_model=TokenSchema,
    status_code=status.HTTP_201_CREATED,
    summary="Direct password registration (Legacy)",
)
def register(user_in: UserRegisterSchema, db: Session = Depends(get_db)):
    """Backward-compatible direct registration."""
    return AuthService(db).register(user_in)


@router.post(
    "/refresh",
    response_model=TokenSchema,
    summary="Refresh access token",
)
def refresh_token(refresh_in: TokenRefreshSchema, db: Session = Depends(get_db)):
    """Refresh an expired access token using a valid refresh token."""
    return AuthService(db).refresh_token(refresh_in)


@router.get(
    "/me",
    response_model=UserOut,
    summary="Current authenticated user session",
)
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """Get active authenticated user session details."""
    biz_id = current_user.business.id if current_user.business else None
    biz_name = current_user.business.name if current_user.business else None
    return UserOut(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name or current_user.email.split("@")[0],
        phone=current_user.phone or "",
        role=current_user.role,
        is_active=current_user.is_active,
        is_verified=current_user.is_verified,
        created_at=current_user.created_at,
        business_id=biz_id,
        business_name=biz_name,
    )


@router.post(
    "/logout",
    summary="End authenticated session",
)
def logout(current_user: User = Depends(get_current_user)):
    """Log out and terminate current session."""
    return {"message": "Successfully logged out."}
