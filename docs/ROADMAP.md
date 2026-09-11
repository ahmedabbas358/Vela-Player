# Engineering Roadmap & Milestones — Vela
**Phased Execution Strategy: From Rock-Solid Core to Media Intelligence Platform**

---

## 1. Master Strategic Philosophy

> **"Never start with AI first. Build an exceptional media player first, an unmatched subtitle studio second, and a transformative AI intelligence engine third."**

Attempting to layer AI on a subpar playback engine results in an unstable demo. Vela establishes rock-solid core foundations before executing heavy machine learning workflows.

---

## 2. Release Roadmap & Milestones

```
Release 0 ──────▶ Release 1 ──────▶ Release 2 ──────▶ Release 3 ──────▶ Release 4
Internal Core     Public MVP        AI Subtitle       Media             Pro & Cloud
Foundation        "Rock-Solid"      Studio            Intelligence      Ecosystem
(Packages,        (Player, ASS,     (Auto-Sync, STT,  (Diarization,     (Network SMB,
USM, Parsers)     Drift Sync)       Translation)      Vision Palette)   Batch, Remux)
```

---

### Milestone 0: Internal Core Foundation (Weeks 1–3)
- [x] Establish modular monorepo packages (`design_system`, `subtitle_core`, `player`, `ai`).
- [x] Configure build targets: Android `targetSdk = 36` and iOS 26 SDK toolchain.
- [x] Implement the **Unified Subtitle Model (USM)** in pure Dart with zero UI coupling.
- [x] Build and benchmark streaming parsers for SRT, WebVTT, and ASS/SSA dialogue tags.
- [x] Implement the 1000+ test fixture subtitle suite (Unicode, Arabic RTL, malformed cues).

---

### Milestone 1: Public MVP — "The Rock-Solid Player" (Weeks 4–8)
- [ ] Hardware-accelerated 4K 60fps / 10-bit HDR video playback across Android & iOS.
- [ ] Multi-track audio and subtitle selection with instantaneous stream switching.
- [ ] Fluid gesture control matrix (vertical brightness/volume, scrub preview, double-tap seek).
- [ ] Dynamic **Subtitle Health Score Engine** with automated anomaly repair.
- [ ] Multi-point subtitle synchronization:
  - Global offset adjustment ($\pm N\text{ ms}$).
  - Two-point timeline drift interpolation.
  - Interactive anchor sync.
- [ ] Subtitle Studio styling drawer: typography, font size, stroke outline, shadow, opacity.
- [ ] Local media library with automatic external subtitle discovery (`.srt`/`.ass` pairing).

#### Definition of Done (DoD) for MVP:
1. Zero crashes during 4K MKV / H.265 playback with rapid 10s scrub cycles.
2. Perfect Arabic RTL and English bidirectional rendering without glyph inversion.
3. Subtitle rendering latency $< 4\text{ ms}$ per frame (zero dropped video frames).

---

### Milestone 2: AI Subtitle Studio (Weeks 9–14)
- [ ] AI Gateway backend microservice (FastAPI + Redis + Celery).
- [ ] **Acoustic Auto-Sync**: Waveform alignment correcting desynchronized subtitles to spoken dialogue.
- [ ] **Speech-to-Subtitle Pipeline**: High-accuracy on-demand Whisper transcription with punctuation.
- [ ] **Context-Aware Translation**: Multi-sentence context LLM translation preserving tone and custom project glossaries.
- [ ] **One-Tap "Make Beautiful"**: Unified button combining health repair, line-balancing, and optimal styling.
- [ ] Google Play Billing (Base Plans/Offers) & iOS StoreKit 2 integration with credit wallet.

---

### Milestone 3: Media Intelligence (Weeks 15–20)
- [ ] **Speaker Diarization**: Distinct clustering of dialogue turns into discrete speakers.
- [ ] **Vision Character Profiling**: Facial tracking linked to audio energy to pair speakers with on-screen characters.
- [ ] **Character Color Engine**: Automatic generation of representative, high-contrast, color-blindness-safe palette colors.
- [ ] **On-Screen Text OCR**: Detection and translated overlay of in-frame signs, notes, and titles.
- [ ] **Batch Processing**: Simultaneous AI sync, repair, and translation of entire series/seasons.

---

### Milestone 4: Pro & Cloud Ecosystem (Weeks 21–26)
- [ ] Network playback integration: SMB v2/v3, WebDAV, FTP, DLNA.
- [ ] Cross-device watch progress and subtitle preset synchronization.
- [ ] Advanced subtitle export: In-container remuxing (MKV/MP4) and video burn-in transcoding.
