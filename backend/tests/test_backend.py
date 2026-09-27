import pytest
from datetime import date, timedelta
from fastapi.testclient import TestClient
from app.main import app
from app.core.security import verify_password, get_password_hash, create_access_token, decode_token
from app.models.user import UserRole
from app.matching.distance import haversine_distance_km, resolve_coordinates
from app.services.ai_service import ai_service


client = TestClient(app)


def test_health_check():
    """Verify system health liveness probe."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "Mach-Hunt API"
    assert data["database"] == "connected"


def test_security_hashing():
    """Verify bcrypt salted hashing and verification."""
    password = "productionSecurePassword123!"
    hashed = get_password_hash(password)
    assert hashed != password
    assert verify_password(password, hashed) is True
    assert verify_password("wrongPassword", hashed) is False


def test_jwt_tokens():
    """Verify JWT access and refresh token lifecycle."""
    user_id = "test-uuid-1234"
    token = create_access_token(subject=user_id, role="SEEKER", business_id="biz-5678")
    payload = decode_token(token)
    assert payload is not None
    assert payload["sub"] == user_id
    assert payload["role"] == "SEEKER"
    assert payload["business_id"] == "biz-5678"
    assert payload["type"] == "access"


def test_haversine_distance():
    """Verify geographic distance calculation."""
    # SIDCO Kurichi (10.9412, 76.9723) to Ganapathy (11.0384, 76.9744) ~10.8 km
    dist = haversine_distance_km(10.9412, 76.9723, 11.0384, 76.9744)
    assert 10.0 <= dist <= 12.0

    # Same location must be 0
    assert haversine_distance_km(11.0, 77.0, 11.0, 77.0) == 0.0


def test_ai_natural_language_interpretation():
    """Verify Pydantic validated AI extraction of manufacturing requirements."""
    prompt = "I need 500 aluminium brackets CNC machined within 4 days near Coimbatore with Rs. 25000 budget."
    result = ai_service.parse_natural_language_requirement(prompt)
    assert result.quantity == 500
    assert "Aluminium" in result.material
    assert "CNC" in result.process
    assert result.deadline_days == 4
    assert result.preferred_location == "Coimbatore"
    assert result.estimated_budget == 25000.0


def test_login_flow():
    """Verify authentication endpoint with seeded user."""
    # Test valid login
    response = client.post(
        "/api/v1/auth/login",
        json={"email": "karthikeyan@machhunt.demo", "password": "password123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["role"] == "SEEKER"

    token = data["access_token"]

    # Test /auth/me with bearer token
    me_resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert me_resp.status_code == 200
    me_data = me_resp.json()
    assert me_data["email"] == "karthikeyan@machhunt.demo"

    # Test invalid login
    bad_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "karthikeyan@machhunt.demo", "password": "wrongPassword!"}
    )
    assert bad_resp.status_code == 401


def test_machines_catalog_and_filters():
    """Verify machine listing search and query filters."""
    # Search all active machines
    response = client.get("/api/v1/machines")
    assert response.status_code == 200
    machines = response.json()
    assert len(machines) >= 4

    # Filter by category
    cnc_resp = client.get("/api/v1/machines?category=Milling")
    assert cnc_resp.status_code == 200
    cnc_machines = cnc_resp.json()
    assert len(cnc_machines) >= 2
    for m in cnc_machines:
        assert "Milling" in m["category"]


def test_matching_engine_api():
    """Verify explainable matching engine endpoint and reason generation."""
    # Login as seeker
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "karthikeyan@machhunt.demo", "password": "password123"}
    )
    token = login_resp.json()["access_token"]

    # Get seeker requirements
    req_resp = client.get("/api/v1/requirements/my", headers={"Authorization": f"Bearer {token}"})
    assert req_resp.status_code == 200
    reqs = req_resp.json()
    assert len(reqs) >= 1
    req_id = reqs[0]["id"]

    # Request matches
    matches_resp = client.get(f"/api/v1/matches/requirement/{req_id}", headers={"Authorization": f"Bearer {token}"})
    assert matches_resp.status_code == 200
    matches = matches_resp.json()
    assert len(matches) >= 3

    top_match = matches[0]
    assert "match_percentage" in top_match
    assert top_match["match_percentage"] >= 75
    assert len(top_match["match_reasons"]) >= 3
    assert "score_breakdown" in top_match
    assert top_match["score_breakdown"]["capability_score"] > 0
    assert top_match["score_breakdown"]["distance_km"] > 0


def test_side_by_side_comparison():
    """Verify multi-machine comparison matrix generation."""
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "karthikeyan@machhunt.demo", "password": "password123"}
    )
    token = login_resp.json()["access_token"]

    req_resp = client.get("/api/v1/requirements/my", headers={"Authorization": f"Bearer {token}"})
    req_id = req_resp.json()[0]["id"]

    mach_resp = client.get("/api/v1/machines")
    mach_ids = [m["id"] for m in mach_resp.json()[:2]]

    compare_resp = client.post(
        "/api/v1/matches/compare",
        json={"requirement_id": req_id, "machine_ids": mach_ids},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert compare_resp.status_code == 200
    matrix = compare_resp.json()
    assert len(matrix["items"]) == 2
    assert matrix["items"][0]["hourly_price"] > 0


def test_booking_state_machine_flow():
    """
    Test end-to-end booking state machine transitions:
    PENDING -> ACCEPTED -> CONFIRMED -> IN_PROGRESS -> COMPLETED
    """
    # Seeker token
    seeker_token = client.post(
        "/api/v1/auth/login", json={"email": "karthikeyan@machhunt.demo", "password": "password123"}
    ).json()["access_token"]

    # Provider token (Janika)
    provider_token = client.post(
        "/api/v1/auth/login", json={"email": "janika@machhunt.demo", "password": "password123"}
    ).json()["access_token"]

    # 1. Create a new requirement
    import random
    today = date.today() + timedelta(days=50 + random.randint(1, 250))
    req_payload = {
        "title": "200 Aluminium Fixture Plates",
        "description": "High tolerance fixture plates for automotive leak test jig.",
        "process": "CNC Milling",
        "material": "Aluminium 6061",
        "quantity": 200,
        "required_date": str(today),
        "delivery_deadline": str(today + timedelta(days=4)),
        "preferred_location": "Ganapathy, Coimbatore",
        "budget": 20000.0,
    }
    new_req = client.post("/api/v1/requirements/", json=req_payload, headers={"Authorization": f"Bearer {seeker_token}"}).json()
    req_id = new_req["id"]

    # Get Janika's machine
    my_machs = client.get("/api/v1/machines/my", headers={"Authorization": f"Bearer {provider_token}"}).json()
    mach_id = my_machs[0]["id"]

    # 2. Seeker requests booking (PENDING)
    booking_payload = {
        "requirement_id": req_id,
        "machine_id": mach_id,
        "start_date": str(today),
        "end_date": str(today + timedelta(days=2)),
        "total_hours": 10.0,
        "notes": "Urgent lot test"
    }
    bk_resp = client.post("/api/v1/bookings/", json=booking_payload, headers={"Authorization": f"Bearer {seeker_token}"})
    assert bk_resp.status_code == 201
    booking = bk_resp.json()
    assert booking["status"] == "PENDING"
    assert booking["total_amount"] > 0
    bk_id = booking["id"]

    # 3. Provider accepts (ACCEPTED)
    accept_resp = client.post(f"/api/v1/bookings/{bk_id}/accept", headers={"Authorization": f"Bearer {provider_token}"})
    assert accept_resp.status_code == 200
    assert accept_resp.json()["status"] == "ACCEPTED"

    # 4. Seeker confirms and funds escrow (CONFIRMED)
    confirm_resp = client.post(f"/api/v1/bookings/{bk_id}/confirm", headers={"Authorization": f"Bearer {seeker_token}"})
    assert confirm_resp.status_code == 200
    assert confirm_resp.json()["status"] == "CONFIRMED"

    # Verify payment record was created
    pay_resp = client.get(f"/api/v1/payments/booking/{bk_id}", headers={"Authorization": f"Bearer {seeker_token}"})
    assert pay_resp.status_code == 200
    assert pay_resp.json()["status"] == "ESCROW_HOLD"

    # 5. Provider starts production (IN_PROGRESS)
    start_resp = client.post(f"/api/v1/bookings/{bk_id}/start", headers={"Authorization": f"Bearer {provider_token}"})
    assert start_resp.status_code == 200
    assert start_resp.json()["status"] == "IN_PROGRESS"

    # 6. Complete job (COMPLETED) and release escrow
    complete_resp = client.post(f"/api/v1/bookings/{bk_id}/complete", headers={"Authorization": f"Bearer {seeker_token}"})
    assert complete_resp.status_code == 200
    assert complete_resp.json()["status"] == "COMPLETED"

    # Verify payment released
    pay_after = client.get(f"/api/v1/payments/booking/{bk_id}", headers={"Authorization": f"Bearer {seeker_token}"})
    assert pay_after.json()["status"] == "RELEASED_TO_PROVIDER"

    # 7. Post review
    rev_resp = client.post(
        "/api/v1/reviews/",
        json={"booking_id": bk_id, "rating": 5, "review_text": "Superb finish on fixture plates."},
        headers={"Authorization": f"Bearer {seeker_token}"},
    )
    assert rev_resp.status_code == 201


def test_admin_metrics_and_verification():
    """Verify admin endpoints and metrics aggregation."""
    admin_token = client.post(
        "/api/v1/auth/login", json={"email": "admin@machhunt.demo", "password": "password123"}
    ).json()["access_token"]

    metrics_resp = client.get("/api/v1/admin/metrics", headers={"Authorization": f"Bearer {admin_token}"})
    assert metrics_resp.status_code == 200
    metrics = metrics_resp.json()
    assert metrics["total_msmes"] >= 3
    assert metrics["active_machines"] >= 4
    assert metrics["completed_jobs"] >= 1
    assert metrics["total_gmv_inr"] > 0
