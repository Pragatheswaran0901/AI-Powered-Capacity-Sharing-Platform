import abc
import os
import json
import logging
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import Dict, Any, List, Optional
import httpx
from app.core.config import settings

logger = logging.getLogger("machhunt.email")


class BaseEmailProvider(abc.ABC):
    @abc.abstractmethod
    def send_email(
        self,
        to_email: str,
        subject: str,
        text_content: str,
        html_content: Optional[str] = None,
    ) -> bool:
        pass


class DevelopmentEmailProvider(BaseEmailProvider):
    """
    Local development email provider.
    Safely captures dispatched emails in-memory and in a local dev mailbox file.
    Does NOT log OTP values to standard output.
    """
    def __init__(self):
        self.sent_emails: List[Dict[str, Any]] = []

    def send_email(
        self,
        to_email: str,
        subject: str,
        text_content: str,
        html_content: Optional[str] = None,
    ) -> bool:
        print("[EMAIL] Preparing OTP email", flush=True)
        print("[EMAIL] Development provider active (saving to dev_mailbox.json)", flush=True)
        record = {
            "to": to_email,
            "subject": subject,
            "text": text_content,
            "html": html_content,
        }
        self.sent_emails.append(record)
        try:
            with open("dev_mailbox.json", "w", encoding="utf-8") as f:
                json.dump(self.sent_emails[-20:], f, indent=2)
        except Exception as e:
            logger.warning(f"[Development Email Provider] Could not write to dev_mailbox.json: {e}")
        print("[EMAIL] Email sent", flush=True)
        logger.info(f"[Development Email Provider] Verification email dispatched to {to_email}")
        return True


class SMTPEmailProvider(BaseEmailProvider):
    """
    Standard production SMTP provider (compatible with Gmail SMTP, SendGrid, Amazon SES, Brevo).
    """
    def __init__(
        self,
        host: str = "smtp.gmail.com",
        port: int = 587,
        user: str = "machhunt2212@gmail.com",
        password: str = "",
        use_tls: bool = True,
        from_email: str = "machhunt2212@gmail.com",
        from_name: str = "Mach-Hunt",
    ):
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.use_tls = use_tls
        self.from_email = from_email
        self.from_name = from_name

    def send_email(
        self,
        to_email: str,
        subject: str,
        text_content: str,
        html_content: Optional[str] = None,
    ) -> bool:
        print("[EMAIL] Preparing OTP email", flush=True)
        print("[EMAIL] SMTP configuration loaded", flush=True)
        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = f"{self.from_name} <{self.from_email}>"
            msg["To"] = to_email

            part1 = MIMEText(text_content, "plain")
            msg.attach(part1)
            if html_content:
                part2 = MIMEText(html_content, "html")
                msg.attach(part2)

            print(f"[EMAIL] Connecting to SMTP server ({self.host}:{self.port})", flush=True)
            try:
                server = smtplib.SMTP(self.host, self.port, timeout=15)
                print("[EMAIL] SMTP connection established", flush=True)
            except Exception as e:
                print(f"[EMAIL] SMTP connection failed: {type(e).__name__} - {e}", flush=True)
                logger.error(f"[EMAIL] SMTP connection failed: {type(e).__name__} - {e}")
                raise

            with server:
                if self.use_tls:
                    try:
                        server.starttls()
                        print("[EMAIL] STARTTLS successful", flush=True)
                    except Exception as e:
                        print(f"[EMAIL] SMTP TLS failed: {type(e).__name__} - {e}", flush=True)
                        logger.error(f"[EMAIL] SMTP TLS failed: {type(e).__name__} - {e}")
                        raise

                if self.user and self.password:
                    try:
                        server.login(self.user, self.password)
                        print("[EMAIL] SMTP authentication successful", flush=True)
                    except smtplib.SMTPAuthenticationError as e:
                        print(f"[EMAIL] SMTP authentication failed: {e.smtp_code} - {e.smtp_error}", flush=True)
                        logger.error(f"[EMAIL] SMTP authentication failed: {e.smtp_code} - {e.smtp_error}")
                        raise
                    except Exception as e:
                        print(f"[EMAIL] SMTP authentication failed: {type(e).__name__} - {e}", flush=True)
                        logger.error(f"[EMAIL] SMTP authentication failed: {type(e).__name__} - {e}")
                        raise
                elif self.user and not self.password:
                    print("[EMAIL] SMTP authentication failed: Missing SMTP_PASSWORD in configuration", flush=True)
                    raise Exception("Missing SMTP_PASSWORD: Set your Google App Password for machhunt2212@gmail.com in .env")

                try:
                    server.sendmail(self.from_email, [to_email], msg.as_string())
                    print("[EMAIL] Email sent successfully", flush=True)
                    logger.info(f"[EMAIL] Email successfully delivered to {to_email}")
                    return True
                except Exception as e:
                    print(f"[EMAIL] Email sending failed: {type(e).__name__} - {e}", flush=True)
                    logger.error(f"[EMAIL] Email sending failed: {type(e).__name__} - {e}")
                    raise
        except Exception as e:
            logger.error(f"[SMTP Provider] Failed to send email to {to_email}: {type(e).__name__}")
            raise


class ResendEmailProvider(BaseEmailProvider):
    """
    Resend Transactional Email API provider.
    """
    def __init__(self, api_key: str, from_email: str, from_name: str):
        self.api_key = api_key
        self.from_email = from_email
        self.from_name = from_name

    def send_email(
        self,
        to_email: str,
        subject: str,
        text_content: str,
        html_content: Optional[str] = None,
    ) -> bool:
        if not self.api_key:
            logger.error("[Resend Provider] Missing RESEND_API_KEY")
            return False
        try:
            payload = {
                "from": f"{self.from_name} <{self.from_email}>",
                "to": [to_email],
                "subject": subject,
                "text": text_content,
            }
            if html_content:
                payload["html"] = html_content

            with httpx.Client(timeout=10.0) as client:
                resp = client.post(
                    "https://api.resend.com/emails",
                    headers={"Authorization": f"Bearer {self.api_key}", "Content-Type": "application/json"},
                    json=payload,
                )
                if resp.status_code in (200, 201):
                    print("[EMAIL] Email sent successfully", flush=True)
                    logger.info(f"[Resend Provider] Email sent to {to_email}")
                    return True
                else:
                    logger.error(f"[Resend Provider] Resend API error: {resp.status_code}")
                    return False
        except Exception as e:
            logger.error(f"[Resend Provider] Failed to dispatch via Resend: {type(e).__name__}")
            return False


class EmailService:
    def __init__(self):
        self._provider = self._resolve_provider()

    def _resolve_provider(self) -> BaseEmailProvider:
        provider_type = getattr(settings, "EMAIL_PROVIDER", "development").lower()

        if provider_type in ("smtp", "sendgrid") or (settings.SMTP_PASSWORD and settings.SMTP_USER):
            return SMTPEmailProvider(
                host=settings.SMTP_HOST,
                port=settings.SMTP_PORT,
                user=settings.SMTP_USER,
                password=settings.SMTP_PASSWORD,
                use_tls=settings.SMTP_TLS,
                from_email=settings.EMAIL_FROM,
                from_name=settings.EMAIL_FROM_NAME,
            )

        if provider_type == "resend" and settings.EMAIL_API_KEY:
            return ResendEmailProvider(
                api_key=settings.EMAIL_API_KEY,
                from_email=settings.EMAIL_FROM,
                from_name=settings.EMAIL_FROM_NAME,
            )

        return DevelopmentEmailProvider()

    def send_otp_email(self, to_email: str, otp: str) -> bool:
        subject = "Your Mach-Hunt Verification Code"
        
        # Professional plain text template strictly matching Section 6
        text_content = (
            f"Hello,\n\n"
            f"Your Mach-Hunt verification code is:\n"
            f"{otp}\n\n"
            f"This code expires in 5 minutes.\n"
            f"If you did not request this code, you can safely ignore this email.\n\n"
            f"Regards,\n"
            f"Mach-Hunt\n"
            f"Manufacturing Capacity, When You Need It."
        )

        # Elegant HTML template
        html_content = f"""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Your Mach-Hunt Verification Code</title>
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; margin: 0; padding: 32px 16px;">
  <div style="max-width: 520px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);">
    <div style="background-color: #0f172a; padding: 24px; text-align: center;">
      <h1 style="color: #ffffff; margin: 0; font-size: 20px; font-weight: 700; letter-spacing: 1px;">MACH-HUNT</h1>
      <p style="color: #94a3b8; margin: 6px 0 0 0; font-size: 13px;">Manufacturing capacity, when you need it.</p>
    </div>
    <div style="padding: 32px 28px;">
      <p style="font-size: 15px; color: #334155; margin: 0 0 16px 0;">Hello,</p>
      <p style="font-size: 15px; color: #334155; line-height: 1.5; margin: 0 0 24px 0;">
        Your Mach-Hunt verification code is:
      </p>
      <div style="background-color: #f1f5f9; border-radius: 6px; padding: 18px; text-align: center; margin: 0 0 24px 0; border: 1px dashed #cbd5e1;">
        <span style="font-family: monospace; font-size: 32px; font-weight: 800; color: #0284c7; letter-spacing: 8px; display: inline-block;">{otp}</span>
      </div>
      <p style="font-size: 14px; color: #64748b; margin: 0 0 16px 0;">
        This code expires in <strong>5 minutes</strong>.
      </p>
      <p style="font-size: 13px; color: #94a3b8; margin: 0 0 24px 0;">
        If you did not request this code, you can safely ignore this email.
      </p>
      <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 24px 0 16px 0;" />
      <p style="font-size: 13px; color: #64748b; margin: 0;">
        Regards,<br><strong>Mach-Hunt</strong><br>
        <span style="color: #94a3b8; font-size: 12px;">Manufacturing Capacity, When You Need It.</span>
      </p>
    </div>
  </div>
</body>
</html>
"""
        return self._provider.send_email(
            to_email=to_email,
            subject=subject,
            text_content=text_content,
            html_content=html_content,
        )


email_service = EmailService()
