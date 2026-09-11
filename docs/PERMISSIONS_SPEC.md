# Platform Permissions & Hardware Signals Specification — Vela v1.0
**Android 16 (API 36) & iOS 26 SDK: Zero-Overprivilege, Just-in-Time UX & Device Signals**

---

## 1. Core Philosophy: Zero-Overprivilege

Vela rejects the legacy practice of requesting broad permissions upon initial app installation.
- ❌ **No `MANAGE_EXTERNAL_STORAGE`**: All-Files-Access is dangerous, violates Google Play Policy for media utilities, and exposes user private directories.
- ❌ **No Camera Permission**: Analysis is performed on existing video frames, never live camera capture.
- ❌ **No Location Permission**: Media playback and subtitle intelligence are geographically independent.
- ❌ **No Contacts / Phone / SMS Permissions**: Zero access to personal telemetry.
- ❌ **No App Tracking Transparency (ATT)**: Vela contains zero cross-app advertising tracking SDKs.

---

## 2. Platform Permission Inventories

### 2.1 Android 16 (API 36) Permission Matrix

```xml
<!-- Core Network & Playback -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Conditional Notifications (Requested Just-in-Time) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Conditional Microphone (Only for Live Audio Dictation) -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Foreground Services (Strictly Declared Types) -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROCESSING" />
```

| Permission | Android Level | Trigger Context | Fallback if Denied |
|---|---|---|---|
| `INTERNET` | Install-Time | Background API sync, cloud AI workers | App operates in 100% offline playback mode |
| `POST_NOTIFICATIONS` | Runtime (API 33+) | User toggles "Notify me when AI finishes" | In-app notification toast when active; zero disruption |
| `RECORD_AUDIO` | Runtime | User taps "Live Voice-to-Subtitle" | File picker offered to import existing recorded audio |
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Declared | Background audio playback with system media notification | Playback stops when app leaves foreground |
| `FOREGROUND_SERVICE_MEDIA_PROCESSING` | Declared | Subtitle burn-in transcoding / MP4 remuxing | Processing pauses or warns user to keep app open |

---

### 2.2 iOS 26 SDK Permission Matrix

Configured strictly in `Info.plist` with transparent, user-centric disclosure strings:

```xml
<!-- Microphone (Only used if user taps Live Transcription) -->
<key>NSMicrophoneUsageDescription</key>
<string>Vela uses the microphone only when you explicitly tap Live Voice Transcription to convert speech into subtitles.</string>

<!-- Add-Only Photo Library (Saving exported clips without reading photos) -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Vela needs permission to save exported videos with embedded subtitles to your Photos library.</string>

<!-- Local Network Access (SMB / WebDAV / DLNA) -->
<key>NSLocalNetworkUsageDescription</key>
<string>Vela uses your local network to discover and stream media from your NAS, PC, or SMB servers.</string>
```

---

## 3. Permission State Machine & Just-In-Time UX

Every permission is wrapped in an isolated state machine managed centrally by `PermissionManager`:

```
[ NOT_REQUESTED ] ──▶ [ PRE_EXPLANATION_MODAL ]
                                │
                      User Taps "Continue"
                                │
                                ▼
                       [ SYSTEM_REQUESTING ]
                                │
         ┌──────────────────────┼──────────────────────┐
         ▼                      ▼                      ▼
    [ GRANTED ]            [ DENIED ]        [ PERMANENTLY_DENIED ]
                                │                      │
                                ▼                      ▼
                       [ GRACEFUL FALLBACK ]  [ SETTINGS_DEEP_LINK ]
```

### 3.1 Pre-Explanation Screen (Contextual Disclosure)
Before triggering the uncustomizable OS system dialogue, Vela displays an internal contextual sheet:
> **Enable Background Notifications?**
> Vela can alert you when:
> - Your 45-minute AI subtitle translation finishes.
> - High-resolution video export is ready.
> *(You can customize or silence this anytime in Settings).*
> `[ Not Now ]`   `[ Continue to Allow ]`

---

## 4. Hardware Signals & Device Event Architecture

To deliver an intelligent, battery-safe playback experience, the application listens to ambient system telemetry via `DeviceEventManager`:

```
┌─────────────────────────────────────────────────────────────┐
│                      DEVICE EVENT MANAGER                   │
├───────────────────┬─────────────────────────────────────────┤
│ Signal Source     │ Automated Application Response          │
├───────────────────┼─────────────────────────────────────────┤
│ Battery < 15%     │ Disables auto-start for heavy export;   │
│                   │ alerts user: "Connect charger to burn"  │
├───────────────────┼─────────────────────────────────────────┤
│ Thermal State Hot │ Throttles local AI threads; offers to   │
│                   │ offload translation job to Cloud        │
├───────────────────┼─────────────────────────────────────────┤
│ Storage < 2GB     │ Checks available space before remuxing; │
│                   │ prevents corrupted 99% export failures  │
├───────────────────┼─────────────────────────────────────────┤
│ Cellular Data     │ Prompts before uploading audio slices;  │
│                   │ default setting: "Wi-Fi Only for AI"    │
├───────────────────┼─────────────────────────────────────────┤
│ Headphone Unplug  │ Automatically pauses playback instantly │
├───────────────────┼─────────────────────────────────────────┤
│ Audio Focus Lost  │ Pauses video on incoming phone call or  │
│                   │ ducks audio for navigation prompts      │
└───────────────────┴─────────────────────────────────────────┘
```

---

## 5. System Media Integration & Share Sheet

1. **Lock Screen Media Controls**:
   - Integrated with `MediaSessionCompat` (Android) and `MPNowPlayingInfoCenter` (iOS).
   - Shows movie title, season/episode, timeline scrubber, and skip $\pm 10\text{s}$ buttons.
2. **System Share Target (Intent Filter / Share Extension)**:
   - When users tap "Share" on any `.mkv`, `.mp4`, `.srt`, or `.ass` file in the Files app, Vela appears as a verified target handler to open the media directly without requiring broad storage permissions.
