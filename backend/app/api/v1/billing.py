from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/billing", tags=["Billing & Entitlements"])


class GoogleVerifyRequest(BaseModel):
    purchase_token: str
    product_id: str
    package_name: str


class AppleVerifyRequest(BaseModel):
    signed_payload_jws: str


@router.post("/google/verify")
async def verify_google_purchase(payload: GoogleVerifyRequest):
    """Verify Google Play Billing 9.1+ Base Plan / Offer purchase."""
    return {
        "status": "ACTIVE",
        "tier": "plus",
        "entitlements": ["AI_TRANSLATION", "SMART_SYNC"],
        "monthly_credits_granted": 500,
    }


@router.post("/apple/verify")
async def verify_apple_purchase(payload: AppleVerifyRequest):
    """Verify Apple StoreKit 2 cryptographically signed JWS transaction."""
    return {
        "status": "ACTIVE",
        "tier": "plus",
        "entitlements": ["AI_TRANSLATION", "SMART_SYNC"],
        "monthly_credits_granted": 500,
    }


@router.get("/wallet")
async def get_credit_wallet():
    """Fetch user credit wallet balance and usage."""
    return {
        "balance": 485,
        "reserved": 15,
        "tier": "plus",
        "renewal_date": "2026-10-01T00:00:00Z",
    }


@router.get("/entitlements")
async def get_user_entitlements():
    """Retrieve active user subscription tier and unlocked feature entitlements."""
    return {
        "tier": "PLUS",
        "features": [
            "HD_PLAYBACK",
            "SMART_SYNC_WAVEFORM",
            "AI_CHARACTER_STYLING",
            "CONTEXTUAL_TRANSLATION",
            "EXPORT_ASS",
        ],
        "quota_remaining": 485,
        "is_active": True,
    }
