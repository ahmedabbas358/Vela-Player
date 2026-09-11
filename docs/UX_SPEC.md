# UX & UI Specification — Vela v1.0
**Human-Centered Design for Next-Gen Media Consumption**

---

## 1. Visual Language & Design Tokens

Vela embraces a modern, minimalist aesthetic inspired by Apple Human Interface Guidelines and Linear:
- **Refined Surfaces**: Subtle dark gradients, deep obsidian canvas (`#0D0E12`), translucent elevated cards (`rgba(26, 29, 36, 0.75)`), and zero unnecessary neon clutters.
- **Typography**: Primary typeface is **Outfit** / **Inter** for crisp Latin clarity, paired with **Readex Pro** / **Cairo** for natural Arabic RTL balance.
- **Micro-Interactions**: Fluid spring physics (stiffness: 300, damping: 25) for modal transitions, haptic ticks on gesture seeking, and subtle pulse feedback on AI processing.

```
┌────────────────────────────────────────────────────────────┐
│ COLOR PALETTE TOKENS                                       │
├───────────────────┬────────────────────────────────────────┤
│ Token             │ Hex / RGBA Value                       │
├───────────────────┼────────────────────────────────────────┤
│ bg-canvas         │ #0B0D13 (Obsidian Navy)                │
│ bg-surface        │ #151821 (Deep Slate)                   │
│ bg-surface-elev   │ #1E2230 (Elevated Card)                │
│ primary-accent    │ #4FA3FF (Electric Cerulean)            │
│ secondary-accent  │ #9D65FF (Amethyst Violet)              │
│ status-success    │ #10B981 (Emerald Green)                │
│ status-warning    │ #F59E0B (Amber Gold)                   │
│ status-error      │ #EF4444 (Crimson Rose)                 │
│ text-primary      │ #F8FAFC (98% Bright White)             │
│ text-secondary    │ #94A3B8 (Cool Slate Gray)              │
│ border-subtle     │ rgba(255, 255, 255, 0.08)              │
└───────────────────┴────────────────────────────────────────┘
```

---

## 2. Screen-by-Screen Wireframes & Specifications

### 2.1 Screen 1: Home (`HomeScreen`)

```
┌────────────────────────────────────────────────────────────┐
│ ✦ VELA                      [🔍 Search] [🔔 Notifications] │
├────────────────────────────────────────────────────────────┤
│ Good evening, Ahmed                                        │
│                                                            │
│ ▶ CONTINUE WATCHING                                        │
│ ┌───────────────────────────┐  ┌─────────────────────────┐ │
│ │ [Thumbnail Preview] 68%   │  │ [Thumbnail Preview] 22% │ │
│ │ Breaking Bad — S05E14     │  │ Suzume (2022)           │ │
│ │ 00:32:15 / 00:47:00       │  │ 00:24:10 / 02:01:45     │ │
│ └───────────────────────────┘  └─────────────────────────┘ │
│                                                            │
│ ⚡ AI STUDIO QUICK ACTIONS                                  │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ [ ✨ Make Beautiful ]  [ 🌐 Translate ]  [ ⏱ Smart Sync]│ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ 📁 MEDIA HUBS                                              │
│ ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│ │ 🎬 Movies    │  │ 📺 Series    │  │ ⛩ Anime (ASS/OCR) │ │
│ │ (142 titles) │  │ (18 shows)   │  │ (34 titles)        │ │
│ └──────────────┘  └──────────────┘  └────────────────────┘ │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ 🌐 Network Shares (SMB / WebDAV / DLNA)                │ │
│ └────────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────┤
│ [🏠 Home]   [📁 Library]   [✨ AI Studio]   [💎 Plus]      │
└────────────────────────────────────────────────────────────┘
```

---

### 2.2 Screen 2: Fullscreen Video Player (`VideoPlayerScreen`)

The player follows a zero-distraction policy: controls auto-hide after 3 seconds of inactivity.

```
┌─────────────────────────────────────────────────────────────┐
│ [◀ Back]   Breaking Bad — S05E14       [PIP] [⚙ Audio/Subs] │
│                                                             │
│                                                             │
│   ▲ Brightness Zone                       ▲ Volume Zone     │
│   │ (Left 30% swipe)                      │ (Right 30% swipe│
│   ▼                                       ▼                 │
│                                                             │
│                  [ Smart Subtitle Cue ]                     │
│               "We need to leave immediately."               │
│                                                             │
│                                                             │
│ 00:14:22 ━━━━━━━━━━━━●━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 00:47:00 │
│ [⏮ Prev]  [⏪ -10s]   [ ▶ Play / ❚❚ Pause ]   [⏩ +10s]  [⏭]│
│                                                             │
│ [ 💬 Subtitle Studio ]    [ 🔊 Audio FX ]    [ ⛶ Fill Mode ]│
└─────────────────────────────────────────────────────────────┘
```

#### Gesture Interaction Specifications:
1. **Vertical Swipes**:
   - Left third of screen: Linear screen brightness ($0.0 \rightarrow 1.0$) with smooth vertical progress pill.
   - Right third of screen: System volume slider with haptic feedback on max/min limits.
2. **Horizontal Scrubbing**:
   - Dragging across the center reveals a floating timestamp badge: `+00:15 (00:14:37)`.
3. **Double Taps**:
   - Double-tap left: Quick seek back 10s with ripple arrow animation.
   - Double-tap right: Quick seek forward 10s with ripple arrow animation.
4. **Pinch-to-Zoom**:
   - Smooth transition between **Fit (Letterbox)**, **Fill (Crop)**, **Original**, **16:9**, and **2.35:1 Cinematic**.
5. **Long Press**:
   - Holding down boosts playback speed to **2.0×** with a discreet `2× ▶▶` pill at the top; releasing restores normal speed.

---

### 2.3 Screen 3: Subtitle Studio & "Make Beautiful" Modal

Accessible directly from the player or the AI Studio tab.

```
┌─────────────────────────────────────────────────────────────┐
│ ✨ Vela Subtitle Studio                 [Revert] [Export ▾] │
├─────────────────────────────────────────────────────────────┤
│ Subtitle Health: 89 / 100                                   │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ [✓ Timing: 98%]  [✓ No Overlaps]  [⚠ CPS: 21.4 (Fast)]  │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │  ✨ MAKE BEAUTIFUL (One-Tap Optimize)                   │ │
│ │  Repairs overlaps, calculates speaker colors & balances │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ── TIMELINE CUE INSPECTOR ────────────────────────────────  │
│ [◀ Prev]                      Cue 84/412            [Next ▶]│
│ Text:   "We need to leave immediately."                     │
│ Timing: [ 00:14:22.400 ]  ──▶  [ 00:14:24.950 ]  (2.55s)    │
│ Speaker: [ Levi Ackerman (spk_02) ▾ ]                       │
│                                                             │
│ ── STYLING CONTROLS ──────────────────────────────────────  │
│ Font:      [ Outfit ▾ ]        Size: [ ──●────── ] 22 sp    │
│ Color:     [ #4FA3FF (Levi) ▾] Weight: [ Regular | Bold ]   │
│ Outline:   [ 2.5 px ▾ ]        Shadow: [ Medium Blur ▾ ]    │
│ Position:  [ Classic Bottom | Smart Speaker-Aligned ▾ ]     │
│ Contrast:  [ 11.4:1 — WCAG AAA Verified ✓ ]                 │
└─────────────────────────────────────────────────────────────┘
```

---

### 2.4 Screen 4: AI Studio Hub (`AIStudioScreen`)

```
┌─────────────────────────────────────────────────────────────┐
│ ✦ AI STUDIO                                [Credits: 420 ⚡] │
├─────────────────────────────────────────────────────────────┤
│ Choose an AI Enhancement Pipeline:                          │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🎙 Speech to Subtitle (Whisper Pipeline)                 │ │
│ │ Generate precise SRT/ASS from dialogue audio in seconds │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🌐 Context-Aware Translation                            │ │
│ │ Translate with character tone & glossary preservation   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ⏱ Acoustic Auto-Sync                                    │ │
│ │ Align desynced subtitles to speech audio waveforms      │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 👁 Japanese / Foreign Screen Text OCR                    │ │
│ │ Detect signs, letters, and banners & overlay translation│ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ── RECENT AI JOBS ────────────────────────────────────────  │
│ • Attack on Titan S04E01 — Auto-Sync        [Completed ✓]   │
│ • Oppenheimer (2023) — AR Translation       [Completed ✓]   │
│ • Jujutsu Kaisen S02E05 — Screen OCR        [In Progress 64%]│
└─────────────────────────────────────────────────────────────┘
```

---

### 2.5 Screen 5: Subscriptions & Credits Paywall

```
┌─────────────────────────────────────────────────────────────┐
│ [✕ Close]                                                   │
│                        ✦ VELA PLUS                          │
│             Elevate Your Viewing Intelligence               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   [✓] Ad-Free Forever (Even on Free Tier)                   │
│   [✓] Acoustic Auto-Sync with Video Dialogue                │
│   [✓] Contextual Translation with Custom Glossary           │
│   [✓] Character Intelligence Palette Generator              │
│   [✓] Batch Processing & Subtitle Burn-in Remux             │
│                                                             │
│ ┌───────────────────────────┐  ┌──────────────────────────┐ │
│ │ MONTHLY PLUS              │  │ BEST VALUE — YEARLY PRO  │ │
│ │ $1.99 / month             │  │ $39.99 / year            │ │
│ │ 500 Monthly AI Credits    │  │ 2,500 Monthly Credits    │ │
│ └───────────────────────────┘  └──────────────────────────┘ │
│                                                             │
│ [ ⭐ Start 7-Day Free Trial ]                               │
│ Cancel anytime in Google Play / App Store Settings          │
│ Terms of Service • Privacy Policy • Restore Purchases      │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Accessibility Standards (WCAG 2.2 AAA Compliance)

1. **Color Blindness Safety**:
   - Character colors are verified using the **CVD Simulation Algorithm** (Deuteranopia, Protanopia, Tritanopia).
   - If a character's designated hue falls below a $4.5:1$ contrast ratio against the scene background, an automatic dual-stroke halo (Black $2.5\text{px}$ + White $1\text{px}$) is injected.
2. **Dyslexia-Friendly Fonts**:
   - Built-in support for **OpenDyslexic** and weighted baseline fonts.
3. **RTL Native Mirroring**:
   - Bi-directional text engine natively handles mixed Arabic/English sentences without punctuation reversal or bracket inversion.
