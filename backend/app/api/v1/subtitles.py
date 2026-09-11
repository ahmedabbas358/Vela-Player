import uuid
from typing import List
from fastapi import APIRouter
from app.schemas.subtitle import SubtitleProjectCreateRequest, SubtitleProjectResponse

router = APIRouter(prefix="/subtitles", tags=["Subtitles"])


@router.post("/projects", response_model=SubtitleProjectResponse)
async def create_subtitle_project(payload: SubtitleProjectCreateRequest):
    """Initialize a subtitle project bound to a media hash."""
    project_id = f"proj_{uuid.uuid4().hex[:12]}"
    return SubtitleProjectResponse(
        id=project_id,
        user_id="user_current_mock",
        title=payload.title,
        source_language=payload.source_language,
        target_language=payload.target_language,
        quality_score=100,
        status="ready",
    )


@router.get("/projects", response_model=List[SubtitleProjectResponse])
async def list_subtitle_projects(limit: int = 50, cursor: str = None):
    """List subtitle projects with cursor-based pagination."""
    return [
        SubtitleProjectResponse(
            id="proj_demo1",
            user_id="user_current_mock",
            title="Attack on Titan S04E01",
            source_language="ja",
            target_language="ar",
            quality_score=96,
            status="ready",
        )
    ]
