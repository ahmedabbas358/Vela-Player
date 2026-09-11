# Subtitle Engine Specification — Vela v1.0
**The Unified Subtitle Model, Repair Heuristics & Multi-Point Sync Algorithms**

---

## 1. The Unified Subtitle Model (USM)

Rather than maintaining separate, lossy data pipelines for SRT, ASS, and VTT, all subtitle inputs are parsed into a single normalized data structure: **Unified Subtitle Model**.

```
  SRT ────────┐
  ASS / SSA ──┤
  WebVTT ─────┼──▶ [ Unified Subtitle Model (USM) ] ──▶ [ Subtitle Canvas Renderer ]
  TTML ───────┤                     │
  SBV ────────┘                     └──▶ Serializers (SRT / ASS / VTT Exporter)
```

### 1.1 JSON Schema Definition
```typescript
interface UnifiedSubtitleProject {
  projectId: string;
  mediaHash: string;
  sourceEncoding: string; // 'UTF-8' | 'windows-1256' | 'shift_jis'
  metadata: {
    title?: string;
    originalAuthor?: string;
    targetLanguage?: string;
    fps?: number;
  };
  styles: Record<string, SubtitleStyleDefinition>;
  cues: UnifiedSubtitleCue[];
  healthReport: SubtitleHealthReport;
}

interface UnifiedSubtitleCue {
  id: string; // e.g. "cue_0001"
  index: number;
  startMs: number;
  endMs: number;
  durationMs: number;
  text: string; // Cleaned dialogue text
  rawFormatting?: string; // Preserved ASS or HTML override tags
  speakerId?: string; // e.g. "spk_01"
  characterId?: string; // e.g. "char_eren"
  styleKey: string; // References styles map
  position: {
    mode: 'bottom_center' | 'top_center' | 'speaker_anchored' | 'custom_xy';
    normalizedX?: number; // 0.0 - 1.0
    normalizedY?: number; // 0.0 - 1.0
    marginV?: number;
  };
  metrics: {
    charCount: number;
    wordCount: number;
    cps: number; // Characters per second
    confidenceScore: number; // 0.0 - 1.0 (from AI or 1.0 for manual)
    flags: SubtitleHealthFlag[];
  };
}
```

---

## 2. Subtitle Health & Repair Engine

The Health Engine inspects every loaded subtitle track and outputs a **Subtitle Health Score (0–100)**:

$$\text{Health Score} = \max\left(0, 100 - \sum \text{Penalty}_i\right)$$

### 2.1 Health Diagnostics & Repair Rules

| Anomaly Type | Detection Rule | Penalty | Automated Repair Strategy |
|---|---|---|---|
| **Overlapping Cues** | $\text{Cue}_n.\text{startMs} < \text{Cue}_{n-1}.\text{endMs}$ | $-15$ | Truncate previous cue end to $\text{Cue}_n.\text{startMs} - 20\text{ms}$ |
| **Negative Duration** | $\text{Cue}.\text{endMs} \le \text{Cue}.\text{startMs}$ | $-25$ | Set $\text{endMs} = \text{startMs} + \max(1200\text{ms}, \text{length} \times 60\text{ms})$ |
| **Micro Flash** | $\text{Duration} < 350\text{ms}$ | $-10$ | Extend duration to $800\text{ms}$ if no overlap with next cue |
| **Excessive Reading Speed** | $\text{CPS} > 22.0\text{ chars/sec}$ | $-10$ | Suggest line splitting or duration extension |
| **Broken Charset** | Replacement character `` or invalid UTF-8 byte sequences | $-30$ | Auto-fallback to `windows-1256` (Arabic) or `Shift-JIS` (Japanese) |
| **HTML / Garbage Tags** | Unclosed `<i>`, `<b>`, font color artifacts | $-5$ | Strip invalid tags; convert valid styling into USM style tokens |
| **Orphan Words** | Single trailing word on second line ($< 4$ characters) | $-5$ | Rebalance line break to natural linguistic comma / clause point |

---

## 3. Synchronization Algorithms

### 3.1 Global Offset Correction
Adjusts the entire track uniformly by $\Delta$:
$$t' = t + \Delta$$

### 3.2 Timeline Drift Correction
Solves progressive desynchronization where subtitles slowly fall behind or race ahead due to framerate mismatches (e.g. 23.976 fps vs 25.0 fps):

Given anchor points $(t_1, \Delta_1)$ and $(t_2, \Delta_2)$:
$$t' = t + \Delta_1 + \left(\frac{t - t_1}{t_2 - t_1}\right) \times (\Delta_2 - \Delta_1)$$

### 3.3 Two-Point Anchor Sync
1. User pauses video at an obvious dialogue start point (e.g. character begins speaking) $\rightarrow$ marks **Video Anchor 1** ($V_1$).
2. User selects the matching subtitle line in the Timeline $\rightarrow$ marks **Subtitle Anchor 1** ($S_1$).
3. User repeats for a later scene $\rightarrow$ marks **Video Anchor 2** ($V_2$) and **Subtitle Anchor 2** ($S_2$).
4. Vela calculates the linear affine transformation matrix and aligns all intermediary cues instantly.

### 3.4 Acoustic Waveform Auto-Sync (AI Pipeline)

```
Video File
    │
    ▼
FFmpeg Audio Extraction (16kHz Mono WAV)
    │
    ▼
Voice Activity Detection (Silero VAD) ──▶ Speech Segments [T_start, T_end]
    │
    ▼
Phoneme / Acoustic Envelope Matching ──▶ Cross-Correlation with Subtitle Dialogue
    │
    ▼
Dynamic Time Warping (DTW) ───────────▶ Compute Non-Linear Time Shift Matrix
    │
    ▼
Aligned Subtitle Track Export (.SRT / .ASS)
```

---

## 4. Advanced ASS / SSA Rendering Engine

Vela includes an engine for Advanced SubStation Alpha (`.ass`):
- **Styles Block**: Full parsing of `PrimaryColour`, `SecondaryColour`, `OutlineColour`, `BackColour`, `Bold`, `Italic`, `BorderStyle`, `Outline`, `Shadow`, `Alignment`, `MarginL`, `MarginR`, `MarginV`.
- **Dialogue Override Tags**:
  - `{\pos(x,y)}`: Exact pixel coordinates.
  - `{\an1}` to `{\an9}`: NumPad screen alignment mapping.
  - `{\c&HBBGGRR&}`: Dynamic color overrides.
  - `{\b1}` / `{\b0}`: Inline bold toggles.
  - `{\k}` / `{\kf}`: Karaoke timing tags.
- **Canvas Composition**: Renders text with vector-based stroke paths rather than multiple blurred overlays for crisp 60fps / 120fps performance on mobile displays.
