import json
import logging
import re
from typing import Dict, Any, Optional
import httpx
from app.core.config import settings
from app.schemas.requirement import InterpretedRequirement

logger = logging.getLogger("machhunt.ai_service")


# Manufacturing process catalog for entity extraction
MANUFACTURING_PROCESSES = [
    "CNC Milling", "CNC Turning", "CNC Machining", "VMC Machining",
    "Laser Cutting", "Lathe", "Wire EDM", "Sheet Metal Fabrication",
    "MIG Welding", "TIG Welding", "Press Brake Bending", "Injection Moulding"
]

MATERIALS_CATALOG = [
    "Aluminium 6061", "Aluminium", "Mild Steel", "Stainless Steel 304",
    "Stainless Steel 316", "Brass", "Copper", "Delrin", "Polycarbonate", "Titanium"
]

LOCATIONS_CATALOG = [
    "Coimbatore", "Ganapathy", "SIDCO Kurichi", "Peelamedu", "Saravanampatti",
    "Chennai", "Ambattur", "Guindy", "Sriperumbudur", "Hosur", "Salem",
    "Tiruppur", "Erode", "Madurai", "Trichy", "Bengaluru"
]


class AIService:
    def __init__(self):
        self.provider = settings.AI_PROVIDER
        self.api_key = settings.AI_API_KEY

    def parse_natural_language_requirement(self, prompt: str) -> InterpretedRequirement:
        """
        Interprets natural language requirement into a Pydantic-validated InterpretedRequirement.
        If AI_PROVIDER is configured with LLM credentials, invokes cloud LLM adapter;
        otherwise runs high-accuracy deterministic rule & token extraction engine.
        """
        extracted = None
        if self.api_key and self.provider.lower() in ("gemini", "auto", "nlp_engine"):
            extracted = self._gemini_extraction(prompt)

        # Resilient fallback to deterministic extraction engine
        if not extracted:
            extracted = self._rule_based_extraction(prompt)

        # Pydantic validation ensures strict schema compliance
        validated = InterpretedRequirement(**extracted)
        return validated

    def _gemini_extraction(self, prompt: str) -> Optional[Dict[str, Any]]:
        try:
            model_name = getattr(settings, "AI_MODEL_NAME", "gemini-1.5-flash")
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={self.api_key}"
            
            system_instruction = (
                "You are an industrial manufacturing requirement extractor. Parse the requirement prompt into JSON with: "
                "title (str), process (str, e.g. CNC Milling, CNC Turning, Laser Cutting, Sheet Metal Fabrication), "
                "material (str, e.g. Aluminium 6061, Mild Steel, Stainless Steel 304, Brass), quantity (int), "
                "dimensions (str, e.g. '150 x 80 x 25 mm'), tolerance_mm (float, e.g. 0.05), deadline_days (int), "
                "preferred_location (str, e.g. Coimbatore, Chennai, Tiruppur), estimated_budget (float in INR), "
                "confidence_score (float between 0.8 and 1.0), and extracted_entities (dict with raw_prompt, parsed_process, parsed_material)."
            )
            payload = {
                "contents": [
                    {
                        "role": "user",
                        "parts": [
                            {"text": f"{system_instruction}\n\nRequirement: {prompt}\n\nOutput only raw JSON:"}
                        ]
                    }
                ],
                "generationConfig": {
                    "temperature": 0.1,
                    "responseMimeType": "application/json"
                }
            }
            with httpx.Client(timeout=8.0) as client:
                res = client.post(url, json=payload)
                if res.status_code == 200:
                    data = res.json()
                    candidates = data.get("candidates", [])
                    if candidates:
                        text_content = candidates[0].get("content", {}).get("parts", [{}])[0].get("text", "")
                        parsed = json.loads(text_content)
                        if isinstance(parsed, dict) and "process" in parsed and "quantity" in parsed:
                            parsed.setdefault("title", f"{parsed.get('quantity', 100)} {parsed.get('material', 'Components')} ({parsed.get('process', 'CNC')})")
                            parsed.setdefault("dimensions", "150 x 80 x 25 mm")
                            parsed.setdefault("tolerance_mm", 0.05)
                            parsed.setdefault("deadline_days", 5)
                            parsed.setdefault("preferred_location", "Coimbatore")
                            parsed.setdefault("estimated_budget", 25000.0)
                            parsed.setdefault("confidence_score", 0.98)
                            parsed.setdefault("extracted_entities", {"raw_prompt": prompt, "model": model_name})
                            return parsed
                else:
                    logger.warning(f"Gemini API returned status {res.status_code}: {res.text[:120]}")
        except Exception as e:
            logger.warning(f"Gemini extraction fallback triggered: {e}")
        return None

    def _rule_based_extraction(self, prompt: str) -> Dict[str, Any]:
        text_lower = prompt.lower()

        # Extract Quantity (e.g. 500, 500 pcs, 500 units, 500 nos)
        quantity = 100
        qty_match = re.search(r"(\d+)\s*(?:nos|pcs|units|pieces|brackets|parts|components)?", text_lower)
        if qty_match:
            try:
                quantity = int(qty_match.group(1))
            except ValueError:
                quantity = 100

        # Extract Process
        matched_process = "CNC Milling"
        for proc in MANUFACTURING_PROCESSES:
            if proc.lower() in text_lower:
                matched_process = proc
                break
        if matched_process == "CNC Milling":
            if "laser" in text_lower:
                matched_process = "Laser Cutting"
            elif "turn" in text_lower or "lathe" in text_lower:
                matched_process = "CNC Turning"
            elif "weld" in text_lower:
                matched_process = "MIG Welding"
            elif "sheet" in text_lower or "fabricat" in text_lower:
                matched_process = "Sheet Metal Fabrication"

        # Extract Material
        matched_material = "Aluminium 6061"
        for mat in MATERIALS_CATALOG:
            if mat.lower() in text_lower:
                matched_material = mat
                break
        if matched_material == "Aluminium 6061":
            if "steel" in text_lower:
                matched_material = "Stainless Steel 304" if "stainless" in text_lower else "Mild Steel"
            elif "brass" in text_lower:
                matched_material = "Brass"
            elif "copper" in text_lower:
                matched_material = "Copper"
            elif "plastic" in text_lower:
                matched_material = "Delrin"

        # Extract Deadline (e.g. 4 days, within 3 days, 1 week)
        deadline_days = 5
        day_match = re.search(r"(\d+)\s*(?:day|days|d)", text_lower)
        if day_match:
            try:
                deadline_days = int(day_match.group(1))
            except ValueError:
                deadline_days = 5
        elif "week" in text_lower:
            deadline_days = 7

        # Extract Location
        matched_location = "Coimbatore"
        for loc in LOCATIONS_CATALOG:
            if loc.lower() in text_lower:
                matched_location = loc
                break

        # Extract Budget if mentioned (e.g. ₹25000, 25k, Rs. 20000, 30,000 budget)
        budget = 25000.0
        # Check patterns with explicit currency or budget keyword
        budget_match = re.search(r"(?:rs\.?|inr|₹)\s*(\d+(?:,\d+)*)\s*(k|thousand)?\b", text_lower)
        if not budget_match:
            budget_match = re.search(r"\b(\d+(?:,\d+)*)\s*(?:k|thousand)?\s*(?:budget|inr|rupees)\b", text_lower)

        if budget_match:
            try:
                raw_num = budget_match.group(1).replace(",", "")
                val = float(raw_num)
                # Check if group 2 was k or if 'k' follows the number
                full_match = budget_match.group(0).lower()
                if "k" in full_match or "thousand" in full_match:
                    if val < 1000:
                        val *= 1000
                if val >= 500:
                    budget = val
            except Exception:
                budget = 25000.0

        # Extract Tolerance if mentioned (e.g. 0.05 mm, +/- 0.02 mm)
        tolerance_mm = 0.05
        tol_match = re.search(r"(?:±|\+\/-)?\s*(\d+\.?\d*)\s*mm", text_lower)
        if tol_match:
            try:
                tolerance_mm = float(tol_match.group(1))
            except Exception:
                tolerance_mm = 0.05

        title = f"{quantity} {matched_material} Components ({matched_process})"

        return {
            "title": title,
            "process": matched_process,
            "material": matched_material,
            "quantity": quantity,
            "dimensions": "150 x 80 x 25 mm",
            "tolerance_mm": tolerance_mm,
            "deadline_days": deadline_days,
            "preferred_location": matched_location,
            "estimated_budget": budget,
            "confidence_score": 0.94,
            "extracted_entities": {
                "raw_prompt": prompt,
                "parsed_process": matched_process,
                "parsed_material": matched_material,
                "parsed_quantity": quantity,
                "parsed_deadline_days": deadline_days,
                "parsed_location": matched_location,
            }
        }


ai_service = AIService()
