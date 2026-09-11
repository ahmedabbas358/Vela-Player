# Vela Player — AI Media Player & Subtitle Studio
> **Play. Sync. Translate. Style.**  
> A premium, commercial-grade cross-platform media intelligence platform for Android and iOS.

[![CI Status](https://github.com/ahmedabbas358/Vela-Player/actions/workflows/ci.yml/badge.svg)](https://github.com/ahmedabbas358/Vela-Player/actions/workflows/ci.yml)
[![Target Android 16](https://img.shields.io/badge/Android-API%2036-3DDC84.svg)](https://developer.android.com)
[![Target iOS 26](https://img.shields.io/badge/iOS-SDK%2026-000000.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 1. Product Overview

**Vela Player** decisively outperforms legacy media players (like MX Player and VLC) by combining a hardware-accelerated playback core with a revolutionary **Subtitle Intelligence Studio**:

- **Media Player Engine**: Multi-format support (MKV, MP4, WebM, TS, AVI, MOV) with hardware decoding (HEVC, H.264, VP9, AV1, 10-bit HDR), multi-track audio/subtitles, zero-distraction HUD, and precision gestures.
- **Unified Subtitle Studio**: Bi-directional parsing and editing of SRT, WebVTT, and ASS/SSA (with full styles, karaoke, and dialogue override tags).
- **Smart Synchronization**: Multi-point timeline calibration featuring Global Offset, 2-point Linear Drift Interpolation, Anchor Sync, and Acoustic Waveform Auto-Sync (DTW + VAD).
- **Subtitle Health Score (0–100%)**: Instant heuristic detection and one-tap automated repair of cue overlaps, negative durations, micro-flashes, and excessive reading speed (>21 CPS).
- **AI Character & Visual Styling**: Automatic extraction of character hair, eye, and costume palettes in anime and live-action, paired with an automated **Readability Guard** ensuring WCAG AAA contrast.
- **Context-Aware Translation**: Multi-sentence contextual dialogue translation with custom Project Glossaries and Translation Memory.
- **Local-First Privacy**: Complete offline playback and subtitle editing. Zero full-video uploads. Zero user tracking.
- **Monetization**: Ad-free video player on the Free tier, with symbolic Plus ($1.99/mo) and Pro ($4.99/mo) plans powered by Google Play Billing 9.1+ and Apple StoreKit 2.

---

## 2. Project Architecture

```
ahmedabbas358/Vela-Player
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                 # Automated CI (lint, analyze, test, dry-run build)
│   │   ├── release-android.yml    # Protected Google Play AAB release workflow
│   │   └── release-ios.yml        # Protected App Store Connect IPA release workflow
│   ├── pull_request_template.md
│   └── dependabot.yml
│
├── backend/                       # Modular Monolith Cloud Platform
│   ├── app/
│   │   ├── api/v1/                # REST endpoints (Auth, AI Jobs, Subtitles, Billing)
│   │   ├── core/                  # Security, JWT, Pydantic settings
│   │   └── schemas/               # Typed validation schemas
│   ├── Dockerfile
│   └── pyproject.toml
│
├── packages/                      # Isolated Monorepo Modules
│   ├── subtitle_core/             # Pure Dart USM model, parsers, health evaluator, drift corrector
│   ├── design_system/             # Design tokens, typography (Inter + Readex Pro), media cards
│   ├── player/                    # Video aspect modes, smart subtitle overlay canvas
│   └── ai/                        # Character profiles, AI job contracts
│
├── docs/                          # Complete Technical Specification Suite
│   ├── MASTER_ENGINEERING_PLAN_AND_PROMPT.md # Master 18-section plan and build prompt
│   ├── PRD.md                     # Product requirements document
│   ├── ARCHITECTURE.md            # System architecture & hardware decoding
│   ├── UX_SPEC.md                 # Screen-by-screen wireframes & gestures
│   ├── SUBTITLE_ENGINE.md         # Unified Subtitle Model & sync algorithms
│   ├── AI_PIPELINE.md             # STT, translation, diarization, OCR
│   ├── BILLING.md                 # StoreKit 2 & Google Play Billing 9.1+
│   ├── SECURITY.md                # Zero in-app secrets & storage sandboxing
│   ├── PRIVACY.md                 # Local-first data minimization policy
│   ├── STORE_REQUIREMENTS.md      # Android 16 API 36 & iOS 26 SDK guidelines
│   ├── DATABASE.md                # 30+ PostgreSQL relational table schemas
│   └── ROADMAP.md                 # Engineering roadmap from Milestone 0 to 8
│
└── lib/                           # Flutter Application Core & Features
    ├── core/                      # Permissions manager, hardware signals, storage
    ├── features/                  # Home, Library, Player, Subtitle Studio, Settings
    └── main.dart
```

---

## 3. Getting Started & Development Setup

### Prerequisites
- **Flutter SDK**: `>= 3.24.0` (Dart `>= 3.5.0`)
- **Android SDK**: Build tools supporting `compileSdk = 36`, `targetSdk = 36`
- **Java**: JDK 17
- **Xcode**: Version 26 or higher (macOS for iOS builds)
- **Python**: `>= 3.11` (for backend development)

### Quick Start
```bash
# 1. Clone the repository
git clone https://github.com/ahmedabbas358/Vela-Player.git
cd Vela-Player

# 2. Install Flutter dependencies
flutter pub get

# 3. Run static analysis
flutter analyze

# 4. Run automated unit and widget tests
flutter test

# 5. Run the application
flutter run
```

---

## 4. Modern Store Compliance (2026 Standards)

- **Android (Google Play)**:
  - Strict compliance with `targetSdkVersion = 36` (Android 16).
  - No `MANAGE_EXTERNAL_STORAGE` permission; uses Android Photo Picker and Storage Access Framework.
  - Foreground services explicitly typed (`mediaPlayback` and `mediaProcessing`).
- **iOS (Apple App Store)**:
  - Built against the latest iOS 26 SDK.
  - Just-In-Time runtime permissions with transparent `Info.plist` disclosures.
  - In-App purchases managed via modern `StoreKit 2` with server-side JWS validation.

---

## 5. Contributing

Contributions are welcome! Please read through our [Pull Request Template](.github/pull_request_template.md) and ensure that all unit and golden tests pass before submitting changes.

---

## 6. License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
>>>>>>> a029898 (feat(baseline): bootstrap Vela Player commercial architecture, design system, subtitle engine, backend, CI/CD, and docs)
