import csv
import json
import os
import uuid
from datetime import datetime, timezone, date, timedelta, time
from sqlalchemy.orm import Session
from app.core.database import SessionLocal, engine, Base, run_migrations
from app.core.security import get_password_hash
from app.models import (
    Base, Company, User, UserRole, Business, BusinessDocument, VerificationStatus,
    Machine, MachineCapability, MachineAvailability, MachineStatus,
    Requirement, RequirementStatus, Match, Booking, BookingStatus,
    Payment, PaymentStatus, Review, Notification, AuditLog
)
from app.matching.engine import matching_engine


def get_capacity_specs_for_industry(industry: str, company_name: str, city: str):
    """
    Generate realistic DEMO machine specs, capabilities, and pricing tailored to the industry.
    Clearly marks generated machine attributes as DEMO marketplace capacity.
    """
    ind_lower = industry.lower()
    
    # 1. Precision Engineering / Components / Products
    if "precision" in ind_lower or ("component" in ind_lower and "auto" not in ind_lower and "textile" not in ind_lower):
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
    elif "laser" in ind_lower or ("fabricat" in ind_lower and "sheet" not in ind_lower):
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
    # 3. Pumps / Motors / Valves / Industrial Equipment
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
    # 5. Auto Components / Precision Engineering / Gears
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
    # 6. Compressors / Pneumatics / Drilling / Mining / Testing / Instrumentation / Engineering Works
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


def seed_database():
    print("[*] Initializing Mach-Hunt Master 49-Company Marketplace Database...")
    Base.metadata.create_all(bind=engine)
    run_migrations(engine)
    db: Session = SessionLocal()

    try:
        # Check if already seeded and purge for clean shared marketplace state
        existing_admin = db.query(User).filter(User.email == "admin@machhunt.demo").first()
        if existing_admin:
            print("[INFO] Database already contains records. Refreshing tables for 49-company marketplace...")
            db.query(AuditLog).delete()
            db.query(Notification).delete()
            db.query(Review).delete()
            db.query(Payment).delete()
            db.query(Booking).delete()
            db.query(Match).delete()
            db.query(Requirement).delete()
            db.query(MachineAvailability).delete()
            db.query(MachineCapability).delete()
            db.query(Machine).delete()
            db.query(Company).delete()
            db.query(BusinessDocument).delete()
            db.query(Business).delete()
            db.query(User).delete()
            db.commit()

        # =========================================================================
        # 1. THE 4 DEMO ACCOUNTS + ADMIN & BACKGROUND PROFILES
        # =========================================================================
        print("[1/7] Creating the 4 primary demo users...")
        pw_hash = get_password_hash("password123")

        admin_user = User(
            email="admin@machhunt.demo",
            hashed_password=pw_hash,
            full_name="Pragatheswaran (Admin)",
            phone="+91 98765 00001",
            role=UserRole.ADMIN,
            is_active=True,
            is_verified=True,
        )
        db.add(admin_user)

        # Demo Account 1: Janika (Provider in Coimbatore)
        janika_owner = User(
            email="janika@machhunt.demo",
            hashed_password=pw_hash,
            full_name="Janika",
            phone="+91 94432 12345",
            role=UserRole.PROVIDER,
            is_active=True,
            is_verified=True,
            is_onboarded=True,
            email_verified=True,
            authentication_provider="password",
        )
        db.add(janika_owner)

        # Demo Account 2: Pragatheswaran (Provider in Tiruppur / Coimbatore)
        pragatheswaran_user = User(
            email="pragatheswaran@machhunt.demo",
            hashed_password=pw_hash,
            full_name="Pragatheswaran",
            phone="+91 98765 43210",
            role=UserRole.PROVIDER,
            is_active=True,
            is_verified=True,
            is_onboarded=True,
            email_verified=True,
            authentication_provider="password",
        )
        db.add(pragatheswaran_user)

        # Demo Account 3: Jayanth (Seeker / Provider)
        jayanth_user = User(
            email="jayanth@machhunt.demo",
            hashed_password=pw_hash,
            full_name="Jayanth",
            phone="+91 98432 56789",
            role=UserRole.SEEKER,
            is_active=True,
            is_verified=True,
            is_onboarded=True,
            email_verified=True,
            authentication_provider="password",
        )
        db.add(jayanth_user)

        # Demo Account 4: Reethika (Seeker / Provider)
        reethika_user = User(
            email="reethika@machhunt.demo",
            hashed_password=pw_hash,
            full_name="Reethika",
            phone="+91 97890 12345",
            role=UserRole.SEEKER,
            is_active=True,
            is_verified=True,
            is_onboarded=True,
            email_verified=True,
            authentication_provider="password",
        )
        db.add(reethika_user)

        # Background test profiles
        senthil_owner = User(
            email="senthil@machhunt.demo",
            hashed_password=pw_hash,
            full_name="Senthil Kumar (Provider)",
            phone="+91 98421 98765",
            role=UserRole.PROVIDER,
            is_active=True,
            is_verified=True,
            is_onboarded=True,
            email_verified=True,
            authentication_provider="password",
        )
        db.add(senthil_owner)

        murugan_owner = User(
            email="murugan@machhunt.demo",
            hashed_password=pw_hash,
            full_name="Murugan (Provider)",
            phone="+91 97890 54321",
            role=UserRole.PROVIDER,
            is_active=True,
            is_verified=True,
            is_onboarded=True,
            email_verified=True,
            authentication_provider="password",
        )
        db.add(murugan_owner)

        karthikeyan_seeker = User(
            email="karthikeyan@machhunt.demo",
            hashed_password=pw_hash,
            full_name="Karthikeyan (Seeker)",
            phone="+91 98940 11223",
            role=UserRole.SEEKER,
            is_active=True,
            is_verified=True,
            is_onboarded=True,
            email_verified=True,
            authentication_provider="password",
        )
        db.add(karthikeyan_seeker)
        db.commit()

        # =========================================================================
        # 2. MSME BUSINESSES (DEMO PROVIDER IDENTITY)
        # =========================================================================
        print("[2/7] Registering MSME businesses for the 4 demo accounts...")
        
        # 1. Janika: Kovai Precision Works (Coimbatore)
        kovai_biz = Business(
            user_id=janika_owner.id,
            name="Kovai Precision Works",
            owner_name="Janika",
            phone="+91 94432 12345",
            email="janika@machhunt.demo",
            gstin="33ABCDE1234F1Z5",
            registration_number="UDYAM-TN-03-0012345",
            industry="Aerospace & Automotive Machining",
            address="Plot 14, SIDCO Industrial Estate, Kurichi",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641021",
            latitude=10.9412,
            longitude=76.9723,
            description="ISO 9001 certified precision machining facility specializing in aerospace grade aluminium and high-nickel alloys.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(kovai_biz)

        # 2. Pragatheswaran: Tiruppur Manufacturing Works (Tiruppur)
        kongu_biz = Business(
            user_id=pragatheswaran_user.id,
            name="Tiruppur Manufacturing Works",
            owner_name="Pragatheswaran",
            phone="+91 98765 43210",
            email="pragatheswaran@machhunt.demo",
            gstin="33PRAGA1234F1Z9",
            registration_number="UDYAM-TN-03-0091823",
            industry="Heavy Machining & Precision Garment Tooling",
            address="Plot 22, Textile Machinery & CNC Park, Tiruppur",
            district="Tiruppur",
            state="Tamil Nadu",
            pincode="641603",
            latitude=11.1085,
            longitude=77.3411,
            description="Precision CNC milling, high-speed turning, and precision tooling for garment machinery and automotive assemblies.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(kongu_biz)

        # 3. Jayanth: Hosur Auto Components & Laser Tech
        jayanth_biz = Business(
            user_id=jayanth_user.id,
            name="Hosur Auto Components",
            owner_name="Jayanth",
            phone="+91 98432 56789",
            email="jayanth@machhunt.demo",
            gstin="33JAYAN2345G2Z8",
            registration_number="UDYAM-TN-03-0076543",
            industry="Sheet Metal & Precision Machining",
            address="15, Industrial Automation & Laser Park, Tiruppur",
            district="Tiruppur",
            state="Tamil Nadu",
            pincode="641603",
            latitude=11.1120,
            longitude=77.3450,
            description="High-precision fiber laser cutting, CNC turning, and automated sheet metal fabrication center.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(jayanth_biz)

        # 4. Reethika: Coimbatore Industrial Systems (Coimbatore)
        reethika_biz = Business(
            user_id=reethika_user.id,
            name="Coimbatore Industrial Systems",
            owner_name="Reethika",
            phone="+91 97890 12345",
            email="reethika@machhunt.demo",
            gstin="33REETH3456H3Z7",
            registration_number="UDYAM-TN-03-0065432",
            industry="Industrial Fabrication, Welding & Powder Coating",
            address="42, Ganapathy Industrial Estate, Coimbatore",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641006",
            latitude=11.0350,
            longitude=76.9750,
            description="Full-service industrial manufacturing center with robotic welding, certified powder coating, and micro-machining.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(reethika_biz)

        # Additional background businesses
        cbe_cnc_biz = Business(
            user_id=senthil_owner.id,
            name="Coimbatore CNC Engineering",
            owner_name="Senthil Kumar",
            phone="+91 98421 98765",
            email="info@cbecnc.demo",
            gstin="33BCDEF2345G2Z6",
            registration_number="UDYAM-TN-03-0087654",
            industry="General Engineering & Component Tooling",
            address="88, Ganapathy Industrial Cluster, Coimbatore",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641006",
            latitude=11.0384,
            longitude=76.9744,
            description="Established MSME with multi-axis CNC turning and automated inspection capabilities.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(cbe_cnc_biz)

        apex_laser_biz = Business(
            user_id=murugan_owner.id,
            name="Apex Laser Tech & Fabrication",
            owner_name="Murugan",
            phone="+91 97890 54321",
            email="sales@apexlaser.demo",
            gstin="33CDEFG3456H3Z7",
            registration_number="UDYAM-TN-03-0099887",
            industry="Sheet Metal & Laser Processing",
            address="12/A, Civil Aerodrome Post, Peelamedu, Coimbatore",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641014",
            latitude=11.0289,
            longitude=77.0093,
            description="Fiber laser cutting center for automotive and electrical enclosures.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(apex_laser_biz)

        tamiltech_biz = Business(
            user_id=karthikeyan_seeker.id,
            name="TamilTech Components Pvt Ltd",
            owner_name="Karthikeyan",
            phone="+91 98940 11223",
            email="procurement@tamiltech.demo",
            gstin="33DEFGH4567I4Z8",
            registration_number="UDYAM-TN-03-0055443",
            industry="EV & Renewable Energy Sub-assemblies",
            address="Plot 5, Saravanampatti IT & Tech Corridor, Coimbatore",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641035",
            latitude=11.0797,
            longitude=76.9997,
            description="Product engineering company developing battery management housings and electric drive enclosures.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(tamiltech_biz)
        db.commit()

        # =========================================================================
        # 3. IMPORT 49-COMPANY DATASET INTO DATABASE (COMPANIES & MACHINES)
        # =========================================================================
        csv_file_path = os.path.join(os.path.dirname(__file__), "..", "data", "machhunt_49_companies_master_cleaned.csv")
        print(f"[3/7] Loading 49 companies dataset from: {csv_file_path}")
        
        with open(csv_file_path, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            company_rows = list(reader)

        # Sort deterministically by company_id
        company_rows.sort(key=lambda x: x["company_id"])
        print(f"       Found {len(company_rows)} valid company records.")

        # Upsert Company records
        companies_map = {}
        for r in company_rows:
            comp = Company(
                id=r["company_id"].strip(),
                name=r["company_name"].strip(),
                city=r["city"].strip(),
                state=r["state"].strip() or "Tamil Nadu",
                address=r["address"].strip(),
                latitude=float(r["latitude"].strip()),
                longitude=float(r["longitude"].strip()),
                industry=r["industry"].strip(),
                google_maps_link=r["google_maps_link"].strip(),
            )
            db.add(comp)
            companies_map[comp.id] = comp
        db.commit()
        print(f"       [OK] Upserted {len(companies_map)} companies into 'companies' table.")

        # =========================================================================
        # 4. DETERMINISTIC CAPACITY DISTRIBUTION (13 / 12 / 12 / 12)
        # =========================================================================
        # Janika:         records 0..12  (13 machines)
        # Pragatheswaran: records 13..24 (12 machines)
        # Jayanth:        records 25..36 (12 machines)
        # Reethika:       records 37..48 (12 machines)
        print("[4/7] Generating 49 DEMO capacity listings across the 4 demo providers...")

        provider_distribution = [
            (kovai_biz.id, "Janika", 0, 13),
            (kongu_biz.id, "Pragatheswaran", 13, 25),
            (jayanth_biz.id, "Jayanth", 25, 37),
            (reethika_biz.id, "Reethika", 37, 49),
        ]

        all_machines = []
        photos_stock = [
            "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800",
            "https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=800",
            "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800",
        ]

        for biz_id, provider_label, start_idx, end_idx in provider_distribution:
            assigned_rows = company_rows[start_idx:end_idx]
            print(f"       Assigning {len(assigned_rows)} listings to {provider_label} (indices {start_idx}..{end_idx-1})...")

            for idx, r in enumerate(assigned_rows):
                cid = r["company_id"].strip()
                cname = r["company_name"].strip()
                city = r["city"].strip()
                ind = r["industry"].strip()
                lat = float(r["latitude"].strip())
                lng = float(r["longitude"].strip())
                gurl = r["google_maps_link"].strip()
                addr = r["address"].strip()

                specs = get_capacity_specs_for_industry(ind, cname, city)
                
                # Deterministic machine UUID derived from company_id
                mach_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, f"machhunt.capacity.{cid}"))

                machine = Machine(
                    id=mach_id,
                    business_id=biz_id,
                    company_id=cid,
                    name=specs["name"],
                    category=specs["category"],
                    manufacturer=specs["manufacturer"],
                    model=specs["model"],
                    year=specs["year"],
                    description=specs["description"],
                    dimensions_capacity=specs["dimensions_capacity"],
                    precision_tolerance=specs["precision_tolerance"],
                    operating_parameters=json.dumps(specs["operating_parameters"]),
                    hourly_price=specs["hourly_price"],
                    min_job_value=specs["min_job_value"],
                    operator_available=True,
                    location_address=addr,
                    latitude=lat,
                    longitude=lng,
                    google_maps_link=gurl,
                    photos=json.dumps([photos_stock[(start_idx + idx) % len(photos_stock)]]),
                    status=MachineStatus.ACTIVE,
                    verification_status=VerificationStatus.VERIFIED,
                )
                db.add(machine)
                db.commit()

                # Add capabilities
                for cap in specs["capabilities"]:
                    proc, mat, tol, dx, dy, dz = cap
                    db.add(MachineCapability(
                        machine_id=machine.id,
                        process=proc,
                        material=mat,
                        min_tolerance_mm=tol,
                        max_dimension_x=dx,
                        max_dimension_y=dy,
                        max_dimension_z=dz,
                    ))

                all_machines.append(machine)

        db.commit()
        print(f"       [OK] Successfully created {len(all_machines)} active capacity listings with capabilities.")

        # =========================================================================
        # 5. AVAILABILITY CALENDAR SLOTS (NEXT 30 DAYS FOR ALL 49 MACHINES)
        # =========================================================================
        print("[5/7] Scheduling 30-day operating calendar availability across all 49 machines...")
        today = date.today()
        avail_batch = []
        for offset in range(30):
            day = today + timedelta(days=offset)
            for m in all_machines:
                avail_batch.append(MachineAvailability(
                    machine_id=m.id,
                    date=day,
                    start_time=time(8, 0),
                    end_time=time(20, 0),
                    is_available=True,
                    reason="Standard Production Shift (12 hrs/day)",
                ))
        db.add_all(avail_batch)
        db.commit()
        print(f"       [OK] Generated {len(avail_batch)} availability slot entries.")

        # =========================================================================
        # 6. CROSS-ACCOUNT REQUIREMENTS & EXPLAINABLE MATCHING
        # =========================================================================
        print("[6/7] Creating cross-account requirements and computing AI matches...")

        # Requirement 1: Pragatheswaran as Seeker looking for CNC Machining in Coimbatore
        praga_req = Requirement(
            seeker_id=pragatheswaran_user.id,
            title="500 Aluminium Brackets (CNC Machining)",
            description="Need 500 units custom aerospace brackets, 4-axis CNC machined with tight ±0.01 mm tolerance in Coimbatore.",
            process="CNC Milling",
            material="Aluminium 6061",
            quantity=500,
            dimensions="140 x 75 x 30 mm",
            tolerance_mm=0.01,
            required_date=today + timedelta(days=2),
            delivery_deadline=today + timedelta(days=7),
            preferred_location="Coimbatore",
            latitude=11.0546,
            longitude=76.9839,
            max_distance_km=50.0,
            budget=25000.0,
            quality_requirements="Dimensional inspection certificate required.",
            operator_required=True,
            status=RequirementStatus.OPEN,
        )
        db.add(praga_req)

        # Requirement 2: Reethika as Seeker looking for Laser Cutting in Tiruppur
        reethika_req = Requirement(
            seeker_id=reethika_user.id,
            title="150 Fiber Laser Cut Stainless Steel Panels",
            description="Need 150 units precision 3mm SS304 instrument chassis panels cut with burr-free nitrogen assist.",
            process="Laser Cutting",
            material="Stainless Steel 304",
            quantity=150,
            dimensions="400 x 300 x 3 mm",
            tolerance_mm=0.03,
            required_date=today + timedelta(days=3),
            delivery_deadline=today + timedelta(days=8),
            preferred_location="Tiruppur",
            latitude=11.1085,
            longitude=77.3411,
            max_distance_km=60.0,
            budget=22000.0,
            quality_requirements="Nitrogen clean-cut edges without dross.",
            operator_required=True,
            status=RequirementStatus.OPEN,
        )
        db.add(reethika_req)

        # Requirement 3: Janika as Seeker looking for Garment / Fabric Production in Tiruppur
        janika_req = Requirement(
            seeker_id=janika_owner.id,
            title="1000 Premium Knitted Cotton Garment Panels",
            description="Need 1000 units circular knitted single jersey panels in organic combed cotton yarn.",
            process="Circular Knitting",
            material="Combed Cotton Yarn",
            quantity=1000,
            dimensions="1800 x 1800 mm",
            tolerance_mm=0.1,
            required_date=today + timedelta(days=4),
            delivery_deadline=today + timedelta(days=12),
            preferred_location="Tiruppur",
            latitude=11.0995,
            longitude=77.3185,
            max_distance_km=50.0,
            budget=35000.0,
            quality_requirements="Uniform stitch density and fastness grade 4.",
            operator_required=True,
            status=RequirementStatus.OPEN,
        )
        db.add(janika_req)

        # Requirement 4: Jayanth as Seeker looking for CNC Turning in Coimbatore
        jayanth_req = Requirement(
            seeker_id=jayanth_user.id,
            title="300 CNC Turned Textile Rollers & Shafts",
            description="Precision turned textile drive shafts and bronze bushings for high-speed yarn spinning machines.",
            process="CNC Turning",
            material="Mild Steel",
            quantity=300,
            dimensions="Ø65 x 350 mm",
            tolerance_mm=0.008,
            required_date=today + timedelta(days=2),
            delivery_deadline=today + timedelta(days=9),
            preferred_location="Coimbatore",
            latitude=11.0168,
            longitude=76.9558,
            max_distance_km=40.0,
            budget=20000.0,
            quality_requirements="Runout tolerance within 0.01 mm.",
            operator_required=True,
            status=RequirementStatus.OPEN,
        )
        db.add(jayanth_req)

        # Requirement 5: Karthikeyan (Test Seeker)
        karthik_req = Requirement(
            seeker_id=karthikeyan_seeker.id,
            title="500 Precision Aluminium Mounting Brackets",
            description="Need 500 units of custom aerospace grade 6061-T6 mounting brackets, 4-axis CNC machined with tight ±0.02 mm bore tolerance.",
            process="CNC Milling",
            material="Aluminium 6061",
            quantity=500,
            dimensions="140 x 75 x 30 mm",
            tolerance_mm=0.02,
            required_date=today + timedelta(days=1),
            delivery_deadline=today + timedelta(days=5),
            preferred_location="Coimbatore",
            latitude=11.0546,
            longitude=76.9839,
            max_distance_km=40.0,
            budget=28000.0,
            quality_requirements="CMM Inspection Report required.",
            operator_required=True,
            status=RequirementStatus.OPEN,
        )
        db.add(karthik_req)
        db.commit()

        # Compute matches for all requirements (excluding the seeker's own machines!)
        requirements_to_match = [praga_req, reethika_req, janika_req, jayanth_req, karthik_req]
        for req in requirements_to_match:
            candidates = [m for m in all_machines if m.business.user_id != req.seeker_id]
            ranked = matching_engine.rank_matches(req, candidates, search_location=req.preferred_location)
            for m_res in ranked:
                db.add(Match(
                    requirement_id=req.id,
                    machine_id=m_res.machine_id,
                    overall_score=m_res.overall_score,
                    capability_score=m_res.score_breakdown.capability_score,
                    availability_score=m_res.score_breakdown.availability_score,
                    distance_score=m_res.score_breakdown.distance_score,
                    cost_score=m_res.score_breakdown.cost_score,
                    reliability_score=m_res.score_breakdown.reliability_score,
                    match_reasons=json.dumps(m_res.match_reasons),
                ))
            if ranked:
                req.status = RequirementStatus.MATCHED
        db.commit()
        print("       [OK] AI Matching Engine completed deterministic evaluations.")

        # =========================================================================
        # 7. CROSS-ACCOUNT BOOKINGS (REAL TRANSACTIONAL WORKFLOW)
        # =========================================================================
        print("[7/7] Seeding cross-account bookings and notifications...")
        
        # SCENARIO A: Pragatheswaran has requested a booking on Janika's CBE001 CNC capacity!
        # Janika sees this under "Incoming Capacity Requests" on Provider Dashboard and can click [Accept Request]!
        janika_cbe001_mach = next(m for m in all_machines if m.company_id == "CBE001")
        booking_praga_to_janika = Booking(
            requirement_id=praga_req.id,
            machine_id=janika_cbe001_mach.id,
            seeker_id=pragatheswaran_user.id,
            provider_id=janika_owner.id,
            status=BookingStatus.PENDING,
            start_date=today + timedelta(days=2),
            end_date=today + timedelta(days=5),
            total_hours=15.0,
            unit_price=janika_cbe001_mach.hourly_price,
            total_amount=15.0 * janika_cbe001_mach.hourly_price,
            commission_amount=(15.0 * janika_cbe001_mach.hourly_price) * 0.05,
            provider_payout=(15.0 * janika_cbe001_mach.hourly_price) * 0.95,
            notes="500 Aluminium brackets with aerospace tolerance ±0.01 mm.",
        )
        db.add(booking_praga_to_janika)

        # SCENARIO B: Reethika booked Jayanth's Laser capacity (CBE026 / TPR001) -> Jayanth accepted -> CONFIRMED & ESCROW HELD!
        jayanth_laser_mach = next((m for m in all_machines if m.business_id == jayanth_biz.id and "Laser" in m.category), all_machines[25])
        booking_reethika_to_jayanth = Booking(
            requirement_id=reethika_req.id,
            machine_id=jayanth_laser_mach.id,
            seeker_id=reethika_user.id,
            provider_id=jayanth_user.id,
            status=BookingStatus.CONFIRMED,
            start_date=today + timedelta(days=3),
            end_date=today + timedelta(days=6),
            total_hours=15.0,
            unit_price=jayanth_laser_mach.hourly_price,
            total_amount=15.0 * jayanth_laser_mach.hourly_price,
            commission_amount=(15.0 * jayanth_laser_mach.hourly_price) * 0.05,
            provider_payout=(15.0 * jayanth_laser_mach.hourly_price) * 0.95,
            notes="150 Laser cut instrument panels in SS304. Escrow authorized.",
        )
        db.add(booking_reethika_to_jayanth)

        # SCENARIO C: Janika booked Reethika's Knitting capacity in Tiruppur -> COMPLETED & REVIEWED!
        reethika_knit_mach = next((m for m in all_machines if m.business_id == reethika_biz.id and "Knit" in m.category), all_machines[37])
        booking_janika_to_reethika = Booking(
            requirement_id=janika_req.id,
            machine_id=reethika_knit_mach.id,
            seeker_id=janika_owner.id,
            provider_id=reethika_user.id,
            status=BookingStatus.COMPLETED,
            start_date=today - timedelta(days=7),
            end_date=today - timedelta(days=3),
            total_hours=20.0,
            unit_price=reethika_knit_mach.hourly_price,
            total_amount=20.0 * reethika_knit_mach.hourly_price,
            commission_amount=(20.0 * reethika_knit_mach.hourly_price) * 0.05,
            provider_payout=(20.0 * reethika_knit_mach.hourly_price) * 0.95,
            notes="1000 Circular knitted cotton panels completed with Grade 4 inspection.",
        )
        db.add(booking_janika_to_reethika)

        # SCENARIO D: Karthikeyan booked Janika's capacity (Completed for test verification)
        booking_karthik_to_janika = Booking(
            requirement_id=karthik_req.id,
            machine_id=janika_cbe001_mach.id,
            seeker_id=karthikeyan_seeker.id,
            provider_id=janika_owner.id,
            status=BookingStatus.COMPLETED,
            start_date=today - timedelta(days=10),
            end_date=today - timedelta(days=6),
            total_hours=12.0,
            unit_price=janika_cbe001_mach.hourly_price,
            total_amount=12.0 * janika_cbe001_mach.hourly_price,
            commission_amount=(12.0 * janika_cbe001_mach.hourly_price) * 0.05,
            provider_payout=(12.0 * janika_cbe001_mach.hourly_price) * 0.95,
            notes="Delivered on schedule with CMM verification report.",
        )
        db.add(booking_karthik_to_janika)
        db.commit()

        # Seed Payments
        db.add(Payment(
            booking_id=booking_reethika_to_jayanth.id,
            transaction_id="tx_demo_escrow_123456",
            amount=booking_reethika_to_jayanth.total_amount,
            commission=booking_reethika_to_jayanth.commission_amount,
            provider_payout=booking_reethika_to_jayanth.provider_payout,
            status=PaymentStatus.ESCROW_HOLD,
            provider="razorpay_escrow",
        ))
        db.add(Payment(
            booking_id=booking_janika_to_reethika.id,
            transaction_id="tx_demo_released_789012",
            amount=booking_janika_to_reethika.total_amount,
            commission=booking_janika_to_reethika.commission_amount,
            provider_payout=booking_janika_to_reethika.provider_payout,
            status=PaymentStatus.RELEASED_TO_PROVIDER,
            provider="razorpay_escrow",
        ))

        # Seed Reviews
        db.add(Review(
            booking_id=booking_janika_to_reethika.id,
            reviewer_id=janika_owner.id,
            reviewee_id=reethika_user.id,
            rating=5,
            review_text="Outstanding knitting quality! Flawless loop consistency and delivered 1 day ahead of schedule.",
        ))

        # Seed Notifications
        db.add(Notification(
            user_id=janika_owner.id,
            title="New Capacity Booking Request",
            message=f"Pragatheswaran requested {booking_praga_to_janika.total_hours} hrs on '{janika_cbe001_mach.name}' for Aluminium Brackets.",
            event_type="BOOKING_REQUEST",
            reference_id=booking_praga_to_janika.id,
        ))
        db.add(Notification(
            user_id=pragatheswaran_user.id,
            title="Booking Request Submitted",
            message=f"Your booking request for '{janika_cbe001_mach.name}' has been sent to Janika.",
            event_type="BOOKING_STATUS",
            reference_id=booking_praga_to_janika.id,
        ))

        db.commit()
        print("\n=======================================================")
        print("MACH-HUNT SHARED MARKETPLACE SEEDING COMPLETE!")
        print("  - 49 Real Industrial Companies Imported")
        print("  - 49 Demo Marketplace Capacity Listings Distributed:")
        print("      * Janika (Kovai Precision Works):        13 Listings")
        print("      * Pragatheswaran (Tiruppur Mfg Works):   12 Listings")
        print("      * Jayanth (Hosur Auto Components):       12 Listings")
        print("      * Reethika (Coimbatore Industrial):      12 Listings")
        print("      * Total Capacity Listings:               49 Listings")
        print("  - 33 Distinct Manufacturing Industries Exposed")
        print("  - Cross-Account Bookings & Escrow Payments Initialized")
        print("=======================================================\n")

    except Exception as e:
        db.rollback()
        print(f"[FATAL SEED ERROR] {e}")
        import traceback
        traceback.print_exc()
        raise e
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
