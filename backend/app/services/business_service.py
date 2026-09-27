from typing import Optional, List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.business import Business, BusinessDocument, VerificationStatus
from app.models.user import User
from app.schemas.business import BusinessCreate, BusinessUpdate, BusinessOut, DocumentOut
from app.repositories.business_repo import BusinessRepository


class BusinessService:
    def __init__(self, db: Session):
        self.db = db
        self.biz_repo = BusinessRepository(db)

    def create_business(self, user_id: str, biz_in: BusinessCreate) -> Business:
        existing = self.biz_repo.get_by_user_id(user_id)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A business profile already exists for this account.",
            )

        if biz_in.gstin:
            by_gst = self.biz_repo.get_by_gstin(biz_in.gstin)
            if by_gst:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="A business with this GSTIN is already registered.",
                )

        new_biz = Business(
            user_id=user_id,
            name=biz_in.name,
            owner_name=biz_in.owner_name,
            phone=biz_in.phone,
            email=biz_in.email,
            gstin=biz_in.gstin,
            registration_number=biz_in.registration_number,
            industry=biz_in.industry,
            address=biz_in.address,
            district=biz_in.district,
            state=biz_in.state,
            pincode=biz_in.pincode,
            latitude=biz_in.latitude,
            longitude=biz_in.longitude,
            description=biz_in.description,
            verification_status=VerificationStatus.PENDING,
        )
        return self.biz_repo.create(new_biz)

    def get_user_business(self, user_id: str) -> Optional[Business]:
        return self.biz_repo.get_by_user_id(user_id)

    def update_business(self, user_id: str, update_in: BusinessUpdate) -> Business:
        biz = self.biz_repo.get_by_user_id(user_id)
        if not biz:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Business profile not found.",
            )

        update_data = update_in.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(biz, key, value)

        return self.biz_repo.update(biz)

    def get_public_profile(self, biz_id: str) -> Business:
        biz = self.biz_repo.get(biz_id)
        if not biz:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Business profile not found.",
            )
        return biz

    def add_document(self, biz_id: str, doc_type: str, file_path: str) -> BusinessDocument:
        doc = BusinessDocument(
            business_id=biz_id,
            document_type=doc_type,
            file_path=file_path,
            verification_status=VerificationStatus.PENDING,
        )
        return self.biz_repo.add_document(doc)
