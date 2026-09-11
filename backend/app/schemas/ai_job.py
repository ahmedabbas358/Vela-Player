from enum import Enum
from typing import Any, Dict, Optional
from pydantic import BaseModel, Field


class AIJobType(str, Enum):
    TRANSCRIBE = "TRANSCRIBE"
    TRANSLATE = "TRANSLATE"
    SYNC = "SYNC"
    REPAIR = "REPAIR"
    OCR = "OCR"
    DIARIZE = "DIARIZE"


class AIJobStatus(str, Enum):
    CREATED = "CREATED"
    QUEUED = "QUEUED"
    PREPARING = "PREPARING"
    UPLOADING = "UPLOADING"
    PROCESSING = "PROCESSING"
    POST_PROCESSING = "POST_PROCESSING"
    REVIEW_REQUIRED = "REVIEW_REQUIRED"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"
    EXPIRED = "EXPIRED"


class AIJobCreateRequest(BaseModel):
    project_id: str
    type: AIJobType
    parameters: Dict[str, Any] = Field(default_factory=dict)
    max_credits_allowed: int = 100


class AIJobResponse(BaseModel):
    id: str
    user_id: str
    type: AIJobType
    status: AIJobStatus
    progress: int = 0
    credits_reserved: int = 0
    credits_used: int = 0
    error_code: Optional[str] = None
    error_message: Optional[str] = None
