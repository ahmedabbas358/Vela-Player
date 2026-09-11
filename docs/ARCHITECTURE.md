# System Architecture — Vela v1.0
**High-Performance Modular Media & Subtitle Platform**

---

## 1. High-Level Architectural Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          PRESENTATION LAYER (Flutter)                       │
│  ┌────────────────────┐ ┌──────────────────────┐ ┌───────────────────────┐  │
│  │ VideoPlayerScreen  │ │ SubtitleStudioScreen │ │ AIStudio & MakeBeauty │  │
│  │ (HUD, Gestures)    │ │ (Timeline, Styler)   │ │ (Jobs, Translation)   │  │
│  └─────────┬──────────┘ └──────────┬───────────┘ └───────────┬───────────┘  │
│            └───────────────────────┼─────────────────────────┘              │
│                                    ▼                                        │
│                      APPLICATION / STATE (Riverpod)                         │
│  ┌────────────────────┐ ┌──────────────────────┐ ┌───────────────────────┐  │
│  │ PlayerController   │ │ SubtitleController   │ │ AIJobController       │  │
│  └─────────┬──────────┘ └──────────┬───────────┘ └───────────┬───────────┘  │
└────────────┼───────────────────────┼─────────────────────────┼──────────────┘
             │                       │                         │
┌────────────▼───────────────────────▼─────────────────────────▼──────────────┐
│                            MONOREPO PACKAGES                                │
│                                                                             │
│  ┌──────────────────────┐ ┌──────────────────────┐ ┌─────────────────────┐  │
│  │ packages/player      │ │ packages/subtitle    │ │ packages/ai         │  │
│  │ - MediaController    │ │ - UnifiedSubtitle    │ │ - GatewayClient     │  │
│  │ - TrackSelection     │ │ - Parsers (SRT, ASS) │ │ - JobPoller         │  │
│  │ - HardwareDecoder    │ │ - Health & Repair    │ │ - CostMeter         │  │
│  │ - SmartPlacement     │ │ - Sync & Drift Engine│ │ - Local Heuristics  │  │
│  └─────────┬────────────┘ └──────────┬───────────┘ └──────────┬──────────┘  │
│            │                         │                        │             │
│  ┌─────────┴─────────────────────────┴────────────────────────┴──────────┐  │
│  │ packages/design_system (Tokens, Atoms, Molecules, Dark/Light Themes) │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     │
┌────────────────────────────────────▼────────────────────────────────────────┐
│                        NATIVE & HARDWARE INTEGRATION                        │
│                                                                             │
│  ┌────────────────────────────────────┐ ┌────────────────────────────────┐  │
│  │ Android Native (targetSdk 36)      │ │ iOS Native (Xcode 26 / iOS 26) │  │
│  │ - Kotlin / Media3 (ExoPlayer)      │ │ - Swift / AVFoundation         │  │
│  │ - MediaCodec (HW Decoder)          │ │ - VideoToolbox (HW Decoder)    │  │
│  │ - Google Play Billing 9.1+         │ │ - StoreKit 2 (Signed JWS)      │  │
│  └──────────────────┬─────────────────┘ └────────────────┬───────────────┘  │
│                     └─────────────────┬──────────────────┘                  │
│                                       ▼                                     │
│                     Shared Core Algorithms (Rust / C++)                     │
│                     - libmpv / ffmpeg bindings                              │
│                     - High-speed Subtitle Normalizer & Renderer             │
│                     - Waveform acoustic feature extractor                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ HTTPS / WSS
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CLOUD BACKEND & AI GATEWAY                         │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ FastAPI Microservices (Auth, Projects, Billing, Subtitles)            │  │
│  └───────────────────────────────────┬───────────────────────────────────┘  │
│                                      ▼                                      │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Redis Job Queue + Celery Workers                                      │  │
│  │ ├── Whisper STT Speech Recognition                                    │  │
│  │ ├── LLM Contextual Translation (Glossary-aware)                       │  │
│  │ ├── PyAnnote Speaker Diarization                                      │  │
│  │ └── Vision OCR & Character Color Palette Analyzer                     │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Core Architectural Principles

### 2.1 Separation of Concerns
1. **Media Engine $\neq$ Subtitle Engine $\neq$ AI Gateway**:
   - Media playback is completely decoupled from subtitle rendering and AI. The video player can operate seamlessly even if the subtitle engine or network is inactive.
2. **Unified Subtitle Model as Universal Intermediate Representation (IR)**:
   - No feature operates on raw SRT or ASS text directly. Everything passes through the `UnifiedSubtitleCue` pipeline.
3. **Local-First & Offline Resilience**:
   - Playback, manual synchronization, subtitle repair, and preset styling operate 100% offline without requiring network permissions or user authentication.

### 2.2 Unidirectional Data Flow (UDF)
State updates follow strict unidirectional loops managed by Riverpod:
$$\text{User Event / Player Clock} \longrightarrow \text{Controller} \longrightarrow \text{State Mutation} \longrightarrow \text{UI View}$$

```
                ┌────────────────────────────────┐
                │   Video Timestamp Clock (ms)   │
                └───────────────┬────────────────┘
                                │
                                ▼
                ┌────────────────────────────────┐
                │ SubtitleTimeline.findActiveCues│
                │ (O(log N) Binary Search)       │
                └───────────────┬────────────────┘
                                │
                                ▼
                ┌────────────────────────────────┐
                │  Active Cues State Stream      │
                └───────────────┬────────────────┘
                                │
                                ▼
                ┌────────────────────────────────┐
                │  SmartSubtitleOverlay (Canvas) │
                │  - Character Color Palette     │
                │  - Contrast Optimization       │
                │  - Smart Placement             │
                └────────────────────────────────┘
```

---

## 3. Package Decomposition (Monorepo)

| Package | Responsibility | Dependencies |
|---|---|---|
| `packages/design_system` | Visual design tokens, typography, theme data, reusable controls | Flutter SDK, Google Fonts |
| `packages/subtitle_core` | Parsers (SRT, ASS, VTT, TTML), Unified Subtitle Model, repair engine, sync algorithms | None (Pure Dart / zero Flutter UI dependency) |
| `packages/player` | High-level player controller, hardware decoder bridges, gesture handlers, overlay canvas | `media_kit`, `subtitle_core`, `design_system` |
| `packages/ai` | AI gateway client, job state machine, local heuristics, cost tracking | `http`, `web_socket_channel`, `subtitle_core` |
| `apps/mobile` | Android & iOS application shell, navigation, screens, native store bridges | All local packages, Riverpod, StoreKit/PlayBilling |

---

## 4. Platform Bridging & Modern SDK Specifications

### 4.1 Android Target Configuration
- `compileSdk = 36`
- `targetSdk = 36`
- `minSdk = 24` (Android 7.0 Nougat+)
- Native player bridge utilizes AndroidX Media3 `1.5.x` / ExoPlayer, taking advantage of hardware decoders (`MediaCodecList`, `MediaCodecVideoRenderer`) with graceful fallback to software decoding.
- Audio attributes configured with `C.USAGE_MEDIA` and `C.AUDIO_CONTENT_TYPE_MOVIE` supporting spatial audio and multichannel passthrough.

### 4.2 iOS Target Configuration
- Xcode 26 toolchain targeting iOS 26 SDK.
- `minDeploymentTarget = 16.0`.
- Media pipeline powered by AVPlayer / VideoToolbox hardware decoding, supporting PiP (`AVPictureInPictureController`), Background Audio Session, and Display HDR (`AVPlayerLayer`).
- Purchases and entitlements managed via Swift `StoreKit 2` with server-side validation using JSON Web Signatures (JWS).

---

## 5. Performance & Memory Budget

| Metric | Target Limit | Enforcement Mechanism |
|---|---|---|
| **App Cold Start** | $< 1.2\text{ s}$ | Deferred module initialization, lazy provider instantiation |
| **Subtitle Render Latency** | $< 4\text{ ms / frame}$ | Binary search timestamp index, cached `TextPainter` layouts |
| **Memory Footprint (4K Video)** | $< 180\text{ MB}$ | Zero in-memory caching of raw video frames; hardware surface directly managed |
| **Subtitle Parsing (10,000 cues)** | $< 85\text{ ms}$ | Optimized single-pass streaming parser with regex pre-compilation |
