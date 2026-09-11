# Security & Protection Specification — Vela v1.0
**Zero-Key Client Architecture, Scoped Storage & Media Protection**

---

## 1. Zero Secret In-App Principle

**Under no circumstances are external AI API keys, payment secrets, or master tokens compiled into the mobile application binaries.**
- All third-party interactions (OpenAI, Anthropic, ElevenLabs, DeepL, Google Cloud, Apple Server) occur exclusively through the Vela Backend AI Gateway.
- The mobile app authenticates with the Vela Gateway using short-lived cryptographically signed JSON Web Tokens (JWT) via OAuth 2.0 with PKCE (Proof Key for Code Exchange).

---

## 2. Storage Security & Media Sandboxing

### 2.1 Android Scoped Storage Compliance (API 36 / Android 16)
- **Zero Legacy Storage Permissions**: Vela never requests `READ_EXTERNAL_STORAGE` or `WRITE_EXTERNAL_STORAGE`.
- **Granular Permissions**:
  - `READ_MEDIA_VIDEO` and `READ_MEDIA_AUDIO` for direct library scanning.
  - Android PhotoPicker and Storage Access Framework (SAF) for user-picked custom video and external subtitle directories.
- **Private App Sandbox**: User-saved subtitle presets, translation glossaries, and exported `.srt` files are stored in `getExternalFilesDir(null)` or app-isolated internal storage.

### 2.2 iOS App Sandbox & Security
- All file access utilizes security-scoped bookmarks for external media opened via the iOS Files app or AirDrop.
- Secure data (user credentials, encryption keys, auth tokens) is persisted strictly in the **iOS Keychain** via `kSecAttrAccessibleAfterFirstUnlock`.

---

## 3. Network & Transport Security

1. **Transport Layer Security**: Strict enforcement of **TLS 1.3** across all backend and gateway communication.
2. **Encrypted Temporary Assets**: Any audio slice uploaded for speech recognition is uploaded via pre-signed, time-limited S3 URLs (TTL: 15 minutes) with server-side encryption (`AES-256`).
3. **Data Ephemerality**:
   - Audio slices uploaded for AI processing are deleted immediately upon job completion.
   - Subtitle text cached in server Redis buffers for translation is purged within 24 hours.

---

## 4. Anti-Tampering & Piracy Compliance

- **No DRM Circumvention**: Vela does not provide or bundle tools to bypass Widevine, FairPlay, or other Digital Rights Management mechanisms.
- **No Piracy Aggregation**: Vela is strictly a neutral media player and processing utility. It contains zero built-in torrent scrapers, unauthenticated streaming scrapers, or links to copyright-infringing databases.
