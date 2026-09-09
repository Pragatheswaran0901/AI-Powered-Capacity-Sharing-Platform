from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    phone = Column(String, nullable=True)
    password_hash = Column(String, nullable=False)
    role = Column(String, nullable=False)  # 'admin', 'machine_owner', 'machine_seeker'
    created_at = Column(DateTime, default=datetime.utcnow)

    msmes = relationship("MSME", back_populates="owner")
    reviews_written = relationship("Review", foreign_keys="Review.reviewer_id", back_populates="reviewer")
    notifications = relationship("Notification", back_populates="user")


class MSME(Base):
    __tablename__ = "msmes"

    id = Column(Integer, primary_key=True, index=True)
    owner_user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    company_name = Column(String, nullable=False)
    business_type = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    city = Column(String, nullable=False)
    district = Column(String, nullable=False)
    state = Column(String, default="Tamil Nadu")
    pincode = Column(String, nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    verification_status = Column(String, default="pending")  # 'verified', 'pending', 'rejected'
    created_at = Column(DateTime, default=datetime.utcnow)

    owner = relationship("User", back_populates="msmes")
    machines = relationship("Machine", back_populates="msme")
    requirements = relationship("Requirement", back_populates="seeker_msme")
    reviews_received = relationship("Review", foreign_keys="Review.reviewed_msme_id", back_populates="reviewed_msme")


class Machine(Base):
    __tablename__ = "machines"

    id = Column(Integer, primary_key=True, index=True)
    msme_id = Column(Integer, ForeignKey("msmes.id"), nullable=False)
    machine_name = Column(String, nullable=False)
    machine_type = Column(String, nullable=False)  # CNC Milling, Lathe, VMC, etc.
    manufacturer = Column(String, nullable=True)
    model = Column(String, nullable=True)
    year = Column(Integer, nullable=True)
    description = Column(Text, nullable=True)
    hourly_rate = Column(Float, nullable=False)
    minimum_booking_hours = Column(Integer, default=1)
    location = Column(String, nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    operator_available = Column(Boolean, default=True)
    verification_status = Column(String, default="pending")  # 'verified', 'pending', 'rejected'
    created_at = Column(DateTime, default=datetime.utcnow)

    msme = relationship("MSME", back_populates="machines")
    capabilities = relationship("MachineCapability", back_populates="machine", cascade="all, delete-orphan")
    availabilities = relationship("Availability", back_populates="machine", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="machine")
    matches = relationship("Match", back_populates="machine")


class MachineCapability(Base):
    __tablename__ = "machine_capabilities"

    id = Column(Integer, primary_key=True, index=True)
    machine_id = Column(Integer, ForeignKey("machines.id"), nullable=False)
    process = Column(String, nullable=False)  # CNC Milling, Turning, etc.
    material = Column(String, nullable=False)  # Aluminium, Mild Steel, etc.
    max_dimension = Column(String, nullable=True)
    tolerance = Column(String, nullable=True)
    capacity_description = Column(Text, nullable=True)

    machine = relationship("Machine", back_populates="capabilities")


class Availability(Base):
    __tablename__ = "availability"

    id = Column(Integer, primary_key=True, index=True)
    machine_id = Column(Integer, ForeignKey("machines.id"), nullable=False)
    available_date = Column(String, nullable=False)  # YYYY-MM-DD
    start_time = Column(String, default="08:00")
    end_time = Column(String, default="18:00")
    available_hours = Column(Float, nullable=False)
    status = Column(String, default="available")  # 'available', 'booked', 'maintenance'

    machine = relationship("Machine", back_populates="availabilities")


class Requirement(Base):
    __tablename__ = "requirements"

    id = Column(Integer, primary_key=True, index=True)
    seeker_msme_id = Column(Integer, ForeignKey("msmes.id"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    process = Column(String, nullable=False)
    material = Column(String, nullable=False)
    quantity = Column(Integer, nullable=False)
    deadline = Column(String, nullable=False)  # Date or e.g. "3 days"
    budget = Column(Float, nullable=False)
    preferred_city = Column(String, nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    status = Column(String, default="open")  # 'open', 'matched', 'in_progress', 'completed', 'cancelled'
    created_at = Column(DateTime, default=datetime.utcnow)

    seeker_msme = relationship("MSME", back_populates="requirements")
    matches = relationship("Match", back_populates="requirement", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="requirement")


class Match(Base):
    __tablename__ = "matches"

    id = Column(Integer, primary_key=True, index=True)
    requirement_id = Column(Integer, ForeignKey("requirements.id"), nullable=False)
    machine_id = Column(Integer, ForeignKey("machines.id"), nullable=False)
    capability_score = Column(Float, default=0.0)
    availability_score = Column(Float, default=0.0)
    distance_score = Column(Float, default=0.0)
    cost_score = Column(Float, default=0.0)
    reliability_score = Column(Float, default=0.0)
    total_score = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)

    requirement = relationship("Requirement", back_populates="matches")
    machine = relationship("Machine", back_populates="matches")


class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)
    requirement_id = Column(Integer, ForeignKey("requirements.id"), nullable=False)
    machine_id = Column(Integer, ForeignKey("machines.id"), nullable=False)
    seeker_msme_id = Column(Integer, ForeignKey("msmes.id"), nullable=False)
    owner_msme_id = Column(Integer, ForeignKey("msmes.id"), nullable=False)
    booking_date = Column(String, nullable=False)
    start_time = Column(String, default="09:00")
    end_time = Column(String, default="17:00")
    quantity = Column(Integer, nullable=False)
    agreed_price = Column(Float, nullable=False)
    status = Column(String, default="pending")  # 'pending', 'accepted', 'rejected', 'confirmed', 'in_progress', 'completed', 'cancelled'
    created_at = Column(DateTime, default=datetime.utcnow)

    requirement = relationship("Requirement", back_populates="bookings")
    machine = relationship("Machine", back_populates="bookings")
    review = relationship("Review", back_populates="booking", uselist=False)
    payment = relationship("Payment", back_populates="booking", uselist=False)


class Review(Base):
    __tablename__ = "reviews"

    id = Column(Integer, primary_key=True, index=True)
    booking_id = Column(Integer, ForeignKey("bookings.id"), nullable=False)
    reviewer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    reviewed_msme_id = Column(Integer, ForeignKey("msmes.id"), nullable=False)
    rating = Column(Float, nullable=False)
    quality_rating = Column(Float, default=5.0)
    reliability_rating = Column(Float, default=5.0)
    communication_rating = Column(Float, default=5.0)
    comment = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    booking = relationship("Booking", back_populates="review")
    reviewer = relationship("User", back_populates="reviews_written")
    reviewed_msme = relationship("MSME", back_populates="reviews_received")


class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    booking_id = Column(Integer, ForeignKey("bookings.id"), nullable=False)
    amount = Column(Float, nullable=False)
    platform_fee = Column(Float, nullable=False)
    status = Column(String, default="completed")  # 'pending', 'completed', 'refunded'
    payment_reference = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    booking = relationship("Booking", back_populates="payment")


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="notifications")
