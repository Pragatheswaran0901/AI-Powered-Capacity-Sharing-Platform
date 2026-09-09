# Mach-Hunt 🚀

> **From Idle Machines to Shared Manufacturing Capacity**

Mach-Hunt is an AI-assisted MSME manufacturing capacity-sharing platform focused on **Tamil Nadu, India** (Coimbatore Industrial Cluster Pilot). It connects manufacturing MSMEs that own machinery with unused capacity (Machine Owners / Providers) to MSMEs requiring manufacturing capacity (Machine Seekers).

---

## 1. Problem & Solution

### The Problem
* **Machine Owners**: Own expensive CNC, VMC, Lathe, Laser, or Welding machines that sit idle for 8+ hours a day, leading to lost ROI and unmonetized overhead.
* **Machine Seekers**: Face sudden order spikes or lack specific high-precision machinery, resulting in rejected orders or unnecessary capital expenditure.

### The Solution
Mach-Hunt provides **Manufacturing Capacity-as-a-Service**:
> *"We don't just help MSMEs find machines. We help them find the right manufacturing capacity."*

---

## 2. Key Features

1. **Smart Capacity Matching Engine**:
   Evaluates machines using a transparent weighted scoring formula:
   $$\text{Match Score} = \text{Capability (40\%)} + \text{Availability (20\%)} + \text{Distance (15\%)} + \text{Cost (15\%)} + \text{Reliability (10\%)}$$
2. **Natural Language Requirement Assistant**:
   Extracts process, material, quantity, deadline, and target city from prompts like:
   > *"I need 500 aluminium brackets machined within 3 days in Coimbatore with ₹25,000 budget."*
3. **Side-by-Side Machine Comparison Tool**:
   Compare 2–3 capacity options on hourly rates, location distance (km), ratings, and verification status.
4. **Tamil Nadu & Coimbatore Map View**:
   Interactive map pins across Coimbatore, Chennai, Hosur, Salem, Tiruppur, Erode, Madurai, and Trichy.
5. **End-to-End Booking & Escrow Workflow**:
   Requirement submission → Capacity matching → Request booking → Owner acceptance → Confirmed → Job completion → Rating & review.
6. **Role-Based Portals**:
   * **Seeker**: Create requirements, view recommendations, compare, book, rate.
   * **Owner**: Machine inventory, available hours, earnings tracking, accept/decline requests.
   * **Admin**: Verification queue (Approve/Reject MSMEs & machines), GMV analytics, platform revenue.
7. **Phase 2 IoT Hardware Sensor Roadmap**:
   Simulated telemetry drawer showcasing ESP32 microcontrollers with CT current transformers and ADXL345 vibration sensors for live active hour tracking.

---

## 3. Demo Credentials

Evaluators can test the prototype immediately using these pre-seeded demo accounts:

| Role | Name | Email | Password | Company |
| :--- | :--- | :--- | :--- | :--- |
| **Admin** | Pragatheswaran | `admin@machhunt.demo` | `password123` | Mach-Hunt Admin |
| **Machine Owner** | Janika | `janika@machhunt.demo` | `password123` | Kovai Precision Works |
| **Machine Seeker** | Karthikeyan | `karthikeyan@machhunt.demo` | `password123` | TamilTech Components |

---

## 4. Critical Demo Flow (Evaluator Walkthrough)

1. **Login as Karthikeyan (Seeker)**:
   * View active requirement: *"500 Aluminium Components, CNC Milling, Coimbatore"*.
   * Mach-Hunt matching engine displays **Janika — Kovai Precision Works** at **95% Match** (4.2 km away).
   * Click **"95% Match"** chip to inspect transparent score breakdown.
   * Click **"Compare"** to view side-by-side comparison matrix against other CNC providers.
   * Click **"Book Capacity"** → Authorize escrow payment.
2. **Switch to Janika (Owner)**:
   * View **"Incoming Capacity Requests"** on Owner Dashboard.
   * Click **"Accept Request"** → Status becomes **Confirmed**.
3. **Switch back to Karthikeyan (Seeker)**:
   * Navigate to **Bookings** → Click **"Mark Production Complete"**.
   * Submit a **5-Star Rating & Review**.
4. **Switch to Pragatheswaran (Admin)**:
   * Open **Admin Dashboard** → See real-time metrics update for total GMV, platform revenue (5%), and completed jobs.

---

## 5. Technology Stack

* **Frontend**: React.js + TypeScript, Vite, Tailwind CSS, Lucide Icons, Leaflet Maps.
* **Backend**: Python 3.10+, FastAPI, SQLAlchemy ORM, Pydantic v2, PyJWT.
* **Database**: SQLite (`machhunt.db` default for zero-setup instant local running) & PostgreSQL supported via `DATABASE_URL`.

---

## 6. How to Run Locally

### Prerequisites
* Python 3.10+
* Node.js v18+ & npm

### 1. Run Backend
```bash
cd backend
py -m pip install -r requirements.txt
py -m app.seed_data
py -m uvicorn app.main:app --port 8000 --reload
```
API Documentation will be available at: `http://localhost:8000/docs`

### 2. Run Frontend
```bash
cd frontend
npm install
npm run dev
```
Application will be live at: `http://localhost:3000`

---

## 7. Limitations & Demo Disclaimer

* **Fictional Demo Data**: All company names, personal names, phone numbers, and addresses are fictional representation of Tamil Nadu manufacturing clusters.
* **Phase 2 IoT Integration**: IoT sensor monitoring (ESP32) is simulated in Phase 2 drawer modal.

---

*Mach-Hunt — Access manufacturing capacity when you need it.*
