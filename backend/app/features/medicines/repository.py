from __future__ import annotations
from datetime import date, datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from app.features.medicines.models import MedicineKB, ProfileMedicine, IntakeLog
from app.features.medicines.schemas import ProfileMedicineCreate, ProfileMedicineUpdate


class MedicineKBRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_id(self, kb_id: str) -> MedicineKB | None:
        result = await self.db.execute(select(MedicineKB).where(MedicineKB.id == kb_id))
        return result.scalar_one_or_none()

    async def search_by_name(self, name: str) -> list[MedicineKB]:
        result = await self.db.execute(
            select(MedicineKB).where(MedicineKB.name_trade.ilike(f"%{name}%")).limit(10)
        )
        return list(result.scalars().all())

    async def create_from_ai(self, ai_data: dict) -> MedicineKB:
        kb = MedicineKB(
            name_trade=ai_data.get("name_trade", "Unknown"),
            name_generic=ai_data.get("name_generic"),
            substance=ai_data.get("substance", []),
            form=ai_data.get("form", "capsule"),
            dosage_per_unit=ai_data.get("dosage_per_unit"),
            category=ai_data.get("category", "supplement"),
            action_simple=ai_data.get("action_simple"),
            side_effects_top=ai_data.get("side_effects_top", []),
            recommended_dose=ai_data.get("recommended_dose", {}),
            interactions_caution=ai_data.get("interactions_caution", []),
            interactions_avoid=ai_data.get("interactions_avoid", []),
            contraindications=ai_data.get("contraindications", []),
            source="ai_extracted",
        )
        self.db.add(kb)
        await self.db.flush()
        return kb


class ProfileMedicineRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_profile(self, profile_id: str, active_only: bool = False) -> list[ProfileMedicine]:
        q = select(ProfileMedicine).where(ProfileMedicine.profile_id == profile_id)
        if active_only:
            q = q.where(ProfileMedicine.is_active == True)
        q = q.order_by(ProfileMedicine.created_at.desc())
        result = await self.db.execute(q)
        return list(result.scalars().all())

    async def get_by_id(self, pm_id: str) -> ProfileMedicine | None:
        result = await self.db.execute(select(ProfileMedicine).where(ProfileMedicine.id == pm_id))
        return result.scalar_one_or_none()

    async def create(self, data: ProfileMedicineCreate) -> ProfileMedicine:
        pm = ProfileMedicine(**data.model_dump())
        self.db.add(pm)
        await self.db.flush()
        return pm

    async def update(self, pm_id: str, data: ProfileMedicineUpdate) -> ProfileMedicine | None:
        pm = await self.get_by_id(pm_id)
        if not pm:
            return None
        for field, value in data.model_dump(exclude_none=True).items():
            setattr(pm, field, value)
        await self.db.flush()
        return pm

    async def delete(self, pm_id: str) -> bool:
        pm = await self.get_by_id(pm_id)
        if not pm:
            return False
        await self.db.delete(pm)
        return True

    async def get_active_names_for_profile(self, profile_id: str) -> list[str]:
        pms = await self.get_by_profile(profile_id, active_only=True)
        return [pm.medicine_name for pm in pms]

    async def increment_units_taken(self, pm_id: str) -> None:
        pm = await self.get_by_id(pm_id)
        if pm:
            pm.units_taken += 1
            await self.db.flush()


class IntakeLogRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_today_for_profile(self, profile_id: str) -> list[IntakeLog]:
        today_start = datetime.combine(date.today(), datetime.min.time())
        today_end = datetime.combine(date.today(), datetime.max.time())
        result = await self.db.execute(
            select(IntakeLog)
            .join(ProfileMedicine, IntakeLog.profile_medicine_id == ProfileMedicine.id)
            .where(
                and_(
                    ProfileMedicine.profile_id == profile_id,
                    IntakeLog.scheduled_at >= today_start,
                    IntakeLog.scheduled_at <= today_end,
                )
            )
            .order_by(IntakeLog.scheduled_at)
        )
        return list(result.scalars().all())

    async def create(self, profile_medicine_id: str, scheduled_at: datetime) -> IntakeLog:
        log = IntakeLog(profile_medicine_id=profile_medicine_id, scheduled_at=scheduled_at)
        self.db.add(log)
        await self.db.flush()
        return log

    async def update_status(self, log_id: str, status: str) -> IntakeLog | None:
        result = await self.db.execute(select(IntakeLog).where(IntakeLog.id == log_id))
        log = result.scalar_one_or_none()
        if log:
            log.status = status
            if status == "taken":
                log.taken_at = datetime.utcnow()
            await self.db.flush()
        return log
