import time
import uuid
from datetime import datetime, timezone
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.database import Base, engine, run_migrations
from app.api.api import api_router
from app import models  # Ensures all models are registered

# Create database tables automatically and apply non-destructive schema migrations
Base.metadata.create_all(bind=engine)
run_migrations(engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    description="Mach-Hunt: AI-powered manufacturing capacity-sharing platform for MSMEs.",
)


@app.on_event("startup")
def startup_diagnostics():
    is_smtp_host = bool(settings.SMTP_HOST)
    is_user_set = bool(settings.SMTP_USER)
    is_pw_set = bool(settings.SMTP_PASSWORD and len(settings.SMTP_PASSWORD) > 0)
    is_sender_set = bool(settings.EMAIL_FROM)
    is_smtp_ready = is_smtp_host and is_user_set and is_pw_set and is_sender_set

    print("\n--- Mach-Hunt Configuration Diagnostics ---", flush=True)
    print(f"Auth Mode: {settings.AUTH_MODE.upper()} ({'Password Authentication active' if settings.AUTH_MODE == 'demo' else 'OTP Authentication active'})", flush=True)
    print(f"SMTP configured: {'true' if is_smtp_ready else 'false'}", flush=True)
    print(f"SMTP host: {settings.SMTP_HOST}", flush=True)
    print(f"SMTP username configured: {'true' if is_user_set else 'false'}", flush=True)
    print(f"SMTP password configured: {'true' if is_pw_set else 'false'}", flush=True)
    print(f"SMTP sender configured: {'true' if is_sender_set else 'false'}", flush=True)
    print("-------------------------------------------\n", flush=True)

    if settings.AUTH_MODE == "otp" and not is_smtp_ready and settings.EMAIL_PROVIDER == "smtp":
        print("[CONFIGURATION ERROR] OTP mode active with SMTP provider, but SMTP_PASSWORD is empty.", flush=True)
        print("                      Please set your 16-character Google App Password in .env as SMTP_PASSWORD=...", flush=True)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_origin_regex=settings.CORS_ORIGIN_REGEX,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_process_time_and_request_id(request: Request, call_next):
    request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    start_time = time.time()
    
    response: Response = await call_next(request)
    
    process_time = time.time() - start_time
    response.headers["X-Request-ID"] = request_id
    response.headers["X-Process-Time-Sec"] = f"{process_time:.4f}"
    return response


@app.get(f"{settings.API_V1_STR}/health", tags=["Health"])
def health_check():
    """Liveness probe and system health indicator."""
    return {
        "status": "healthy",
        "service": "Mach-Hunt API",
        "version": settings.VERSION,
        "database": "connected",
        "environment": settings.ENVIRONMENT,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


# Include unified API router
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/", tags=["Root"])
def root():
    return {
        "message": "Welcome to Mach-Hunt API",
        "docs": "/docs",
        "health": f"{settings.API_V1_STR}/health",
        "api_v1": settings.API_V1_STR,
    }
