# AI Intelligence Pipeline — Vela v1.0
**Acoustics, Speech, Diarization, Vision & Contextual Translation**

---

## 1. AI Gateway Architecture

Vela decouples its presentation clients from specific AI model vendors through an internal **AI Gateway Abstraction Layer**. The mobile application communicates strictly with standard schema payloads, allowing the backend to hot-swap between local on-device models, specialized cloud workers, or frontier LLM APIs without application updates.

```
                   VELA MOBILE APPLICATION
                             │
                             ▼ (HTTPS / WSS)
                    AI GATEWAY ROUTER
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
   SPEECH ENGINE     TRANSLATION ENGINE     VISION ENGINE
   ├── Whisper Large   ├── Contextual LLM    ├── PyAnnote Diarization
   ├── Silero VAD      ├── Project Glossary  ├── Character Palette
   └── CTC Align       └── Memory Cache      └── Screen OCR
```

---

## 2. Speech-to-Subtitle Pipeline

When a media file lacks a subtitle track, Vela executes an automated audio-to-text pipeline:

```
[ Input Video ] ──▶ [ FFmpeg: Extract 16kHz Audio ]
                           │
                           ▼
                    [ Silero VAD ] ──▶ Filters non-speech / silence
                           │
                           ▼
              [ Whisper Large-v3-Turbo ] ──▶ Raw Tokens with Logits
                           │
                           ▼
              [ Phoneme CTC Timestamp Align ] ──▶ Exact Word Boundaries
                           │
                           ▼
              [ Sentence & Punctuation Shaper ] ──▶ Max 42 chars/line
                           │
                           ▼
              [ Unified Subtitle Model (.SRT / .ASS) ]
```

1. **Audio Pre-processing**: Video never leaves the user device for transcription. FFmpeg extracts a low-bitrate $16\text{ kHz}$ mono Opus/WAV stream, reducing bandwidth by over $96\%$.
2. **Word-Level Alignment**: High-precision word boundaries prevent early cut-offs or trailing delays common in naive speech models.
3. **Smart Line Splitting**: Enforces television/streaming subtitle constraints (maximum 2 lines, maximum 40–42 characters per line, breaking at natural grammatical pauses).

---

## 3. Contextual Translation & Project Glossary

Standard API translations fail on dialogue because they translate lines in isolation. Vela employs a **Context-Aware Translation Pipeline**:

```
Previous Dialogue History (5 lines) ──┐
Current Dialogue Line               ──┼──▶ [ Contextual Translation Prompt ] ──▶ Arabic Subtitle
Next Dialogue Anticipation (2 lines) ──┤
Character Profiles & Relationships  ──┤
Project Glossary / Term Memory      ──┘
```

### 3.1 Project Glossary & Translation Memory
- User-defined or auto-mined terminology tables (e.g. *Survey Corps* $\rightarrow$ *فيلق الاستكشاف*, *Curse Energy* $\rightarrow$ *طاقة اللعنة*).
- Consistent gender inflection: If Character #02 is identified as female, verbs and adjectives in Arabic translation are conjugated in the feminine form automatically.

---

## 4. Character Intelligence & Speaker Diarization

### 4.1 Speaker Diarization
- Groups audio waveforms into unique voice identities: `Speaker_01`, `Speaker_02`, `Speaker_03`.
- Produces temporal segments with voice-print vector embeddings.

### 4.2 Vision-to-Speaker Cross-Modal Matching
1. **Face & Position Tracking**: Tracks faces on screen during active voice time windows.
2. **Active Speaker Detection (SyncNet)**: Measures lip-sync motion correlation with audio energy to bind `Speaker_01` $\rightarrow$ `Person A (Screen Left)`.
3. **Character Palette Extraction**:
   - Analyzes RGB histograms of the character's hair, eyes, and clothing.
   - Example Profile:
   ```json
   {
     "character_id": "char_01",
     "name": "Levi",
     "hair_dominant": "#1C2833",
     "clothing_dominant": "#2C3E50",
     "assigned_subtitle_color": "#5DADE2",
     "confidence": 0.94
   }
   ```
4. **Smart Contrast Engine**:
   - If the assigned character color matches the scene's background color (e.g., blue ocean background with blue text), the engine dynamically adjusts luminance or adds an inverted high-contrast outer stroke to maintain WCAG AAA legibility.

---

## 5. On-Screen Video OCR & In-Place Translation

Designed specifically for foreign films, anime, and international content:
1. **Scene Text Detection**: Detects signs, letters, title cards, and text overlays in the video frame (e.g., Japanese Kanji, Korean Hangul).
2. **Text Recognition & Translation**: OCR transforms the glyphs into text, queries the translation engine, and synthesizes an aesthetic overlay.
3. **In-Place Overlay**: Positions translated text over the original bounding box with matching perspective and font style, optionally blending with the background.

---

## 6. AI Job Lifecycle & Credit Consumption

| Job Type | Local / Cloud | Estimated Cost | Processing Speed |
|---|---|---|---|
| **Subtitle Repair** | Local (On-Device) | $0\text{ Credits}$ (Free) | Instant ($< 0.1\text{ s}$) |
| **Subtitle Health Check** | Local (On-Device) | $0\text{ Credits}$ (Free) | Instant ($< 0.1\text{ s}$) |
| **Manual / Drift Sync** | Local (On-Device) | $0\text{ Credits}$ (Free) | Instant |
| **Acoustic Auto-Sync** | Cloud / Local Hybrid | $10\text{ Credits / 30m}$ | $15\text{ s}$ per 30m video |
| **AI Translation (per 1,000 words)** | Cloud Worker | $15\text{ Credits}$ | $4\text{ s}$ |
| **Speech-to-Subtitle (Full STT)** | Cloud Worker | $40\text{ Credits / 30m}$ | $45\text{ s}$ per 30m video |
| **Speaker & Character Diarization** | Cloud GPU | $50\text{ Credits / 30m}$ | $60\text{ s}$ per 30m video |
| **On-Screen Text OCR (per 10 signs)** | Cloud Vision | $20\text{ Credits}$ | $5\text{ s}$ |
