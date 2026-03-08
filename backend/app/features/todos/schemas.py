from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class TodoCreate(BaseModel):
    profile_id: str
    text: str
    notes: Optional[str] = None
    due_at: Optional[datetime] = None
    priority: int = 0
    tags: list[str] = []
    repeat_rule: Optional[str] = None
    parent_id: Optional[str] = None


class TodoUpdate(BaseModel):
    text: Optional[str] = None
    notes: Optional[str] = None
    due_at: Optional[datetime] = None
    is_done: Optional[bool] = None
    priority: Optional[int] = None
    tags: Optional[list[str]] = None
    repeat_rule: Optional[str] = None


class TodoResponse(BaseModel):
    id: str
    profile_id: str
    text: str
    notes: Optional[str]
    due_at: Optional[datetime]
    is_done: bool
    done_at: Optional[datetime]
    priority: int
    tags: list[str]
    repeat_rule: Optional[str]
    parent_id: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}
