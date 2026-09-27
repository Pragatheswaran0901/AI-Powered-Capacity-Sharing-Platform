import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.security import decode_token

client = TestClient(app)

DEMO_USERS = [
    ("janika@machhunt.demo", "password123", "Janika"),
    ("pragatheswaran@machhunt.demo", "password123", "Pragatheswaran"),
    ("jayanth@machhunt.demo", "password123", "Jayanth"),
    ("reethika@machhunt.demo", "password123", "Reethika"),
]


def test_auth_config_mode():
    """Verify that backend configuration exposes the active auth mode."""
    res = client.get("/api/v1/auth/config")
    assert res.status_code == 200
    data = res.json()
    assert data["auth_mode"] in ["demo", "otp"]
    assert "email_from" in data


@pytest.mark.parametrize("email,password,expected_name_substr", DEMO_USERS)
def test_valid_login_for_demo_users(email, password, expected_name_substr):
    """Explicitly verify valid password authentication for Janika, Pragatheswaran, Jayanth, and Reethika."""
    res = client.post("/api/v1/auth/login", json={"email": email, "password": password})
    assert res.status_code == 200, f"Login failed for {email}: {res.text}"
    data = res.json()
    
    # 7. JWT returned
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"
    assert data["user_id"]
    assert expected_name_substr.lower() in data["full_name"].lower()
    
    # Verify token payload
    payload = decode_token(data["access_token"])
    assert payload is not None
    assert payload["sub"] == data["user_id"]
    assert payload["type"] == "access"


def test_tolerant_demo_alias_login():
    """Verify that janika@machunt.demo (typo from screenshot) and password@123 authenticate cleanly."""
    res = client.post("/api/v1/auth/login", json={"email": "janika@machunt.demo", "password": "password@123"})
    assert res.status_code == 200
    data = res.json()
    assert "access_token" in data
    assert data["role"] == "PROVIDER"
    assert "janika" in data["full_name"].lower()


def test_invalid_password_returns_401():
    """Verify that wrong password returns 401 with standard error message."""
    res = client.post(
        "/api/v1/auth/login",
        json={"email": "janika@machhunt.demo", "password": "wrongPasswordXYZ!"},
    )
    assert res.status_code == 401
    assert "detail" in res.json()
    assert "Invalid email or password" in res.json()["detail"]


def test_invalid_email_returns_401():
    """Verify that non-existent email returns 401 with standard error message."""
    res = client.post(
        "/api/v1/auth/login",
        json={"email": "non_existent_user_999@machhunt.demo", "password": "password123"},
    )
    assert res.status_code == 401
    assert "detail" in res.json()
    assert "Invalid email or password" in res.json()["detail"]


def test_protected_api_works_with_jwt_and_logout():
    """Verify protected endpoints work with issued JWT and logout endpoint functions."""
    # 1. Login
    login_res = client.post(
        "/api/v1/auth/login",
        json={"email": "pragatheswaran@machhunt.demo", "password": "password123"},
    )
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 8. Protected API works with JWT
    me_res = client.get("/api/v1/auth/me", headers=headers)
    assert me_res.status_code == 200
    me_data = me_res.json()
    assert me_data["email"] == "pragatheswaran@machhunt.demo"
    assert "Pragatheswaran" in me_data["full_name"]

    # 9. Logout handling
    logout_res = client.post("/api/v1/auth/logout", headers=headers)
    assert logout_res.status_code == 200
    assert "Successfully logged out" in logout_res.json()["message"]
