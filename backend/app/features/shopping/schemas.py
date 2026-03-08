from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class ShoppingListCreate(BaseModel):
    profile_id: str
    name: str
    emoji: str = "🛒"


class ShoppingListResponse(BaseModel):
    id: str
    profile_id: str
    name: str
    emoji: str
    created_at: datetime
    item_count: int = 0
    done_count: int = 0

    model_config = {"from_attributes": True}


class ShoppingItemCreate(BaseModel):
    text: str
    quantity: Optional[str] = None
    category: Optional[str] = None
    position: int = 0


class ShoppingItemUpdate(BaseModel):
    text: Optional[str] = None
    quantity: Optional[str] = None
    is_done: Optional[bool] = None
    category: Optional[str] = None
    position: Optional[int] = None


class ShoppingItemResponse(BaseModel):
    id: str
    list_id: str
    text: str
    quantity: Optional[str]
    category: Optional[str]
    is_done: bool
    position: int
    created_at: datetime

    model_config = {"from_attributes": True}
