from __future__ import annotations
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from app.features.profiles.models import Profile
from app.features.profiles.schemas import ProfileCreate, ProfileUpdate


class ProfileRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_all(self) -> list[Profile]:
        result = await self.db.execute(select(Profile).order_by(Profile.is_default.desc(), Profile.created_at))
        return list(result.scalars().all())

    async def get_by_id(self, profile_id: str) -> Profile | None:
        result = await self.db.execute(select(Profile).where(Profile.id == profile_id))
        return result.scalar_one_or_none()

    async def create(self, data: ProfileCreate) -> Profile:
        if data.is_default:
            await self.db.execute(update(Profile).values(is_default=False))
        profile = Profile(**data.model_dump())
        self.db.add(profile)
        await self.db.flush()
        return profile

    async def update(self, profile_id: str, data: ProfileUpdate) -> Profile | None:
        profile = await self.get_by_id(profile_id)
        if not profile:
            return None
        if data.is_default:
            await self.db.execute(update(Profile).values(is_default=False))
        for field, value in data.model_dump(exclude_none=True).items():
            setattr(profile, field, value)
        await self.db.flush()
        return profile

    async def delete(self, profile_id: str) -> bool:
        profile = await self.get_by_id(profile_id)
        if not profile:
            return False
        await self.db.delete(profile)
        return True

    async def ensure_default_exists(self) -> Profile | None:
        result = await self.db.execute(select(Profile).where(Profile.is_default == True).limit(1))
        return result.scalar_one_or_none()
