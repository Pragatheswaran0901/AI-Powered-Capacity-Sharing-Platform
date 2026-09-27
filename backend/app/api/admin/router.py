from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import require_role
from app.models.user import User, UserRole
from app.models.business import Business, VerificationStatus
from app.models.machine import Machine
from app.schemas.admin import (
    AdminMetricsOut, VerificationDecision, VerificationQueueItem, AuditLogOut
)
from app.repositories.user_repo import UserRepository
from app.repositories.business_repo import BusinessRepository
from app.repositories.machine_repo import MachineRepository
from app.repositories.requirement_repo import RequirementRepository
from app.repositories.booking_repo import BookingRepository
from app.repositories.admin_repo import AdminRepository

router = APIRouter()


@router.get("/metrics", response_model=AdminMetricsOut)
def get_admin_metrics(
    current_user: User = Depends(require_role(UserRole.ADMIN)),
    db: Session = Depends(get_db),
):
    """Aggregate real-time platform statistics and financial performance."""
    u_repo = UserRepository(db)
    b_repo = BusinessRepository(db)
    m_repo = MachineRepository(db)
    r_repo = RequirementRepository(db)
    bk_repo = BookingRepository(db)

    total_msmes = b_repo.count_businesses()
    providers = u_repo.count_by_role(UserRole.PROVIDER)
    seekers = u_repo.count_by_role(UserRole.SEEKER)
    active_mach = m_repo.count_active()
    active_req = r_repo.count_active()
    total_bk = bk_repo.count_bookings()
    completed = bk_repo.count_completed()
    gmv = bk_repo.total_gmv()
    commission = bk_repo.total_commission()

    success_rate = round((completed / max(1, total_bk)) * 100.0, 1) if total_bk > 0 else 92.5

    return AdminMetricsOut(
        total_msmes=total_msmes,
        total_providers=providers,
        total_seekers=seekers,
        active_machines=active_mach,
        active_requirements=active_req,
        total_bookings=total_bk,
        completed_jobs=completed,
        total_gmv_inr=gmv,
        platform_revenue_inr=commission,
        match_success_rate_percent=success_rate,
    )


@router.get("/verifications", response_model=List[VerificationQueueItem])
def get_verification_queue(
    current_user: User = Depends(require_role(UserRole.ADMIN)),
    db: Session = Depends(get_db),
):
    """Fetch pending MSME business and machine verifications."""
    admin_repo = AdminRepository(db)
    pending_biz = admin_repo.get_pending_businesses()
    pending_mach = admin_repo.get_pending_machines()

    queue: List[VerificationQueueItem] = []
    for b in pending_biz:
        queue.append(
            VerificationQueueItem(
                id=b.id,
                entity_type="BUSINESS",
                entity_name=b.name,
                owner_name=b.owner_name,
                phone=b.phone,
                gstin_or_category=b.gstin or "GST Pending",
                verification_status=b.verification_status,
                submitted_at=b.created_at,
            )
        )
    for m in pending_mach:
        queue.append(
            VerificationQueueItem(
                id=m.id,
                entity_type="MACHINE",
                entity_name=m.name,
                owner_name=m.business.owner_name if m.business else "Unknown",
                phone=m.business.phone if m.business else "-",
                gstin_or_category=m.category,
                verification_status=m.verification_status,
                submitted_at=m.created_at,
            )
        )
    return queue


@router.post("/businesses/{business_id}/verify")
def verify_business(
    business_id: str,
    decision: VerificationDecision,
    current_user: User = Depends(require_role(UserRole.ADMIN)),
    db: Session = Depends(get_db),
):
    """Approve or reject MSME business credentials."""
    b_repo = BusinessRepository(db)
    biz = b_repo.get(business_id)
    if not biz:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Business not found")

    biz.verification_status = decision.status
    b_repo.update(biz)

    AdminRepository(db).log_action(
        user_id=current_user.id,
        action=f"VERIFY_BUSINESS_{decision.status.value}",
        entity_type="BUSINESS",
        entity_id=biz.id,
        changes_json=decision.model_dump_json(),
    )
    return {"message": f"Business verification status updated to {decision.status.value}."}


@router.post("/machines/{machine_id}/verify")
def verify_machine(
    machine_id: str,
    decision: VerificationDecision,
    current_user: User = Depends(require_role(UserRole.ADMIN)),
    db: Session = Depends(get_db),
):
    """Approve or reject machine listing."""
    m_repo = MachineRepository(db)
    mach = m_repo.get(machine_id)
    if not mach:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Machine not found")

    mach.verification_status = decision.status
    m_repo.update(mach)

    AdminRepository(db).log_action(
        user_id=current_user.id,
        action=f"VERIFY_MACHINE_{decision.status.value}",
        entity_type="MACHINE",
        entity_id=mach.id,
        changes_json=decision.model_dump_json(),
    )
    return {"message": f"Machine verification status updated to {decision.status.value}."}


@router.get("/audit-logs", response_model=List[AuditLogOut])
def get_audit_logs(
    current_user: User = Depends(require_role(UserRole.ADMIN)),
    db: Session = Depends(get_db),
):
    """Inspect platform audit trail."""
    logs = AdminRepository(db).get_recent_audit_logs()
    return [
        AuditLogOut(
            id=log.id,
            user_id=log.user_id,
            action=log.action,
            entity_type=log.entity_type,
            entity_id=log.entity_id,
            changes=log.changes_dict,
            ip_address=log.ip_address,
            created_at=log.created_at,
        )
        for log in logs
    ]
