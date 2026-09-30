import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Float, DateTime, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class Company(Base):
    """
    Physical Industrial Location & Company Entity.
    Sourced from the 49-company master industrial dataset (Coimbatore & Tiruppur).
    Maintains real industrial coordinates, address, industry, and Google Maps URL.
    """
    __tablename__ = "companies"

    id = Column(String(50), primary_key=True)  # CSV company_id (e.g., CBE001, TPR001)
    name = Column(String(255), nullable=False, index=True)
    city = Column(String(100), nullable=False, index=True)
    state = Column(String(100), nullable=False, default="Tamil Nadu")
    address = Column(Text, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    industry = Column(String(100), nullable=False, index=True)
    google_maps_link = Column(String(500), nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # Relationship to demo marketplace capacity listings
    machines = relationship("Machine", back_populates="company")
