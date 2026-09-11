from typing import List, Optional
from pydantic import BaseModel, Field


class SubtitleCueSchema(BaseModel):
    id: str
    sequence: int
    start_ms: int
    end_ms: int
    text: str
    original_text: Optional[str] = None
    speaker_id: Optional[str] = None
    character_id: Optional[str] = None
    confidence: float = 1.0


class SubtitleProjectCreateRequest(BaseModel):
    title: str
    source_language: str = "en"
    target_language: str = "ar"
    media_hash: Optional[str] = None


class SubtitleProjectResponse(BaseModel):
    id: str
    user_id: str
    title: str
    source_language: str
    target_language: str
    quality_score: int = 100
    status: str = "ready"
