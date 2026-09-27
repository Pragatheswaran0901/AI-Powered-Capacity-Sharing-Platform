from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.user import User, UserRole
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    def __init__(self, db: Session):
        super().__init__(User, db)

    def get_by_email(self, email: str) -> Optional[User]:
        return self.db.query(User).filter(User.email == email).first()

    def get_by_role(self, role: UserRole) -> List[User]:
        return self.db.query(User).filter(User.role == role).all()

    def count_users(self) -> int:
        return self.db.query(User).count()

    def count_by_role(self, role: UserRole) -> int:
        return self.db.query(User).filter(User.role == role).count()
