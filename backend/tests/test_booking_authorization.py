import pytest
import random
from datetime import date, timedelta
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_booking_authorization_cross_account_and_security():
    """
    Direct verification of Sections 11 & 12 of the Mach-Hunt specification:
    - Normal cross-account booking flow (Seeker Pragatheswaran books Provider Janika's CNC)
    - Booking lifecycle (Pending -> Accepted -> Confirmed)
    - Security rejection: User A cannot book for User B's requirement (HTTP 403)
    """

    # -------------------------------------------------------------------------
    # SETUP: Authenticate Janika and Pragatheswaran
    # -------------------------------------------------------------------------
    resp_janika = client.post("/api/v1/auth/login", json={"email": "janika@machhunt.demo", "password": "password123"})
    assert resp_janika.status_code == 200
    janika_token = resp_janika.json()["access_token"]
    janika_id = resp_janika.json()["user_id"]
    janika_headers = {"Authorization": f"Bearer {janika_token}"}

    resp_praga = client.post("/api/v1/auth/login", json={"email": "pragatheswaran@machhunt.demo", "password": "password123"})
    assert resp_praga.status_code == 200
    praga_token = resp_praga.json()["access_token"]
    praga_id = resp_praga.json()["user_id"]
    praga_headers = {"Authorization": f"Bearer {praga_token}"}

    # -------------------------------------------------------------------------
    # TEST A: Verify Janika's CNC machine in Coimbatore
    # -------------------------------------------------------------------------
    janika_machs = client.get("/api/v1/machines/my", headers=janika_headers).json()
    assert len(janika_machs) > 0, "Janika must have registered capacity"
    haas_cnc = next((m for m in janika_machs if "HAAS" in m["name"] or "CNC" in m["category"] or "VMC" in m["category"]), janika_machs[0])
    target_machine_id = haas_cnc["id"]

    # -------------------------------------------------------------------------
    # TEST B: Pragatheswaran creates requirement: 500 aluminium brackets in Coimbatore
    # -------------------------------------------------------------------------
    detail = client.get(f"/api/v1/machines/{target_machine_id}").json()
    avs = detail.get("availabilities", [])
    blocked = {a["date"] for a in avs if not a.get("is_available", True) or a.get("booking_id")}
    valid_slots = [
        date.fromisoformat(a["date"])
        for a in avs
        if a.get("is_available", True)
        and not a.get("booking_id")
        and a["date"] not in blocked
        and date.fromisoformat(a["date"]) >= date.today()
    ]
    valid_slots.sort()
    slot_date = valid_slots[0] if valid_slots else date.today() + timedelta(days=20)

    req_payload = {
        "title": "500 aluminium brackets",
        "description": "500 units CNC machining in Coimbatore for aerospace mounting assemblies.",
        "process": "CNC Milling",
        "material": "Aluminium 6061",
        "quantity": 500,
        "required_date": str(slot_date),
        "delivery_deadline": str(slot_date + timedelta(days=5)),
        "preferred_location": "Coimbatore",
        "budget": 28000.0,
        "operator_required": True,
    }
    create_resp = client.post("/api/v1/requirements/", json=req_payload, headers=praga_headers)
    assert create_resp.status_code == 201, f"Failed to create requirement: {create_resp.text}"
    req_data = create_resp.json()
    praga_req_id = req_data["id"]
    assert req_data["seeker_id"] == praga_id, "Requirement seeker_id must match authenticated Pragatheswaran ID"

    # -------------------------------------------------------------------------
    # TEST C: Pragatheswaran books Janika's CNC capacity
    # Expected: HTTP 201, NOT 403
    # -------------------------------------------------------------------------
    booking_payload = {
        "requirement_id": praga_req_id,
        "machine_id": target_machine_id,
        "start_date": str(slot_date),
        "end_date": str(slot_date),
        "total_hours": 6.0,
        "notes": "Booked directly via Seeker Capacity Discovery Workspace."
    }
    booking_resp = client.post("/api/v1/bookings/", json=booking_payload, headers=praga_headers)
    assert booking_resp.status_code == 201, f"Booking failed with status {booking_resp.status_code}: {booking_resp.text}"
    booking_data = booking_resp.json()
    booking_id = booking_data["id"]

    # -------------------------------------------------------------------------
    # TEST D: Verify booking database record relationships
    # -------------------------------------------------------------------------
    assert booking_data["seeker_id"] == praga_id, "booking.seeker must be Pragatheswaran"
    assert booking_data["provider_id"] == janika_id, "booking.provider must be Janika"
    assert booking_data["machine_id"] == target_machine_id, "booking.machine must be Janika's CNC"
    assert booking_data["requirement_id"] == praga_req_id, "booking.requirement must be Pragatheswaran's requirement"
    assert booking_data["status"] == "PENDING"

    # -------------------------------------------------------------------------
    # TEST E: Janika views incoming request and accepts
    # -------------------------------------------------------------------------
    janika_requests = client.get("/api/v1/bookings/my", headers=janika_headers).json()
    assert any(b["id"] == booking_id for b in janika_requests), "Janika must see Pragatheswaran's booking request"

    accept_resp = client.post(f"/api/v1/bookings/{booking_id}/accept", headers=janika_headers)
    assert accept_resp.status_code == 200, f"Accept failed: {accept_resp.text}"
    assert accept_resp.json()["status"] == "ACCEPTED"

    # -------------------------------------------------------------------------
    # TEST F: Pragatheswaran confirms escrow -> booking confirmed
    # -------------------------------------------------------------------------
    confirm_resp = client.post(f"/api/v1/bookings/{booking_id}/confirm", headers=praga_headers)
    assert confirm_resp.status_code == 200, f"Confirm failed: {confirm_resp.text}"
    assert confirm_resp.json()["status"] == "CONFIRMED"

    # -------------------------------------------------------------------------
    # SECTION 12: SECURITY AUTHORIZATION REJECTION TEST
    # Janika attempts to book capacity for Pragatheswaran's requirement
    # Expected: HTTP 403 Forbidden with exact message
    # -------------------------------------------------------------------------
    tampered_booking_payload = {
        "requirement_id": praga_req_id,  # Owned by Pragatheswaran, NOT Janika
        "machine_id": target_machine_id,
        "start_date": str(slot_date + timedelta(days=1)),
        "end_date": str(slot_date + timedelta(days=2)),
        "total_hours": 8.0,
        "notes": "Unauthorized booking attempt"
    }
    unauthorized_resp = client.post("/api/v1/bookings/", json=tampered_booking_payload, headers=janika_headers)
    assert unauthorized_resp.status_code == 403, f"Expected 403 Forbidden, got {unauthorized_resp.status_code}"
    assert unauthorized_resp.json()["detail"] == "Not authorized to book for this requirement"
