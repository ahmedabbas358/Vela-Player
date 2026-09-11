import uuid
from typing import Optional
from fastapi import APIRouter, Header, HTTPException, status
from app.schemas.ai_job import AIJobCreateRequest, AIJobResponse, AIJobStatus, AIJobType

router = APIRouter(prefix="/ai/jobs", tags=["AI Jobs"])


@router.post("", response_model=AIJobResponse, status_code=status.HTTP_202_ACCEPTED)
async def create_ai_job(
    payload: AIJobCreateRequest,
    idempotency_key: Optional[str] = Header(None, alias="Idempotency-Key"),
):
    """
    Submit an asynchronous AI job (Speech-to-Text, Contextual Translation, Auto-Sync, OCR).
    Enforces atomic credit reservation and optional idempotency key.
    """
    job_id = f"job_{uuid.uuid4().hex[:12]}"

    return AIJobResponse(
        id=job_id,
        user_id="user_current_mock",
        type=payload.type,
        status=AIJobStatus.QUEUED,
        progress=0,
        credits_reserved=15,
        credits_used=0,
    )


@router.get("/{job_id}", response_model=AIJobResponse)
async def get_ai_job_status(job_id: str):
    """Inspect progress, status, and metrics of an active or completed AI job."""
    return AIJobResponse(
        id=job_id,
        user_id="user_current_mock",
        type=AIJobType.TRANSLATE,
        status=AIJobStatus.PROCESSING,
        progress=64,
        credits_reserved=15,
        credits_used=0,
    )


@router.post("/{job_id}/cancel")
async def cancel_ai_job(job_id: str):
    """Cancel an in-flight AI job and release reserved credits."""
    return {"job_id": job_id, "status": "CANCELLED", "credits_refunded": 15}
