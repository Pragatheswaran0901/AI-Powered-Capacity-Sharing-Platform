import pytest
from datetime import date, timedelta
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_shared_marketplace_four_accounts_cross_booking():
    """
    End-to-End Validation of the 4-Account Shared Marketplace:
    Janika, Pragatheswaran, Jayanth, Reethika
    """
    # -------------------------------------------------------------
    # 1. AUTHENTICATE ALL 4 DEMO USERS
    # -------------------------------------------------------------
    users = {}
    for name, email in [
        ("Janika", "janika@machhunt.demo"),
        ("Pragatheswaran", "pragatheswaran@machhunt.demo"),
        ("Jayanth", "jayanth@machhunt.demo"),
        ("Reethika", "reethika@machhunt.demo"),
    ]:
        resp = client.post("/api/v1/auth/login", json={"email": email, "password": "password123"})
        assert resp.status_code == 200, f"Login failed for {name}: {resp.text}"
        data = resp.json()
        users[name] = {
            "token": data["access_token"],
            "user_id": data["user_id"],
            "role": data["role"],
            "headers": {"Authorization": f"Bearer {data['access_token']}"}
        }

    # -------------------------------------------------------------
    # 2. VERIFY EVERY USER OWNS REAL MACHINES IN DATABASE
    # -------------------------------------------------------------
    janika_machs = client.get("/api/v1/machines/my", headers=users["Janika"]["headers"]).json()
    assert len(janika_machs) >= 2, "Janika must own machines"
    assert any("HAAS" in m["name"] for m in janika_machs), "Janika owns HAAS VMC"

    praga_machs = client.get("/api/v1/machines/my", headers=users["Pragatheswaran"]["headers"]).json()
    assert len(praga_machs) >= 2, "Pragatheswaran must own machines"
    assert any("BFW" in m["name"] for m in praga_machs), "Pragatheswaran owns BFW VMC"

    jayanth_machs = client.get("/api/v1/machines/my", headers=users["Jayanth"]["headers"]).json()
    assert len(jayanth_machs) == 12, "Jayanth must own 12 machines"
    assert any("Mazak" in m["name"] or "Juki" in m["name"] or "BFW" in m["name"] for m in jayanth_machs), "Jayanth owns machines"

    reethika_machs = client.get("/api/v1/machines/my", headers=users["Reethika"]["headers"]).json()
    assert len(reethika_machs) == 12, "Reethika must own 12 machines"
    assert any("Juki" in m["name"] or "Mayer" in m["name"] for m in reethika_machs), "Reethika owns machines"

    # -------------------------------------------------------------
    # 3. VERIFY USERS DO NOT SEE THEIR OWN CAPACITY AS EXTERNAL CAPACITY
    # -------------------------------------------------------------
    import random
    base_offset = random.randint(40, 350)
    today = date.today() + timedelta(days=base_offset)
    praga_new_req = client.post(
        "/api/v1/requirements/",
        json={
            "title": "500 Precision Aluminium Mounting Brackets",
            "description": "500 units CNC milled aluminium brackets in Coimbatore",
            "process": "CNC Milling",
            "material": "Aluminium 6061",
            "quantity": 500,
            "required_date": str(today),
            "delivery_deadline": str(today + timedelta(days=5)),
            "preferred_location": "Coimbatore",
            "budget": 30000.0,
        },
        headers=users["Pragatheswaran"]["headers"]
    ).json()
    req_id = praga_new_req["id"]

    # Match results for Pragatheswaran's requirement
    matches_resp = client.get(
        f"/api/v1/matches/requirement/{req_id}?location=Coimbatore",
        headers=users["Pragatheswaran"]["headers"]
    )
    assert matches_resp.status_code == 200
    matches = matches_resp.json()
    assert len(matches) > 0

    # Ensure NONE of the matched machines belong to Pragatheswaran
    for m in matches:
        assert m["machine_id"] not in [pm["id"] for pm in praga_machs], \
            "Seeker must NOT be recommended their own machines!"

    # Janika's machines must be discovered in matching results!
    janika_ids = [jm["id"] for jm in janika_machs]
    assert any(m["machine_id"] in janika_ids for m in matches), "Janika's capacity must be discovered by Pragatheswaran!"
    janika_match = [m for m in matches if m["machine_id"] in janika_ids][0]
    target_machine_id = janika_match["machine_id"]

    # -------------------------------------------------------------
    # 4. SCENARIO A: PRAGATHESWARAN BOOKS JANIKA'S CAPACITY
    # -------------------------------------------------------------
    booking_resp = client.post(
        "/api/v1/bookings/",
        json={
            "requirement_id": req_id,
            "machine_id": target_machine_id,
            "start_date": str(today),
            "end_date": str(today + timedelta(days=3)),
            "total_hours": 12.0,
            "notes": "Cross-account shared marketplace validation order"
        },
        headers=users["Pragatheswaran"]["headers"]
    )
    assert booking_resp.status_code == 201, f"Booking creation failed: {booking_resp.text}"
    booking_data = booking_resp.json()
    booking_id = booking_data["id"]
    assert booking_data["status"] == "PENDING"
    assert booking_data["seeker_id"] == users["Pragatheswaran"]["user_id"]
    assert booking_data["provider_id"] == users["Janika"]["user_id"]
    assert booking_data["machine_id"] == target_machine_id

    # -------------------------------------------------------------
    # 5. JANIKA RECEIVES BOOKING REQUEST AND NOTIFICATION
    # -------------------------------------------------------------
    janika_requests = client.get("/api/v1/bookings/my", headers=users["Janika"]["headers"]).json()
    assert any(b["id"] == booking_id and b["status"] == "PENDING" for b in janika_requests), \
        "Janika must see Pragatheswaran's booking request in incoming requests!"

    janika_notifs = client.get("/api/v1/notifications/", headers=users["Janika"]["headers"]).json()
    assert any(n["reference_id"] == booking_id for n in janika_notifs), \
        "Janika must receive a real backend notification for the booking request!"

    # -------------------------------------------------------------
    # 6. JANIKA ACCEPTS BOOKING REQUEST
    # -------------------------------------------------------------
    accept_resp = client.post(
        f"/api/v1/bookings/{booking_id}/accept",
        headers=users["Janika"]["headers"]
    )
    assert accept_resp.status_code == 200
    accepted_status = accept_resp.json()["status"]
    assert accepted_status in ["ACCEPTED", "CONFIRMED"]

    # -------------------------------------------------------------
    # 7. CONFIRMATION AND ESCROW PROTECTION
    # -------------------------------------------------------------
    if accepted_status == "ACCEPTED":
        confirm_resp = client.post(
            f"/api/v1/bookings/{booking_id}/confirm",
            headers=users["Pragatheswaran"]["headers"]
        )
        assert confirm_resp.status_code == 200
        assert confirm_resp.json()["status"] == "CONFIRMED"

    # Both Janika and Pragatheswaran see the EXACT SAME CONFIRMED booking!
    janika_view = client.get(f"/api/v1/bookings/{booking_id}", headers=users["Janika"]["headers"]).json()
    praga_view = client.get(f"/api/v1/bookings/{booking_id}", headers=users["Pragatheswaran"]["headers"]).json()
    assert janika_view["id"] == praga_view["id"] == booking_id
    assert janika_view["status"] == praga_view["status"] == "CONFIRMED"

    # -------------------------------------------------------------
    # 8. AVAILABILITY RESPONDED: SLOT IS BOOKED / LOCKED
    # -------------------------------------------------------------
    # Create a requirement owned by Jayanth to attempt double-booking on the locked slot
    jayanth_test_req = client.post(
        "/api/v1/requirements/",
        json={
            "title": "Jayanth Slot Conflict Test",
            "description": "Attempting to book an already locked slot",
            "process": "CNC Milling",
            "material": "Aluminium 6061",
            "quantity": 50,
            "required_date": str(today),
            "delivery_deadline": str(today + timedelta(days=4)),
            "preferred_location": "Coimbatore",
            "budget": 10000.0,
        },
        headers=users["Jayanth"]["headers"]
    ).json()

    # Attempting to book the exact same machine on the same date window should conflict
    double_book_resp = client.post(
        "/api/v1/bookings/",
        json={
            "requirement_id": jayanth_test_req["id"],
            "machine_id": target_machine_id,
            "start_date": str(today),
            "end_date": str(today + timedelta(days=3)),
            "total_hours": 8.0,
            "notes": "Attempted double booking"
        },
        headers=users["Jayanth"]["headers"]
    )
    assert double_book_resp.status_code == 409, "Double booking on booked slot must be rejected with 409 Conflict"

    # -------------------------------------------------------------
    # 9. SCENARIO B: REETHIKA BOOKS JAYANTH'S CAPACITY IN TIRUPPUR
    # -------------------------------------------------------------
    reethika_req = client.post(
        "/api/v1/requirements/",
        json={
            "title": "5000 Overlock Stitched Garment Panels",
            "description": "5000 units high-speed automated overlock stitching in Tiruppur",
            "process": "Stitching",
            "material": "Cotton Fabric",
            "quantity": 5000,
            "required_date": str(today + timedelta(days=10)),
            "delivery_deadline": str(today + timedelta(days=15)),
            "preferred_location": "Tiruppur",
            "budget": 25000.0,
        },
        headers=users["Reethika"]["headers"]
    ).json()

    stitching_matches = client.get(
        f"/api/v1/matches/requirement/{reethika_req['id']}?location=Tiruppur",
        headers=users["Reethika"]["headers"]
    ).json()
    assert len(stitching_matches) > 0
    # Must find Jayanth's Juki automated stitching line in Tiruppur
    assert any("Juki" in m["machine_name"] or "Stitching" in m["machine_name"] for m in stitching_matches)
    chosen_machine = stitching_matches[0]["machine_id"]

    # Reethika books
    stitching_bk = client.post(
        "/api/v1/bookings/",
        json={
            "requirement_id": reethika_req["id"],
            "machine_id": chosen_machine,
            "start_date": str(today + timedelta(days=10)),
            "end_date": str(today + timedelta(days=13)),
            "total_hours": 10.0,
            "notes": "Scenario B booking"
        },
        headers=users["Reethika"]["headers"]
    ).json()

    # Jayanth receives and accepts
    jayanth_accept = client.post(
        f"/api/v1/bookings/{stitching_bk['id']}/accept",
        headers=users["Jayanth"]["headers"]
    )
    assert jayanth_accept.status_code == 200

    # -------------------------------------------------------------
    # 10. SCENARIO C: JANIKA BOOKS REETHIKA'S CAPACITY IN TIRUPPUR
    # -------------------------------------------------------------
    janika_seek_req = client.post(
        "/api/v1/requirements/",
        json={
            "title": "3000 Knitted Garment Runs",
            "description": "High-volume fabric stitching & cutting in Tiruppur",
            "process": "Stitching",
            "material": "Cotton Fabric",
            "quantity": 3000,
            "required_date": str(today + timedelta(days=15)),
            "delivery_deadline": str(today + timedelta(days=22)),
            "preferred_location": "Tiruppur",
            "budget": 35000.0,
        },
        headers=users["Janika"]["headers"]
    ).json()

    garment_matches = client.get(
        f"/api/v1/matches/requirement/{janika_seek_req['id']}?location=Tiruppur",
        headers=users["Janika"]["headers"]
    ).json()
    assert len(garment_matches) > 0
    # Must find Reethika's Juki or Mayer & Cie capacity
    assert any("Juki" in m["machine_name"] or "Mayer" in m["machine_name"] for m in garment_matches)
    chosen_garment = garment_matches[0]["machine_id"]

    garment_bk = client.post(
        "/api/v1/bookings/",
        json={
            "requirement_id": janika_seek_req["id"],
            "machine_id": chosen_garment,
            "start_date": str(today + timedelta(days=15)),
            "end_date": str(today + timedelta(days=18)),
            "total_hours": 16.0,
            "notes": "Scenario C booking"
        },
        headers=users["Janika"]["headers"]
    ).json()

    # Reethika receives and accepts
    reethika_accept = client.post(
        f"/api/v1/bookings/{garment_bk['id']}/accept",
        headers=users["Reethika"]["headers"]
    )
    assert reethika_accept.status_code == 200
