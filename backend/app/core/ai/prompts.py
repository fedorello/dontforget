ANALYZE_MEDICINE_SYSTEM = """You are a medical information assistant.
Analyze images of medicine/supplement packaging and extract structured information.
Always respond in valid JSON format only, no markdown.
Be concise and factual. Use simple, clear language for descriptions."""

ANALYZE_MEDICINE_USER = """Analyze this medicine/supplement image and extract:
{
  "name_trade": "brand name",
  "name_generic": "generic/INN name",
  "substance": ["active ingredient 1", "active ingredient 2"],
  "form": "tablet|capsule|syrup|drops|injection|cream|other",
  "dosage_per_unit": "amount per unit e.g. 500mg",
  "category": "medicine|supplement|vitamin|mineral|probiotic|other",
  "action_simple": "what it does in 1-2 simple sentences",
  "side_effects_top": ["most common side effect 1", "side effect 2", "side effect 3"],
  "recommended_dose": {
    "amount": "e.g. 1 tablet",
    "frequency": "e.g. 2 times daily",
    "timing": "e.g. after meals",
    "course_days": 30
  },
  "interactions_caution": ["drug/substance to be careful with"],
  "interactions_avoid": ["drug/substance to avoid completely"],
  "contraindications": ["pregnancy", "children under 12"]
}

If information is not visible, use reasonable defaults based on the medicine name.
Return ONLY the JSON object, nothing else."""


def get_recommendation_prompt(medicine_name: str, profile: dict, active_medicines: list[str]) -> str:
    active_str = ", ".join(active_medicines) if active_medicines else "none"
    return f"""Based on this profile:
- Age: {profile.get('age', 'unknown')} years
- Gender: {profile.get('gender', 'unknown')}
- Weight: {profile.get('weight_kg', 'unknown')} kg
- Health notes: {profile.get('health_notes', 'none')}
- Allergies: {profile.get('allergies', 'none')}
- Currently taking: {active_str}

Provide personalized recommendation for: {medicine_name}

Respond in JSON:
{{
  "recommended_dose": "specific dose for this person",
  "recommended_frequency": "how many times per day",
  "recommended_timing": "when to take (morning/evening/with food etc)",
  "recommended_course_days": 30,
  "personalized_note": "1-2 sentences specific to this person's profile",
  "compatibility_with_current": {{
    "status": "ok|caution|danger",
    "notes": "compatibility notes with current medicines"
  }}
}}
Return ONLY the JSON object."""


def get_compatibility_prompt(new_medicine: str, active_medicines: list[str]) -> str:
    active_str = ", ".join(active_medicines)
    return f"""Check drug compatibility between:
New medicine: {new_medicine}
Currently taking: {active_str}

Respond in JSON:
{{
  "overall_status": "ok|caution|danger",
  "pairs": [
    {{
      "medicine": "name of interacting medicine",
      "status": "ok|caution|danger",
      "note": "brief explanation"
    }}
  ],
  "summary": "one sentence overall assessment"
}}
Return ONLY the JSON object."""
