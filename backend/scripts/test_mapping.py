import csv
import json
import os
import uuid

def get_capacity_specs_for_industry(industry: str, company_name: str, city: str):
    """
    Generate realistic DEMO machine specs, capabilities, and pricing tailored to the industry.
    """
    ind_lower = industry.lower()
    
    # 1. Precision Engineering / Components / Products
    if "precision" in ind_lower or "component" in ind_lower and "auto" not in ind_lower and "textile" not in ind_lower:
        category = "CNC Milling"
        name = f"HAAS VF-4SS Super-Speed 4-Axis VMC [DEMO - {company_name}]"
        mfr = "HAAS Automation"
        model = "VF-4SS"
        desc = f"DEMO CAPACITY: High-precision 4-axis VMC equipped with Renishaw wireless probing and 12,000 RPM inline spindle at {company_name} ({city})."
        dim = "1270 x 508 x 635 mm"
        tol = "±0.005 mm"
        params = {"spindle_rpm": 12000, "tool_capacity": 30, "coolant": "Through-Spindle High Pressure"}
        price = 1200.0
        caps = [
            ("CNC Milling", "Aluminium 6061", 0.005, 1270, 508, 635),
            ("CNC Milling", "Stainless Steel 316", 0.008, 1270, 508, 635),
            ("Precision Machining", "Brass", 0.010, 1000, 500, 500),
        ]
    # 2. Laser Cutting / Fabrication
    elif "laser" in ind_lower or "fabricat" in ind_lower and "sheet" not in ind_lower:
        category = "Laser Cutting"
        name = f"Trumpf TruLaser 3030 4kW Fiber Laser [DEMO - {company_name}]"
        mfr = "Trumpf"
        model = "TruLaser 3030 Fiber"
        desc = f"DEMO CAPACITY: High-speed 4kW fiber laser cutting center with auto pallet shuttle and nitrogen assist at {company_name} ({city})."
        dim = "3000 x 1500 mm Sheet Envelope"
        tol = "±0.03 mm"
        params = {"laser_power_watts": 4000, "gas_assist": ["Nitrogen", "Oxygen"]}
        price = 1600.0
        caps = [
            ("Laser Cutting", "Mild Steel", 0.03, 3000, 1500, 20),
            ("Laser Cutting", "Stainless Steel 304", 0.03, 3000, 1500, 12),
            ("Laser Cutting", "Aluminium 6061", 0.04, 3000, 1500, 10),
        ]
    # 3. Pumps / Motors / Valves / Foundry
    elif "pump" in ind_lower or "motor" in ind_lower or "valve" in ind_lower:
        category = "CNC Machining"
        name = f"Mazak Quick Turn 250 Heavy CNC Turning Center [DEMO - {company_name}]"
        mfr = "Yamazaki Mazak"
        model = "QT-250"
        desc = f"DEMO CAPACITY: Heavy-duty CNC lathe tailored for pump impellers, motor shafts, and valve bodies at {company_name} ({city})."
        dim = "Max Turning Dia: 380 mm, Length: 500 mm"
        tol = "±0.008 mm"
        params = {"max_rpm": 4500, "chuck_size_inch": 10, "tool_stations": 12}
        price = 950.0
        caps = [
            ("CNC Turning", "Cast Iron", 0.010, 380, 380, 500),
            ("CNC Turning", "Stainless Steel 316", 0.008, 380, 380, 500),
            ("CNC Machining", "Gunmetal / Bronze", 0.012, 380, 380, 500),
        ]
    # 4. Foundry
    elif "foundry" in ind_lower:
        category = "Foundry & Casting"
        name = f"Inductotherm 1-Ton Medium Frequency Melting Line [DEMO - {company_name}]"
        mfr = "Inductotherm"
        model = "VIP Power-Trak"
        desc = f"DEMO CAPACITY: Industrial induction melting and automated sand casting facility at {company_name} ({city})."
        dim = "Mould Size: 800 x 600 x 400 mm"
        tol = "±0.5 mm as-cast"
        params = {"melt_capacity_kg_hr": 1000, "lining": "Silica / Neutral"}
        price = 1400.0
        caps = [
            ("Casting", "Grey Iron FG 260", 0.5, 800, 600, 400),
            ("Casting", "Ductile Iron 500/7", 0.5, 800, 600, 400),
            ("Pattern Making", "Aluminium Alloy", 0.2, 800, 600, 400),
        ]
    # 5. Auto Components / Precision Engineering
    elif "auto" in ind_lower or "gear" in ind_lower or "transmission" in ind_lower:
        category = "CNC Turning"
        name = f"LMW Smarturn Precision CNC Lathe [DEMO - {company_name}]"
        mfr = "Lakshmi Machine Works"
        model = "Smarturn-Twin"
        desc = f"DEMO CAPACITY: High-volume CNC turning center for automotive transmission pins, bushes, and gear blanks at {company_name} ({city})."
        dim = "Max Turning Dia: 320 mm, Length: 400 mm"
        tol = "±0.006 mm"
        params = {"max_rpm": 5000, "rapid_traverse_m_min": 30}
        price = 850.0
        caps = [
            ("CNC Turning", "Alloy Steel 20MnCr5", 0.006, 320, 320, 400),
            ("CNC Turning", "Mild Steel", 0.008, 320, 320, 400),
            ("CNC Turning", "Aluminium 6061", 0.006, 320, 320, 400),
        ]
    # 6. Air Compressors / Pneumatics / Drilling / Mining / Testing / Instrumentation / Engineering Works
    elif any(k in ind_lower for k in ["compressor", "pneumatic", "drill", "mining", "test", "instrument", "engineering"]):
        category = "CNC Milling"
        name = f"BFW Chakra BMV 60+ Heavy Duty VMC [DEMO - {company_name}]"
        mfr = "Bharat Fritz Werner"
        model = "Chakra BMV 60+"
        desc = f"DEMO CAPACITY: Heavy-duty BT-50 vertical machining center for compressor housings, pneumatic blocks, and industrial tooling at {company_name} ({city})."
        dim = "1050 x 610 x 610 mm"
        tol = "±0.008 mm"
        params = {"spindle_rpm": 8000, "table_load_kg": 1000}
        price = 1050.0
        caps = [
            ("CNC Milling", "Cast Iron", 0.010, 1050, 610, 610),
            ("CNC Milling", "Mild Steel", 0.008, 1050, 610, 610),
            ("CNC Machining", "Aluminium 6061", 0.006, 1050, 610, 610),
        ]
    # 7. Knitting / Knitwear
    elif "knit" in ind_lower:
        category = "Knitting & Fabric Production"
        name = f"Mayer & Cie High-Speed Circular Knitting Machine [DEMO - {company_name}]"
        mfr = "Mayer & Cie"
        model = "Relanit 3.2 II"
        desc = f"DEMO CAPACITY: 30-inch circular single-jersey knitting plant with 96 feeders for premium cotton and elastane fabrics at {company_name} ({city})."
        dim = "Diameter: 30 inch, Gauge: 28 GG"
        tol = "Uniform loop density ±1.5%"
        params = {"speed_rpm": 35, "feeders": 96, "structure": "Single Jersey / Pique"}
        price = 800.0
        caps = [
            ("Circular Knitting", "Combed Cotton Yarn", 0.05, 1800, 1800, 0),
            ("Rib Knitting", "Cotton / Spandex", 0.05, 1800, 1800, 0),
            ("Fabric Cutting", "Knitted Fabric", 0.1, 1800, 1800, 0),
        ]
    # 8. Dyeing / Finishing
    elif "dye" in ind_lower or "finish" in ind_lower:
        category = "Textile Dyeing & Wet Processing"
        name = f"Fongs Eco-Soft Low-Liquor Fabric Dyeing Unit [DEMO - {company_name}]"
        mfr = "Fongs National"
        model = "TECWIN High Temp"
        desc = f"DEMO CAPACITY: High-temperature low-liquor ratio soft-flow dyeing vessel with automated recipe controller at {company_name} ({city})."
        dim = "Batch Capacity: 500 kg"
        tol = "Color fastness Grade 4-5"
        params = {"liquor_ratio": "1:4.5", "max_temp_c": 135}
        price = 900.0
        caps = [
            ("Fabric Dyeing", "Cotton Knitted Fabric", 0.1, 2000, 2000, 0),
            ("Bleaching", "Organic Cotton", 0.1, 2000, 2000, 0),
            ("Compacting", "Knitted Tubular Fabric", 0.1, 2000, 2000, 0),
        ]
    # 9. Textile / Garment / Garment Manufacturing / Export
    else:
        category = "Garment & Textile Production"
        name = f"Juki Automated Multi-Needle Stitching & Overlock Line [DEMO - {company_name}]"
        mfr = "Juki Corporation"
        model = "MF-7923 / DDL-9000C"
        desc = f"DEMO CAPACITY: Automated 12-station industrial garment stitching, overlock, and flatlock line at {company_name} ({city})."
        dim = "Table Length: 12 meters, 12 Stations"
        tol = "Stitch count 12-14 SPI"
        params = {"max_speed_spm": 5000, "stations": 12, "feed": "Differential"}
        price = 750.0
        caps = [
            ("Stitching", "Cotton Knitted Fabric", 0.1, 1500, 1000, 0),
            ("Fabric Cutting", "Woven / Knitted", 0.2, 2000, 1200, 0),
            ("Garment Finishing", "Cotton Blends", 0.1, 1200, 800, 0),
        ]

    return {
        "category": category,
        "name": name,
        "manufacturer": mfr,
        "model": model,
        "year": 2023,
        "description": desc,
        "dimensions_capacity": dim,
        "precision_tolerance": tol,
        "operating_parameters": params,
        "hourly_price": price,
        "min_job_value": price * 3.0,
        "capabilities": caps,
    }

print("Tested get_capacity_specs_for_industry successfully!")
