from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.core.database import get_db
from app.features.shopping.models import ShoppingList, ShoppingItem
from app.features.shopping.schemas import (
    ShoppingListCreate, ShoppingListResponse,
    ShoppingItemCreate, ShoppingItemUpdate, ShoppingItemResponse,
)
from app.shared.exceptions import NotFoundError

router = APIRouter(prefix="/shopping", tags=["shopping"])


@router.get("/lists/{profile_id}", response_model=list[ShoppingListResponse])
async def get_lists(profile_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(ShoppingList).where(ShoppingList.profile_id == profile_id).order_by(ShoppingList.updated_at.desc())
    )
    lists = result.scalars().all()
    responses = []
    for lst in lists:
        items_result = await db.execute(
            select(func.count(ShoppingItem.id), func.sum(ShoppingItem.is_done.cast(type_=type(1))))
            .where(ShoppingItem.list_id == lst.id)
        )
        row = items_result.one()
        total = row[0] or 0
        done = int(row[1] or 0)
        resp = ShoppingListResponse.model_validate(lst)
        resp.item_count = total
        resp.done_count = done
        responses.append(resp)
    return responses


@router.post("/lists", response_model=ShoppingListResponse, status_code=201)
async def create_list(data: ShoppingListCreate, db: AsyncSession = Depends(get_db)):
    lst = ShoppingList(**data.model_dump())
    db.add(lst)
    await db.flush()
    return ShoppingListResponse.model_validate(lst)


@router.delete("/lists/{list_id}", status_code=204)
async def delete_list(list_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ShoppingList).where(ShoppingList.id == list_id))
    lst = result.scalar_one_or_none()
    if not lst:
        raise NotFoundError("ShoppingList")
    await db.delete(lst)


@router.get("/lists/{list_id}/items", response_model=list[ShoppingItemResponse])
async def get_items(list_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(ShoppingItem).where(ShoppingItem.list_id == list_id).order_by(ShoppingItem.is_done, ShoppingItem.position)
    )
    return list(result.scalars().all())


@router.post("/lists/{list_id}/items", response_model=ShoppingItemResponse, status_code=201)
async def add_item(list_id: str, data: ShoppingItemCreate, db: AsyncSession = Depends(get_db)):
    item = ShoppingItem(list_id=list_id, **data.model_dump())
    db.add(item)
    await db.flush()
    return item


@router.patch("/items/{item_id}", response_model=ShoppingItemResponse)
async def update_item(item_id: str, data: ShoppingItemUpdate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ShoppingItem).where(ShoppingItem.id == item_id))
    item = result.scalar_one_or_none()
    if not item:
        raise NotFoundError("ShoppingItem")
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(item, field, value)
    await db.flush()
    return item


@router.delete("/items/{item_id}", status_code=204)
async def delete_item(item_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ShoppingItem).where(ShoppingItem.id == item_id))
    item = result.scalar_one_or_none()
    if not item:
        raise NotFoundError("ShoppingItem")
    await db.delete(item)


@router.delete("/lists/{list_id}/items/done", status_code=204)
async def clear_done_items(list_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(ShoppingItem).where(ShoppingItem.list_id == list_id, ShoppingItem.is_done == True))
    for item in result.scalars().all():
        await db.delete(item)
