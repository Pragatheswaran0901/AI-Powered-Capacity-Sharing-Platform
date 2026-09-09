import os

try:
    from pydantic_settings import BaseSettings
    class Settings(BaseSettings):
        PROJECT_NAME: str = "Mach-Hunt"
        VERSION: str = "1.0.0"
        API_PREFIX: str = "/api"
        SECRET_KEY: str = "machhunt_secret_key_tamil_nadu_2026_super_secure_demo"
        ALGORITHM: str = "HS256"
        ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7
        DATABASE_URL: str = "sqlite:///./machhunt.db"
        
        class Config:
            env_file = ".env"
            extra = "allow"
except ImportError:
    class Settings:
        PROJECT_NAME: str = "Mach-Hunt"
        VERSION: str = "1.0.0"
        API_PREFIX: str = "/api"
        SECRET_KEY: str = os.getenv("SECRET_KEY", "machhunt_secret_key_tamil_nadu_2026_super_secure_demo")
        ALGORITHM: str = "HS256"
        ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7
        DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./machhunt.db")

settings = Settings()
