from __future__ import annotations
import uuid
from datetime import date, datetime
from typing import Optional, List
from sqlalchemy import String, Date, Float, Text, Boolean, DateTime, JSON, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column
from app.core.database import Base


class MedicineKB(Base):
    """Knowledge Base entry for a medicine/supplement."""
    __tablename__ = "medicines_kb"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name_trade: Mapped[str] = mapped_column(String(200))
    name_generic: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    substance: Mapped[List] = mapped_column(JSON, default=list)
    form: Mapped[str] = mapped_column(String(50), default="capsule")
    dosage_per_unit: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    category: Mapped[str] = mapped_column(String(50), default="supplement")
    action_simple: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    side_effects_top: Mapped[List] = mapped_column(JSON, default=list)
    recommended_dose: Mapped[dict] = mapped_column(JSON, default=dict)
    interactions_caution: Mapped[List] = mapped_column(JSON, default=list)
    interactions_avoid: Mapped[List] = mapped_column(JSON, default=list)
    contraindications: Mapped[List] = mapped_column(JSON, default=list)
    source: Mapped[str] = mapped_column(String(50), default="ai_extracted")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class ProfileMedicine(Base):
    """Active medicine assigned to a profile."""
    __tablename__ = "profile_medicines"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    profile_id: Mapped[str] = mapped_column(String, ForeignKey("profiles.id", ondelete="CASCADE"))
    medicine_kb_id: Mapped[str] = mapped_column(String, ForeignKey("medicines_kb.id"))
    medicine_name: Mapped[str] = mapped_column(String(200))
    dose: Mapped[str] = mapped_column(String(100), default="1 tablet")
    frequency_per_day: Mapped[int] = mapped_column(Integer, default=1)
    times_json: Mapped[List] = mapped_column(JSON, default=list)
    course_days: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    start_date: Mapped[date] = mapped_column(Date, default=date.today)
    end_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    total_units: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    units_taken: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    @property
    def units_remaining(self) -> Optional[int]:
        if self.total_units is None:
            return None
        return max(0, self.total_units - self.units_taken)


class IntakeLog(Base):
    """Log of medicine intake events."""
    __tablename__ = "intake_logs"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    profile_medicine_id: Mapped[str] = mapped_column(String, ForeignKey("profile_medicines.id", ondelete="CASCADE"))
    scheduled_at: Mapped[datetime] = mapped_column(DateTime)
    taken_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="pending")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
