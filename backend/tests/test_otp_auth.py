import pytest
import re
import random
from datetime import datetime, timezone, timedelta
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models.otp import EmailOTPCode
from app.models.user import User, UserRole
from app.services.email_service import email_service
from app.core.security import verify_otp_hash

client = TestClient(app)


def test_request_otp_success_and_email_dispatched():
    """Verify requesting OTP generates secure hash, stores record, and dispatches email."""
    test_email = "tester_unique_1@machhunt.com"
    db = SessionLocal()
    # Clean previous records
    db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).delete()
    db.commit()

    initial_email_count = len(email_service._provider.sent_emails) if hasattr(email_service._provider, "sent_emails") else 0

    response = client.post("/api/v1/auth/request-otp", json={"email": test_email})
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert data["expires_in"] == 300
    # Must NOT expose OTP in response
    assert "otp" not in data

    # Verify database record
    record = db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email, EmailOTPCode.consumed == False).first()
    assert record is not None
    assert record.otp_hash is not None
    assert len(record.otp_hash) == 64  # SHA-256 / HMAC length
    # Must NOT store plaintext OTP
    assert not record.otp_hash.isdigit()

    # Verify email was captured by development email provider
    if hasattr(email_service._provider, "sent_emails"):
        assert len(email_service._provider.sent_emails) > initial_email_count
        last_sent = email_service._provider.sent_emails[-1]
        assert last_sent["to"] == test_email
        assert "Your Mach-Hunt Verification Code" in last_sent["subject"]
    db.close()


def test_request_otp_cooldown_rate_limit():
    """Verify 60-second cooldown triggers HTTP 429."""
    test_email = "cooldown_test@gmail.com"
    db = SessionLocal()
    db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).delete()
    db.commit()
    db.close()

    # First request
    res1 = client.post("/api/v1/auth/request-otp", json={"email": test_email})
    assert res1.status_code == 200

    # Immediate second request should trigger 429
    res2 = client.post("/api/v1/auth/request-otp", json={"email": test_email})
    assert res2.status_code == 429
    assert "Please wait" in res2.json()["detail"]


def test_verify_otp_success_creates_user_and_jwt():
    """Verify correct OTP creates new user, returns JWT and marks record consumed."""
    test_email = "new_seeker_otp@gmail.com"
    db = SessionLocal()
    db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).delete()
    db.query(User).filter(User.email == test_email).delete()
    db.commit()

    # Request OTP
    res_req = client.post("/api/v1/auth/request-otp", json={"email": test_email})
    assert res_req.status_code == 200

    # Retrieve dispatched OTP from development email service
    last_sent = email_service._provider.sent_emails[-1]
    match = re.search(r"\b\d{6}\b", last_sent["text"])
    assert match is not None
    otp_code = match.group(0)

    # Verify with correct code
    res_verify = client.post("/api/v1/auth/verify-otp", json={"email": test_email, "otp": otp_code})
    assert res_verify.status_code == 200
    auth_data = res_verify.json()
    assert "access_token" in auth_data
    assert "refresh_token" in auth_data
    assert auth_data["user"]["email"] == test_email
    assert auth_data["user"]["role"] == "SEEKER"
    assert auth_data["user"]["is_onboarded"] is False

    # Verify record is marked consumed
    rec = db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).first()
    assert rec.consumed is True
    assert rec.verified_at is not None

    # Verify user persisted in database with email_verified=True
    user = db.query(User).filter(User.email == test_email).first()
    assert user is not None
    assert user.email_verified is True
    assert user.authentication_provider == "email_otp"
    db.close()


def test_verify_otp_cannot_be_reused():
    """Verify that a single-use OTP cannot be used twice."""
    test_email = "single_use@gmail.com"
    db = SessionLocal()
    db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).delete()
    db.commit()

    client.post("/api/v1/auth/request-otp", json={"email": test_email})
    match = re.search(r"\b\d{6}\b", email_service._provider.sent_emails[-1]["text"])
    otp_code = match.group(0)

    # First verify: success
    res1 = client.post("/api/v1/auth/verify-otp", json={"email": test_email, "otp": otp_code})
    assert res1.status_code == 200

    # Second verify: fails (already consumed)
    res2 = client.post("/api/v1/auth/verify-otp", json={"email": test_email, "otp": otp_code})
    assert res2.status_code == 400
    assert "Code expired" in res2.json()["detail"] or "Request a new code" in res2.json()["detail"]
    db.close()


def test_verify_incorrect_otp_rejected_and_attempts_counted():
    """Verify incorrect code rejection and 5-attempt limit."""
    test_email = "bad_attempts@gmail.com"
    db = SessionLocal()
    db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).delete()
    db.commit()

    client.post("/api/v1/auth/request-otp", json={"email": test_email})

    # Enter wrong OTP 4 times
    for _ in range(4):
        res = client.post("/api/v1/auth/verify-otp", json={"email": test_email, "otp": "999999"})
        assert res.status_code == 400
        assert "Incorrect code" in res.json()["detail"]

    # 5th wrong attempt should exceed limit and invalidate
    res5 = client.post("/api/v1/auth/verify-otp", json={"email": test_email, "otp": "999999"})
    assert res5.status_code == 400
    assert "Too many attempts" in res5.json()["detail"]
    db.close()


def test_onboarding_blocks_admin_role_and_allows_provider_seeker():
    """Verify onboarding blocks ADMIN self-assignment and creates Business profile."""
    test_email = "onboard_me@gmail.com"
    db = SessionLocal()
    db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).delete()
    db.query(User).filter(User.email == test_email).delete()
    db.commit()

    # Request and verify OTP
    client.post("/api/v1/auth/request-otp", json={"email": test_email})
    match = re.search(r"\b\d{6}\b", email_service._provider.sent_emails[-1]["text"])
    res_verify = client.post("/api/v1/auth/verify-otp", json={"email": test_email, "otp": match.group(0)})
    token = res_verify.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Attempt to self-assign ADMIN -> Rejected with 403 or 422
    res_admin = client.post(
        "/api/v1/auth/onboarding",
        headers=headers,
        json={
            "role": "ADMIN",
            "full_name": "Hacker Admin",
            "phone": "9876543210",
            "business_name": "Fake Corp",
            "industry": "CNC",
            "district": "Coimbatore",
            "pincode": "641001",
            "address": "123 Main Rd"
        }
    )
    assert res_admin.status_code in (400, 403, 422)

    # Valid onboarding as PROVIDER
    unique_gstin = f"33AAECK{random.randint(1000, 9999)}F1Z5"
    res_provider = client.post(
        "/api/v1/auth/onboarding",
        headers=headers,
        json={
            "role": "PROVIDER",
            "full_name": "Pranesh Natarajan",
            "phone": "9876543210",
            "business_name": "Kongu High Precision Components",
            "industry": "Automotive & Aerospace",
            "district": "Coimbatore",
            "state": "Tamil Nadu",
            "pincode": "641006",
            "address": "Plot 42, SIDCO Industrial Estate, Kurichi",
            "description": "4-axis CNC and VMC precision machining workshop",
            "gstin": unique_gstin
        }
    )
    assert res_provider.status_code == 200
    p_data = res_provider.json()
    assert p_data["user"]["role"] == "PROVIDER"
    assert p_data["user"]["is_onboarded"] is True
    assert p_data["user"]["business_id"] is not None
    db.close()


def test_backward_compatibility_password_login():
    """Verify seeded password accounts (admin, janika, karthikeyan) continue to work."""
    res = client.post(
        "/api/v1/auth/login",
        json={"email": "karthikeyan@machhunt.demo", "password": "password123"}
    )
    assert res.status_code == 200
    data = res.json()
    assert "access_token" in data
    assert data["role"] == "SEEKER"


def test_verify_expired_otp_rejected():
    """Verify that an expired OTP is rejected."""
    test_email = "expired_otp_test@machhunt.com"
    db = SessionLocal()
    db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).delete()
    db.commit()

    client.post("/api/v1/auth/request-otp", json={"email": test_email})
    rec = db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email, EmailOTPCode.consumed == False).first()
    assert rec is not None
    # Force expire by setting expires_at to 10 minutes ago
    rec.expires_at = datetime.now(timezone.utc) - timedelta(minutes=10)
    db.commit()

    match = re.search(r"\b\d{6}\b", email_service._provider.sent_emails[-1]["text"])
    res = client.post("/api/v1/auth/verify-otp", json={"email": test_email, "otp": match.group(0)})
    assert res.status_code == 400
    assert "expired" in res.json()["detail"].lower()
    db.close()


def test_existing_user_otp_login_preserves_role_and_business():
    """Verify that an existing user logging in via OTP retains their existing role and profile."""
    test_email = "existing_provider@machhunt.demo"
    db = SessionLocal()
    # Ensure existing user exists
    user = db.query(User).filter(User.email == test_email).first()
    if not user:
        user = User(
            email=test_email,
            hashed_password="pw",
            full_name="Existing Provider",
            role=UserRole.PROVIDER,
            is_onboarded=True,
            email_verified=True,
        )
        db.add(user)
        db.commit()
    else:
        user.role = UserRole.PROVIDER
        user.is_onboarded = True
        db.commit()

    db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).delete()
    db.commit()

    client.post("/api/v1/auth/request-otp", json={"email": test_email})
    match = re.search(r"\b\d{6}\b", email_service._provider.sent_emails[-1]["text"])
    res = client.post("/api/v1/auth/verify-otp", json={"email": test_email, "otp": match.group(0)})
    assert res.status_code == 200
    data = res.json()
    assert data["user"]["email"] == test_email
    assert data["user"]["role"] == "PROVIDER"
    assert data["user"]["is_onboarded"] is True
    db.close()


def test_email_service_failure_handling(monkeypatch):
    """Verify that email service failures are caught and return a clean error without crashing."""
    def broken_send(*args, **kwargs):
        raise RuntimeError("SMTP connection timeout")

    monkeypatch.setattr(email_service._provider, "send_email", broken_send)
    test_email = "fail_mail@machhunt.com"
    db = SessionLocal()
    db.query(EmailOTPCode).filter(EmailOTPCode.email == test_email).delete()
    db.commit()
    db.close()

    res = client.post("/api/v1/auth/request-otp", json={"email": test_email})
    # Should handle gracefully with 500 or 503 instead of unhandled exception crash
    assert res.status_code in (500, 503)
    assert "Unable to send" in res.json()["detail"] or "failed" in res.json()["detail"].lower()


def test_gmail_smtp_mock_delivery_success(monkeypatch):
    """Verify Gmail SMTP email construction, dedicated sender, recipient, subject and body with mocked SMTP."""
    import smtplib
    from unittest.mock import MagicMock
    from app.services.email_service import SMTPEmailProvider

    mock_server_instance = MagicMock()
    mock_server_instance.__enter__.return_value = mock_server_instance
    mock_smtp_constructor = MagicMock(return_value=mock_server_instance)

    monkeypatch.setattr(smtplib, "SMTP", mock_smtp_constructor)

    provider = SMTPEmailProvider(
        host="smtp.gmail.com",
        port=587,
        user="machhunt2212@gmail.com",
        password="mock_google_app_password",
        use_tls=True,
        from_email="machhunt2212@gmail.com",
        from_name="Mach-Hunt",
    )

    test_recipient = "customer@manufacturing.com"
    test_otp = "842915"
    test_subject = "Your Mach-Hunt Verification Code"
    test_body = (
        f"Hello,\n\n"
        f"Your Mach-Hunt verification code is:\n"
        f"{test_otp}\n\n"
        f"This code expires in 5 minutes.\n"
        f"If you did not request this code, you can safely ignore this email.\n\n"
        f"Regards,\n"
        f"Mach-Hunt\n"
        f"Manufacturing Capacity, When You Need It."
    )

    result = provider.send_email(
        to_email=test_recipient,
        subject=test_subject,
        text_content=test_body,
    )

    assert result is True
    # 1. Connected to smtp.gmail.com:587
    mock_smtp_constructor.assert_called_once_with("smtp.gmail.com", 587, timeout=15)
    # 2. STARTTLS initiated
    mock_server_instance.starttls.assert_called_once()
    # 3. Authenticated with dedicated user credentials
    mock_server_instance.login.assert_called_once_with("machhunt2212@gmail.com", "mock_google_app_password")
    # 4. Dispatched from dedicated sender to customer
    mock_server_instance.sendmail.assert_called_once()
    args, _ = mock_server_instance.sendmail.call_args
    assert args[0] == "machhunt2212@gmail.com"  # Sender is machhunt2212@gmail.com
    assert args[1] == [test_recipient]         # Recipient is user's email
    sent_mime_text = args[2]
    assert "From: Mach-Hunt <machhunt2212@gmail.com>" in sent_mime_text
    assert f"To: {test_recipient}" in sent_mime_text
    assert "Subject: Your Mach-Hunt Verification Code" in sent_mime_text
    assert test_otp in sent_mime_text


def test_gmail_smtp_mock_auth_failure(monkeypatch):
    """Verify that SMTP authentication failure raises exception for safe handling."""
    import smtplib
    from unittest.mock import MagicMock
    from app.services.email_service import SMTPEmailProvider

    mock_server_instance = MagicMock()
    mock_server_instance.__enter__.return_value = mock_server_instance
    mock_server_instance.login.side_effect = smtplib.SMTPAuthenticationError(535, b"5.7.8 Username and Password not accepted")

    monkeypatch.setattr(smtplib, "SMTP", MagicMock(return_value=mock_server_instance))

    provider = SMTPEmailProvider(
        host="smtp.gmail.com",
        port=587,
        user="machhunt2212@gmail.com",
        password="bad_password",
        from_email="machhunt2212@gmail.com",
    )

    with pytest.raises(Exception):
        provider.send_email(
            to_email="test@user.com",
            subject="Test Subject",
            text_content="Test body",
        )


def test_gmail_smtp_mock_connection_failure(monkeypatch):
    """Verify that SMTP connection failure raises exception for safe handling."""
    import smtplib
    from unittest.mock import MagicMock
    from app.services.email_service import SMTPEmailProvider

    monkeypatch.setattr(smtplib, "SMTP", MagicMock(side_effect=smtplib.SMTPConnectError(421, b"Connection refused")))

    provider = SMTPEmailProvider(
        host="smtp.gmail.com",
        port=587,
        user="machhunt2212@gmail.com",
        password="mock_app_password",
        from_email="machhunt2212@gmail.com",
    )

    with pytest.raises(Exception):
        provider.send_email(
            to_email="test@user.com",
            subject="Test Subject",
            text_content="Test body",
        )


