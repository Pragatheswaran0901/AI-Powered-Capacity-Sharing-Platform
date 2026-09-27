from typing import Optional, List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.requirement import Requirement, RequirementAttachment, RequirementStatus
from app.schemas.requirement import RequirementCreate, RequirementUpdate
from app.repositories.requirement_repo import RequirementRepository
from app.matching.distance import resolve_coordinates


class RequirementService:
    def __init__(self, db: Session):
        self.db = db
        self.req_repo = RequirementRepository(db)

    def create_requirement(self, seeker_id: str, req_in: RequirementCreate) -> Requirement:
        lat = req_in.latitude
        lng = req_in.longitude
        if lat is None or lng is None:
            lat, lng = resolve_coordinates(req_in.preferred_location)

        req = Requirement(
            seeker_id=seeker_id,
            title=req_in.title,
            description=req_in.description,
            process=req_in.process,
            material=req_in.material,
            quantity=req_in.quantity,
            dimensions=req_in.dimensions,
            tolerance_mm=req_in.tolerance_mm,
            required_date=req_in.required_date,
            delivery_deadline=req_in.delivery_deadline,
            preferred_location=req_in.preferred_location,
            latitude=lat,
            longitude=lng,
            max_distance_km=req_in.max_distance_km,
            budget=req_in.budget,
            quality_requirements=req_in.quality_requirements,
            operator_required=req_in.operator_required,
            status=RequirementStatus.OPEN,
        )
        return self.req_repo.create(req)

    def get_my_requirements(self, seeker_id: str) -> List[Requirement]:
        return self.req_repo.get_by_seeker(seeker_id)

    def get_requirement(self, req_id: str) -> Requirement:
        req = self.req_repo.get_with_details(req_id)
        if not req:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Requirement not found")
        return req

    def add_attachment(self, req_id: str, file_name: str, file_path: str, file_size: int, file_type: str) -> RequirementAttachment:
        attachment = RequirementAttachment(
            requirement_id=req_id,
            file_name=file_name,
            file_path=file_path,
            file_size=file_size,
            file_type=file_type,
        )
        return self.req_repo.add_attachment(attachment)
