from datetime import datetime, timezone
from typing import List, Optional
from pydantic import BaseModel, Field


class EntitlementTier:
    FREE = "free"
    PLUS = "plus"
    PRO = "pro"


class PurchaseSource:
    GOOGLE_PLAY = "google_play"
    APP_STORE = "app_store"
    TEST = "test"


class EntitlementState(BaseModel):
    """
    Canonical Entitlement State model (Specification Section 18).
    Never trust a local boolean for premium gating.
    """
    tier: str = Field(default=EntitlementTier.FREE, description="Active subscription tier: free, plus, or pro")
    source: str = Field(default=PurchaseSource.TEST, description="Origin: google_play, app_store, or test")
    active: bool = Field(default=False, description="Whether the user is currently entitled to the tier")
    expires_at: Optional[str] = Field(default=None, description="ISO-8601 expiration timestamp")
    auto_renew: bool = Field(default=False, description="Whether subscription auto-renews at period end")
    grace_period: bool = Field(default=False, description="In store grace period following billing issue")
    billing_issue: bool = Field(default=False, description="Payment retry / declined card state")
    revoked: bool = Field(default=False, description="Whether purchase was revoked or refunded by store")
    last_validated_at: str = Field(
        default_factory=lambda: datetime.now(timezone.utc).isoformat(),
        description="Timestamp of last server-side cryptographic validation"
    )
    features: List[str] = Field(default_factory=list, description="List of granular capability flags")
    monthly_credits_granted: int = Field(default=0, description="AI compute credits quota for billing cycle")
    credits_remaining: int = Field(default=0, description="Available remaining credits")


class GoogleVerifyRequest(BaseModel):
    purchase_token: str
    product_id: str
    package_name: str
    account_id: Optional[str] = None


class AppleVerifyRequest(BaseModel):
    signed_payload_jws: str
    account_id: Optional[str] = None


class StoreWebhookNotification(BaseModel):
    source: str
    notification_type: str
    payload: dict
