from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.audit import AuditLog
from app.models.business import Business, VerificationStatus
from app.models.machine import Machine
from app.repositories.base import BaseRepository


class AdminRepository(BaseRepository[AuditLog]):
    def __init__(self, db: Session):
        super().__init__(AuditLog, db)

    def log_action(self, user_id: Optional[str], action: str, entity_type: str, entity_id: str, changes_json: Optional[str] = None, ip_address: Optional[str] = None) -> AuditLog:
        log = AuditLog(
            user_id=user_id,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            changes_json=changes_json,
            ip_address=ip_address,
        )
        self.db.add(log)
        self.db.commit()
        self.db.refresh(log)
        return log

    def get_pending_businesses(self) -> List[Business]:
        return self.db.query(Business).filter(Business.verification_status == VerificationStatus.PENDING).all()

    def get_pending_machines(self) -> List[Machine]:
        return self.db.query(Machine).filter(Machine.verification_status == VerificationStatus.PENDING).all()

    def get_recent_audit_logs(self, limit: int = 50) -> List[AuditLog]:
        return self.db.query(AuditLog).order_by(AuditLog.created_at.desc()).limit(limit).all()
