import os
from typing import List, Union
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import AnyHttpUrl, field_validator, Field, AliasChoices


class Settings(BaseSettings):
    PROJECT_NAME: str = "Mach-Hunt API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True

    # Security
    SECRET_KEY: str = "machhunt-super-secret-key-change-in-production-minimum-32-chars-long"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 day
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Database
    # Support SQLite out-of-the-box for seamless testing and PostgreSQL in production
    DATABASE_URL: str = "sqlite:///./machhunt_v2.db"

    # AI Configuration
    AI_PROVIDER: str = "rule_based"  # or 'gemini', 'openai'
    AI_API_KEY: str = ""

    # Payment Configuration
    PAYMENT_PROVIDER: str = "escrow_simulated"
    PAYMENT_SECRET: str = "simulated_escrow_secret_key"

    # Auth Mode: 'demo' (Email + Password) or 'otp' (Email OTP passwordless)
    AUTH_MODE: str = Field(default="demo", validation_alias=AliasChoices("AUTH_MODE"))

    # Email & Passwordless OTP Authentication
    EMAIL_PROVIDER: str = "development"  # 'development', 'smtp', 'resend', 'sendgrid'
    EMAIL_MODE: str = "development"      # 'development', 'production'
    EMAIL_API_KEY: str = ""
    EMAIL_FROM: str = Field(default="machhunt2212@gmail.com", validation_alias=AliasChoices("EMAIL_FROM", "SMTP_FROM_EMAIL"))
    EMAIL_FROM_NAME: str = "Mach-Hunt"

    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = Field(default="machhunt2212@gmail.com", validation_alias=AliasChoices("SMTP_USER", "SMTP_USERNAME"))
    SMTP_PASSWORD: str = ""
    SMTP_TLS: bool = Field(default=True, validation_alias=AliasChoices("SMTP_TLS", "SMTP_USE_TLS"))

    OTP_LENGTH: int = 6
    OTP_EXPIRY_MINUTES: int = 5
    OTP_EXPIRY_SECONDS: int = 300
    OTP_RESEND_COOLDOWN_SECONDS: int = 60
    OTP_MAX_ATTEMPTS: int = 5
    OTP_MAX_REQUESTS_PER_HOUR: int = 5

    @property
    def SMTP_USERNAME(self) -> str:
        return self.SMTP_USER

    @property
    def SMTP_FROM_EMAIL(self) -> str:
        return self.EMAIL_FROM

    @property
    def SMTP_USE_TLS(self) -> bool:
        return self.SMTP_TLS

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8000",
        "http://localhost:5173",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
        "http://127.0.0.1:5173",
    ]
    CORS_ORIGIN_REGEX: str = r"^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$"

    model_config = SettingsConfigDict(
        case_sensitive=True,
        env_file=".env",
        extra="allow",
    )


settings = Settings()
