from typing import List
from sqlalchemy.orm import Session
from app.models.notification import Notification
from app.repositories.notification_repo import NotificationRepository


class NotificationService:
    def __init__(self, db: Session):
        self.db = db
        self.notif_repo = NotificationRepository(db)

    def get_user_notifications(self, user_id: str) -> List[Notification]:
        return self.notif_repo.get_by_user(user_id)

    def mark_all_read(self, user_id: str) -> int:
        return self.notif_repo.mark_all_read(user_id)

    def mark_one_read(self, notif_id: str) -> bool:
        notif = self.notif_repo.get(notif_id)
        if notif:
            notif.is_read = True
            self.notif_repo.update(notif)
            return True
        return False
