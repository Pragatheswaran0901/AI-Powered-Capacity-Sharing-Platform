from fastapi import APIRouter
from app.api.auth.router import router as auth_router
from app.api.users.router import router as users_router
from app.api.businesses.router import router as businesses_router
from app.api.machines.router import router as machines_router
from app.api.requirements.router import router as requirements_router
from app.api.matching.router import router as matching_router
from app.api.bookings.router import router as bookings_router
from app.api.payments.router import router as payments_router
from app.api.reviews.router import router as reviews_router
from app.api.notifications.router import router as notifications_router
from app.api.admin.router import router as admin_router
from app.api.companies.router import router as companies_router, get_industries

api_router = APIRouter()

api_router.include_router(auth_router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users_router, prefix="/users", tags=["Users"])
api_router.include_router(businesses_router, prefix="/businesses", tags=["Businesses"])
api_router.include_router(machines_router, prefix="/machines", tags=["Machines"])
api_router.include_router(companies_router, prefix="/companies", tags=["Industrial Locations & Companies"])
api_router.add_api_route("/industries", get_industries, methods=["GET"], tags=["Industrial Locations & Companies"])
api_router.include_router(requirements_router, prefix="/requirements", tags=["Requirements & AI"])
api_router.include_router(matching_router, prefix="/matches", tags=["Capacity Matching"])
api_router.include_router(bookings_router, prefix="/bookings", tags=["Bookings"])
api_router.include_router(payments_router, prefix="/payments", tags=["Payments & Escrow"])
api_router.include_router(reviews_router, prefix="/reviews", tags=["Reviews & Trust"])
api_router.include_router(notifications_router, prefix="/notifications", tags=["Notifications"])
api_router.include_router(admin_router, prefix="/admin", tags=["Admin Oversight"])
