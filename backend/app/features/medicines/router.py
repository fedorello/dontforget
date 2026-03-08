from fastapi import APIRouter, Depends, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
import base64
from app.core.database import get_db
from app.core.ai.client import ai_client
from app.features.medicines.repository import MedicineKBRepository, ProfileMedicineRepository, IntakeLogRepository
from app.features.medicines.schemas import (
    MedicineKBResponse, AnalyzeByNameRequest, AnalyzePhotoRequest,
    ProfileMedicineCreate, ProfileMedicineUpdate, ProfileMedicineResponse,
    CompatibilityRequest, IntakeLogUpdate, TodayScheduleItem,
)
from app.shared.exceptions import NotFoundError

router = APIRouter(prefix="/medicines", tags=["medicines"])


@router.post("/analyze/name", response_model=MedicineKBResponse)
async def analyze_by_name(req: AnalyzeByNameRequest, db: AsyncSession = Depends(get_db)):
    """Analyze medicine by name using AI and save to Knowledge Base."""
    kb_repo = MedicineKBRepository(db)
    existing = await kb_repo.search_by_name(req.name)
    if existing:
        return existing[0]
    ai_data = await ai_client.analyze_medicine_by_name(req.name)
    return await kb_repo.create_from_ai(ai_data)


@router.post("/analyze/photo", response_model=MedicineKBResponse)
async def analyze_by_photo(req: AnalyzePhotoRequest, db: AsyncSession = Depends(get_db)):
    """Analyze medicine photo using AI and save to Knowledge Base."""
    kb_repo = MedicineKBRepository(db)
    ai_data = await ai_client.analyze_medicine_photo(req.image_base64, req.mime_type)
    name = ai_data.get("name_trade", "")
    if name:
        existing = await kb_repo.search_by_name(name)
        if existing:
            return existing[0]
    return await kb_repo.create_from_ai(ai_data)


@router.get("/kb/search")
async def search_kb(q: str, db: AsyncSession = Depends(get_db)):
    kb_repo = MedicineKBRepository(db)
    return await kb_repo.search_by_name(q)


@router.get("/kb/{kb_id}", response_model=MedicineKBResponse)
async def get_kb_entry(kb_id: str, db: AsyncSession = Depends(get_db)):
    kb_repo = MedicineKBRepository(db)
    entry = await kb_repo.get_by_id(kb_id)
    if not entry:
        raise NotFoundError("Medicine")
    return entry


@router.post("/compatibility")
async def check_compatibility(req: CompatibilityRequest, db: AsyncSession = Depends(get_db)):
    """Check compatibility of new medicine with profile's active medicines."""
    pm_repo = ProfileMedicineRepository(db)
    active_names = await pm_repo.get_active_names_for_profile(req.profile_id)
    result = await ai_client.check_compatibility(req.new_medicine_name, active_names)
    return result


@router.get("/profile/{profile_id}", response_model=list[ProfileMedicineResponse])
async def get_profile_medicines(profile_id: str, active_only: bool = False, db: AsyncSession = Depends(get_db)):
    pm_repo = ProfileMedicineRepository(db)
    return await pm_repo.get_by_profile(profile_id, active_only=active_only)


@router.post("/profile", response_model=ProfileMedicineResponse, status_code=201)
async def add_medicine_to_profile(data: ProfileMedicineCreate, db: AsyncSession = Depends(get_db)):
    pm_repo = ProfileMedicineRepository(db)
    return await pm_repo.create(data)


@router.patch("/profile/{pm_id}", response_model=ProfileMedicineResponse)
async def update_profile_medicine(pm_id: str, data: ProfileMedicineUpdate, db: AsyncSession = Depends(get_db)):
    pm_repo = ProfileMedicineRepository(db)
    pm = await pm_repo.update(pm_id, data)
    if not pm:
        raise NotFoundError("ProfileMedicine")
    return pm


@router.delete("/profile/{pm_id}", status_code=204)
async def delete_profile_medicine(pm_id: str, db: AsyncSession = Depends(get_db)):
    pm_repo = ProfileMedicineRepository(db)
    if not await pm_repo.delete(pm_id):
        raise NotFoundError("ProfileMedicine")


@router.get("/recommend/{medicine_kb_id}")
async def get_recommendation(medicine_kb_id: str, profile_id: str, db: AsyncSession = Depends(get_db)):
    """Get AI personalized recommendation for medicine + profile."""
    from app.features.profiles.repository import ProfileRepository
    from app.features.profiles.models import Profile

    kb_repo = MedicineKBRepository(db)
    kb = await kb_repo.get_by_id(medicine_kb_id)
    if not kb:
        raise NotFoundError("Medicine")

    profile_repo = ProfileRepository(db)
    profile = await profile_repo.get_by_id(profile_id)
    if not profile:
        raise NotFoundError("Profile")

    pm_repo = ProfileMedicineRepository(db)
    active_names = await pm_repo.get_active_names_for_profile(profile_id)

    profile_dict = {
        "age": profile.age,
        "gender": profile.gender,
        "weight_kg": profile.weight_kg,
        "health_notes": profile.health_notes,
        "allergies": profile.allergies,
    }
    return await ai_client.get_recommendation(kb.name_trade, profile_dict, active_names)


@router.get("/schedule/today/{profile_id}", response_model=list[TodayScheduleItem])
async def get_today_schedule(profile_id: str, db: AsyncSession = Depends(get_db)):
    """Get today's medicine schedule for a profile."""
    from datetime import datetime, date
    pm_repo = ProfileMedicineRepository(db)
    log_repo = IntakeLogRepository(db)
    kb_repo = MedicineKBRepository(db)

    active_pms = await pm_repo.get_by_profile(profile_id, active_only=True)
    today_logs = await log_repo.get_today_for_profile(profile_id)
    logs_by_pm = {log.profile_medicine_id: log for log in today_logs}

    items = []
    for pm in active_pms:
        kb = await kb_repo.get_by_id(pm.medicine_kb_id)
        for time_str in pm.times_json:
            log = logs_by_pm.get(pm.id)
            items.append(TodayScheduleItem(
                profile_medicine_id=pm.id,
                medicine_name=pm.medicine_name,
                dose=pm.dose,
                scheduled_time=time_str,
                action_simple=kb.action_simple if kb else None,
                status=log.status if log else "pending",
                log_id=log.id if log else None,
            ))
    return sorted(items, key=lambda x: x.scheduled_time)


@router.patch("/logs/{log_id}")
async def update_intake_log(log_id: str, data: IntakeLogUpdate, db: AsyncSession = Depends(get_db)):
    log_repo = IntakeLogRepository(db)
    log = await log_repo.update_status(log_id, data.status)
    if not log:
        raise NotFoundError("IntakeLog")
    return log
