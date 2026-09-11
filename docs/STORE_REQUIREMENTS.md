# App Store & Google Play Compliance Guide — Vela v1.0
**Target SDK 36, Xcode 26 / iOS 26 SDK, Billing & Store Safety Policies**

---

## 1. Google Play Store Compliance (Android)

### 1.1 Target SDK Specification
- **Mandatory Target**: `targetSdkVersion = 36` (Android 16).
- **Minimum Target**: `minSdkVersion = 24` (Android 7.0 Nougat).
- **Compile SDK**: `compileSdkVersion = 36`.
- **Architectures**: Must produce 64-bit `.aab` bundles containing `arm64-v8a` and `x86_64` native binaries.

### 1.2 Foreground Services & Media Permissions
- Playback in background utilizes `ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK`.
- Required manifest permissions:
  ```xml
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
  <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
  ```

### 1.3 Google Play Billing 9.1.0+
- Must use Google Play Billing Library version `9.1.0` or higher.
- Subscriptions must be defined using Base Plans and Offers (no legacy SKU structures).
- Must implement account holding, grace period handling, and user cancellation redirection via Play Store deep links (`https://play.google.com/store/account/subscriptions`).

---

## 2. Apple App Store Compliance (iOS)

### 2.1 Toolchain & SDK Specification
- **Mandatory Build Environment**: Xcode 26 or higher using the iOS 26 SDK.
- **Minimum Deployment Target**: iOS 16.0.

### 2.2 App Store Review Guidelines
1. **Guideline 3.1.1 (In-App Purchase)**: All digital features (AI translation credits, cloud sync, premium subtitle presets) must be unlockable via StoreKit 2.
2. **Guideline 4.8 (Sign in with Apple)**: Because Google Sign-In is offered as an authentication option, Sign in with Apple must be provided as an equivalent primary option with identical prominent placement.
3. **Guideline 2.5.4 (Background Audio)**: Background audio execution is declared via the `audio` key in `UIBackgroundModes`, actively managing `NowPlayingInfoCenter` and remote command events.

---

## 3. Store Safety & Policy Checklist

- [x] **Zero Copyright Infringing Assets**: Store screenshots, video previews, and app descriptions feature 100% royalty-free, open-source demonstration media (e.g. *Big Buck Bunny*, *Cosmos Laundromat*, or licensed anime sequences).
- [x] **Clear Data Safety Form**: Declares that user video media is never tracked, sold, or shared with third parties.
- [x] **Ad Placement Safety**: No advertising banners or interstitials are presented during video playback.
