import re
from typing import Dict, Any

PROCESS_KEYWORDS = {
    "cnc milling": "CNC Milling",
    "milling": "CNC Milling",
    "vmc": "VMC",
    "hmc": "HMC",
    "cnc turning": "CNC Turning",
    "turning": "CNC Turning",
    "lathe": "Conventional Lathe",
    "laser": "Laser Cutting",
    "laser cutting": "Laser Cutting",
    "plasma": "Plasma Cutting",
    "press brake": "Press Brake",
    "welding": "Welding",
    "fabrication": "Sheet Metal Fabrication",
    "sheet metal": "Sheet Metal Fabrication",
    "grinding": "Grinding",
    "drilling": "Drilling",
    "3d print": "3D Printing",
    "3d printing": "3D Printing",
    "injection": "Injection Moulding"
}

MATERIAL_KEYWORDS = {
    "aluminium": "Aluminium",
    "aluminum": "Aluminium",
    "mild steel": "Mild Steel",
    "ms": "Mild Steel",
    "stainless steel": "Stainless Steel",
    "ss": "Stainless Steel",
    "carbon steel": "Carbon Steel",
    "brass": "Brass",
    "copper": "Copper",
    "nylon": "Nylon",
    "abs": "ABS",
    "delrin": "POM / Delrin",
    "pom": "POM / Delrin",
    "acrylic": "Acrylic"
}

CITY_KEYWORDS = [
    "coimbatore", "chennai", "hosur", "salem", "tiruppur", "erode", "madurai",
    "trichy", "sriperumbudur", "ambattur", "avadi", "pollachi", "karur", "sivakasi"
]

def parse_natural_language_requirement(prompt: str) -> Dict[str, Any]:
    prompt_lower = prompt.lower()
    
    # 1. Process Extraction
    detected_process = "CNC Milling"
    for kw, process_name in PROCESS_KEYWORDS.items():
        if kw in prompt_lower:
            detected_process = process_name
            break

    # 2. Material Extraction
    detected_material = "Aluminium"
    for kw, material_name in MATERIAL_KEYWORDS.items():
        if kw in prompt_lower:
            detected_material = material_name
            break

    # 3. Quantity Extraction (e.g. 500, 500 pcs, 1000 units)
    detected_quantity = 500
    qty_match = re.search(r'(\d+)\s*(?:nos|pcs|pieces|units|components|brackets|parts|quantity)?', prompt_lower)
    if qty_match:
        val = int(qty_match.group(1))
        if val > 0:
            detected_quantity = val

    # 4. Deadline Extraction (e.g. 3 days, 1 week, within 5 days)
    detected_deadline = "3 days"
    deadline_match = re.search(r'(\d+)\s*(?:days?|weeks?|hours?)', prompt_lower)
    if deadline_match:
        detected_deadline = f"{deadline_match.group(0)}"

    # 5. Budget Extraction (e.g. ₹25,000, 25000, rs 25000)
    detected_budget = 25000.0
    budget_match = re.search(r'(?:₹|rs\.?|inr)\s*([\d,]+)', prompt_lower)
    if budget_match:
        num_str = budget_match.group(1).replace(',', '')
        detected_budget = float(num_str)

    # 6. Location Extraction
    detected_city = "Coimbatore"
    for city in CITY_KEYWORDS:
        if city in prompt_lower:
            detected_city = city.capitalize()
            break

    # Title generation
    generated_title = f"{detected_quantity} {detected_material} {detected_process} Components"

    return {
        "title": generated_title,
        "description": prompt,
        "process": detected_process,
        "material": detected_material,
        "quantity": detected_quantity,
        "deadline": detected_deadline,
        "budget": detected_budget,
        "preferred_city": detected_city
    }
