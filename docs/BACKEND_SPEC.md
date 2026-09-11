# Vela Backend & Platform Engineering Specification
**Scalable Cloud Infrastructure, AI Job Orchestration, Async Queues & APIs**

---

## 1. Architectural Philosophy: The Modular Monolith

Vela avoids premature microservice sprawl. To scale from MVP to millions of concurrent active users without operational fragmentation, the backend is architected as a high-performance **Modular Monolith** in **FastAPI** with isolated domain boundaries:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          API GATEWAY & LOAD BALANCER                        │
│                         (TLS 1.3, Rate Limiting, CDN)                       │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       MODULAR MONOLITH (FastAPI Core)                       │
│                                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────────────┐  │
│  │ Auth & Users │ │ Media Catalog│ │ Subtitles &  │ │ AI Orchestration   │  │
│  │ & Devices    │ │ & Sync Engine│ │ Projects     │ │ & Credit Wallet    │  │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘ └─────────┬──────────┘  │
│         │                │                │                   │             │
│  ┌──────┴────────────────┴────────────────┴───────────────────┴──────────┐  │
│  │ Billing (StoreKit 2 + Google Play RTDN), Notifications & Audit Log    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└──────────────┬───────────────────────────────────────────────┬──────────────┘
               │                                               │
               ▼                                               ▼
┌──────────────────────────────┐              ┌──────────────────────────────┐
│  PRIMARY DATA STORE          │              │  MESSAGE QUEUE & CACHE       │
│  PostgreSQL 16+              │              │  Redis 7+ (Streams & Pub/Sub)│
│  (ACID, JSONB, Full-Text FTS)│              │  Job Queues, Sessions, WSS   │
└──────────────────────────────┘              └──────────────┬───────────────┘
                                                             │
                                                             ▼
┌──────────────────────────────┐              ┌──────────────────────────────┐
│  OBJECT STORAGE              │              │  DEDICATED AI WORKERS        │
│  S3-Compatible (MinIO / AWS) │◀─────────────┤  Celery / Python Workers     │
│  Presigned Multi-part URLs   │              │  - Whisper Speech STT        │
│  Ephemeral 15m Scratch Pools │              │  - Contextual LLM Translation│
└──────────────────────────────┘              │  - PyAnnote Diarization      │
                                              │  - Vision OCR Extraction     │
                                              └──────────────────────────────┘
```

---

## 2. Processing Strategy: Local vs. Cloud vs. Hybrid

### 2.1 The Zero-Full-Video-Upload Principle
Video files (e.g., 2GB–10GB 4K MKVs) **never leave the user's phone** unless explicitly requested for server-side cloud transcoding.

| Processing Mode | Features Executed | Bandwidth & Data Flow |
|---|---|---|
| **100% Local (Default)** | Playback, hardware decoding, subtitle parsing, styling, manual/drift sync, timeline editing, subtitle health score, basic formatting. | **$0\text{ bytes}$** transferred; complete offline functionality. |
| **Hybrid (Opt-In AI)** | Speech transcription, acoustic waveform auto-sync, translation, speaker diarization. | Local app extracts audio slice ($16\text{kHz}$ Opus/WAV $\approx 15\text{MB}$); uploads audio only; server returns structured subtitle JSON ($< 150\text{KB}$). |
| **Cloud Dedicated** | Multi-file batch translation, long-form series diarization, in-place screen video OCR. | Chunked parallel workers processing pre-signed ephemeral asset slices. |

---

## 3. Authentication, Session & Token Architecture

Vela implements an **OAuth 2.1 / OIDC** authentication gateway supporting **Sign in with Apple**, **Google Identity Services**, and **Magic Link / Email**, with an unauthenticated **Guest Mode First** philosophy.

```
[ Client Request ] ──▶ Header: Authorization: Bearer <access_token>
                            │
                            ▼
               [ FastAPI Auth Middleware ]
               - Validates EdDSA / RS256 Signature
               - Verifies Expiration (15-minute TTL)
               - Extracts user_id, device_id, permissions
```

### 3.1 Token Lifecycles & Security
1. **Access Token**:
   - Format: Cryptographically signed JWT.
   - Lifespan: $15\text{ minutes}$.
   - Contains: `sub` (User UUID), `dev` (Device UUID), `ent` (Entitlement flags), `iss`, `exp`.
2. **Refresh Token**:
   - Format: High-entropy CSPRNG string ($256\text{ bits}$), stored in PostgreSQL strictly as a SHA-256 hash (`refresh_token_hash`).
   - Lifespan: $30\text{ days}$ (Sliding window on active usage).
   - Rotation: On every refresh exchange, the existing refresh token is permanently revoked, and a new token family pair is issued. Detects replay attacks immediately.
3. **Session Revocation**:
   - Users can view and terminate active sessions per device (`DELETE /api/v1/devices/{id}`).

---

## 4. Device Management & Capability Negotiation

Every device registers its technical profile upon first handshake (`POST /api/v1/devices`):

```json
{
  "device_id": "8f3b2a19-c451-4e76-8e12-39c28892d192",
  "platform": "android",
  "os_version": "16",
  "app_version": "1.0.0",
  "model": "Pixel 9 Pro",
  "locale": "ar-SA",
  "timezone": "Asia/Riyadh",
  "capabilities": {
    "hardware_decoder": true,
    "av1": true,
    "hevc": true,
    "hdr": true,
    "ram_class": "high",
    "on_device_stt_supported": true
  }
}
```
**Backend Decision Routing**: If `ram_class == "high"` and `on_device_stt_supported == true`, the backend can instruct the client to run Whisper-Tiny locally, saving cloud compute costs.

---

## 5. Object Storage & Presigned Multi-Part Uploads

Vela utilizes **S3-compatible Object Storage** with strict time-limited Presigned URLs:
1. **Never Proxy Media Through FastAPI**: The application client talks directly to Object Storage for large asset transfers.
2. **Chunked Resumable Uploads**:
   - `POST /api/v1/uploads/init`: Returns `upload_id` and presigned part URLs.
   - Client streams $5\text{MB}$ chunks concurrently with MD5 checksum verification.
   - `POST /api/v1/uploads/complete`: Backend assembles the parts and queues the background worker job.
3. **Automated Lifecycle Expiration**: Temporary audio slices and OCR frame crops reside in `/ephemeral/` buckets configured with a strict 24-hour lifecycle deletion rule.

---

## 6. AI Job Orchestration & Finite State Machine (FSM)

Every AI action (transcription, translation, sync, diarization, OCR) is governed by an explicit state machine:

```
[ CREATED ] ──▶ [ QUEUED ] ──▶ [ PREPARING ] ──▶ [ UPLOADING ]
                                                        │
                                                        ▼
[ COMPLETED ] ◀── [ POST_PROCESSING ] ◀── [ PROCESSING ]
      │
      ├──▶ [ REVIEW_REQUIRED ] (Low confidence score < 85%)
      │
      └──▶ [ FAILED / CANCELLED / EXPIRED ] ──▶ (Credits Auto-Refunded)
```

### 6.1 Atomic Credit Reservation Ledger
To prevent account balance exploitation through concurrent parallel requests:
1. **Reservation**: When the job is `QUEUED`, estimated credits are moved from `balance_monthly` to `balance_reserved`.
2. **Execution**: The Celery worker tracks actual token / compute consumption.
3. **Commit or Refund**:
   - If `COMPLETED`: `balance_reserved` is deducted, and actual credits are logged in `credit_transactions`.
   - If `FAILED` or `CANCELLED`: `balance_reserved` is unlocked and restored to `balance_monthly`.

---

## 7. Real-Time Communication (WebSockets & Push)

### 7.1 WebSocket Gateway (`wss://api.vela.app/api/v1/realtime`)
Clients maintain a persistent connection authenticated via query token or initial handshake frame:
```json
{
  "event": "ai_job.progress",
  "data": {
    "job_id": "job_091a7b",
    "status": "PROCESSING",
    "progress_percentage": 64,
    "message": "Analyzing dialogue timestamps — Scene 14/22",
    "stage": "diarization"
  }
}
```

### 7.2 Push Notifications (FCM / APNs)
Triggered strictly for asynchronous long-running jobs (e.g. 45-minute anime translation or batch project) when the app is backgrounded or terminated:
- Android: High-priority Firebase Cloud Messaging with localized channel IDs (`subtitles_ready`).
- iOS: APNs payload with mutable content for badge and action buttons (`Open in Subtitle Studio`).
- Deep Linking: Payload embeds `vela://subtitle/project/{id}`.

---

## 8. REST API v1 Specification

All endpoints require `Content-Type: application/json` and return structured RFC 7807 error envelopes.

### 8.1 Core Endpoints Table

| Method | Endpoint | Description | Idempotent |
|---|---|---|---|
| `POST` | `/api/v1/auth/google` | Exchange Google ID token for Vela session | No |
| `POST` | `/api/v1/auth/apple` | Exchange Apple authorization code for session | No |
| `POST` | `/api/v1/auth/refresh` | Rotate refresh token and issue new access JWT | Yes |
| `POST` | `/api/v1/auth/logout` | Revoke active session token family | Yes |
| `GET` | `/api/v1/me` | Fetch user profile, preferences, and entitlements | Yes |
| `POST` | `/api/v1/devices` | Register / update device capabilities and push token | Yes |
| `GET` | `/api/v1/subtitles/projects` | List subtitle projects with cursor pagination | Yes |
| `POST` | `/api/v1/subtitles/projects` | Create new subtitle project from media hash | No |
| `POST` | `/api/v1/ai/jobs` | Submit AI job (STT, Translate, Sync, OCR) | Yes (`Idempotency-Key`)|
| `GET` | `/api/v1/ai/jobs/{id}` | Inspect job state, progress percentage, and events | Yes |
| `POST` | `/api/v1/ai/jobs/{id}/cancel` | Cancel in-flight job and release reserved credits | Yes |
| `POST` | `/api/v1/billing/google/verify`| Validate Google Play Billing 9.1+ purchase token | Yes |
| `POST` | `/api/v1/billing/apple/verify` | Validate StoreKit 2 cryptographically signed JWS | Yes |
| `GET` | `/api/v1/sync/state` | Fetch delta synchronization state across devices | Yes |
| `POST` | `/api/v1/sync/delta` | Push watch progress and subtitle preset changes | No |

---

## 9. Error Model & Fault Tolerance

API responses never leak internal traces or server exceptions. All errors follow the uniform schema:

```json
{
  "error": {
    "code": "AI_CREDITS_INSUFFICIENT",
    "message": "You need 25 credits for this translation job, but only 12 are available.",
    "request_id": "req_88f910a2",
    "timestamp": "2026-09-11T20:45:00Z",
    "details": {
      "required_credits": 25,
      "available_credits": 12,
      "upgrade_url": "https://vela.app/pricing"
    }
  }
}
```

---

## 10. Observability, Telemetry & Disaster Recovery

1. **OpenTelemetry Instrumentation**: Distributed tracing connects the incoming mobile HTTP request $\rightarrow$ FastAPI endpoint $\rightarrow$ Redis stream $\rightarrow$ Celery worker $\rightarrow$ LLM provider.
2. **Structured JSON Logs**: All application logs format as single-line JSON with `trace_id`, `user_id` (anonymized), and `latency_ms`.
3. **Disaster Recovery (RPO $< 1\text{ hr}$, RTO $< 30\text{ min}$)**:
   - PostgreSQL continuous WAL archiving to secondary cloud region.
   - Daily snapshot testing with automated dry-run restoration drills.
