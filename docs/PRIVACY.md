# Privacy Policy & Architecture — Vela v1.0
**On-Device First Guarantee & Data Minimization Architecture**

---

## 1. The Core Privacy Pledge

> **"Your media stays on your device unless you explicitly choose cloud processing."**

Vela is engineered so that $100\%$ of standard media playback, subtitle rendering, manual/drift synchronization, subtitle styling, and health checks happen strictly on-device with zero network traffic.

---

## 2. Local vs. Cloud Processing Matrix

| Feature | Where it Runs | Data Transferred | User Consent Required? |
|---|---|---|---|
| **Video Playback** | 100% Local (Hardware) | None | No (Default) |
| **Subtitle Parsing & Styling** | 100% Local | None | No (Default) |
| **Subtitle Health Score** | 100% Local Heuristics | None | No (Default) |
| **Manual & Drift Sync** | 100% Local | None | No (Default) |
| **Subtitle Editor & Timeline** | 100% Local | None | No (Default) |
| **Acoustic Auto-Sync** | Cloud / Local Hybrid | Extracted audio waveform only | Explicit user action |
| **AI Translation** | Cloud Gateway | Subtitle dialogue lines + Glossary | Explicit user action |
| **Speech-to-Text (STT)** | Cloud Worker | Compressed audio slice (16kHz mono) | Explicit user action |
| **Screen OCR Translation** | Cloud Vision Worker | Video frame crops of detected text | Explicit user action |

---

## 3. Data Minimization & Retention Rules

1. **Zero Full-Video Transfers**: Vela **never** uploads raw full video files to any server. Only stripped audio tracks or individual cropped frames are uploaded when specific AI jobs are triggered.
2. **Immediate Server Deletion**:
   - Audio files are stored in ephemeral memory or scratch buckets with a maximum Time-To-Live (TTL) of 15 minutes.
   - Upon completion or failure of an AI job, all media artifacts are permanently removed.
3. **Privacy-Preserving Telemetry**:
   - Crash reports (Crashlytics / Sentry) only capture stack traces and device models.
   - **Never collected**: File paths, video file names, media hash IDs, or subtitle text dialogue.

---

## 4. User Rights & Data Portability (GDPR / CCPA)

- **One-Tap Data Export**: Users can export all saved subtitle presets, glossaries, and watch histories as an encrypted JSON archive.
- **Immediate Account Deletion**: Deleting an account instantly wipes the user record, active device bindings, and credit transaction history from production and backup databases within 7 days.
