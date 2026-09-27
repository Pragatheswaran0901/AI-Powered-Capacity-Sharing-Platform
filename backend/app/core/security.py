import bcrypt
from datetime import datetime, timedelta, timezone
from typing import Any, Union, Optional
import jwt
from app.core.config import settings


def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        # Bcrypt max 72 bytes constraint
        plain_bytes = plain_password.encode("utf-8")[:72]
        hash_bytes = hashed_password.encode("utf-8")
        return bcrypt.checkpw(plain_bytes, hash_bytes)
    except Exception:
        return False


def get_password_hash(password: str) -> str:
    plain_bytes = password.encode("utf-8")[:72]
    salt = bcrypt.gensalt(rounds=12)
    return bcrypt.hashpw(plain_bytes, salt).decode("utf-8")


import hmac
import hashlib
import secrets


def generate_secure_otp(length: int = 6) -> str:
    """Generate a cryptographically secure numeric OTP."""
    digits = "0123456789"
    return "".join(secrets.choice(digits) for _ in range(length))


def hash_otp(otp: str, email: str) -> str:
    """Compute HMAC-SHA256 hash of OTP salted with email and server secret."""
    norm_email = email.strip().lower()
    msg = f"{otp}:{norm_email}".encode("utf-8")
    key = settings.SECRET_KEY.encode("utf-8")
    return hmac.new(key, msg, hashlib.sha256).hexdigest()


def verify_otp_hash(otp: str, email: str, stored_hash: str) -> bool:
    """Constant-time verification of OTP hash against stored hash."""
    computed_hash = hash_otp(otp, email)
    return hmac.compare_digest(computed_hash, stored_hash)


def create_access_token(
    subject: Union[str, Any],
    role: str,
    business_id: Optional[str] = None,
    email: Optional[str] = None,
    expires_delta: Optional[timedelta] = None,
) -> str:
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode = {
        "sub": str(subject),
        "user_id": str(subject),
        "role": role,
        "email": email,
        "business_id": business_id,
        "iat": int(now.timestamp()),
        "exp": expire,
        "type": "access",
    }
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def create_refresh_token(
    subject: Union[str, Any],
    role: Optional[str] = None,
    email: Optional[str] = None,
    business_id: Optional[str] = None,
    expires_delta: Optional[timedelta] = None,
) -> str:
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    
    to_encode = {
        "sub": str(subject),
        "user_id": str(subject),
        "role": role,
        "email": email,
        "business_id": business_id,
        "iat": int(now.timestamp()),
        "exp": expire,
        "type": "refresh",
    }
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def decode_token(token: str) -> Optional[dict]:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except jwt.PyJWTError:
        return None
