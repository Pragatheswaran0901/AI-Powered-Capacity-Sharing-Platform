from typing import Optional, List
from sqlalchemy.orm import Session, joinedload
from app.models.requirement import Requirement, RequirementAttachment, RequirementStatus
from app.models.machine import Machine
from app.models.match import Match
from app.repositories.base import BaseRepository


class RequirementRepository(BaseRepository[Requirement]):
    def __init__(self, db: Session):
        super().__init__(Requirement, db)

    def get_with_details(self, req_id: str) -> Optional[Requirement]:
        return (
            self.db.query(Requirement)
            .options(
                joinedload(Requirement.attachments),
                joinedload(Requirement.matches),
                joinedload(Requirement.seeker),
            )
            .filter(Requirement.id == req_id)
            .first()
        )

    def get_by_seeker(self, seeker_id: str) -> List[Requirement]:
        return (
            self.db.query(Requirement)
            .options(joinedload(Requirement.matches))
            .filter(Requirement.seeker_id == seeker_id)
            .order_by(Requirement.created_at.desc())
            .all()
        )

    def count_active(self) -> int:
        return self.db.query(Requirement).filter(Requirement.status.in_([RequirementStatus.OPEN, RequirementStatus.MATCHED])).count()

    def add_attachment(self, attachment: RequirementAttachment) -> RequirementAttachment:
        self.db.add(attachment)
        self.db.commit()
        self.db.refresh(attachment)
        return attachment

    def save_matches(self, req_id: str, matches: List[Match]) -> List[Match]:
        # Clear previous matches for this requirement
        self.db.query(Match).filter(Match.requirement_id == req_id).delete()
        for m in matches:
            self.db.add(m)
        self.db.commit()
        return matches

    def get_matches_for_requirement(self, req_id: str) -> List[Match]:
        return (
            self.db.query(Match)
            .options(joinedload(Match.machine).joinedload(Machine.business))
            .filter(Match.requirement_id == req_id)
            .order_by(Match.overall_score.desc())
            .all()
        )
