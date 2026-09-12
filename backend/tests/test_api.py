import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health_live():
    response = client.get("/health/live")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["service"] == "vela-backend"


def test_health_ready():
    response = client.get("/health/ready")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ready"


def test_auth_google_login():
    response = client.post(
        "/api/v1/auth/google",
        json={"id_token": "mock_google_id_token", "device_id": "device_pixel9_001"},
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert data["expires_in_seconds"] == 900


def test_ai_job_creation_and_status():
    create_res = client.post(
        "/api/v1/ai/jobs",
        json={
            "project_id": "proj_12345",
            "type": "TRANSLATE",
            "parameters": {
                "source_language": "ja",
                "target_language": "ar",
                "media_hash": "sha256_mock_hash_12345",
            },
        },
        headers={"Idempotency-Key": "req_uuid_12345"},
    )
    assert create_res.status_code == 202
    job_data = create_res.json()
    assert "id" in job_data
    assert job_data["status"] == "QUEUED"
    assert job_data["credits_reserved"] == 15

    job_id = job_data["id"]
    status_res = client.get(f"/api/v1/ai/jobs/{job_id}")
    assert status_res.status_code == 200
    status_data = status_res.json()
    assert status_data["id"] == job_id


def test_subtitle_project_lifecycle():
    create_res = client.post(
        "/api/v1/subtitles/projects",
        json={
            "title": "Sousou no Frieren Ep 1",
            "source_language": "ja",
            "target_language": "ar",
            "media_hash": "hash_frieren_01",
        },
    )
    assert create_res.status_code == 200
    project = create_res.json()
    assert project["title"] == "Sousou no Frieren Ep 1"
    assert project["quality_score"] == 100

    list_res = client.get("/api/v1/subtitles/projects")
    assert list_res.status_code == 200
    assert len(list_res.json()) >= 1


def test_billing_entitlements():
    res = client.get("/api/v1/billing/entitlements")
    assert res.status_code == 200
    data = res.json()
    assert data["tier"].upper() in ["FREE", "PLUS", "PRO"]
    assert "features" in data
