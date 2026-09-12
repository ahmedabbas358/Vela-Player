# Software Bill of Materials (SBOM) & Open-Source License Inventory

**Vela Player — Production Architecture | Verified September 2026**  
**Repository**: `ahmedabbas358/Vela-Player`  
**Application ID**: `com.velaplayer.app`

---

## 1. Executive Summary & Legal Compliance Strategy

Vela Player is built on an open-source, privacy-first foundation. Because high-performance multimedia applications often incorporate native decoders, multiplexers, and rendering engines (e.g., FFmpeg, libass, libmpv, Media3), commercial distribution through the **Google Play Store** and **Apple App Store** requires strict compliance with copyright licenses (LGPL, GPL, Apache 2.0, MIT) and patent pool disclosures (MPEG LA, HEVC Advance / Access Advance, Via Licensing).

### Core Licensing Rule
> **Do not infer patent freedom from an open-source copyright license.**  
> An open-source license grants copyright permissions under specific conditions; it does **not** indemnify against patent claims on proprietary codecs (e.g., patented HEVC/H.265 profiles, Dolby AC-3/E-AC-3, DTS).

### Dual-Engine Risk Isolation
- **Primary Android Path (AndroidX Media3 1.11.0)**: Relies exclusively on platform-provided hardware decoders (`MediaCodec`). Codec patent royalties for hardware decoders are licensed and indemnified by device OEMs and Google.
- **Primary iOS Path (AVFoundation / AVPlayer)**: Uses Apple platform decoders (`VideoToolbox`). Patent indemnification is covered by Apple Inc.
- **Secondary Fallback Engine (libmpv / FFmpeg)**: Dynamically linked under LGPL v2.1+ (or GPL v2+ if GPL-only filters are activated). Source code offers and relinking capabilities are provided in accordance with section 6 of LGPL v2.1.

---

## 2. Shipped Native Binaries & Core Engine Inventory

| Component | Version / Baseline | Upstream Source | License | Distribution Constraints |
| :--- | :--- | :--- | :--- | :--- |
| **AndroidX Media3 (ExoPlayer)** | `1.11.0` (Aug 2026) | [androidx/media](https://github.com/androidx/media) | Apache 2.0 | Permissive. Attribution required in App Legal Notices. |
| **Media3 Session & UI** | `1.11.0` (Aug 2026) | [androidx/media](https://github.com/androidx/media) | Apache 2.0 | Permissive. Requires NOTICE preservation. |
| **libmpv** (Optional Fallback) | `0.38.0+` | [mpv-player/mpv](https://github.com/mpv-player/mpv) | LGPL v2.1+ / GPL v2+ | Dynamic library (`.so` / `.dylib`). Must permit end-user replacement/relinking. |
| **FFmpeg Core Libraries** | `7.0.x / 7.1` | [FFmpeg/FFmpeg](https://ffmpeg.org) | LGPL v2.1+ (default build) | Built without `--enable-gpl` / `--enable-nonfree` for store release. Source release provided upon request. |
| **libass** (Advanced Subtitles) | `0.17.x` | [libass/libass](https://github.com/libass/libass) | ISC License | Highly permissive BSD-like. Copyright notice required. |
| **FreeType2** | `2.13.x` | [freetype/freetype](https://freetype.org) | FreeType / FTL | FTL license attribution in About screen. |
| **HarfBuzz** | `9.0.x` | [harfbuzz/harfbuzz](https://github.com/harfbuzz/harfbuzz) | MIT License | Permissive. Text shaping engine for Arabic RTL & complex scripts. |
| **Fribidi** | `1.0.x` | [fribidi/fribidi](https://github.com/fribidi/fribidi) | LGPL v2.1+ | Dynamic linkage for Unicode Bidirectional Algorithm (Bidi). |

---

## 3. Flutter & Dart Package Ecosystem Inventory

| Package Name | Specified Scope | Declared License | Upstream Origin |
| :--- | :--- | :--- | :--- |
| `flutter` | UI Framework | BSD-3-Clause | Google Inc. |
| `provider` | State Management | MIT | Remi Rousselet |
| `shared_preferences` | Key-Value Storage | BSD-3-Clause | Flutter Community |
| `flutter_secure_storage`| Hardware Keystore/Keychain | BSD-3-Clause | German Saprykin |
| `http` | HTTP Client | BSD-3-Clause | Dart Project |
| `intl` | Arabic & Internationalization | BSD-3-Clause | Dart Project |
| `media_kit` | Multi-engine player bridge | MIT | Hitesh Kumar Saini |
| `file_picker` | Local Document Provider | MIT | Miguel Ruivo |
| `package_info_plus` | App Version Diagnostics | BSD-3-Clause | Flutter Community |
| `in_app_purchase` | Play Billing 9.1 & StoreKit 2 | BSD-3-Clause | Flutter Project |
| `test` | Unit & Fuzz Testing | BSD-3-Clause | Dart Project |

---

## 4. Codec & Patent Licensing Disclosures

### 4.1 H.264 / AVC (MPEG LA AVC Patent Portfolio)
- **Decoding via Platform**: Covered by Android OEM and iOS device licenses.
- **Decoding via Software**: Permissible for non-commercial distribution. For high-volume distribution, royalty obligations are tracked below standard royalty thresholds (first 100k units free per annum).

### 4.2 HEVC / H.265 (Access Advance / MPEG LA)
- Hardware decoders are preferred on all mobile devices.
- Vela does **not** bundle proprietary software HEVC encoders.
- Decodes exclusively through system decoders (`MediaCodec` on Android, `VideoToolbox` on iOS) where hardware royalties have already been remitted by the device manufacturer.

### 4.3 AV1 (AOMedia Video 1) & VP9
- Royalty-free, open media specifications developed by the Alliance for Open Media (AOMedia).
- Supported out of the box via Media3 and system software decoders with zero licensing friction.

### 4.4 Audio Codecs (AAC, MP3, Opus, FLAC, Vorbis)
- **Opus & FLAC**: Royalty-free open formats (RFC 6716, Xiph.Org).
- **AAC**: Decoded using platform decoders. No standalone AAC software encoder license required.
- **Dolby Digital (AC-3 / E-AC-3)**: Passthrough to AV receivers and HDMI/eARC endpoints is supported without in-app decode royalty liability.

---

## 5. Build-Time Attribution & Machine-Readable Notices

All production releases generate a machine-readable notice asset:
- **Location**: `assets/licenses/NOTICES.json` and system `LicenseRegistry.addLicense()`
- **Runtime Access**: Navigable in-app under **Settings → About & Open Source Notices**.

### Compliance Checklist for Store Submissions
1. [x] **No GPL-contaminated static binaries** linked to the main Flutter executable.
2. [x] **Dynamic linking** preserved for all LGPL dependencies (`.so` on Android).
3. [x] **Relinking instructions** documented in developer guides.
4. [x] **Complete source code** corresponding to LGPL components published on GitHub.
5. [x] **Zero tracking/analytics binaries** bundled without user consent.
