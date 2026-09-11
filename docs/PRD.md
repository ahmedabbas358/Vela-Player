# Product Requirements Document (PRD) — Vela v1.0
**AI Media Player & Subtitle Studio**
*Play. Sync. Translate. Style.*

---

## 1. Vision & Executive Summary

**Vela** is not just another video player; it is an intelligent **Media Intelligence Platform**. It provides a top-tier media playback experience built for modern hardware, coupled with an advanced Subtitle Studio that understands, repairs, synchronizes, translates, and restyles subtitles using both deterministic heuristics and cutting-edge on-device & cloud AI.

### Target Platforms & Modern App Store Compliance
- **Google Play**: Fully configured for `targetSdk = 36` (Android 16), utilizing Google Play Billing Library 9.1.0+ with modern Subscriptions (Base Plans & Offers).
- **Apple App Store**: Built targeting the latest Xcode 26 toolchain and iOS 26 SDK, utilizing StoreKit 2 and modern AVFoundation capabilities.
- **Privacy-First Principle**: All media stays strictly on the user's device by default. Cloud processing is opt-in, strictly limited to extracted audio or text slices needed for specific AI jobs, with zero unnecessary data transfers.

---

## 2. The 4-in-1 Product Identity

```
                         VELA ECOSYSTEM
                               │
       ┌───────────────────────┼───────────────────────┐
       │                       │                       │
 MEDIA PLAYER           SUBTITLE STUDIO            AI ENGINE
 ├── Hardware Decoding   ├── Unified Model       ├── Speech Recognition
 ├── Multi-Track Audio   ├── Smart Sync & Drift  ├── Contextual Translation
 ├── Multi-Track Subs    ├── Subtitle Health     ├── Speaker Diarization
 ├── Gesture Controls    ├── Timeline Editor     ├── Character Intelligence
 └── Network Playback    └── "Make Beautiful"    └── On-Screen Vision OCR
```

1. **Media Player**: A robust daily-driver player supporting all modern formats (MKV, MP4, WebM, TS, FLAC, OPUS) with hardware acceleration, multiple audio/subtitle streams, chapters, gestures, and PiP.
2. **Subtitle Studio**: A comprehensive suite for repairing invalid timestamps, broken encodings, bad line breaks, overlapping cues, and calculating a real-time Subtitle Health Score (0–100%).
3. **AI Engine**: Advanced capabilities providing automatic speech-to-text generation, context-aware translation with translation memory, speaker diarization, character profiling, and smart positioning.
4. **Library & Network**: Intelligent media cataloging (Movies, Series with SxxExx tracking, Anime) and network streaming (SMB, WebDAV, DLNA).

---

## 3. Core Competitive Advantage: Vela Subtitle Intelligence™

Traditional players treat subtitles as passive text with a timestamp:
$$\text{Subtitle} = \text{Text} + [\text{Start Time}, \text{End Time}]$$

**Vela Subtitle Intelligence™** treats subtitles as multi-dimensional scene data:
$$\text{Subtitle} = \text{Text} + \text{Timestamp} + \text{Speaker} + \text{Character} + \text{Scene Context} + \text{Position} + \text{Style} + \text{Reading Speed} + \text{Confidence}$$

```json
{
  "cue_id": "cue_00492",
  "text": "We need to secure the perimeter before dawn.",
  "start_ms": 142350,
  "end_ms": 145120,
  "speaker": "spk_commander",
  "character": "character_erwin",
  "scene": "scene_courtyard_night",
  "language": "en",
  "style": "character_emerald",
  "confidence": 0.98,
  "reading_speed_cps": 15.8
}
```

---

## 4. Feature Scope & Requirements

### 4.1 Media Player Capabilities (P0)
- **Container Support**: MP4, MKV, MOV, AVI, WebM, TS, M4V, FLV.
- **Audio Support**: MP3, AAC, WAV, FLAC, OGG, OPUS, M4A, AC3, EAC3.
- **Codecs**: H.264 (AVC), H.265 (HEVC), VP9, AV1, 10-bit color, HDR10/Dolby Vision passthrough where hardware permits.
- **Multi-Track Management**: Dynamic switching of audio streams, embedded subtitle tracks, and external subtitle files.
- **Hardware Decoding**: Primary hardware decoding (MediaCodec / VideoToolbox) with automatic software decoding fallback.
- **Gesture System**:
  - Left vertical swipe: Brightness.
  - Right vertical swipe: Volume.
  - Horizontal swipe: Precise seek with scrubbing preview.
  - Double tap left/right: ±10s seek.
  - Double tap center: Play/Pause.
  - Long press: 2.0× playback speed.
  - Pinch-to-zoom: Fit, Fill, 16:9, 21:9 aspect ratio adjustment.

### 4.2 Subtitle Formats & Unified Model (P0)
- Formats: SRT, WebVTT, ASS, SSA, TTML, SBV, SUB.
- Internal Representation: All formats parsed into the **Unified Subtitle Model** to allow bi-directional lossless conversion and styling.
- Full ASS/SSA Rendering: Support for styles, colors, alignment, margins, font weights, and override tags.

### 4.3 Subtitle Health & Repair Engine (P0 / P1)
- Computes **Subtitle Health Score (0–100%)** based on:
  - Overlapping cues detection & resolution.
  - Empty or single-character noise cues.
  - Invalid timestamps or negative durations.
  - Excessive reading speed (> 21 characters per second).
  - Poor line breaks and orphan words.
  - Broken charset encoding (e.g. Windows-1256 vs UTF-8).
  - Residual HTML artifacts or malformed ASS tags.

### 4.4 Smart Synchronization (P1)
- **Global Sync**: Uniform offset adjustments ($\pm N$ ms).
- **Drift Correction**: Progressive timeline drift interpolation between timepoints $T_1$ and $T_2$.
- **Anchor Sync**: User pins Subtitle Cue $A \rightarrow \text{Frame } A$ and Subtitle Cue $B \rightarrow \text{Frame } B$; Vela automatically computes linear/affine time transformations.
- **Auto Sync with Audio (Premium)**: Waveform acoustic alignment comparing subtitle dialogue text with phoneme recognition to calculate alignment correction maps.

### 4.5 AI Subtitle Studio (P2)
- **AI Subtitle Generation**: End-to-end audio transcription (Whisper-based pipeline) with punctuation, sentence segmentation, and timestamp alignment.
- **AI Translation**: Context-aware dialogue translation (EN $\rightarrow$ AR and 50+ languages) honoring character gender, tone, scene history, and Project Glossary / Translation Memory.
- **Speaker Diarization**: Audio clustering into distinct speakers (Speaker 1, Speaker 2...).
- **Character Intelligence**: Vision + Audio linking speakers to on-screen characters, computing high-contrast readable palette colors based on character design (hair, eyes, clothing) against scene backgrounds.
- **On-Screen OCR**: Translation of in-scene text (signs, letters, titles) with styled overlay.
- **"Make Beautiful" Button**: One-tap automated execution of health repair, speaker coloring, contrast balancing, and optimal typography.

### 4.6 Media Library & Network (P1 / P2)
- **Library Sections**: Continue Watching, Recently Added, Movies, Series (with automated SxxExx folder/file grouping), Anime, Favorites.
- **External Subtitle Discovery**: Automatic pairing of video files with matching local `.srt`/`.ass` files.
- **Network Streaming**: SMB (v2/v3), WebDAV, FTP, HTTP/HTTPS, DLNA.

---

## 5. Monetization, Subscriptions & Credits

- **Ad Policy**: Completely ad-free video player experience. No video pre-rolls, mid-rolls, or banners during playback. Rewarded ads may only be used optionally in the Library to earn small bonus AI credits.
- **Free Tier**: Full player, all codecs, multi-track audio/subs, manual sync, basic styling, subtitle repair diagnostics, local library.
- **Plus Tier ($1.99/mo | $14.99/yr)**: Auto-sync, subtitle translation (500 monthly credits), character color engine, advanced subtitle presets.
- **Pro Tier ($4.99/mo | $39.99/yr)**: Full AI studio, speech-to-subtitle generation, batch processing, OCR screen translation, priority cloud processing (2,000 monthly credits + top-ups).
- **Store Compliance**: Google Play Subscriptions (Base Plans + Offers) and Apple StoreKit 2 with Server-Side Entitlement validation.

---

## 6. Release Phases

| Release | Codename | Target Focus |
|---|---|---|
| **v1.0** | *Rock-Solid Core* | Media Player, Unified Subtitle Model, ASS/SRT/VTT, Manual/Drift Sync, Subtitle Health, Design System |
| **v2.0** | *AI Subtitle Studio* | Auto Sync with Audio, AI Generation, Contextual Translation, Make Beautiful |
| **v3.0** | *Media Intelligence* | Character Vision Profiling, Speaker Diarization, On-Screen OCR, Batch Processing, Network NAS |
