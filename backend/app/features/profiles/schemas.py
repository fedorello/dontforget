from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional


class ProfileCreate(BaseModel):
    name: str
    avatar_emoji: str = "👤"
    birth_date: Optional[date] = None
    gender: Optional[str] = None
    weight_kg: Optional[float] = None
    health_notes: Optional[str] = None
    allergies: Optional[str] = None
    is_default: bool = False


class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    avatar_emoji: Optional[str] = None
    birth_date: Optional[date] = None
    gender: Optional[str] = None
    weight_kg: Optional[float] = None
    health_notes: Optional[str] = None
    allergies: Optional[str] = None
    is_default: Optional[bool] = None


class ProfileResponse(BaseModel):
    id: str
    name: str
    avatar_emoji: str
    birth_date: Optional[date]
    gender: Optional[str]
    weight_kg: Optional[float]
    health_notes: Optional[str]
    allergies: Optional[str]
    is_default: bool
    age: Optional[int]
    created_at: datetime

    model_config = {"from_attributes": True}
