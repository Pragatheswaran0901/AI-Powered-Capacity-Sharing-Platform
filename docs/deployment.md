# Mach-Hunt: Deployment & DevOps Guide

## 1. Container Architecture

Mach-Hunt provides multi-container orchestration via `docker-compose.yml` for unified local staging and production deployment:

- **Database**: PostgreSQL 16 Alpine with persistent volume mount (`postgres_data`).
- **Backend**: Python 3.11/3.14 slim container running FastAPI via Uvicorn with auto-workers.
- **Frontend**: Flutter Web served via Nginx with TLS or compiled Android APK.

---

## 2. Environment Configuration Matrix (`.env`)

```ini
# --- Core Environment ---
ENVIRONMENT=production
DEBUG=false
PROJECT_NAME="Mach-Hunt API"
API_V1_STR=/api/v1

# --- Security & Secrets ---
SECRET_KEY=generate_with_openssl_rand_hex_32
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=7

# --- Database Credentials ---
POSTGRES_SERVER=db
POSTGRES_PORT=5432
POSTGRES_DB=machhunt
POSTGRES_USER=machhunt_user
POSTGRES_PASSWORD=secure_production_password_here
DATABASE_URL=postgresql://machhunt_user:secure_production_password_here@db:5432/machhunt

# --- AI Natural Language Parsing ---
AI_PROVIDER=gemini # or openai / local
AI_API_KEY=your_gemini_api_key_or_empty_for_rule_engine

# --- Payment Adapter ---
PAYMENT_PROVIDER=escrow_simulated # or razorpay / stripe
PAYMENT_SECRET=your_payment_webhook_secret

# --- Storage Configuration ---
STORAGE_PROVIDER=local # or s3 / gcs
UPLOAD_DIR=/app/uploads
MAX_FILE_SIZE_MB=10

# --- CORS & Hosts ---
BACKEND_CORS_ORIGINS=["http://localhost:3000","http://localhost:8000","https://machhunt.yourdomain.com"]
```

---

## 3. Database Migration & Initialization

Apply schema migrations using Alembic or standard declarative sync:

```bash
# Execute Alembic schema upgrades
docker-compose exec backend alembic upgrade head

# Run development/staging seed script
docker-compose exec backend python -m app.seed_data
```

---

## 4. Production Health Checks & Observability

- **API Liveness Probe**: `GET /api/v1/health`  
  Returns:
  ```json
  {
    "status": "healthy",
    "database": "connected",
    "version": "1.0.0",
    "timestamp": "2026-09-26T15:00:00Z"
  }
  ```
- **Structured JSON Logging**: Every incoming request is decorated with `X-Request-ID` and logged with response status, latency in milliseconds, and client IP address.

---

## 5. Flutter Compilation & Build Commands

### 5.1 Flutter Web Production Build
```bash
cd frontend
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://api.machhunt.yourdomain.com/api/v1
```
The compiled output in `build/web/` can be served via Nginx or any CDN.

### 5.2 Flutter Android Release APK
```bash
cd frontend
flutter build apk --release --dart-define=API_BASE_URL=https://api.machhunt.yourdomain.com/api/v1
```
Resulting APK: `build/app/outputs/flutter-apk/app-release.apk`
