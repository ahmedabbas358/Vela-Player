# Complete Relational Database Specification — Vela v1.0
**Production PostgreSQL Schema, Indices, Constraints & Dual SQLite Architecture**

---

## 1. Architectural Strategy

- **On-Device SQLite / Drift**: Real-time position tracking (0ms network latency), cached subtitle styles, offline playback history.
- **Cloud PostgreSQL 16+**: Source of truth for identity, devices, subscriptions, multi-device synchronization, project glossaries, and AI job orchestration.

```
┌─────────────────────────────────────────────────────────────┐
│                   VELA CLOUD POSTGRESQL SCHEMA              │
├──────────────────────┬──────────────────────────────────────┤
│ Domain Module        │ Core Tables                          │
├──────────────────────┼──────────────────────────────────────┤
│ Identity & Access    │ users, user_profiles, auth_identities│
│                      │ sessions, devices                    │
│ Media Catalog        │ media_items, media_tracks            │
│ Subtitle Studio      │ subtitle_projects, subtitle_cues,    │
│                      │ subtitle_styles, subtitle_presets    │
│ Intelligence & Vision│ speakers, characters, mappings       │
│ Translation Engine   │ translation_projects, glossaries,    │
│                      │ glossary_terms                       │
│ AI Job Orchestration │ ai_jobs, ai_job_events, ai_outputs   │
│ Billing & Credits    │ subscriptions, subscription_events,  │
│                      │ entitlements, credit_wallets, txs    │
│ Platform Operations  │ notifications, watch_history, sync,  │
│                      │ files, file_variants, audit_logs     │
└──────────────────────┴──────────────────────────────────────┘
```

---

## 2. Production PostgreSQL Relational Schema (DDL)

```sql
-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. IDENTITY & SESSIONS
-- ============================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE,
    display_name VARCHAR(128),
    avatar_url TEXT,
    locale VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(64) DEFAULT 'UTC',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;

CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    preferred_subtitle_size INT DEFAULT 22,
    preferred_subtitle_color VARCHAR(7) DEFAULT '#FFFFFF',
    auto_repair_enabled BOOLEAN DEFAULT TRUE,
    high_contrast_outline BOOLEAN DEFAULT TRUE,
    wifi_only_for_ai BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE auth_identities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(32) NOT NULL, -- 'google', 'apple', 'email_otp'
    provider_subject VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(provider, provider_subject)
);

CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    platform VARCHAR(16) NOT NULL, -- 'android', 'ios', 'windows', 'macos'
    os_version VARCHAR(32) NOT NULL,
    app_version VARCHAR(32) NOT NULL,
    model VARCHAR(64),
    push_token TEXT,
    capabilities JSONB DEFAULT '{}', -- hardware_decoder, av1, ram_class
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_devices_user ON devices(user_id);

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    refresh_token_hash VARCHAR(64) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE,
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_sessions_token_hash ON sessions(refresh_token_hash) WHERE revoked_at IS NULL;

-- ============================================================================
-- 2. MEDIA CATALOG
-- ============================================================================

CREATE TABLE media_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    source VARCHAR(32) NOT NULL DEFAULT 'local', -- 'local', 'smb', 'webdav'
    local_identifier VARCHAR(512),
    title VARCHAR(512) NOT NULL,
    duration_ms BIGINT NOT NULL DEFAULT 0,
    size_bytes BIGINT NOT NULL DEFAULT 0,
    mime_type VARCHAR(64) DEFAULT 'video/mp4',
    media_hash VARCHAR(64) NOT NULL, -- SHA-256 of first 16MB for instant recognition
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_media_user_updated ON media_items(user_id, updated_at DESC);
CREATE INDEX idx_media_hash ON media_items(media_hash);

CREATE TABLE media_tracks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    media_id UUID NOT NULL REFERENCES media_items(id) ON DELETE CASCADE,
    type VARCHAR(16) NOT NULL, -- 'video', 'audio', 'subtitle'
    language VARCHAR(10) DEFAULT 'und',
    codec VARCHAR(32),
    title VARCHAR(128),
    channels INT,
    is_default BOOLEAN DEFAULT FALSE,
    is_forced BOOLEAN DEFAULT FALSE
);
CREATE INDEX idx_tracks_media ON media_tracks(media_id);

-- ============================================================================
-- 3. SUBTITLE STUDIO & UNIFIED SUBTITLE MODEL
-- ============================================================================

CREATE TABLE subtitle_projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    media_id UUID REFERENCES media_items(id) ON DELETE SET NULL,
    title VARCHAR(256) NOT NULL,
    source_language VARCHAR(10) DEFAULT 'en',
    target_language VARCHAR(10) DEFAULT 'ar',
    source_type VARCHAR(32) DEFAULT 'srt', -- 'srt', 'ass', 'vtt', 'ai_generated'
    status VARCHAR(32) DEFAULT 'ready',
    quality_score INT DEFAULT 100,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_sub_projects_user ON subtitle_projects(user_id, updated_at DESC);

CREATE TABLE subtitle_styles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES subtitle_projects(id) ON DELETE CASCADE,
    name VARCHAR(64) NOT NULL,
    font_family VARCHAR(64) DEFAULT 'Outfit',
    font_size INT DEFAULT 22,
    primary_color VARCHAR(9) DEFAULT '#FFFFFFFF',
    outline_color VARCHAR(9) DEFAULT '#FF000000',
    outline_width REAL DEFAULT 2.5,
    shadow_color VARCHAR(9) DEFAULT '#88000000',
    alignment VARCHAR(32) DEFAULT 'bottom_center'
);

CREATE TABLE subtitle_cues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES subtitle_projects(id) ON DELETE CASCADE,
    sequence INT NOT NULL,
    start_ms INT NOT NULL,
    end_ms INT NOT NULL,
    text TEXT NOT NULL,
    original_text TEXT,
    speaker_id UUID,
    character_id UUID,
    style_id UUID REFERENCES subtitle_styles(id) ON DELETE SET NULL,
    confidence REAL DEFAULT 1.0,
    reading_speed REAL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_cues_project_timeline ON subtitle_cues(project_id, start_ms);

-- ============================================================================
-- 4. CHARACTER & SPEAKER INTELLIGENCE
-- ============================================================================

CREATE TABLE speakers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES subtitle_projects(id) ON DELETE CASCADE,
    label VARCHAR(64) NOT NULL, -- 'Speaker 01'
    confidence REAL DEFAULT 1.0,
    voice_embedding_ref VARCHAR(128), -- Ephemeral S3 pointer; purged after job
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE characters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES subtitle_projects(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    hair_color VARCHAR(7),
    eye_color VARCHAR(7),
    dominant_palette VARCHAR(7)[],
    assigned_color VARCHAR(7) NOT NULL,
    confidence REAL DEFAULT 1.0,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE speaker_character_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    speaker_id UUID NOT NULL REFERENCES speakers(id) ON DELETE CASCADE,
    character_id UUID NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    confidence REAL DEFAULT 1.0,
    method VARCHAR(32) DEFAULT 'hybrid' -- 'vision', 'audio_syncnet', 'manual'
);

-- ============================================================================
-- 5. TRANSLATION ENGINE & GLOSSARIES
-- ============================================================================

CREATE TABLE glossaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    source_language VARCHAR(10) NOT NULL,
    target_language VARCHAR(10) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE glossary_terms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    glossary_id UUID NOT NULL REFERENCES glossaries(id) ON DELETE CASCADE,
    source_term VARCHAR(256) NOT NULL,
    target_term VARCHAR(256) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_glossary_search ON glossary_terms(glossary_id, source_term);

CREATE TABLE translation_projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_project_id UUID NOT NULL REFERENCES subtitle_projects(id) ON DELETE CASCADE,
    source_language VARCHAR(10) NOT NULL,
    target_language VARCHAR(10) NOT NULL,
    provider VARCHAR(64) NOT NULL,
    model VARCHAR(64) NOT NULL,
    status VARCHAR(32) DEFAULT 'queued',
    quality_score INT DEFAULT 100,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================================
-- 6. AI JOB ORCHESTRATION & STATE MACHINE
-- ============================================================================

CREATE TYPE ai_job_status AS ENUM (
    'CREATED', 'QUEUED', 'PREPARING', 'UPLOADING', 'PROCESSING',
    'POST_PROCESSING', 'REVIEW_REQUIRED', 'COMPLETED', 'FAILED', 'CANCELLED', 'EXPIRED'
);

CREATE TABLE ai_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES devices(id) ON DELETE SET NULL,
    type VARCHAR(32) NOT NULL, -- 'TRANSCRIBE', 'TRANSLATE', 'SYNC', 'REPAIR', 'OCR', 'DIARIZE'
    status ai_job_status NOT NULL DEFAULT 'CREATED',
    priority INT DEFAULT 5, -- 1-10
    provider VARCHAR(64),
    model VARCHAR(64),
    input_size_bytes BIGINT DEFAULT 0,
    input_duration_ms BIGINT DEFAULT 0,
    credits_reserved INT NOT NULL DEFAULT 0,
    credits_used INT DEFAULT 0,
    progress INT DEFAULT 0, -- 0 to 100
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    error_code VARCHAR(64),
    error_message TEXT
);
CREATE INDEX idx_ai_jobs_user_status ON ai_jobs(user_id, status);
CREATE INDEX idx_ai_jobs_active ON ai_jobs(status, created_at) WHERE status IN ('QUEUED', 'PROCESSING');

CREATE TABLE ai_job_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES ai_jobs(id) ON DELETE CASCADE,
    event VARCHAR(64) NOT NULL,
    progress INT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_job_events ON ai_job_events(job_id, created_at);

-- ============================================================================
-- 7. BILLING, ENTITLEMENTS & CREDITS
-- ============================================================================

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    store VARCHAR(32) NOT NULL, -- 'google_play', 'app_store'
    store_original_tx_id VARCHAR(128) NOT NULL UNIQUE,
    product_id VARCHAR(64) NOT NULL,
    base_plan_id VARCHAR(64),
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE entitlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entitlement_key VARCHAR(64) NOT NULL, -- 'AI_TRANSLATION', 'SMART_SYNC', 'OCR'
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, entitlement_key)
);

CREATE TABLE credit_wallets (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    balance INT NOT NULL DEFAULT 50,
    reserved INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT balance_non_negative CHECK (balance >= 0)
);

CREATE TABLE credit_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    job_id UUID REFERENCES ai_jobs(id) ON DELETE SET NULL,
    delta INT NOT NULL,
    balance_after INT NOT NULL,
    reason VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 8. OPERATIONS, SYNC & AUDIT LOGS
-- ============================================================================

CREATE TABLE watch_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    media_hash VARCHAR(64) NOT NULL,
    position_ms BIGINT NOT NULL DEFAULT 0,
    duration_ms BIGINT NOT NULL DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, media_hash)
);

CREATE TABLE sync_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_type VARCHAR(32) NOT NULL,
    entity_id UUID NOT NULL,
    version INT NOT NULL DEFAULT 1,
    device_id UUID NOT NULL REFERENCES devices(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, entity_type, entity_id)
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID, -- NULL if system
    action VARCHAR(64) NOT NULL,
    target_type VARCHAR(64) NOT NULL,
    target_id VARCHAR(128) NOT NULL,
    ip_address INET,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
```
