from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, ConfigDict
from app.models.business import VerificationStatus


class AdminMetricsOut(BaseModel):
    total_msmes: int
    total_providers: int
    total_seekers: int
    active_machines: int
    active_requirements: int
    total_bookings: int
    completed_jobs: int
    total_gmv_inr: float
    platform_revenue_inr: float
    match_success_rate_percent: float


class VerificationDecision(BaseModel):
    status: VerificationStatus
    remarks: Optional[str] = None


class VerificationQueueItem(BaseModel):
    id: str
    entity_type: str  # BUSINESS or MACHINE
    entity_name: str
    owner_name: str
    phone: str
    gstin_or_category: Optional[str] = None
    verification_status: VerificationStatus
    submitted_at: datetime


class AuditLogOut(BaseModel):
    id: str
    user_id: Optional[str] = None
    action: str
    entity_type: str
    entity_id: str
    changes: Optional[Dict[str, Any]] = None
    ip_address: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
