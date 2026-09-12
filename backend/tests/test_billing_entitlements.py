import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_default_free_entitlements():
    res = client.get("/api/v1/billing/entitlements?account_id=new_user_123")
    assert res.status_code == 200
    data = res.json()
    assert data["tier"] == "free"
    assert data["active"] is True
    assert "LOCAL_PLAYBACK_HD_4K" in data["features"]
    assert "ACOUSTIC_SPEECH_AUTO_SYNC" not in data["features"]
    assert data["credits_remaining"] == 0


def test_verify_google_play_pro_purchase():
    payload = {
        "purchase_token": "token_play_pro_xyz789",
        "product_id": "vela.pro.monthly",
        "package_name": "com.velaplayer.app",
        "account_id": "google_user_456",
    }
    res = client.post("/api/v1/billing/google/verify", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["tier"] == "pro"
    assert data["source"] == "google_play"
    assert data["active"] is True
    assert data["auto_renew"] is True
    assert "ACOUSTIC_SPEECH_AUTO_SYNC" in data["features"]
    assert "CHARACTER_AWARE_PALETTE_STYLING" in data["features"]
    assert "SUPER_RESOLUTION_NEURAL_UPSCALE" in data["features"]
    assert data["credits_remaining"] == 1000

    # Verify query for this account reflects PRO
    query_res = client.get("/api/v1/billing/entitlements?account_id=google_user_456")
    assert query_res.status_code == 200
    assert query_res.json()["tier"] == "pro"


def test_verify_apple_storekit2_purchase():
    payload = {
        "signed_payload_jws": "eyJhbGciOiJFUzI1NiJ9.eyJwcm9kdWN0SWQiOiJ2ZWxhLnByby55ZWFybHkifQ.mock_sig",
        "account_id": "apple_user_789",
    }
    res = client.post("/api/v1/billing/apple/verify", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["tier"] == "pro"
    assert data["source"] == "app_store"
    assert data["active"] is True
    assert data["credits_remaining"] == 1000


def test_webhooks_google_and_apple():
    g_res = client.post(
        "/api/v1/billing/webhooks/google-play",
        json={
            "source": "google_play",
            "notification_type": "SUBSCRIPTION_RENEWED",
            "payload": {"token": "sample_token"},
        },
    )
    assert g_res.status_code == 200
    assert g_res.json()["status"] == "ACK"

    a_res = client.post(
        "/api/v1/billing/webhooks/app-store",
        json={
            "source": "app_store",
            "notification_type": "DID_RENEW",
            "payload": {"signedPayload": "sample_jws"},
        },
    )
    assert a_res.status_code == 200
    assert a_res.json()["status"] == "ACK"
