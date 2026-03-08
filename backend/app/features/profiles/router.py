from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.features.profiles.repository import ProfileRepository
from app.features.profiles.schemas import ProfileCreate, ProfileUpdate, ProfileResponse
from app.shared.exceptions import NotFoundError

router = APIRouter(prefix="/profiles", tags=["profiles"])


@router.get("/", response_model=list[ProfileResponse])
async def list_profiles(db: AsyncSession = Depends(get_db)):
    repo = ProfileRepository(db)
    return await repo.get_all()


@router.post("/", response_model=ProfileResponse, status_code=201)
async def create_profile(data: ProfileCreate, db: AsyncSession = Depends(get_db)):
    repo = ProfileRepository(db)
    return await repo.create(data)


@router.get("/{profile_id}", response_model=ProfileResponse)
async def get_profile(profile_id: str, db: AsyncSession = Depends(get_db)):
    repo = ProfileRepository(db)
    profile = await repo.get_by_id(profile_id)
    if not profile:
        raise NotFoundError("Profile")
    return profile


@router.patch("/{profile_id}", response_model=ProfileResponse)
async def update_profile(profile_id: str, data: ProfileUpdate, db: AsyncSession = Depends(get_db)):
    repo = ProfileRepository(db)
    profile = await repo.update(profile_id, data)
    if not profile:
        raise NotFoundError("Profile")
    return profile


@router.delete("/{profile_id}", status_code=204)
async def delete_profile(profile_id: str, db: AsyncSession = Depends(get_db)):
    repo = ProfileRepository(db)
    if not await repo.delete(profile_id):
        raise NotFoundError("Profile")
