# Vela Design System & UI/UX Architecture Specification
**Master Product Design Language: Precision + Intelligence + Cinema + Simplicity**

---

## 1. Executive Design Philosophy

**Vela** is positioned as a globally competitive, world-class media intelligence platform. It merges an uncompromised media playback core with an advanced AI Subtitle Studio and Translation Engine.

### 1.1 Aesthetic Influences & Synthesis
The visual language bridges the best principles of:
- **Apple**: Calm hierarchy, fluid springs, human accessibility, and unobtrusive controls.
- **Linear**: Razor-sharp density, subtle micro-borders, purposeful monochrome surfaces, and high-performance keyboard/gesture ergonomics.
- **Notion**: Calm whitespace, structural elegance, and content-first layouts.
- **High-End Audio/Cinema Hardware**: Tactile precision, measured scrubbers, authentic waveform visualization, and dark obsidian canvas.

### 1.2 Anti-Patterns Explicitly Forbidden
- ❌ **No Neon Cyberpunk / Excessive Gradients**: Avoid psychedelic glowing borders, multi-colored neon text, and cheap linear gradients.
- ❌ **No Aggressive Glassmorphism**: Avoid blurry milk-bottle cards that obscure content or drain GPU battery. Use translucent obsidian surfaces with restrained 1px hairline borders (`rgba(255, 255, 255, 0.07)`).
- ❌ **No Template-Looking / Generic AI UI**: Zero floating "magical sparkle" buttons cluttering every toolbar. AI features are presented as precision engineering instruments (like high-end audio mastering tools).
- ❌ **No Cluttered Toolbars**: The player interface remains $100\%$ invisible during playback until requested. Controls fade gracefully with zero abrupt popping.

---

## 2. Complete Design Token Architecture

The token system is built on strict 4pt / 8pt rhythmic units, ensuring mathematical harmony across iOS, Android, and Desktop form factors.

### 2.1 Color Tokens

#### A. Dark Mode Palette (Primary Experience)
```
┌────────────────────────┬─────────────┬───────────────────────────────────────────┐
│ Token                  │ Hex Code    │ Purpose                                   │
├────────────────────────┼─────────────┼───────────────────────────────────────────┤
│ color-canvas           │ #090A0F     │ Deep obsidian base background             │
│ color-surface-base     │ #12141A     │ Ground level container / bottom nav       │
│ color-surface-elevated │ #1A1D26     │ Cards, modal sheets, floating panels      │
│ color-surface-active   │ #222634     │ Highlighted rows, hovered list items      │
│ color-border-subtle    │ #202430     │ Hairline container dividers (1px)         │
│ color-border-focus     │ #3B4259     │ Active inputs, focused elements           │
│ color-text-primary     │ #F8FAFC     │ High-emphasis titles & active text        │
│ color-text-secondary   │ #94A3B8     │ Metadata, duration, inactive track names  │
│ color-text-tertiary    │ #64748B     │ Captions, timestamps, subtle labels       │
│ color-text-disabled    │ #475569     │ Unavailable features, disabled buttons    │
└────────────────────────┴─────────────┴───────────────────────────────────────────┘
```

#### B. Light Mode Palette (Full Daylight Parity)
```
┌────────────────────────┬─────────────┬───────────────────────────────────────────┐
│ Token                  │ Hex Code    │ Purpose                                   │
├────────────────────────┼─────────────┼───────────────────────────────────────────┤
│ color-canvas           │ #F8F9FA     │ Clean porcelain canvas                    │
│ color-surface-base     │ #FFFFFF     │ Pure white elevated cards & sheets        │
│ color-surface-elevated │ #F1F3F7     │ Secondary containers & search bars        │
│ color-surface-active   │ #E5E8F0     │ Selected items and tab indicators         │
│ color-border-subtle    │ #E2E4EC     │ Soft neutral boundaries (1px)             │
│ color-border-focus     │ #CBD0DF     │ Focused inputs                            │
│ color-text-primary     │ #0F172A     │ Deep slate black for high legibility      │
│ color-text-secondary   │ #475569     │ Cool slate for secondary information      │
│ color-text-tertiary    │ #94A3B8     │ Muted captions and metadata               │
│ color-text-disabled    │ #CBD5E1     │ Inactive elements                         │
└────────────────────────┴─────────────┴───────────────────────────────────────────┘
```

#### C. Brand Accent & Functional Semantics (Shared)
```
┌────────────────────────┬─────────────┬───────────────────────────────────────────┐
│ Token                  │ Hex Code    │ Purpose                                   │
├────────────────────────┼─────────────┼───────────────────────────────────────────┤
│ color-accent-primary   │ #6366F1     │ Electric Indigo / Violet (Action point)   │
│ color-accent-hover     │ #4F46E5     │ Pressed / focused state                   │
│ color-accent-subtle    │ #1E1B4B     │ Tinted pill backgrounds (Dark Mode)       │
│ color-status-success   │ #10B981     │ Health score 90-100, synced, completed    │
│ color-status-warning   │ #F59E0B     │ Health score 75-89, timing drift detected │
│ color-status-error     │ #EF4444     │ Health score <75, decoding failure, desync│
│ color-status-info      │ #3B82F6     │ Audio track switch, subtitle load notices │
└────────────────────────┴─────────────┴───────────────────────────────────────────┘
```

---

### 2.2 Typography Scale & Bilingual Rules

Vela pairs **Inter** (or Apple SF Pro) for Latin characters with **Readex Pro** / **Cairo** for Arabic RTL typography, ensuring natural line baselines, zero character clipping, and balanced bilingual text.

```
┌────────────────┬──────────┬────────┬─────────────┬───────────────────────────────┐
│ Token          │ Size(sp) │ Weight │ Line Height │ Usage Example                 │
├────────────────┼──────────┼────────┼─────────────┼───────────────────────────────┤
│ type-display   │ 32       │ 700    │ 40px        │ Hero headers, Large titles    │
│ type-headline  │ 24       │ 600    │ 32px        │ Modal headers, Player title   │
│ type-title     │ 18       │ 600    │ 26px        │ Section headers, Movie titles │
│ type-body-lg   │ 15       │ 400    │ 22px        │ Primary subtitle dialogue     │
│ type-body-md   │ 13       │ 400    │ 18px        │ Metadata, descriptions        │
│ type-label     │ 12       │ 600    │ 16px        │ Badges, track selectors, tags │
│ type-caption   │ 11       │ 500    │ 14px        │ Timestamps (00:14:22), CPS    │
│ type-mono      │ 12       │ 500    │ 16px        │ Timecode scrubber, ASS tags   │
└────────────────┴──────────┴────────┴─────────────┴───────────────────────────────┘
```

#### Arabic & RTL Typography Principles:
1. **Vertical Alignment Offset**: Arabic scripts require $1.35\times$ to $1.45\times$ line height compared to Latin to prevent clipping of diacritics (Tashkeel) and descending glyphs (such as *Raa*, *Zay*, *Meem*).
2. **Bi-Directional Punctuation Shielding**: Arabic sentences embedded with English terms (e.g. `فيلم Oppenheimer (2023) رائع`) utilize explicit Unicode Left-to-Right / Right-to-Left embedding marks (`\u200E` and `\u200F`) to prevent inverted quotation marks or misplaced parentheses.

---

### 2.3 Spacing, Radii & Depth Tokens

#### Spacing (8pt Base Grid)
- `space-1` = `4px` (Tight padding between icon and text label)
- `space-2` = `8px` (Standard inner padding for badges and chips)
- `space-3` = `12px` (Internal spacing inside media metadata cards)
- `space-4` = `16px` (Standard horizontal gutter on mobile screens)
- `space-5` = `20px` (Card padding on tablet / desktop views)
- `space-6` = `24px` (Section divider vertical gaps)
- `space-8` = `32px` (Major screen segment transitions)
- `space-12` = `48px` (Top / bottom safe area insets)

#### Corner Radii
- `radius-xs` = `4px` (Timecode chips, subtitle bounding tags)
- `radius-sm` = `8px` (Buttons, track switches, input fields)
- `radius-md` = `12px` (Media cards, timeline blocks, drawer items)
- `radius-lg` = `16px` (Modal bottom sheets, elevated containers)
- `radius-full` = `9999px` (Pills, circular playback controls, scrub heads)

#### Depth & Surface Elevation
- **Level 0 (Base)**: `#090A0F` canvas, zero shadow.
- **Level 1 (Card)**: `#1A1D26` surface with `border: 1px solid #202430` and ambient shadow: `0 2px 8px rgba(0, 0, 0, 0.25)`.
- **Level 2 (Modal / Sheet)**: `#1E2230` surface with `border: 1px solid rgba(255, 255, 255, 0.08)` and directional shadow: `0 12px 32px rgba(0, 0, 0, 0.5)`.
- **Level 3 (HUD Overlay)**: Translucent `#0E1017` with `backdrop-filter: blur(20px)` and subtle hair-line accent stroke.

---

## 3. App Icon Master Specification

The Vela app icon is an abstract, recognizable mark representing:
$$\text{Media Motion} + \text{Audio Waveform} + \text{Subtitle Line} + \text{Intelligence Frame}$$

### 3.1 Icon Geometry & Symbol Construction
- **Base**: A rounded squircle in deep graphite obsidian (`#0B0D13`).
- **Core Glyph**: A luminous geometric **V-glyph** rendered in electric indigo (`#6366F1`) and violet (`#8B5CF6`).
- **Integration**:
  - The left arm forms a bold angular descent.
  - The vertex transitions into a refined soundwave oscillation, symbolizing acoustic synchronization.
  - The base rests on a crisp horizontal bar representing a calibrated subtitle cue.
  - The silhouette is razor-sharp and legible down to $16\text{px}$ in notification trays.
- **Strict Rule**: Zero text or letterforms ("Vela") inside the icon artwork.

---

## 4. Information Architecture & Navigation

The primary navigation follows an anchored bottom bar with contextual elevated layers:

```
┌─────────────────────────────────────────────────────────────┐
│                       MAIN APPLICATION                      │
│                                                             │
│  [ 🏠 HOME ]   [ 📁 LIBRARY ]   [ ✨ AI STUDIO ]            │
│  [ ⬇ DOWNLOADS ]   [ ⚙ SETTINGS ]                           │
│                                                             │
│                      CONTEXTUAL LAYER                       │
│  ├── [ ▶ FULLSCREEN IMMERSIVE PLAYER ] (Modal Surface)      │
│  │   ├── Minimalist HUD (Auto-hide 3s)                      │
│  │   ├── Gesture Surface (Brightness / Volume / Scrubbing)  │
│  │   └── Track Drawer (Audio / Subtitles / Channels)        │
│  └── [ 💬 SUBTITLE STUDIO & MAKE BEAUTIFUL ] (Drawer)       │
│      ├── Health Score Dial (0-100)                          │
│      ├── Timeline Scrubbing Editor                          │
│      └── Live Typography & Character Styler                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Screen-by-Screen UX Blueprint

### 5.1 Home Screen (`HomeScreen`)
- **Header**: Contextual time-of-day greeting ("Good evening, Ahmed") with secondary prompt ("Continue where you left off").
- **Continue Watching Carousel**:
  - Full-bleed cinematic 16:9 thumbnails.
  - Linear progress rail with remaining duration badge.
  - Embedded audio/subtitle flags (e.g. `[MKV] [HEVC 10-bit] [E-AC3] [AR Subs]`).
- **Recently Added**: Horizontal snap-carousel of newly scanned local media.
- **AI Quick Actions**:
  - `[ ✨ Make Beautiful ]`: Instant one-tap repair & styling.
  - `[ 🌐 Translate ]`: Fast contextual translation into user's primary language.
  - `[ ⏱ Smart Sync ]`: Automatic drift and offset correction.
  - `[ 🎙 Generate ]`: Speech-to-text pipeline for videos with missing subtitles.
- **Media Hubs Grid**: Fast routes to Movies, TV Shows, Anime (with specialized ASS support), and Network (SMB/WebDAV/DLNA).

---

### 5.2 The Media Library (`MediaLibraryScreen`)
- **View Modes**:
  1. **Cinematic Grid**: 3-column poster cards with high-contrast metadata badges.
  2. **Compact Grid**: 4-column compact items for dense storage browsing.
  3. **Detail List**: Single-column with technical parameters (file size, resolution, audio channels, embedded subtitle formats).
- **Intelligent Sorting**:
  - Recently Added, Recently Played, Alphabetical (A–Z), Duration, File Size.
- **Anime & Series Intelligence**:
  - Automatically parses file signatures (e.g. `[SubsPlease] Frieren - 28 (1080p).mkv`) into Show Title, Season, and Episode number, grouping them into clean seasons with continuous auto-play.

---

### 5.3 Subtitle Studio & "Make Beautiful" (`SubtitleStudioSheet`)
- **Subtitle Health Score (0–100)**: Real-time diagnostic bar categorizing issues:
  - Overlapping lines (Red)
  - Negative timestamps (Crimson)
  - Excessive reading speed > 21 CPS (Amber)
  - Broken encodings (Windows-1256 / UTF-8) (Cyan)
- **Make Beautiful Button**: Prominent indigo/violet gradient action button. On tap, it executes an automated pipeline:
  1. Resolves all cue overlaps by adjusting boundary timestamps.
  2. Rebalances text line-breaks at linguistic clause boundaries.
  3. Evaluates character and scene background colors for WCAG AAA contrast.
  4. Applies optimal typography tokens (Outfit, bold stroke halo, smooth drop shadow).
- **Interactive Timeline Inspector**:
  - Horizontal scrubbing rail displaying active cue duration blocks.
  - Fine-tune start/end times with $\pm 50\text{ms}$ precision buttons.

---

### 5.4 AI Studio Hub (`AIStudioScreen`)
An engineering-grade control center featuring 4 primary modular pipelines:
1. **Speech-to-Subtitle (Whisper Large-v3-Turbo)**: Extracts audio locally, performs VAD segmentation, and transcribes speech with word-level timestamps.
2. **Context-Aware Translation**: Translates complete dialogue scenes while honoring character relationships, tone, and project glossaries.
3. **Acoustic Waveform Auto-Sync**: Aligns existing desynchronized subtitle text to spoken audio phonemes via Dynamic Time Warping.
4. **Foreign Screen Text OCR**: Scans video frames for Japanese Kanji, Korean, or foreign signage, translating them in-place with styled perspective overlays.

---

### 5.5 Fullscreen Player (`VideoPlayerScreen`)
- **Zero-Distraction Mode**: Controls auto-hide after 3 seconds of inactivity.
- **Precision Gesture Zones**:
  - **Left 30% Vertical**: Linear brightness control with floating vertical pill.
  - **Right 30% Vertical**: Smooth system volume control with haptic tick at boundary limits.
  - **Horizontal Swipe**: Timecode scrubbing with floating thumbnail preview badge.
  - **Double-Tap**: $\pm 10\text{s}$ seek with smooth directional ripple arrows.
  - **Long-Press**: Accelerates playback to $2.0\times$ with discrete top indicator.
  - **Pinch-to-Zoom**: Smooth animated transition between Fit, Fill, 16:9, and 21:9 Ultrawide.

---

## 6. Accessibility & Inclusivity Matrix (WCAG 2.2 AAA)

1. **Color-Blindness Protection (CVD Engine)**:
   - All character subtitle colors undergo automated simulation against Deuteranopia, Protanopia, and Tritanopia color blindness curves.
   - If a color's contrast against the scene background falls below $4.5:1$, a protective dual-stroke boundary is dynamically applied.
2. **Dyslexia-Optimized Typography**:
   - One-tap switch to OpenDyslexic or heavy-baseline typography.
3. **Motion Sensitivity (Reduced Motion)**:
   - System accessibility setting automatically substitutes slide and spring animations with instant opacity fades.
