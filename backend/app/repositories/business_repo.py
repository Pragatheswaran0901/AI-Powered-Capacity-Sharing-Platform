from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.business import Business, BusinessDocument, VerificationStatus
from app.repositories.base import BaseRepository


class BusinessRepository(BaseRepository[Business]):
    def __init__(self, db: Session):
        super().__init__(Business, db)

    def get_by_user_id(self, user_id: str) -> Optional[Business]:
        return self.db.query(Business).filter(Business.user_id == user_id).first()

    def get_by_gstin(self, gstin: str) -> Optional[Business]:
        return self.db.query(Business).filter(Business.gstin == gstin).first()

    def get_by_verification_status(self, status: VerificationStatus) -> List[Business]:
        return self.db.query(Business).filter(Business.verification_status == status).all()

    def count_businesses(self) -> int:
        return self.db.query(Business).count()

    def add_document(self, document: BusinessDocument) -> BusinessDocument:
        self.db.add(document)
        self.db.commit()
        self.db.refresh(document)
        return document

    def get_document(self, doc_id: str) -> Optional[BusinessDocument]:
        return self.db.query(BusinessDocument).filter(BusinessDocument.id == doc_id).first()

    def update_document(self, document: BusinessDocument) -> BusinessDocument:
        self.db.add(document)
        self.db.commit()
        self.db.refresh(document)
        return document
