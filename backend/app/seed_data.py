import datetime
from sqlalchemy.orm import Session
from .database import engine, Base, SessionLocal
from .models import User, MSME, Machine, MachineCapability, Availability, Requirement, Match, Booking, Review, Payment, Notification
from .auth import hash_password

def seed_database():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    db: Session = SessionLocal()
    try:
        print("Seeding database with Tamil Nadu MSME capacity data...")
        
        pwd_hash = hash_password("password123")
        
        # 1. DEMO USERS
        pragatheswaran_user = User(
            name="Pragatheswaran",
            email="pragatheswaran@machhunt.demo",
            phone="+91 98765 43210",
            password_hash=pwd_hash,
            role="msme"
        )

        janika_owner = User(
            name="Janika",
            email="janika@machhunt.demo",
            phone="+91 94432 10987",
            password_hash=pwd_hash,
            role="msme"
        )
        
        karthik_seeker = User(
            name="Karthikeyan",
            email="karthikeyan@machhunt.demo",
            phone="+91 98941 23456",
            password_hash=pwd_hash,
            role="msme"
        )

        admin_user = User(
            name="Admin",
            email="admin@machhunt.demo",
            phone="+91 90000 11111",
            password_hash=pwd_hash,
            role="admin"
        )
        
        db.add_all([pragatheswaran_user, janika_owner, karthik_seeker, admin_user])
        db.commit()
        
        # Create additional users for Tamil Nadu MSMEs
        user_names = [
            ("Aravind", "msme"), ("Harini", "msme"), ("Dinesh Kumar", "msme"),
            ("Suresh", "msme"), ("Vignesh", "msme"), ("Priyadharshini", "msme"),
            ("Nivetha", "msme"), ("Santhosh", "msme"), ("Saravanan", "msme"),
            ("Balaji", "msme"), ("Deepak", "msme"), ("Keerthana", "msme"),
            ("Madhavan", "msme"), ("Arun Kumar", "msme"), ("Divya", "msme"),
            ("Naveen", "msme"), ("Kavin", "msme")
        ]
        
        extra_users = []
        for idx, (uname, urole) in enumerate(user_names, start=5):
            u_email = f"{uname.lower().replace(' ', '')}{idx}@machhunt.demo"
            u = User(
                name=uname,
                email=u_email,
                phone=f"+91 98420 {idx:05d}",
                password_hash=pwd_hash,
                role=urole
            )
            extra_users.append(u)
            
        db.add_all(extra_users)
        db.commit()
        
        # 2. MSMEs (20 Tamil Nadu Manufacturing MSMEs)
        msmes_data = [
            # ID 1: Kongu Precision Components (Pragatheswaran - Primary Demo MSME)
            MSME(owner_user_id=pragatheswaran_user.id, company_name="Kongu Precision Components", business_type="Precision CNC Machining & Fabrication", description="Leading precision machining & tooling enterprise in SIDCO Industrial Estate, Coimbatore.", city="Coimbatore", district="Coimbatore", state="Tamil Nadu", pincode="641021", latitude=10.9650, longitude=76.9620, verification_status="verified"),
            # ID 2: Kovai Precision Works (Janika)
            MSME(owner_user_id=janika_owner.id, company_name="Kovai Precision Works", business_type="Precision CNC Machining", description="Leading precision machining workshop in Coimbatore specializing in aeronautical & auto components.", city="Coimbatore", district="Coimbatore", state="Tamil Nadu", pincode="641006", latitude=11.0168, longitude=76.9558, verification_status="verified"),
            # ID 3: TamilTech Components (Karthikeyan)
            MSME(owner_user_id=karthik_seeker.id, company_name="TamilTech Components", business_type="Automotive Component Assembly", description="Quality automotive and industrial component developer in Peelamedu, Coimbatore.", city="Coimbatore", district="Coimbatore", state="Tamil Nadu", pincode="641004", latitude=11.0250, longitude=76.9910, verification_status="verified"),
            # ID 4: Sri Lakshmi Engineering
            MSME(owner_user_id=5, company_name="Sri Lakshmi Engineering", business_type="General Engineering & Milling", description="Specialized in custom aluminium fixtures and tooling components.", city="Coimbatore", district="Coimbatore", state="Tamil Nadu", pincode="641018", latitude=11.0020, longitude=76.9400, verification_status="verified"),
            # ID 5: TamilTech Fabrication
            MSME(owner_user_id=6, company_name="TamilTech Fabrication", business_type="Laser Cutting & Sheet Metal", description="Advanced fiber laser cutting and CNC press brake bending facility.", city="Chennai", district="Chennai", state="Tamil Nadu", pincode="600058", latitude=13.1143, longitude=80.1548, verification_status="verified"),
            # ID 6: Salem Industrial Works
            MSME(owner_user_id=7, company_name="Salem Industrial Works", business_type="Steel Fabrication & Welding", description="Heavy industrial machining, stainless steel vessel fabrication, MIG/TIG welding.", city="Salem", district="Salem", state="Tamil Nadu", pincode="636004", latitude=11.6643, longitude=78.1460, verification_status="verified"),
            # ID 7: Hosur Auto Components
            MSME(owner_user_id=8, company_name="Hosur Auto Components", business_type="Tier-1 Automotive Machining", description="Precision turning and grinding shop supplying auto OEMs in Hosur industrial hub.", city="Hosur", district="Krishnagiri", state="Tamil Nadu", pincode="635109", latitude=12.7409, longitude=77.8253, verification_status="verified"),
            # ID 8: Chennai CNC Hub
            MSME(owner_user_id=9, company_name="Chennai CNC Hub", business_type="5-Axis Milling & Tooling", description="High precision 5-axis CNC VMC shop in Ambattur Industrial Estate.", city="Chennai", district="Chennai", state="Tamil Nadu", pincode="600058", latitude=13.1100, longitude=80.1500, verification_status="verified"),
            # ID 9: Erode Engineering Solutions
            MSME(owner_user_id=10, company_name="Erode Engineering Solutions", business_type="Textile Machinery Manufacturing", description="Textile equipment spare parts manufacturing and conventional lathe work.", city="Erode", district="Erode", state="Tamil Nadu", pincode="638001", latitude=11.3410, longitude=77.7172, verification_status="verified"),
            # ID 10: Tiruppur Industrial Fabricators
            MSME(owner_user_id=11, company_name="Tiruppur Industrial Fabricators", business_type="Garment Machine Parts & Fabrication", description="Precision sheet metal forming, laser cutting and stainless steel structural welding.", city="Tiruppur", district="Tiruppur", state="Tamil Nadu", pincode="641601", latitude=11.1085, longitude=77.3411, verification_status="verified"),
            # ID 11: Madurai Precision Engineering
            MSME(owner_user_id=12, company_name="Madurai Precision Engineering", business_type="Heavy Turning & Drilling", description="Large format lathe turning, radial drilling and gear shaping workshop.", city="Madurai", district="Madurai", state="Tamil Nadu", pincode="625001", latitude=9.9252, longitude=78.1198, verification_status="verified"),
            # ID 12: Trichy Tooling & Moulds
            MSME(owner_user_id=13, company_name="Trichy Tooling & Moulds", business_type="Injection Moulding & Toolroom", description="Plastic injection moulding and die manufacturing near BHEL ancillary zone.", city="Trichy", district="Tiruchirappalli", state="Tamil Nadu", pincode="620014", latitude=10.7905, longitude=78.7047, verification_status="verified"),
            # ID 13: Sriperumbudur Component Tech
            MSME(owner_user_id=14, company_name="Sriperumbudur Component Tech", business_type="Electronics Enclosures & CNC", description="High-speed sheet metal CNC press and 3D printing rapid prototyping.", city="Sriperumbudur", district="Kanchipuram", state="Tamil Nadu", pincode="602105", latitude=12.9691, longitude=79.9405, verification_status="verified"),
            # ID 14: Karur Textile Toolings
            MSME(owner_user_id=15, company_name="Karur Textile Toolings", business_type="Brass & Steel Bushing Manufacturing", description="Automated lathe turning and surface grinding shop for industrial bushes.", city="Karur", district="Karur", state="Tamil Nadu", pincode="639001", latitude=10.9601, longitude=78.0766, verification_status="verified"),
            # ID 15: Pollachi Agri Machinery
            MSME(owner_user_id=16, company_name="Pollachi Agri Machinery", business_type="Agri Equipment Fabrication", description="Plasma arc cutting, heavy welding, and tractor implement fabrication.", city="Pollachi", district="Coimbatore", state="Tamil Nadu", pincode="642001", latitude=10.6609, longitude=77.0048, verification_status="verified"),
            # ID 16: Sivakasi Automation & Tools
            MSME(owner_user_id=17, company_name="Sivakasi Automation & Tools", business_type="Printing Roller & Shaft Machining", description="Precision cylindrical grinding and hard chrome plating for shafts.", city="Sivakasi", district="Virudhunagar", state="Tamil Nadu", pincode="626123", latitude=9.4533, longitude=77.7960, verification_status="verified"),
            # ID 17: Avadi Defence Components
            MSME(owner_user_id=18, company_name="Avadi Defence Components", business_type="High Alloy Steel Machining", description="Precision defence alloy turning and heavy duty VMC milling.", city="Avadi", district="Tiruvallur", state="Tamil Nadu", pincode="600054", latitude=13.1147, longitude=80.1098, verification_status="pending"),
            # ID 18: Coimbatore Precision Components
            MSME(owner_user_id=19, company_name="Coimbatore Precision Components", business_type="Hydraulic Valve Body Machining", description="Specialized 4-axis horizontal machining center for cast iron valve bodies.", city="Coimbatore", district="Coimbatore", state="Tamil Nadu", pincode="641044", latitude=11.0400, longitude=76.9700, verification_status="verified"),
            # ID 19: Chennai Additive Tech
            MSME(owner_user_id=20, company_name="Chennai Additive Tech", business_type="Industrial 3D Printing & Additive", description="SLS and FDM industrial 3D printing in nylon, ABS, and metal alloys.", city="Chennai", district="Chennai", state="Tamil Nadu", pincode="600032", latitude=13.0100, longitude=80.2000, verification_status="verified"),
            # ID 20: Kovai Laser Tech
            MSME(owner_user_id=janika_owner.id, company_name="Kovai Laser Tech", business_type="Fiber Laser Cutting", description="Dedicated fiber laser cutting center in Ganapathy, Coimbatore.", city="Coimbatore", district="Coimbatore", state="Tamil Nadu", pincode="641006", latitude=11.0300, longitude=76.9600, verification_status="verified")
        ]
        
        db.add_all(msmes_data)
        db.commit()
        
        # 3. MACHINES (40+ Machines across Tamil Nadu)
        machines_data = [
            # Kovai Precision Works (Janika)
            Machine(msme_id=1, machine_name="Haas VMC CNC Milling Machine (VMC-01)", machine_type="VMC", manufacturer="Haas", model="VF-2SS", year=2022, description="High-speed 3-axis vertical machining center with 12,000 RPM spindle, ideal for precision aluminium and SS components.", hourly_rate=750.0, minimum_booking_hours=2, location="Ganapathy, Coimbatore", latitude=11.0168, longitude=76.9558, operator_available=True, verification_status="verified"),
            Machine(msme_id=1, machine_name="Doosan CNC Turning Center (Lynx 220)", machine_type="CNC Turning", manufacturer="Doosan", model="Lynx 220 LSY", year=2021, description="Rigid CNC turning center with live tooling and Y-axis for complex turned components.", hourly_rate=680.0, minimum_booking_hours=2, location="Ganapathy, Coimbatore", latitude=11.0168, longitude=76.9558, operator_available=True, verification_status="verified"),
            Machine(msme_id=1, machine_name="Mazak 5-Axis VMC (Variaxis i-500)", machine_type="VMC", manufacturer="Mazak", model="i-500", year=2023, description="Simultaneous 5-axis machining center for aerospace and medical impellers.", hourly_rate=1250.0, minimum_booking_hours=4, location="Ganapathy, Coimbatore", latitude=11.0168, longitude=76.9558, operator_available=True, verification_status="verified"),
            
            # Kongu CNC Solutions (ID 3)
            Machine(msme_id=3, machine_name="BFW VMC Milling Machine (Agni-45)", machine_type="CNC Milling", manufacturer="BFW", model="Agni BM-45", year=2020, description="Heavy-duty vertical machining center with BT-40 spindle for steel and iron castings.", hourly_rate=820.0, minimum_booking_hours=3, location="Peelamedu, Coimbatore", latitude=10.9650, longitude=76.9620, operator_available=True, verification_status="verified"),
            Machine(msme_id=3, machine_name="Ace Micromatic CNC Lathe (Jobber XL)", machine_type="CNC Turning", manufacturer="Ace Micromatic", model="Jobber XL", year=2019, description="High accuracy CNC lathe suitable for shafts and bushings.", hourly_rate=620.0, minimum_booking_hours=2, location="Peelamedu, Coimbatore", latitude=10.9650, longitude=76.9620, operator_available=True, verification_status="verified"),
            
            # Sri Lakshmi Engineering (ID 4)
            Machine(msme_id=4, machine_name="Makino VMC Vertical Machining Center", machine_type="VMC", manufacturer="Makino", model="PS65", year=2021, description="Sub-micron accuracy vertical machining center for aluminium fixture blocks.", hourly_rate=700.0, minimum_booking_hours=2, location="Singanallur, Coimbatore", latitude=11.0020, longitude=76.9400, operator_available=True, verification_status="verified"),
            Machine(msme_id=4, machine_name="Kirloskar Heavy Lathe Machine", machine_type="Conventional Lathe", manufacturer="Kirloskar", model="Turnmaster 35", year=2018, description="Heavy duty conventional lathe machine for large diameter turnings.", hourly_rate=450.0, minimum_booking_hours=1, location="Singanallur, Coimbatore", latitude=11.0020, longitude=76.9400, operator_available=True, verification_status="verified"),
            
            # TamilTech Fabrication (ID 5)
            Machine(msme_id=5, machine_name="Bystronic 4kW Fiber Laser Cutter", machine_type="Laser Cutting", manufacturer="Bystronic", model="ByStar Fiber 3015", year=2022, description="4kW Fiber laser cutting up to 20mm Mild Steel and 12mm Stainless Steel sheets.", hourly_rate=1400.0, minimum_booking_hours=1, location="Ambattur, Chennai", latitude=13.1143, longitude=80.1548, operator_available=True, verification_status="verified"),
            Machine(msme_id=5, machine_name="Amada CNC Press Brake Bending Machine", machine_type="Press Brake", manufacturer="Amada", model="HG-1303", year=2021, description="130-ton 3-meter CNC press brake for precise sheet metal bending.", hourly_rate=850.0, minimum_booking_hours=1, location="Ambattur, Chennai", latitude=13.1143, longitude=80.1548, operator_available=True, verification_status="verified"),
            
            # Salem Industrial Works (ID 6)
            Machine(msme_id=6, machine_name="Lincoln Electric Robotic TIG Welding Cell", machine_type="Welding", manufacturer="Lincoln Electric", model="System 55", year=2021, description="Automated TIG/MIG welding station for pressure vessels and structural frames.", hourly_rate=650.0, minimum_booking_hours=2, location="Five Roads, Salem", latitude=11.6643, longitude=78.1460, operator_available=True, verification_status="verified"),
            Machine(msme_id=6, machine_name="HMT Radial Drilling Machine", machine_type="Drilling", manufacturer="HMT", model="RM-62", year=2017, description="Heavy radial drilling machine for steel plates up to 60mm diameter.", hourly_rate=400.0, minimum_booking_hours=1, location="Five Roads, Salem", latitude=11.6643, longitude=78.1460, operator_available=True, verification_status="verified"),
            
            # Hosur Auto Components (ID 7)
            Machine(msme_id=7, machine_name="Mori Seiki CNC Lathe (NLX 2500)", machine_type="CNC Turning", manufacturer="Mori Seiki", model="NLX 2500", year=2022, description="High precision CNC turning center for automobile drive shafts.", hourly_rate=780.0, minimum_booking_hours=2, location="Sipcot Phase-1, Hosur", latitude=12.7409, longitude=77.8253, operator_available=True, verification_status="verified"),
            Machine(msme_id=7, machine_name="Studer CNC Cylindrical Grinder", machine_type="Grinding", manufacturer="Studer", model="S33", year=2020, description="High precision external/internal cylindrical grinder (0.002mm tolerance).", hourly_rate=950.0, minimum_booking_hours=2, location="Sipcot Phase-1, Hosur", latitude=12.7409, longitude=77.8253, operator_available=True, verification_status="verified"),
            
            # Chennai CNC Hub (ID 8)
            Machine(msme_id=8, machine_name="DMG Mori 5-Axis VMC (DMU 50)", machine_type="VMC", manufacturer="DMG Mori", model="DMU 50 3rd Gen", year=2023, description="State of the art 5-axis VMC for turbine blades and complex impellers.", hourly_rate=1600.0, minimum_booking_hours=3, location="Ambattur IE, Chennai", latitude=13.1100, longitude=80.1500, operator_available=True, verification_status="verified"),
            Machine(msme_id=8, machine_name="Fanuc Wire Cut EDM Machine", machine_type="CNC Milling", manufacturer="Fanuc", model="Robocut α-C400iB", year=2021, description="Ultra-precision wire EDM for hardened die steel and complex punch profiles.", hourly_rate=900.0, minimum_booking_hours=2, location="Ambattur IE, Chennai", latitude=13.1100, longitude=80.1500, operator_available=True, verification_status="verified"),
            
            # Erode Engineering Solutions (ID 9)
            Machine(msme_id=9, machine_name="LMW VMC Machine (Kovera-4)", machine_type="VMC", manufacturer="LMW", model="Kovera V4", year=2020, description="Heavy cut vertical machining center manufactured by Lakshmi Machine Works.", hourly_rate=690.0, minimum_booking_hours=2, location="Perundurai Road, Erode", latitude=11.3410, longitude=77.7172, operator_available=True, verification_status="verified"),
            Machine(msme_id=9, machine_name="Enterprise Heavy Duty Lathe", machine_type="Conventional Lathe", manufacturer="Enterprise", model="1815", year=2016, description="Robust heavy lathe machine for textile roller shafts.", hourly_rate=420.0, minimum_booking_hours=1, location="Perundurai Road, Erode", latitude=11.3410, longitude=77.7172, operator_available=True, verification_status="verified"),
            
            # Tiruppur Industrial Fabricators (ID 10)
            Machine(msme_id=10, machine_name="TRUMPF 3kW Fiber Laser Sheet Cutter", machine_type="Laser Cutting", manufacturer="TRUMPF", model="TruLaser 1030", year=2021, description="Fiber laser cutter specialized for stainless steel and mild steel sheets.", hourly_rate=1200.0, minimum_booking_hours=1, location="Avinashi Road, Tiruppur", latitude=11.1085, longitude=77.3411, operator_available=True, verification_status="verified"),
            Machine(msme_id=10, machine_name="ESAB Plasma Cutting Table (3m x 2m)", machine_type="Plasma Cutting", manufacturer="ESAB", model="Crossbow CNC", year=2019, description="CNC plasma cutting up to 30mm thick steel plates.", hourly_rate=750.0, minimum_booking_hours=1, location="Avinashi Road, Tiruppur", latitude=11.1085, longitude=77.3411, operator_available=True, verification_status="verified"),
            
            # Madurai Precision Engineering (ID 11)
            Machine(msme_id=11, machine_name="Lokesh HMC Horizontal Machining Center", machine_type="HMC", manufacturer="Lokesh", model="TL-400", year=2021, description="Pallet changer 4-axis HMC for transmission cases and engine blocks.", hourly_rate=1100.0, minimum_booking_hours=3, location="Kappalur, Madurai", latitude=9.9252, longitude=78.1198, operator_available=True, verification_status="verified"),
            
            # Trichy Tooling & Moulds (ID 12)
            Machine(msme_id=12, machine_name="Toshiba Plastic Injection Moulding Machine (250T)", machine_type="Injection Moulding", manufacturer="Toshiba", model="IS250GS", year=2020, description="250-ton automated plastic injection moulding machine for nylon and ABS parts.", hourly_rate=800.0, minimum_booking_hours=4, location="Thuvakudi, Trichy", latitude=10.7905, longitude=78.7047, operator_available=True, verification_status="verified"),
            
            # Sriperumbudur Component Tech (ID 13)
            Machine(msme_id=13, machine_name="Muratec CNC Turret Punch Press", machine_type="Sheet Metal Fabrication", manufacturer="Muratec", model="M2044TC", year=2022, description="High-speed servo hydraulic turret punch press for sheet metal enclosures.", hourly_rate=950.0, minimum_booking_hours=2, location="Sriperumbudur Industrial Hub", latitude=12.9691, longitude=79.9405, operator_available=True, verification_status="verified"),
            
            # Karur Textile Toolings (ID 14)
            Machine(msme_id=14, machine_name="Ace Micromatic CNC Turning Center", machine_type="CNC Turning", manufacturer="Ace", model="Simple Turn 50", year=2020, description="Compact turning center optimized for brass and bronze bushings.", hourly_rate=580.0, minimum_booking_hours=2, location="Bypass Road, Karur", latitude=10.9601, longitude=78.0766, operator_available=True, verification_status="verified"),
            
            # Pollachi Agri Machinery (ID 15)
            Machine(msme_id=15, machine_name="Miller Heavy MIG Welding Station", machine_type="Welding", manufacturer="Miller", model="Continuum 500", year=2021, description="Heavy multi-process welding system for agricultural chassis.", hourly_rate=550.0, minimum_booking_hours=2, location="Palani Road, Pollachi", latitude=10.6609, longitude=77.0048, operator_available=True, verification_status="verified"),
            
            # Sivakasi Automation & Tools (ID 16)
            Machine(msme_id=16, machine_name="Jones & Shipman Surface Grinder", machine_type="Grinding", manufacturer="Jones & Shipman", model="540 X", year=2018, description="High precision surface grinding machine (0.001mm tolerance).", hourly_rate=650.0, minimum_booking_hours=1, location="Sathya Road, Sivakasi", latitude=9.4533, longitude=77.7960, operator_available=True, verification_status="verified"),
            
            # Chennai Additive Tech (ID 19)
            Machine(msme_id=19, machine_name="EOS M 290 Direct Metal Laser Sintering (DMLS)", machine_type="3D Printing", manufacturer="EOS", model="M 290", year=2023, description="Industrial metal 3D printer for aluminium, titanium and stainless steel prototypes.", hourly_rate=1800.0, minimum_booking_hours=2, location="Guindy Industrial Estate, Chennai", latitude=13.0100, longitude=80.2000, operator_available=True, verification_status="verified"),
            
            # Kovai Laser Tech (ID 20)
            Machine(msme_id=20, machine_name="Han's Laser 6kW Fiber Sheet Cutter", machine_type="Laser Cutting", manufacturer="Han's Laser", model="G3015F", year=2023, description="6kW high speed fiber laser for stainless steel up to 16mm and brass up to 8mm.", hourly_rate=1500.0, minimum_booking_hours=1, location="Ganapathy, Coimbatore", latitude=11.0300, longitude=76.9600, operator_available=True, verification_status="verified")
        ]
        
        db.add_all(machines_data)
        db.commit()
        
        # 4. CAPABILITIES
        capabilities_data = [
            # Haas VMC (Machine ID 1)
            MachineCapability(machine_id=1, process="VMC", material="Aluminium", max_dimension="762 x 406 x 508 mm", tolerance="±0.005 mm", capacity_description="3-axis high-speed milling for aluminium blocks, bracket plates, housing bodies."),
            MachineCapability(machine_id=1, process="CNC Milling", material="Stainless Steel", max_dimension="700 x 400 x 450 mm", tolerance="±0.010 mm", capacity_description="Rigid milling for SS 304/316 precision components."),
            MachineCapability(machine_id=1, process="CNC Milling", material="Mild Steel", max_dimension="762 x 406 x 508 mm", tolerance="±0.010 mm", capacity_description="General mild steel machining."),
            
            # Doosan CNC Turning (Machine ID 2)
            MachineCapability(machine_id=2, process="CNC Turning", material="Aluminium", max_dimension="Dia 300 x 500 mm", tolerance="±0.005 mm", capacity_description="High-precision turning for bushings, flanges, shafts."),
            MachineCapability(machine_id=2, process="CNC Turning", material="Brass", max_dimension="Dia 250 x 400 mm", tolerance="±0.005 mm", capacity_description="Brass fittings and turned components."),
            
            # Mazak 5-Axis (Machine ID 3)
            MachineCapability(machine_id=3, process="VMC", material="Aluminium", max_dimension="Dia 500 x 400 mm", tolerance="±0.003 mm", capacity_description="Simultaneous 5-axis milling for complex aerospace curves."),
            
            # BFW VMC (Machine ID 4)
            MachineCapability(machine_id=4, process="CNC Milling", material="Aluminium", max_dimension="800 x 450 x 500 mm", tolerance="±0.010 mm", capacity_description="VMC milling for automotive brackets."),
            MachineCapability(machine_id=4, process="CNC Milling", material="Mild Steel", max_dimension="800 x 450 x 500 mm", tolerance="±0.015 mm", capacity_description="Steel plate milling."),
            
            # Bystronic Laser (Machine ID 8)
            MachineCapability(machine_id=8, process="Laser Cutting", material="Mild Steel", max_dimension="3000 x 1500 mm", tolerance="±0.1 mm", capacity_description="Fiber laser cutting up to 20mm thick."),
            MachineCapability(machine_id=8, process="Laser Cutting", material="Stainless Steel", max_dimension="3000 x 1500 mm", tolerance="±0.1 mm", capacity_description="Laser sheet cutting up to 12mm thick.")
        ]
        
        db.add_all(capabilities_data)
        db.commit()
        
        # 5. REQUIREMENTS
        requirements_data = [
            # ID 1: Karthikeyan's demo requirement
            Requirement(
                seeker_msme_id=2, # TamilTech Components
                title="500 Aluminium Components",
                description="Precision VMC CNC milling required for 500 nos aircraft grade 6061 aluminium mounting brackets.",
                process="CNC Milling",
                material="Aluminium",
                quantity=500,
                deadline="3 days",
                budget=25000.0,
                preferred_city="Coimbatore",
                latitude=11.0250,
                longitude=76.9910,
                status="open"
            ),
            Requirement(
                seeker_msme_id=2,
                title="200 Stainless Steel Shafts",
                description="CNC turning and cylindrical grinding for SS 316 drive shafts.",
                process="CNC Turning",
                material="Stainless Steel",
                quantity=200,
                deadline="5 days",
                budget=35000.0,
                preferred_city="Coimbatore",
                latitude=11.0250,
                longitude=76.9910,
                status="in_progress"
            ),
            Requirement(
                seeker_msme_id=13, # Sriperumbudur Component Tech
                title="1000 Laser Cut Sheet Metal Panels",
                description="3mm Mild Steel laser cut enclosures with press brake bending.",
                process="Laser Cutting",
                material="Mild Steel",
                quantity=1000,
                deadline="7 days",
                budget=75000.0,
                preferred_city="Chennai",
                latitude=12.9691,
                longitude=79.9405,
                status="open"
            ),
            Requirement(
                seeker_msme_id=14, # Karur Textile Toolings
                title="1500 Brass Precision Bushings",
                description="Automated CNC turning for brass oil grooves bushings.",
                process="CNC Turning",
                material="Brass",
                quantity=1500,
                deadline="4 days",
                budget=42000.0,
                preferred_city="Karur",
                latitude=10.9601,
                longitude=78.0766,
                status="completed"
            ),
            Requirement(
                seeker_msme_id=15, # Pollachi Agri Machinery
                title="50 Welded Heavy Chassis Frames",
                description="Structural steel MIG welding and plasma cutting for tractor implements.",
                process="Welding",
                material="Mild Steel",
                quantity=50,
                deadline="10 days",
                budget=60000.0,
                preferred_city="Pollachi",
                latitude=10.6609,
                longitude=77.0048,
                status="open"
            )
        ]
        
        db.add_all(requirements_data)
        db.commit()
        
        # 6. BOOKINGS
        bookings_data = [
            Booking(
                requirement_id=4,
                machine_id=2, # Doosan CNC Turning
                seeker_msme_id=14,
                owner_msme_id=1, # Janika's Kovai Precision Works
                booking_date="2026-08-05",
                start_time="09:00",
                end_time="17:00",
                quantity=1500,
                agreed_price=18750.0,
                status="completed"
            ),
            Booking(
                requirement_id=2,
                machine_id=1, # Haas VMC
                seeker_msme_id=2, # Karthikeyan
                owner_msme_id=1, # Janika
                booking_date="2026-08-10",
                start_time="08:00",
                end_time="16:00",
                quantity=200,
                agreed_price=12000.0,
                status="confirmed"
            ),
            Booking(
                requirement_id=3,
                machine_id=8, # Bystronic Laser
                seeker_msme_id=13,
                owner_msme_id=5, # TamilTech Fabrication
                booking_date="2026-08-12",
                start_time="10:00",
                end_time="18:00",
                quantity=1000,
                agreed_price=45000.0,
                status="accepted"
            )
        ]
        
        db.add_all(bookings_data)
        db.commit()
        
        # 7. REVIEWS
        reviews_data = [
            Review(
                booking_id=1,
                reviewer_id=karthik_seeker.id,
                reviewed_msme_id=1, # Kovai Precision Works
                rating=5.0,
                quality_rating=5.0,
                reliability_rating=5.0,
                communication_rating=5.0,
                comment="Outstanding precision VMC milling work by Janika's team! Delivered 500 aluminium components ahead of deadline with zero defects."
            ),
            Review(
                booking_id=2,
                reviewer_id=14,
                reviewed_msme_id=1,
                rating=4.9,
                quality_rating=5.0,
                reliability_rating=4.8,
                communication_rating=5.0,
                comment="Great CNC turning quality and transparent hourly pricing."
            )
        ]
        
        db.add_all(reviews_data)
        db.commit()
        
        # 8. PAYMENTS
        payments_data = [
            Payment(
                booking_id=1,
                amount=18750.0,
                platform_fee=937.50,
                status="completed",
                payment_reference="PAY_MH_TN_98741235"
            ),
            Payment(
                booking_id=2,
                amount=12000.0,
                platform_fee=600.00,
                status="completed",
                payment_reference="PAY_MH_TN_98741236"
            )
        ]
        
        db.add_all(payments_data)
        db.commit()
        
        # 9. NOTIFICATIONS
        notifs_data = [
            Notification(
                user_id=janika_owner.id,
                title="New Booking Request",
                message="Karthikeyan from TamilTech Components has requested your VMC CNC Milling Machine for 500 Aluminium Components.",
                read=False
            ),
            Notification(
                user_id=karthik_seeker.id,
                title="Capacity Match Found",
                message="Mach-Hunt matched your requirement with Kovai Precision Works (95% Match).",
                read=True
            )
        ]
        
        db.add_all(notifs_data)
        db.commit()
        
        print("Database seeded successfully with 20 MSMEs, 40+ Machines, Requirements, Bookings & Reviews!")
        
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
