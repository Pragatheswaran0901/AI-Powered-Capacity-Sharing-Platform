# Mach-Hunt: System Architecture Specification

## 1. Executive Summary & Product Vision

**Mach-Hunt** is a production-grade, AI-powered manufacturing capacity-sharing platform designed for Micro, Small, and Medium Enterprises (MSMEs). Unlike traditional machine rental marketplaces or static directories, Mach-Hunt is **requirement-centric**:

$$\text{REQUIREMENT} \longrightarrow \text{AI INTERPRETATION} \longrightarrow \text{CAPACITY DISCOVERY} \longrightarrow \text{EXPLAINABLE MATCHING} \longrightarrow \text{SIDE-BY-SIDE COMPARISON} \longrightarrow \text{ESCROW BOOKING} \longrightarrow \text{PRODUCTION LIFECYCLE} \longrightarrow \text{RATING \& TRUST}$$

Manufacturing MSMEs who have idle equipment (Providers) list machine specifications, operational limits, verified certifications, and calendar availability. MSMEs needing capacity (Seekers) post requirements in plain English or structured parameters. The platform calculates deterministic match scores across capability, availability, distance, cost, and reliability, facilitating seamless end-to-end execution.

---

## 2. High-Level Architecture Diagram

```mermaid
graph TB
    subgraph Client Layer ["Client Tier (Flutter Material 3)"]
        F_Auth["Auth & Session\n(JWT / Refresh Storage)"]
        F_Provider["Provider Portal\n(Machines, Availability, Requests)"]
        F_Seeker["Seeker Portal\n(NLP Prompt, Matches, Bookings)"]
        F_Admin["Admin Console\n(Verification, Audits, Analytics)"]
    end

    subgraph Network Layer ["Transport & API Gateway"]
        DioClient["Dio HTTP Client\n(Auth Interceptor, Retry, Token Refresh)"]
        REST["REST API over TLS\n(CORS, Rate Limiting, Request ID)"]
    end

    subgraph Backend Layer ["FastAPI Application (Clean Architecture)"]
        Routers["Thin API Routers\n(/auth, /businesses, /machines, /requirements, /matches, /bookings, /reviews, /admin)"]
        Security["Core Security\n(OAuth2 Password Bearer, Passlib Bcrypt, JWT Validator)"]
        
        subgraph Services ["Service Layer (Business Logic)"]
            AuthSvc["Auth Service"]
            BizSvc["Business Service"]
            MachSvc["Machine & Capability Service"]
            AvailSvc["Availability Engine"]
            ReqSvc["Requirement Service"]
            AISvc["AI Natural Language Interpreter"]
            MatchSvc["Deterministic Matching Engine"]
            BookSvc["Booking State Machine"]
            PaySvc["Payment & Escrow Adapter"]
            ReviewSvc["Review & Trust Scorer"]
            NotifSvc["In-App Notification Hub"]
        end

        subgraph Repositories ["Repository Layer (Data Access Pattern)"]
            UserRepo["User & Auth Repo"]
            BizRepo["Business Repo"]
            MachRepo["Machine & Availability Repo"]
            ReqRepo["Requirement Repo"]
            BookRepo["Booking & Escrow Repo"]
            AuditRepo["Audit Log Repo"]
        end
    end

    subgraph Data Layer ["Storage & Persistence"]
        Postgres[(PostgreSQL 16\nNormalized Schema, Foreign Keys, GiST/B-tree Indexes)]
        FileStore["Secure File Storage\n(CAD/Technical Drawings, Verifications)"]
    end

    Client Layer --> DioClient
    DioClient --> REST
    REST --> Routers
    Routers --> Security
    Routers --> Services
    Services --> Repositories
    Repositories --> Postgres
    Services --> FileStore
```

---

## 3. Technology Stack Justification

| Layer | Technology | Version | Architectural Rationale |
| :--- | :--- | :--- | :--- |
| **Frontend** | Flutter / Dart | Flutter 3.41+ / Dart 3.11+ | Single codebase for cross-platform (Web & Android/iOS) B2B experience. Material 3 design, deterministic typed state management, declarative routing, and offline-tolerant token persistence. |
| **API Framework** | FastAPI | 0.110+ / 0.141+ | High throughput async Python, native OpenAPI v3 documentation, Pydantic v2 data validation, and dependency injection for security/DB sessions. |
| **Persistence** | PostgreSQL | 15 / 16 | ACID-compliant transactional consistency, native UUID primary keys, JSONB for extensible machine operating parameters, and spatial coordinate queries. |
| **ORM / Migration** | SQLAlchemy 2.0 / Alembic | 2.0+ / 1.13+ | Modern Declarative 2.0 mapped models, strict relationship cascades, typed repository queries, and reversible schema migration history. |
| **Security** | Passlib (Bcrypt) + PyJWT | Passlib 1.7.4 / PyJWT 2.8+ | Standard password hashing with salted cost factors, short-lived JWT access tokens (30 min) and rotating refresh tokens (7 days). |
| **AI Interpretation** | Dual-Mode NLP Engine | Regex/Rule NLP + LLM Adapter | Resilient offline-first fallback parser using token extraction combined with Gemini/OpenAI cloud provider adapter for unstructured natural language prompts. |

---

## 4. Layer Responsibilities & Separation of Concerns

### 4.1 Client Layer (Flutter)
- **Zero Business Logic in Widgets**: Presentation widgets only emit user intents to State Providers and render immutable UI state.
- **Feature-Driven Directory Structure**:
  - `core/`: Network clients, token interceptors, theme tokens, formatters, and reusable atomic UI components.
  - `features/{auth, business, machines, requirements, matching, bookings, reviews, notifications, admin}/`:
    - `data/`: Remote API datasources and entity serialization.
    - `models/`: Immutable Dart data classes.
    - `presentation/`: Responsive screens, cards, modals, and input forms.
    - `state/`: Riverpod / ChangeNotifier state controllers handling async states (`loading`, `data`, `error`).

### 4.2 Backend API Routers (`app/api/`)
- Thin controllers containing zero direct database queries or mathematical scoring logic.
- Sole responsibilities:
  1. Receive HTTP request and parse Pydantic schema.
  2. Enforce authentication and role dependencies (`get_current_user`, `require_role`).
  3. Invoke the designated Service method.
  4. Return typed response schema with standardized HTTP status codes.

### 4.3 Service Layer (`app/services/`)
- Encapsulates all domain rules, state transitions, validation, and third-party interactions.
- Examples:
  - `AvailabilityService`: Verifies that a machine has not been booked for the requested timeframe and computes available slots without client-side trusting.
  - `BookingService`: Executes strict state transitions (`PENDING -> ACCEPTED -> CONFIRMED -> IN_PROGRESS -> COMPLETED`) and ensures escrow payment creation.
  - `MatchingService`: Gathers candidate machines, applies geographic filtering, computes sub-scores, and generates human-readable match explanations.

### 4.4 Repository Layer (`app/repositories/`)
- Abstracts all SQLAlchemy session handling.
- Performs atomic transactions, eager loading of relationships (`joinedload`), pagination, and filter queries.
- Prevents database-specific ORM leakage into business logic.

---

## 5. Security & Governance

1. **Authentication & Session Management**:
   - Access tokens signed with `HS256`, containing user ID, role, and business ID.
   - Refresh tokens stored with one-time revocation tracking.
2. **Role-Based Access Control (RBAC)**:
   - `PROVIDER`: Can manage owned machines, toggle availability, respond to capacity requests.
   - `SEEKER`: Can submit requirements, run matching, initiate bookings, submit reviews.
   - `ADMIN`: Global verification approval/rejection, dispute resolution, audit oversight.
   - *Dual-Role Support*: A business entity can act as both provider and seeker through active persona switching.
3. **Double-Booking Prevention**:
   - Database-level isolation and atomic lock checks during booking creation:
   ```sql
   SELECT id FROM machine_availabilities 
   WHERE machine_id = :mid AND date = :bdate 
     AND is_available = FALSE 
   FOR UPDATE;
   ```
4. **Input Sanitization & Injection Prevention**:
   - All database queries parameterized via SQLAlchemy ORM.
   - File uploads validated against magic bytes, strict MIME types (PDF, PNG, JPG, STEP/DWG), and 10MB size limits.
