import uuid
import json
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Text, ForeignKey
from app.core.database import Base


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    action = Column(String(100), nullable=False)  # CREATE_MACHINE, VERIFY_BUSINESS, etc.
    entity_type = Column(String(100), nullable=False)
    entity_id = Column(String(36), nullable=False)
    changes_json = Column(Text, nullable=True)
    ip_address = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    @property
    def changes_dict(self):
        if not self.changes_json:
            return {}
        try:
            return json.loads(self.changes_json)
        except Exception:
            return {}
