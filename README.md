# Mach-Hunt — Production Application Specification & Guide

> **AI-Powered Manufacturing Capacity-Sharing Platform for MSMEs**  
> *Connecting Idle Manufacturing Machinery to Industrial Demand*

---

## 1. Product Purpose & Overview

Mach-Hunt is a production-ready, AI-driven manufacturing capacity-sharing platform engineered specifically for Micro, Small, and Medium Enterprises (MSMEs). 

Rather than functioning as a standard machinery rental marketplace, Mach-Hunt operates on the principle of **Capacity-as-a-Service**:

$$\text{Requirement} \longrightarrow \text{AI Interpretation} \longrightarrow \text{Capacity Matching} \longrightarrow \text{Comparison} \longrightarrow \text{Booking} \longrightarrow \text{Production} \longrightarrow \text{Completion} \longrightarrow \text{Rating}$$

### Capacity Provider (Machine Owner)
An MSME that owns capital-intensive manufacturing machinery (e.g., 3-Axis / 5-Axis CNC Milling, CNC Turning, Fiber Laser Cutting, Industrial Lathes, Fabrication, Welding) with idle hours between job runs. Providers list machinery, verify capabilities, manage hourly availability slots, and monetize excess production capacity.

### Capacity Seeker (Component Buyer)
An MSME or tier-2 supplier with component production requirements (e.g., "500 aluminium flange brackets within 4 days near Coimbatore"). Seekers submit technical specifications in plain English or structured parameters without needing to know specific machine models. Mach-Hunt discovers, ranks, and books verified capacity.

---

## 2. Technology Stack & Architecture

```text
mach-hunt/
├── frontend/                     # Flutter Cross-Platform Client (Web, Android, Desktop)
│   ├── lib/
│   │   ├── core/                 # Constants, Dio API client, token storage, themes, widgets
│   │   ├── models/               # Strongly-typed immutable JSON data models
│   │   ├── state/                # StateNotifiers (Auth, Provider, Seeker, Admin)
│   │   ├── router/               # GoRouter declarative navigation with shell routing
│   │   └── screens/              # Feature-based modular UI screens
│   ├── test/                     # Flutter widget and unit test suites
│   └── Dockerfile                # Multi-stage release build with Nginx
├── backend/                      # FastAPI Modular Production Backend
│   ├── app/
│   │   ├── core/                 # Config (Pydantic Settings), Bcrypt security, SQLAlchemy engine
│   │   ├── models/               # Normalized PostgreSQL database ORM entities
│   │   ├── schemas/              # Pydantic v2 validation and transfer schemas
│   │   ├── repositories/         # Database persistence layer (Repository Pattern)
│   │   ├── services/             # Business logic layer (Thin controllers)
│   │   ├── matching/             # 5-Component deterministic scoring & Haversine distance engine
│   │   ├── api/                  # Versioned REST routers (/api/v1/...)
│   │   ├── seed_data.py          # Development seed generator (realistic Tamil Nadu MSMEs)
│   │   └── main.py               # Production entrypoint with CORS, Request ID & Health probes
│   ├── tests/                    # Pytest test suite (11 comprehensive integration tests)
│   └── Dockerfile                # Production Python 3.11 image with healthcheck
├── docs/                         # Technical Architecture & API Documentation
│   ├── architecture.md           # System design, data flow diagrams & security architecture
│   ├── matching-engine.md        # Mathematical scoring formula & reason synthesis
│   ├── api.md                    # REST endpoint catalog & request/response schemas
│   └── deployment.md             # Production hosting, Docker & CI/CD deployment guide
├── docker-compose.yml            # Multi-container orchestration (PostgreSQL + Backend + Flutter)
├── .env.example                  # Environment configuration template
└── README.md
```

### Key Technologies
* **Frontend**: Flutter 3.41, Dart 3.11, Material 3, GoRouter, Dio (HTTP/2 with JWT interceptor), StateNotifier.
* **Backend**: Python 3.11+, FastAPI, SQLAlchemy 2.0 ORM, Pydantic v2, Bcrypt 5.0, PyJWT.
* **Database**: PostgreSQL 16 (production) with SQLite zero-setup dev fallback (`machhunt_v2.db`).
* **Security**: SHA-256 salted bcrypt password hashing, 60-min JWT access tokens with rotation, role-based authorization (`PROVIDER`, `SEEKER`, `ADMIN`).

---

## 3. Explainable 5-Component Matching Algorithm

The Mach-Hunt matching engine computes a deterministic, explainable percentage score for every candidate machine relative to an active requirement:

$$\text{Match Score} = (\text{Capability} \times 0.40) + (\text{Availability} \times 0.20) + (\text{Distance} \times 0.15) + (\text{Cost} \times 0.15) + (\text{Reliability} \times 0.10)$$

```text
┌────────────────────────────────────────────────────────────────────────────────┐
│                           5-COMPONENT SCORING ENGINE                           │
├─────────────────────┬────────┬─────────────────────────────────────────────────┤
│ Component           │ Weight │ Evaluation Logic                                │
├─────────────────────┼────────┼─────────────────────────────────────────────────┤
│ Capability Match    │  40%   │ Process exact match (0.50), Material supported │
│                     │        │ (0.25), Tolerance & envelope capacity (0.25)    │
├─────────────────────┼────────┼─────────────────────────────────────────────────┤
│ Availability Match  │  20%   │ Server-side slot checks before delivery deadline │
│                     │        │ (1.0 = available, 0.2 = limited, 0.0 = booked)  │
├─────────────────────┼────────┼─────────────────────────────────────────────────┤
│ Distance Score      │  15%   │ Haversine formula: 1.0 if ≤5km, decaying to 0.0 │
│                     │        │ if distance exceeds max search radius           │
├─────────────────────┼────────┼─────────────────────────────────────────────────┤
│ Cost Alignment      │  15%   │ Hourly rate × required hours vs seeker budget   │
│                     │        │ (1.0 = under budget, decays if over budget)     │
├─────────────────────┼────────┼─────────────────────────────────────────────────┤
│ MSME Reliability    │  10%   │ Historical rating (0.0 to 5.0) normalized       │
│                     │        │ + verified business & machine badges            │
└─────────────────────┴────────┴─────────────────────────────────────────────────┘
```

For every recommended machine, human-readable explainable reasons are generated:
* `✓ Capability matches requirement: CNC Milling in Aluminium 6061`
* `✓ Available capacity before target deadline (24 hrs open)`
* `✓ Located 4.2 km away in Ganapathy industrial area (within 50 km radius)`
* `✓ Within budget: ₹1,500/hr yields estimated ₹24,000 vs ₹25,000 budget`
* `✓ High MSME reliability: 4.9★ rating with 42 verified jobs completed`

---

## 4. End-to-End 8-State Booking Lifecycle

Mach-Hunt enforces a strict server-side state machine with escrow simulation:

```
[PENDING] ──── Provider Declines ────► [REJECTED]
    │
Provider Accepts
    ▼
[ACCEPTED] ─── Seeker Funds Escrow ──► [CONFIRMED] (Slots Locked)
                                            │
                                    Provider Starts Machine
                                            ▼
                                      [IN_PROGRESS]
                                            │
                                     Production Finished
                                            ▼
                                       [COMPLETED] (Escrow Released)
                                            │
                                     Review & Rating
                                            ▼
                                        [REVIEWED]
```

---

## 5. Pre-Seeded Development Accounts

To facilitate instant testing, realistic industrial MSMEs based in the **Coimbatore, Tamil Nadu manufacturing cluster** are pre-seeded:

| Persona | Name | Email | Password | Business Name | Machine Fleet |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Admin** | Pragatheswaran | `admin@machhunt.demo` | `password123` | Mach-Hunt Compliance Admin | Platform oversight |
| **Provider 1** | Janika | `janika@machhunt.demo` | `password123` | Kovai Precision Works | HAAS VF-2 VMC (3-Axis) |
| **Provider 2** | Senthil | `senthil@machhunt.demo` | `password123` | TexCity Laser & Fabrication | TRUMPF TruLaser 3030 Fiber |
| **Provider 3** | Murugan | `murugan@machhunt.demo` | `password123` | Annur Auto Components | Mazak Quick Turn 250 Lathe |
| **Seeker** | Karthikeyan | `karthikeyan@machhunt.demo` | `password123` | TamilTech Aerospace Subassemblies | Procurement |

---

## 6. Local Setup & Execution Guide

### Prerequisites
* **Python 3.10+** (tested on Python 3.11 & Python 3.14)
* **Flutter SDK 3.24+** (tested on Flutter 3.41 / Dart 3.11)
* **Docker & Docker Compose** (optional for containerized deployment)

### 1. Backend Setup & Run

```bash
# Navigate to backend directory
cd backend

# Install dependencies
pip install -r requirements.txt

# Run seed data script (populates SQLite/PostgreSQL with MSMEs, machines, and past reviews)
python -m app.seed_data

# Launch FastAPI development server with auto-reload
python -m uvicorn app.main:app --port 8000 --reload
```

* **Interactive API Documentation (Swagger)**: `http://localhost:8000/docs`
* **Alternative OpenAPI Redoc**: `http://localhost:8000/redoc`
* **System Health Liveness Probe**: `http://localhost:8000/api/v1/health`

### 2. Run Backend Pytest Suite

```bash
cd backend
python -m pytest tests/test_backend.py -v
```
*Executes 11 automated test suites covering Bcrypt hashing, JWT issuance/validation, Haversine geographic calculation, NLP requirement interpretation, machine catalog filters, 5-component matching engine, side-by-side comparison matrix, booking state machine transitions, and admin metrics.*

### 3. Frontend Setup & Run

```bash
# Navigate to frontend directory
cd frontend

# Install Flutter dependencies
flutter pub get

# Verify codebase health
flutter analyze

# Run Flutter tests
flutter test

# Run Flutter Web application
flutter run -d chrome
```

---

## 7. Multi-Container Docker Deployment

Run the entire production stack (PostgreSQL 16 + FastAPI + Flutter Web on Nginx):

```bash
# From repository root
docker-compose up --build
```

Services exposed:
* **Flutter Web Application**: `http://localhost:3000`
* **FastAPI Backend Server**: `http://localhost:8000`
* **PostgreSQL Database**: `localhost:5432`

---

## 8. Complete User Journey Walkthrough

1. **Sign In**: Launch Flutter app → Click quick-demo chip for **Karthikeyan (Seeker)**.
2. **AI Requirement**: Type `"Need 500 aluminium brackets, CNC machined, delivery within 4 days near Coimbatore, tolerance 0.05mm"` → Click **Interpret**.
3. **Verify AI Extraction**: Inspect parsed Process, Material, Quantity, and Budget → Click **Use & Create Requirement**.
4. **Discover Matches**: The 5-component algorithm ranks **Kovai Precision Works (HAAS VF-2)** at 95% match.
5. **Compare**: Check boxes on Kovai Precision and Annur Auto Components → Click **Compare (2)** to benchmark tolerances and hourly rates side-by-side.
6. **Request Booking**: Click **Request Booking** → Select dates (16 hours) → Send request.
7. **Provider Acceptance**: Sign in as **Janika (Provider)** → View **Incoming Bookings** → Click **Accept Order**.
8. **Escrow Guarantee**: Sign back in as **Karthikeyan** → Click **Lock & Deposit Escrow** (₹24,000 + 5% platform fee).
9. **Production & Delivery**: Janika starts machine (**In Production**) → Job completes.
10. **Review**: Karthikeyan submits 5-star rating with quality feedback.
11. **Admin Oversight**: Sign in as **Pragatheswaran (Admin)** → View real-time platform GMV updates, completed job counts, and verification queue.

---

## 9. Security & Production Standards

* **No Hardcoded Credentials**: Configured via `.env` with Pydantic Settings validation.
* **SQL Injection Prevention**: 100% parameterized queries via SQLAlchemy 2.0 ORM.
* **Double Booking Prevention**: Checked server-side at database transaction level.
* **Audit Trail**: Every verification and state transition logged to `audit_logs` table.
* **CORS & Headers**: Production headers with unique `X-Request-ID` and execution timing.

---

## 10. License

Mach-Hunt is licensed under the Apache 2.0 License.
