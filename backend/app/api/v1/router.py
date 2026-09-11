from fastapi import APIRouter
from app.api.v1 import auth, ai_jobs, subtitles, billing

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(ai_jobs.router)
api_router.include_router(subtitles.router)
api_router.include_router(billing.router)
