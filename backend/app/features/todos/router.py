from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, date
from app.core.database import get_db
from app.features.todos.models import Todo
from app.features.todos.schemas import TodoCreate, TodoUpdate, TodoResponse
from app.shared.exceptions import NotFoundError

router = APIRouter(prefix="/todos", tags=["todos"])


@router.get("/{profile_id}", response_model=list[TodoResponse])
async def get_todos(
    profile_id: str,
    filter: str = "all",  # all|today|week|done
    db: AsyncSession = Depends(get_db),
):
    q = select(Todo).where(Todo.profile_id == profile_id, Todo.parent_id == None)
    if filter == "today":
        today_start = datetime.combine(date.today(), datetime.min.time())
        today_end = datetime.combine(date.today(), datetime.max.time())
        q = q.where(Todo.due_at >= today_start, Todo.due_at <= today_end, Todo.is_done == False)
    elif filter == "week":
        from datetime import timedelta
        week_end = datetime.combine(date.today() + timedelta(days=7), datetime.max.time())
        q = q.where(Todo.due_at <= week_end, Todo.is_done == False)
    elif filter == "done":
        q = q.where(Todo.is_done == True)
    else:
        q = q.where(Todo.is_done == False)

    q = q.order_by(Todo.priority.desc(), Todo.due_at.asc().nullslast(), Todo.created_at.desc())
    result = await db.execute(q)
    return list(result.scalars().all())


@router.post("/", response_model=TodoResponse, status_code=201)
async def create_todo(data: TodoCreate, db: AsyncSession = Depends(get_db)):
    todo = Todo(**data.model_dump())
    db.add(todo)
    await db.flush()
    return todo


@router.patch("/{todo_id}", response_model=TodoResponse)
async def update_todo(todo_id: str, data: TodoUpdate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Todo).where(Todo.id == todo_id))
    todo = result.scalar_one_or_none()
    if not todo:
        raise NotFoundError("Todo")
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(todo, field, value)
    if data.is_done is True and not todo.done_at:
        todo.done_at = datetime.utcnow()
    elif data.is_done is False:
        todo.done_at = None
    await db.flush()
    return todo


@router.delete("/{todo_id}", status_code=204)
async def delete_todo(todo_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Todo).where(Todo.id == todo_id))
    todo = result.scalar_one_or_none()
    if not todo:
        raise NotFoundError("Todo")
    await db.delete(todo)


@router.get("/{profile_id}/today-count")
async def get_today_count(profile_id: str, db: AsyncSession = Depends(get_db)):
    today_start = datetime.combine(date.today(), datetime.min.time())
    today_end = datetime.combine(date.today(), datetime.max.time())
    result = await db.execute(
        select(Todo).where(
            Todo.profile_id == profile_id,
            Todo.due_at >= today_start,
            Todo.due_at <= today_end,
            Todo.is_done == False,
        )
    )
    return {"count": len(result.scalars().all())}
