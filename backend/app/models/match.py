import uuid
import json
from datetime import datetime, timezone
from sqlalchemy import Column, String, Float, DateTime, Text, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base


class Match(Base):
    __tablename__ = "matches"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    requirement_id = Column(String(36), ForeignKey("requirements.id", ondelete="CASCADE"), nullable=False)
    machine_id = Column(String(36), ForeignKey("machines.id", ondelete="CASCADE"), nullable=False)
    overall_score = Column(Float, nullable=False)  # 0.0 to 1.0
    capability_score = Column(Float, nullable=False)
    availability_score = Column(Float, nullable=False)
    distance_score = Column(Float, nullable=False)
    cost_score = Column(Float, nullable=False)
    reliability_score = Column(Float, nullable=False)
    match_reasons = Column(Text, nullable=False)  # JSON-encoded array of reason strings
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # Relationships
    requirement = relationship("Requirement", back_populates="matches")
    machine = relationship("Machine", back_populates="matches")

    @property
    def reasons_list(self):
        if not self.match_reasons:
            return []
        try:
            return json.loads(self.match_reasons)
        except Exception:
            return []
