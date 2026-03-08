from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional, Any


class MedicineKBResponse(BaseModel):
    id: str
    name_trade: str
    name_generic: Optional[str]
    substance: list[str]
    form: str
    dosage_per_unit: Optional[str]
    category: str
    action_simple: Optional[str]
    side_effects_top: list[str]
    recommended_dose: dict
    interactions_caution: list[str]
    interactions_avoid: list[str]
    contraindications: list[str]
    created_at: datetime

    model_config = {"from_attributes": True}


class AnalyzeByNameRequest(BaseModel):
    name: str


class AnalyzePhotoRequest(BaseModel):
    image_base64: str
    mime_type: str = "image/jpeg"


class ProfileMedicineCreate(BaseModel):
    profile_id: str
    medicine_kb_id: str
    medicine_name: str
    dose: str = "1 tablet"
    frequency_per_day: int = 1
    times_json: list[str] = ["08:00"]
    course_days: Optional[int] = None
    start_date: date = date.today()
    notes: Optional[str] = None
    total_units: Optional[int] = None


class ProfileMedicineUpdate(BaseModel):
    dose: Optional[str] = None
    frequency_per_day: Optional[int] = None
    times_json: Optional[list[str]] = None
    course_days: Optional[int] = None
    end_date: Optional[date] = None
    notes: Optional[str] = None
    is_active: Optional[bool] = None
    total_units: Optional[int] = None


class ProfileMedicineResponse(BaseModel):
    id: str
    profile_id: str
    medicine_kb_id: str
    medicine_name: str
    dose: str
    frequency_per_day: int
    times_json: list[str]
    course_days: Optional[int]
    start_date: date
    end_date: Optional[date]
    notes: Optional[str]
    is_active: bool
    total_units: Optional[int]
    units_taken: int
    units_remaining: Optional[int]
    created_at: datetime

    model_config = {"from_attributes": True}


class CompatibilityRequest(BaseModel):
    profile_id: str
    new_medicine_name: str


class IntakeLogUpdate(BaseModel):
    status: str  # taken|skipped|snoozed


class IntakeLogResponse(BaseModel):
    id: str
    profile_medicine_id: str
    scheduled_at: datetime
    taken_at: Optional[datetime]
    status: str

    model_config = {"from_attributes": True}


class TodayScheduleItem(BaseModel):
    profile_medicine_id: str
    medicine_name: str
    dose: str
    scheduled_time: str
    action_simple: Optional[str]
    status: str
    log_id: Optional[str]
