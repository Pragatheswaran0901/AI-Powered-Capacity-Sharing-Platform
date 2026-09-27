from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.notification import NotificationOut
from app.services.notification_service import NotificationService

router = APIRouter()


@router.get("/", response_model=List[NotificationOut])
def get_my_notifications(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve in-app notification feed for the current user."""
    return NotificationService(db).get_user_notifications(current_user.id)


@router.put("/{notification_id}/read")
def mark_notification_read(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Mark a specific notification as read."""
    NotificationService(db).mark_one_read(notification_id)
    return {"message": "Notification marked read."}


@router.put("/read-all")
def mark_all_notifications_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Mark all pending notifications as read."""
    count = NotificationService(db).mark_all_read(current_user.id)
    return {"message": f"{count} notifications marked read."}
