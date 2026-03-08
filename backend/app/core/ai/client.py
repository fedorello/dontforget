import httpx
import json
import base64
from typing import Any
from app.core.config import settings
from app.core.ai.prompts import (
    ANALYZE_MEDICINE_SYSTEM,
    ANALYZE_MEDICINE_USER,
    get_recommendation_prompt,
    get_compatibility_prompt,
)


class OpenRouterClient:
    def __init__(self):
        self.base_url = settings.openrouter_base_url
        self.api_key = settings.openrouter_api_key
        self.model = settings.openrouter_model
        self.max_tokens = settings.openrouter_max_tokens
        self.headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://dontforget.app",
            "X-Title": "DontForget App",
        }

    async def _chat(self, messages: list[dict], json_mode: bool = True) -> dict[str, Any]:
        payload = {
            "model": self.model,
            "messages": messages,
            "max_tokens": self.max_tokens,
        }
        if json_mode:
            payload["response_format"] = {"type": "json_object"}

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                f"{self.base_url}/chat/completions",
                headers=self.headers,
                json=payload,
            )
            response.raise_for_status()
            content = response.json()["choices"][0]["message"]["content"]
            return json.loads(content)

    async def analyze_medicine_photo(self, image_base64: str, mime_type: str = "image/jpeg") -> dict:
        """Analyze medicine/supplement photo and extract structured info."""
        if not self.api_key:
            return self._mock_medicine_response()

        messages = [
            {"role": "system", "content": ANALYZE_MEDICINE_SYSTEM},
            {
                "role": "user",
                "content": [
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:{mime_type};base64,{image_base64}"},
                    },
                    {"type": "text", "text": ANALYZE_MEDICINE_USER},
                ],
            },
        ]
        return await self._chat(messages)

    async def analyze_medicine_by_name(self, name: str) -> dict:
        """Analyze medicine by name (no photo)."""
        if not self.api_key:
            return self._mock_medicine_response(name)

        messages = [
            {"role": "system", "content": ANALYZE_MEDICINE_SYSTEM},
            {
                "role": "user",
                "content": f"Medicine name: {name}\n\n{ANALYZE_MEDICINE_USER}",
            },
        ]
        return await self._chat(messages)

    async def get_recommendation(self, medicine_name: str, profile: dict, active_medicines: list[str]) -> dict:
        if not self.api_key:
            return self._mock_recommendation()

        messages = [
            {"role": "system", "content": "You are a helpful medical assistant. Respond in JSON only."},
            {"role": "user", "content": get_recommendation_prompt(medicine_name, profile, active_medicines)},
        ]
        return await self._chat(messages)

    async def check_compatibility(self, new_medicine: str, active_medicines: list[str]) -> dict:
        if not active_medicines:
            return {"overall_status": "ok", "pairs": [], "summary": "No current medications to check against."}

        if not self.api_key:
            return self._mock_compatibility()

        messages = [
            {"role": "system", "content": "You are a pharmacology expert. Respond in JSON only."},
            {"role": "user", "content": get_compatibility_prompt(new_medicine, active_medicines)},
        ]
        return await self._chat(messages)

    # --- Mock responses for dev without API key ---

    def _mock_medicine_response(self, name: str = "Omega-3") -> dict:
        return {
            "name_trade": name,
            "name_generic": f"{name} (generic)",
            "substance": ["Active ingredient"],
            "form": "capsule",
            "dosage_per_unit": "500mg",
            "category": "supplement",
            "action_simple": "Supports cardiovascular health and brain function. Reduces inflammation.",
            "side_effects_top": ["mild stomach upset", "fishy aftertaste", "rare: allergic reaction"],
            "recommended_dose": {
                "amount": "1 capsule",
                "frequency": "once daily",
                "timing": "with meals",
                "course_days": 90,
            },
            "interactions_caution": ["blood thinners"],
            "interactions_avoid": [],
            "contraindications": ["fish allergy"],
        }

    def _mock_recommendation(self) -> dict:
        return {
            "recommended_dose": "1 capsule",
            "recommended_frequency": "once daily",
            "recommended_timing": "morning, with breakfast",
            "recommended_course_days": 90,
            "personalized_note": "Good choice for your age and profile. Take consistently for best results.",
            "compatibility_with_current": {
                "status": "ok",
                "notes": "No known interactions with your current medications.",
            },
        }

    def _mock_compatibility(self) -> dict:
        return {
            "overall_status": "ok",
            "pairs": [],
            "summary": "No significant interactions detected. (Demo mode — add API key for real analysis)",
        }


ai_client = OpenRouterClient()
