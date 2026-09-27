# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.user import UserOut, UserUpdate
from app.repositories.user_repo import UserRepository
from app.core.security import get_password_hash

router = APIRouter()


@router.get("/profile", response_model=UserOut)
def get_profile(current_user: User = Depends(get_current_user)):
    biz_id = current_user.business.id if current_user.business else None
    biz_name = current_user.business.name if current_user.business else None
    return UserOut(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name,
        phone=current_user.phone,
        role=current_user.role,
        is_active=current_user.is_active,
        is_verified=current_user.is_verified,
        created_at=current_user.created_at,
        business_id=biz_id,
        business_name=biz_name,
    )


@router.put("/profile", response_model=UserOut)
def update_profile(
    update_in: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    repo = UserRepository(db)
    if update_in.full_name is not None:
        current_user.full_name = update_in.full_name
    if update_in.phone is not None:
        current_user.phone = update_in.phone
    if update_in.password:
        current_user.hashed_password = get_password_hash(update_in.password)

    saved = repo.update(current_user)
    biz_id = saved.business.id if saved.business else None
    biz_name = saved.business.name if saved.business else None
    return UserOut(
        id=saved.id,
        email=saved.email,
        full_name=saved.full_name,
        phone=saved.phone,
        role=saved.role,
        is_active=saved.is_active,
        is_verified=saved.is_verified,
        created_at=saved.created_at,
        business_id=biz_id,
        business_name=biz_name,
    )
