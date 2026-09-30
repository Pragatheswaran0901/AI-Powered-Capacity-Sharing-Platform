import json
from datetime import datetime, timezone, date, timedelta, time
from sqlalchemy.orm import Session
from app.core.database import SessionLocal, engine, Base
from app.core.security import get_password_hash
from app.models import (
    User, UserRole, Business, BusinessDocument, VerificationStatus,
    Machine, MachineCapability, MachineAvailability, MachineStatus,
    Requirement, RequirementStatus, Match, Booking, BookingStatus,
    Payment, PaymentStatus, Review, Notification, AuditLog
)
from app.matching.engine import matching_engine


def seed_database():
    print("[*] Initializing Mach-Hunt Development Seed System...")
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()

    try:
        # Check if already seeded
        existing_admin = db.query(User).filter(User.email == "admin@machhunt.demo").first()
        if existing_admin:
            print("[INFO] Database already contains seed data. Refreshing seed records...")
            # We can purge existing records for clean test state
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
            db.query(BusinessDocument).delete()
            db.query(Business).delete()
            db.query(User).delete()
            db.commit()

        # 1. USERS
        print("[1/7] Creating demo users...")
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

        janika_owner = User(
            email="janika@machhunt.demo",
            hashed_password=pw_hash,
            full_name="Janika (Provider)",
            phone="+91 94432 12345",
            role=UserRole.PROVIDER,
            is_active=True,
            is_verified=True,
            is_onboarded=True,
            email_verified=True,
            authentication_provider="password",
        )
        db.add(janika_owner)

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

        # 2. BUSINESSES
        print("[2/7] Registering MSME businesses...")
        kovai_biz = Business(
            user_id=janika_owner.id,
            name="Kovai Precision Works",
            owner_name="Janika",
            phone="+91 94432 12345",
            email="contact@kovaiprecision.demo",
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

        cbe_cnc_biz = Business(
            user_id=senthil_owner.id,
            name="Coimbatore CNC Engineering",
            owner_name="Senthil Kumar",
            phone="+91 98421 98765",
            email="info@cbecnc.demo",
            gstin="33BCDEF2345G2Z6",
            registration_number="UDYAM-TN-03-0087654",
            industry="General Engineering & Component Tooling",
            address="88, Ganapathy Industrial Cluster, Sathy Road",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641006",
            latitude=11.0384,
            longitude=76.9744,
            description="Established MSME with multi-axis VMCs, CNC turning, and automated inspection capabilities.",
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
            address="12/A, Civil Aerodrome Post, Peelamedu",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641014",
            latitude=11.0289,
            longitude=77.0093,
            description="High precision 4kW and 6kW fiber laser cutting and CNC bending center for automotive and electrical enclosures.",
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
            address="Plot 5, Saravanampatti IT & Tech Corridor",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641035",
            latitude=11.0797,
            longitude=76.9997,
            description="Product engineering company developing battery management housings and electric drive enclosures.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(tamiltech_biz)

        kongu_biz = Business(
            user_id=pragatheswaran_user.id,
            name="Kongu Precision CNC Works",
            owner_name="Pragatheswaran",
            phone="+91 98765 43210",
            email="pragatheswaran@machhunt.demo",
            gstin="33PRAGA1234F1Z9",
            registration_number="UDYAM-TN-03-0091823",
            industry="Aerospace Precision Components",
            address="Plot 22, SIDCO Industrial Estate, Kurichi",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641021",
            latitude=10.9425,
            longitude=76.9730,
            description="Specialized multi-axis CNC manufacturing and high-tolerance aerospace tooling center.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(kongu_biz)

        jayanth_biz = Business(
            user_id=jayanth_user.id,
            name="Jayanth High-Tech Engineering",
            owner_name="Jayanth",
            phone="+91 98432 56789",
            email="jayanth@machhunt.demo",
            gstin="33JAYAN2345G2Z8",
            registration_number="UDYAM-TN-03-0076543",
            industry="Automotive & Textile Components",
            address="15, Textile Machinery & CNC Park, Tiruppur",
            district="Tiruppur",
            state="Tamil Nadu",
            pincode="641603",
            latitude=11.1085,
            longitude=77.3411,
            description="OEM precision machining, tooling, and component manufacturing for textile machinery and automotive parts.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(jayanth_biz)

        reethika_biz = Business(
            user_id=reethika_user.id,
            name="Reethika Precision Tech",
            owner_name="Reethika",
            phone="+91 97890 12345",
            email="reethika@machhunt.demo",
            gstin="33REETH3456H3Z7",
            registration_number="UDYAM-TN-03-0065432",
            industry="Medical Devices & Prototyping",
            address="42, Ganapathy Industrial Estate",
            district="Coimbatore",
            state="Tamil Nadu",
            pincode="641006",
            latitude=11.0350,
            longitude=76.9750,
            description="Precision component engineering with certified clean-room manufacturing and micro-machining.",
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(reethika_biz)
        db.commit()

        # 3. MACHINES & CAPABILITIES
        print("[3/7] Listing manufacturing machines with capabilities...")
        
        # Machine 1: HAAS VF-4SS (Janika - Kovai Precision)
        haas_vf4 = Machine(
            business_id=kovai_biz.id,
            name="HAAS VF-4SS Super-Speed 4-Axis VMC",
            category="CNC Milling",
            manufacturer="HAAS Automation",
            model="VF-4SS",
            year=2023,
            description="High productivity super-speed vertical machining center equipped with Renishaw wireless probing, 12,000 RPM inline direct-drive spindle, and 4th-axis rotary table.",
            dimensions_capacity="1270 x 508 x 635 mm",
            precision_tolerance="±0.005 mm",
            operating_parameters=json.dumps({"spindle_rpm": 12000, "tool_capacity": 30, "coolant": "High-pressure through spindle"}),
            hourly_price=1200.0,
            min_job_value=5000.0,
            operator_available=True,
            location_address="Plot 14, SIDCO Kurichi, Coimbatore",
            latitude=10.9412,
            longitude=76.9723,
            photos=json.dumps([
                "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800",
                "https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=800",
            ]),
            status=MachineStatus.ACTIVE,
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(haas_vf4)
        db.commit()

        db.add_all([
            MachineCapability(machine_id=haas_vf4.id, process="CNC Milling", material="Aluminium 6061", min_tolerance_mm=0.005, max_dimension_x=1270, max_dimension_y=508, max_dimension_z=635),
            MachineCapability(machine_id=haas_vf4.id, process="CNC Milling", material="Aluminium", min_tolerance_mm=0.005, max_dimension_x=1270, max_dimension_y=508, max_dimension_z=635),
            MachineCapability(machine_id=haas_vf4.id, process="CNC Milling", material="Stainless Steel 304", min_tolerance_mm=0.008, max_dimension_x=1270, max_dimension_y=508, max_dimension_z=635),
            MachineCapability(machine_id=haas_vf4.id, process="CNC Machining", material="Brass", min_tolerance_mm=0.010, max_dimension_x=1270, max_dimension_y=508, max_dimension_z=635),
        ])

        # Machine 2: BFW Chakra BMV 60 (Senthil - Coimbatore CNC)
        bfw_chakra = Machine(
            business_id=cbe_cnc_biz.id,
            name="BFW Chakra BMV 60+ Heavy Duty VMC",
            category="CNC Milling",
            manufacturer="Bharat Fritz Werner (BFW)",
            model="Chakra BMV 60+",
            year=2022,
            description="Rigid vertical machining center optimized for steel, alloy, and batch production with BT-50 spindle.",
            dimensions_capacity="1050 x 610 x 610 mm",
            precision_tolerance="±0.01 mm",
            operating_parameters=json.dumps({"spindle_rpm": 8000, "table_load_kg": 1000}),
            hourly_price=850.0,
            min_job_value=3000.0,
            operator_available=True,
            location_address="88, Ganapathy Industrial Cluster, Coimbatore",
            latitude=11.0384,
            longitude=76.9744,
            photos=json.dumps([
                "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800",
            ]),
            status=MachineStatus.ACTIVE,
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(bfw_chakra)
        db.commit()

        db.add_all([
            MachineCapability(machine_id=bfw_chakra.id, process="CNC Milling", material="Mild Steel", min_tolerance_mm=0.01, max_dimension_x=1050, max_dimension_y=610, max_dimension_z=610),
            MachineCapability(machine_id=bfw_chakra.id, process="CNC Milling", material="Aluminium 6061", min_tolerance_mm=0.01, max_dimension_x=1050, max_dimension_y=610, max_dimension_z=610),
            MachineCapability(machine_id=bfw_chakra.id, process="CNC Machining", material="Cast Iron", min_tolerance_mm=0.015, max_dimension_x=1050, max_dimension_y=610, max_dimension_z=610),
        ])

        # Machine 3: Trumpf TruLaser 3030 (Murugan - Apex Laser)
        trumpf_laser = Machine(
            business_id=apex_laser_biz.id,
            name="Trumpf TruLaser 3030 4kW Fiber Laser",
            category="Laser Cutting",
            manufacturer="Trumpf",
            model="TruLaser 3030 Fiber",
            year=2024,
            description="Ultra-high-speed CNC fiber laser cutting machine with automated pallet changer, capable of cutting up to 20mm mild steel and 15mm aluminium.",
            dimensions_capacity="3000 x 1500 mm Sheet Envelope",
            precision_tolerance="±0.03 mm",
            operating_parameters=json.dumps({"laser_power_watts": 4000, "gas_assist": ["Nitrogen", "Oxygen"]}),
            hourly_price=1750.0,
            min_job_value=4000.0,
            operator_available=True,
            location_address="Civil Aerodrome Post, Peelamedu, Coimbatore",
            latitude=11.0289,
            longitude=77.0093,
            photos=json.dumps([
                "https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=800",
            ]),
            status=MachineStatus.ACTIVE,
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(trumpf_laser)
        db.commit()

        db.add_all([
            MachineCapability(machine_id=trumpf_laser.id, process="Laser Cutting", material="Mild Steel", min_tolerance_mm=0.03, max_dimension_x=3000, max_dimension_y=1500, max_dimension_z=20),
            MachineCapability(machine_id=trumpf_laser.id, process="Laser Cutting", material="Stainless Steel 304", min_tolerance_mm=0.03, max_dimension_x=3000, max_dimension_y=1500, max_dimension_z=12),
            MachineCapability(machine_id=trumpf_laser.id, process="Laser Cutting", material="Aluminium 6061", min_tolerance_mm=0.04, max_dimension_x=3000, max_dimension_y=1500, max_dimension_z=10),
        ])

        # Machine 4: Mazak Quick Turn 250 (Senthil - Coimbatore CNC)
        mazak_turn = Machine(
            business_id=cbe_cnc_biz.id,
            name="Mazak Quick Turn 250 CNC Lathe",
            category="CNC Turning",
            manufacturer="Yamazaki Mazak",
            model="QT-250",
            year=2021,
            description="Precision CNC turning center with 8-inch hydraulic chuck, programmable tailstock, and live rotary tooling.",
            dimensions_capacity="Max Turning Dia: 380 mm, Length: 500 mm",
            precision_tolerance="±0.008 mm",
            operating_parameters=json.dumps({"max_rpm": 4500, "chuck_size_inch": 8}),
            hourly_price=650.0,
            min_job_value=2500.0,
            operator_available=True,
            location_address="88, Ganapathy Industrial Cluster, Coimbatore",
            latitude=11.0384,
            longitude=76.9744,
            photos=json.dumps([
                "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800",
            ]),
            status=MachineStatus.ACTIVE,
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(mazak_turn)
        db.commit()

        db.add_all([
            MachineCapability(machine_id=mazak_turn.id, process="CNC Turning", material="Aluminium 6061", min_tolerance_mm=0.008, max_dimension_x=380, max_dimension_y=380, max_dimension_z=500),
            MachineCapability(machine_id=mazak_turn.id, process="CNC Turning", material="Mild Steel", min_tolerance_mm=0.008, max_dimension_x=380, max_dimension_y=380, max_dimension_z=500),
            MachineCapability(machine_id=mazak_turn.id, process="Lathe", material="Brass", min_tolerance_mm=0.010, max_dimension_x=380, max_dimension_y=380, max_dimension_z=500),
        ])
        db.commit()

        # Machine 5: Doosan DNM 5700 (Jayanth - Tiruppur)
        doosan_vmc = Machine(
            business_id=jayanth_biz.id,
            name="Doosan DNM 5700 4-Axis CNC Machining Center",
            category="CNC Milling",
            manufacturer="Doosan Machine Tools",
            model="DNM 5700",
            year=2023,
            description="High-precision 4-axis vertical machining center equipped with high-pressure coolant and rotary table, optimized for precision textile components, automotive brackets, and aerospace aluminium.",
            dimensions_capacity="1050 x 570 x 510 mm",
            precision_tolerance="±0.005 mm",
            operating_parameters=json.dumps({"spindle_rpm": 12000, "tool_capacity": 30, "coolant": "Through Spindle Coolant"}),
            hourly_price=1100.0,
            min_job_value=4000.0,
            operator_available=True,
            location_address="15, Textile Machinery & CNC Park, Tiruppur",
            latitude=11.1085,
            longitude=77.3411,
            photos=json.dumps([
                "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800",
                "https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=800",
            ]),
            status=MachineStatus.ACTIVE,
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(doosan_vmc)
        db.commit()

        db.add_all([
            MachineCapability(machine_id=doosan_vmc.id, process="CNC Milling", material="Aluminium 6061", min_tolerance_mm=0.005, max_dimension_x=1050, max_dimension_y=570, max_dimension_z=510),
            MachineCapability(machine_id=doosan_vmc.id, process="CNC Milling", material="Aluminium", min_tolerance_mm=0.005, max_dimension_x=1050, max_dimension_y=570, max_dimension_z=510),
            MachineCapability(machine_id=doosan_vmc.id, process="CNC Milling", material="Mild Steel", min_tolerance_mm=0.010, max_dimension_x=1050, max_dimension_y=570, max_dimension_z=510),
            MachineCapability(machine_id=doosan_vmc.id, process="CNC Machining", material="Stainless Steel 304", min_tolerance_mm=0.008, max_dimension_x=1050, max_dimension_y=570, max_dimension_z=510),
        ])
        db.commit()

        # Machine 6: LMW Smarturn (Jayanth - Tiruppur)
        lmw_turn = Machine(
            business_id=jayanth_biz.id,
            name="LMW Smarturn CNC Precision Lathe",
            category="CNC Turning",
            manufacturer="Lakshmi Machine Works (LMW)",
            model="Smarturn",
            year=2022,
            description="Rigid CNC turning center built in Coimbatore/Tiruppur region, tailored for high-speed shaft turning, textile rollers, and precision bushings.",
            dimensions_capacity="Max Turning Dia: 320 mm, Length: 400 mm",
            precision_tolerance="±0.008 mm",
            operating_parameters=json.dumps({"max_rpm": 4000, "chuck_size_inch": 8}),
            hourly_price=700.0,
            min_job_value=2500.0,
            operator_available=True,
            location_address="24, Avinashi Road Industrial Area, Tiruppur",
            latitude=11.1120,
            longitude=77.3450,
            photos=json.dumps([
                "https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=800",
            ]),
            status=MachineStatus.ACTIVE,
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(lmw_turn)
        db.commit()

        db.add_all([
            MachineCapability(machine_id=lmw_turn.id, process="CNC Turning", material="Aluminium 6061", min_tolerance_mm=0.008, max_dimension_x=320, max_dimension_y=320, max_dimension_z=400),
            MachineCapability(machine_id=lmw_turn.id, process="CNC Turning", material="Mild Steel", min_tolerance_mm=0.008, max_dimension_x=320, max_dimension_y=320, max_dimension_z=400),
            MachineCapability(machine_id=lmw_turn.id, process="Lathe", material="Brass", min_tolerance_mm=0.010, max_dimension_x=320, max_dimension_y=320, max_dimension_z=400),
        ])
        db.commit()

        # Machine 7: Amada Ensis Fiber Laser (Jayanth - Tiruppur)
        amada_laser = Machine(
            business_id=jayanth_biz.id,
            name="Amada Ensis 3015 3kW Fiber Laser",
            category="Laser Cutting",
            manufacturer="Amada",
            model="Ensis 3015 AJ",
            year=2023,
            description="Energy-efficient 3kW fiber laser cutting with variable beam control for clean cutting in aluminium, mild steel, and stainless sheet metal.",
            dimensions_capacity="3000 x 1500 mm Sheet Envelope",
            precision_tolerance="±0.03 mm",
            operating_parameters=json.dumps({"laser_power_watts": 3000, "beam_mode": "Auto Collimation"}),
            hourly_price=1600.0,
            min_job_value=3500.0,
            operator_available=True,
            location_address="15, Textile Machinery & CNC Park, Tiruppur",
            latitude=11.1085,
            longitude=77.3411,
            photos=json.dumps([
                "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800",
            ]),
            status=MachineStatus.ACTIVE,
            verification_status=VerificationStatus.VERIFIED,
        )
        db.add(amada_laser)
        db.commit()

        db.add_all([
            MachineCapability(machine_id=amada_laser.id, process="Laser Cutting", material="Aluminium 6061", min_tolerance_mm=0.03, max_dimension_x=3000, max_dimension_y=1500, max_dimension_z=8),
            MachineCapability(machine_id=amada_laser.id, process="Laser Cutting", material="Mild Steel", min_tolerance_mm=0.03, max_dimension_x=3000, max_dimension_y=1500, max_dimension_z=16),
            MachineCapability(machine_id=amada_laser.id, process="Sheet Metal Fabrication", material="Stainless Steel 304", min_tolerance_mm=0.04, max_dimension_x=3000, max_dimension_y=1500, max_dimension_z=10),
        ])
        db.commit()

        # 4. AVAILABILITY CALENDAR SLOTS
        print("[4/7] Scheduling operational calendar availability...")
        today = date.today()
        for offset in range(14):
            day = today + timedelta(days=offset)
            # Haas VF-4 has open operational hours
            db.add(MachineAvailability(
                machine_id=haas_vf4.id,
                date=day,
                start_time=time(8, 0),
                end_time=time(20, 0),
                is_available=True,
                reason="Regular Operating Shift (12 hrs/day)",
            ))
            # BFW Chakra
            db.add(MachineAvailability(
                machine_id=bfw_chakra.id,
                date=day,
                start_time=time(9, 0),
                end_time=time(18, 0),
                is_available=True,
                reason="Available Shift",
            ))
            # TruLaser
            db.add(MachineAvailability(
                machine_id=trumpf_laser.id,
                date=day,
                start_time=time(8, 30),
                end_time=time(21, 0),
                is_available=True,
                reason="2 Shifts Open",
            ))
            # Mazak Turn
            db.add(MachineAvailability(
                machine_id=mazak_turn.id,
                date=day,
                start_time=time(9, 0),
                end_time=time(18, 0),
                is_available=True,
                reason="Day Shift",
            ))
            # Doosan VMC (Tiruppur)
            db.add(MachineAvailability(
                machine_id=doosan_vmc.id,
                date=day,
                start_time=time(8, 0),
                end_time=time(20, 0),
                is_available=True,
                reason="Active Production Shift (12 hrs/day)",
            ))
            # LMW Turn (Tiruppur)
            db.add(MachineAvailability(
                machine_id=lmw_turn.id,
                date=day,
                start_time=time(9, 0),
                end_time=time(18, 0),
                is_available=True,
                reason="Available Shift",
            ))
            # Amada Laser (Tiruppur)
            db.add(MachineAvailability(
                machine_id=amada_laser.id,
                date=day,
                start_time=time(8, 30),
                end_time=time(20, 30),
                is_available=True,
                reason="2 Shifts Open",
            ))
        db.commit()

        # 5. SAMPLE REQUIREMENT (Karthikeyan Seeker)
        print("[5/7] Creating demo manufacturing requirement...")
        req = Requirement(
            seeker_id=karthikeyan_seeker.id,
            title="500 Precision Aluminium Mounting Brackets",
            description="Need 500 units of custom aerospace grade 6061-T6 mounting brackets, 4-axis CNC machined with tight ±0.02 mm bore tolerance and deburred edges for drone sub-chassis.",
            process="CNC Milling",
            material="Aluminium 6061",
            quantity=500,
            dimensions="140 x 75 x 30 mm",
            tolerance_mm=0.02,
            required_date=today + timedelta(days=1),
            delivery_deadline=today + timedelta(days=5),
            preferred_location="Saravanampatti, Coimbatore",
            latitude=11.0797,
            longitude=76.9997,
            max_distance_km=40.0,
            budget=28000.0,
            quality_requirements="CMM Inspection Report required for 10% sampling. Mill test certificate for raw material 6061-T6.",
            operator_required=True,
            status=RequirementStatus.OPEN,
        )
        db.add(req)

        praga_req = Requirement(
            seeker_id=pragatheswaran_user.id,
            title="500 Aluminium Components",
            description="Need 500 units of custom precision components, 4-axis CNC machined with tight ±0.02 mm bore tolerance.",
            process="CNC Milling",
            material="Aluminium",
            quantity=500,
            dimensions="140 x 75 x 30 mm",
            tolerance_mm=0.02,
            required_date=today + timedelta(days=1),
            delivery_deadline=today + timedelta(days=7),
            preferred_location="Coimbatore",
            latitude=11.0168,
            longitude=76.9558,
            max_distance_km=50.0,
            budget=25000.0,
            quality_requirements="Dimensional inspection certificate required.",
            operator_required=True,
            status=RequirementStatus.OPEN,
        )
        db.add(praga_req)

        jayanth_req = Requirement(
            seeker_id=jayanth_user.id,
            title="500 Aluminium Components",
            description="Need 500 units of custom precision components, 4-axis CNC machined with tight ±0.02 mm bore tolerance.",
            process="CNC Milling",
            material="Aluminium",
            quantity=500,
            dimensions="140 x 75 x 30 mm",
            tolerance_mm=0.02,
            required_date=today + timedelta(days=1),
            delivery_deadline=today + timedelta(days=7),
            preferred_location="Coimbatore",
            latitude=11.0168,
            longitude=76.9558,
            max_distance_km=50.0,
            budget=25000.0,
            quality_requirements="Dimensional inspection certificate required.",
            operator_required=True,
            status=RequirementStatus.OPEN,
        )
        db.add(jayanth_req)
        db.commit()

        # 6. RUN REAL MATCHING ENGINE FOR THIS REQUIREMENT
        print("[6/7] Running deterministic explainable capacity matching...")
        candidates = [haas_vf4, bfw_chakra, trumpf_laser, mazak_turn, doosan_vmc, lmw_turn, amada_laser]
        matches = matching_engine.rank_matches(req, candidates)

        for m_res in matches:
            db_m = Match(
                requirement_id=req.id,
                machine_id=m_res.machine_id,
                overall_score=m_res.overall_score,
                capability_score=m_res.score_breakdown.capability_score,
                availability_score=m_res.score_breakdown.availability_score,
                distance_score=m_res.score_breakdown.distance_score,
                cost_score=m_res.score_breakdown.cost_score,
                reliability_score=m_res.score_breakdown.reliability_score,
                match_reasons=json.dumps(m_res.match_reasons),
            )
            db.add(db_m)
        req.status = RequirementStatus.MATCHED
        db.commit()

        # 7. SAMPLE COMPLETED BOOKING (FOR REAL STATS, GMV, AND RATINGS)
        print("[7/7] Seeding realistic completed booking and review...")
        prior_date = today - timedelta(days=7)
        past_booking = Booking(
            requirement_id=req.id,
            machine_id=haas_vf4.id,
            seeker_id=karthikeyan_seeker.id,
            provider_id=janika_owner.id,
            status=BookingStatus.COMPLETED,
            start_date=prior_date,
            end_date=prior_date + timedelta(days=3),
            total_hours=16.0,
            unit_price=1200.0,
            total_amount=19200.0,
            commission_amount=960.0,  # 5%
            provider_payout=18240.0,  # 95%
            notes="Previous batch of 350 heatsink flanges completed ahead of schedule with 100% CMM pass rate.",
        )
        db.add(past_booking)
        db.commit()

        # Escrow payment released
        past_payment = Payment(
            booking_id=past_booking.id,
            transaction_id="TXN-ESCROW-PAID-0012",
            provider="escrow_simulated",
            amount=19200.0,
            commission=960.0,
            provider_payout=18240.0,
            status=PaymentStatus.RELEASED_TO_PROVIDER,
        )
        db.add(past_payment)

        # 5-star review from Karthikeyan to Janika
        review = Review(
            booking_id=past_booking.id,
            reviewer_id=karthikeyan_seeker.id,
            reviewee_id=janika_owner.id,
            rating=5,
            review_text="Exceptional precision on our aerospace bracket lot. Tolerances held within ±0.005mm and delivery was 1 day early. Highly recommended provider!",
        )
        db.add(review)

        # In-app notifications
        db.add_all([
            Notification(
                user_id=karthikeyan_seeker.id,
                title="Capacity Matches Ready!",
                message="4 matching machines found for '500 Precision Aluminium Mounting Brackets'. Top match: HAAS VF-4SS (95% Match).",
                event_type="MATCH_FOUND",
                reference_id=req.id,
            ),
            Notification(
                user_id=janika_owner.id,
                title="Payout Credited: ₹18,240",
                message="Escrow funds for completed machining job #19200 have been released to your account.",
                event_type="PAYMENT_RELEASED",
                reference_id=past_booking.id,
            ),
            Notification(
                user_id=admin_user.id,
                title="Platform Milestone",
                message="Total capacity transactions crossed ₹19,200 GMV.",
                event_type="PLATFORM_UPDATE",
                reference_id=past_booking.id,
            )
        ])
        db.commit()

        print("[SUCCESS] Mach-Hunt Seed Data successfully populated!")
        print("-" * 75)
        print("FOUR ACTIVE DEMO ACCOUNTS (AUTH_MODE=demo):")
        print("  1. Janika:         janika@machhunt.demo         / password123 (Kovai Precision Works)")
        print("  2. Pragatheswaran: pragatheswaran@machhunt.demo / password123 (Kongu Precision CNC Works)")
        print("  3. Jayanth:        jayanth@machhunt.demo        / password123 (Jayanth High-Tech Engineering)")
        print("  4. Reethika:       reethika@machhunt.demo       / password123 (Reethika Precision Tech)")
        print("-" * 75)

    except Exception as e:
        db.rollback()
        print(f"[ERROR] Error during database seeding: {e}")
        raise e
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
