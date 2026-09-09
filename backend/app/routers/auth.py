from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import User, MSME
from ..schemas import Token, UserCreate, LoginRequest, UserResponse
from ..auth import hash_password, verify_password, create_access_token, get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login", response_model=Token)
def login(credentials: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == credentials.email.lower()).first()
    if not user or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
        
    msme = db.query(MSME).filter(MSME.owner_user_id == user.id).first()
    
    access_token = create_access_token(data={"sub": user.id, "role": user.role})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "role": user.role,
        "msme_id": msme.id if msme else None,
        "company_name": msme.company_name if msme else None
    }

@router.post("/register", response_model=Token)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == user_data.email.lower()).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
        
    new_user = User(
        name=user_data.name,
        email=user_data.email.lower(),
        phone=user_data.phone,
        password_hash=hash_password(user_data.password),
        role=user_data.role
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    msme_id = None
    company_name = None
    if user_data.company_name:
        new_msme = MSME(
            owner_user_id=new_user.id,
            company_name=user_data.company_name,
            business_type="Manufacturing MSME",
            description=f"Manufacturing unit owned by {new_user.name}",
            city=user_data.city or "Coimbatore",
            district=user_data.city or "Coimbatore",
            state="Tamil Nadu",
            verification_status="verified"
        )
        db.add(new_msme)
        db.commit()
        db.refresh(new_msme)
        msme_id = new_msme.id
        company_name = new_msme.company_name

    access_token = create_access_token(data={"sub": new_user.id, "role": new_user.role})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": new_user.id,
        "name": new_user.name,
        "email": new_user.email,
        "role": new_user.role,
        "msme_id": msme_id,
        "company_name": company_name
    }

@router.get("/me")
def get_me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    msme = db.query(MSME).filter(MSME.owner_user_id == current_user.id).first()
    return {
        "user_id": current_user.id,
        "name": current_user.name,
        "email": current_user.email,
        "role": current_user.role,
        "msme_id": msme.id if msme else None,
        "company_name": msme.company_name if msme else None,
        "verification_status": msme.verification_status if msme else "unverified"
    }
