# Mach-Hunt: REST API Specification (OpenAPI v3 Aligned)

**Base URL**: `/api/v1`  
**Authentication Header**: `Authorization: Bearer <access_token>`

---

## 1. Authentication Endpoints (`/api/v1/auth`)

| Method | Endpoint | Description | Auth Required | Request Body / Params | Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/auth/register` | Register new user account | None | `UserCreateSchema` (email, password, full_name, phone, role) | `201 Created`: User profile + Token pair |
| `POST` | `/auth/login` | Authenticate with email/password | None | `OAuth2PasswordRequestForm` or `LoginSchema` | `200 OK`: Access & Refresh tokens |
| `POST` | `/auth/refresh` | Refresh expired access token | None | `TokenRefreshSchema` (refresh_token) | `200 OK`: New Access token |
| `GET` | `/auth/me` | Fetch active user session | Bearer | None | `200 OK`: `UserOutSchema` with linked business |
| `POST` | `/auth/logout` | Revoke current token | Bearer | None | `200 OK`: `{ message: "Logged out" }` |

---

## 2. Business Profile Endpoints (`/api/v1/businesses`)

| Method | Endpoint | Description | Auth Required | Request Body / Params | Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/businesses` | Create / Register MSME profile | Bearer | `BusinessCreateSchema` (name, gstin, phone, address, district, state, lat, lng, etc.) | `201 Created`: `BusinessOutSchema` |
| `GET` | `/businesses/me` | Get authenticated user's business | Bearer | None | `200 OK`: `BusinessOutSchema` |
| `PUT` | `/businesses/me` | Update business profile | Bearer | `BusinessUpdateSchema` | `200 OK`: `BusinessOutSchema` |
| `GET` | `/businesses/{id}` | Public business profile | None / Optional | Path `id: UUID` | `200 OK`: Public Business Details + Ratings |
| `POST` | `/businesses/documents` | Upload verification document | Bearer | Multipart: `file`, `document_type` | `201 Created`: `DocumentOutSchema` |

---

## 3. Machine Management Endpoints (`/api/v1/machines`)

| Method | Endpoint | Description | Auth Required | Request Body / Params | Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/machines` | List new machine | Bearer (Provider) | `MachineCreateSchema` (name, category, processes, materials, hourly_rate, tolerances, etc.) | `201 Created`: `MachineOutSchema` |
| `GET` | `/machines` | Search and filter machines | None / Optional | Query: `process, material, district, max_rate, verified_only` | `200 OK`: Paginated `MachineOutSchema[]` |
| `GET` | `/machines/my` | Get current provider's machines | Bearer (Provider) | None | `200 OK`: `MachineOutSchema[]` |
| `GET` | `/machines/{id}` | Machine details with capabilities | None / Optional | Path `id: UUID` | `200 OK`: `MachineDetailSchema` |
| `PUT` | `/machines/{id}` | Update machine specifications | Bearer (Provider) | `MachineUpdateSchema` | `200 OK`: `MachineOutSchema` |
| `DELETE` | `/machines/{id}` | Deactivate machine | Bearer (Provider) | Path `id: UUID` | `200 OK`: Status code / soft delete |
| `POST` | `/machines/{id}/availability` | Define operational schedule / blocked slots | Bearer (Provider) | `AvailabilityBatchSchema` (dates, hours, is_available, reason) | `200 OK`: Updated availability calendar |
| `GET` | `/machines/{id}/availability` | Retrieve machine availability calendar | None / Optional | Query: `start_date, end_date` | `200 OK`: `AvailabilitySlotSchema[]` |

---

## 4. Manufacturing Requirements & AI Endpoints (`/api/v1/requirements`)

| Method | Endpoint | Description | Auth Required | Request Body / Params | Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/requirements/parse-nl` | AI natural language requirement parser | Bearer (Seeker) | `{ prompt: string }` | `200 OK`: `InterpretedRequirementSchema` (Pydantic validated) |
| `POST` | `/requirements` | Create structured manufacturing requirement | Bearer (Seeker) | `RequirementCreateSchema` (title, process, material, quantity, deadline, location, budget) | `201 Created`: `RequirementOutSchema` |
| `GET` | `/requirements/my` | Get current seeker's requirements | Bearer (Seeker) | None | `200 OK`: `RequirementOutSchema[]` |
| `GET` | `/requirements/{id}` | Requirement details + attachments | Bearer | Path `id: UUID` | `200 OK`: `RequirementDetailSchema` |
| `POST` | `/requirements/{id}/attachments` | Upload technical drawings (CAD/PDF/Image) | Bearer (Seeker) | Multipart: `file` | `201 Created`: `AttachmentOutSchema` |

---

## 5. Capacity Matching & Comparison Endpoints (`/api/v1/matches`)

| Method | Endpoint | Description | Auth Required | Request Body / Params | Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/matches/requirement/{req_id}` | Generate and fetch ranked capacity recommendations | Bearer (Seeker) | Path `req_id: UUID` | `200 OK`: `MatchResultSchema[]` with transparent score breakdowns |
| `POST` | `/matches/compare` | Side-by-side comparison matrix | Bearer | `{ machine_ids: UUID[], requirement_id: UUID }` | `200 OK`: `ComparisonMatrixSchema` (Rates, Distances, Precision, Capabilities) |

---

## 6. Booking & Escrow Lifecycle Endpoints (`/api/v1/bookings`)

| Method | Endpoint | Description | Auth Required | State Transition | Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/bookings` | Request capacity booking | Bearer (Seeker) | $\to$ `PENDING` | `201 Created`: `BookingOutSchema` |
| `GET` | `/bookings/my` | List current user's bookings | Bearer | None | `200 OK`: `BookingOutSchema[]` |
| `GET` | `/bookings/{id}` | Detailed booking inspection | Bearer | None | `200 OK`: `BookingDetailSchema` |
| `POST` | `/bookings/{id}/accept` | Provider accepts capacity request | Bearer (Provider) | `PENDING` $\to$ `ACCEPTED` | `200 OK`: `BookingOutSchema` |
| `POST` | `/bookings/{id}/reject` | Provider declines capacity request | Bearer (Provider) | `PENDING` $\to$ `REJECTED` | `200 OK`: `BookingOutSchema` |
| `POST` | `/bookings/{id}/confirm` | Seeker authorizes escrow hold | Bearer (Seeker) | `ACCEPTED` $\to$ `CONFIRMED` | `200 OK`: `BookingOutSchema` + Payment Record |
| `POST` | `/bookings/{id}/start` | Provider commences manufacturing | Bearer (Provider) | `CONFIRMED` $\to$ `IN_PROGRESS` | `200 OK`: `BookingOutSchema` |
| `POST` | `/bookings/{id}/complete` | Seeker / Provider confirms delivery | Bearer | `IN_PROGRESS` $\to$ `COMPLETED` | `200 OK`: Triggers escrow release |
| `POST` | `/bookings/{id}/cancel` | Cancel booking | Bearer | $\to$ `CANCELLED` | `200 OK`: Cancellation status |

---

## 7. Payments & In-App Reviews (`/api/v1/payments`, `/api/v1/reviews`)

| Method | Endpoint | Description | Auth Required | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/payments/booking/{booking_id}` | Check escrow payment details | Bearer | `200 OK`: `PaymentOutSchema` (Escrow status, fees, payout) |
| `POST` | `/payments/create-intent` | Initialize payment intent adapter | Bearer | `200 OK`: `PaymentIntentOutSchema` |
| `POST` | `/reviews` | Submit post-job rating and review | Bearer | `201 Created`: `ReviewOutSchema` |
| `GET` | `/reviews/business/{biz_id}` | List verified reviews for MSME | None / Optional | `200 OK`: `ReviewOutSchema[]` |

---

## 8. Notifications & Admin Oversight (`/api/v1/notifications`, `/api/v1/admin`)

| Method | Endpoint | Description | Auth Required | Response |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/notifications` | List user in-app notifications | Bearer | `200 OK`: `NotificationOutSchema[]` |
| `PUT` | `/notifications/{id}/read` | Mark notification read | Bearer | `200 OK`: `{ is_read: true }` |
| `GET` | `/admin/metrics` | Platform overview (MSMEs, Machines, GMV, Success) | Admin | `200 OK`: `AdminMetricsSchema` |
| `GET` | `/admin/verifications` | Pending verification queue | Admin | `200 OK`: `VerificationQueueSchema[]` |
| `POST` | `/admin/businesses/{id}/verify` | Approve / Reject MSME registration | Admin | `200 OK`: Updated business status |
| `POST` | `/admin/machines/{id}/verify` | Verify machine listing | Admin | `200 OK`: Updated machine status |
| `GET` | `/admin/audit-logs` | Tamper-evident administrative audit trail | Admin | `200 OK`: `AuditLogSchema[]` |
