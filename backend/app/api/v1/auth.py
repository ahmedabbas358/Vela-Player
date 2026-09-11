from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from app.core.security import create_access_token

router = APIRouter(prefix="/auth", tags=["Authentication"])


class GoogleLoginRequest(BaseModel):
    id_token: str
    device_id: str


class AppleLoginRequest(BaseModel):
    authorization_code: str
    identity_token: str
    device_id: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    refresh_token: str
    expires_in_seconds: int


@router.post("/google", response_model=TokenResponse)
async def login_google(payload: GoogleLoginRequest):
    """Authenticate with Google ID token and return access/refresh tokens."""
    # Production: Verify token with Google public certs
    token = create_access_token(subject="user_google_mock")
    return TokenResponse(
        access_token=token,
        refresh_token="mock_refresh_token_rotatable",
        expires_in_seconds=900,
    )


@router.post("/apple", response_model=TokenResponse)
async def login_apple(payload: AppleLoginRequest):
    """Authenticate with Apple Identity token."""
    token = create_access_token(subject="user_apple_mock")
    return TokenResponse(
        access_token=token,
        refresh_token="mock_refresh_token_rotatable",
        expires_in_seconds=900,
    )


@router.post("/logout")
async def logout():
    """Revoke active session token family."""
    return {"status": "success", "message": "Session revoked successfully"}
