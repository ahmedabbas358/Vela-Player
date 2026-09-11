# Billing & Subscriptions Specification — Vela v1.0
**Modern In-App Subscriptions, StoreKit 2, Google Play Billing 9.1+ & Credits**

---

## 1. Subscription Tier Strategy

Vela implements a hybrid **Subscription + Credit Wallet** model. The core video player remains completely ad-free and feature-rich forever to maximize organic adoption and retention.

| Plan | Price (Monthly / Annual) | AI Credits / Mo | Core Feature Inclusions |
|---|---|---|---|
| **Free** | $0 | 50 (Signup gift) | All Codecs, Hardware Acceleration, SRT/ASS/VTT, Subtitle Health, Manual & Drift Sync, Ad-Free Playback |
| **Plus** | $1.99 / mo<br>($14.99 / yr) | 500 | Acoustic Auto-Sync, Contextual Translation, Character Palette Colors, Unlimited Preset Storage, Subtitle Export |
| **Pro** | $4.99 / mo<br>($39.99 / yr) | 2,500 | Full Speech-to-Text Generation, Speaker Diarization, On-Screen OCR Translation, Batch Processing, Priority Cloud Queuing |
| **Credit Packs** | $0.99 (500 credits)<br>$2.99 (2,000 credits) | Add-on | One-time purchases; never expire; used when monthly quota is exhausted |

---

## 2. Google Play Billing Integration (Android)

In compliance with modern Google Play requirements:
- **Billing Library Version**: `com.android.billingclient:billing-ktx:9.1.0` or newer.
- **Product Architecture**: Built on the unified **Subscription $\rightarrow$ Base Plans $\rightarrow$ Offers** paradigm:
  - Subscription ID: `vela_subscription_tier`
    - Base Plan 1: `plus-monthly` ($1.99, auto-renewing)
    - Base Plan 2: `plus-yearly` ($14.99, auto-renewing, with 7-day free trial offer)
    - Base Plan 3: `pro-monthly` ($4.99, auto-renewing)
    - Base Plan 4: `pro-yearly` ($39.99, auto-renewing, with 14-day free trial offer)
- **Proration Mode**: `IMMEDIATE_WITH_TIME_PRORATION` for upgrades/downgrades.
- **Backend Sync**: Cloud Pub/Sub listens for Real-Time Developer Notifications (RTDN).

---

## 3. Apple StoreKit 2 Integration (iOS)

In compliance with Xcode 26 / iOS 26 SDK guidelines:
- **Swift StoreKit 2 Architecture**:
  - Uses `Product.products(for:)`, `product.purchase()`, and `Transaction.currentEntitlements`.
  - Parses cryptographically signed JWS (JSON Web Signature) payloads directly on both client and server.
- **App Store Server Notifications V2**:
  - Server listens to events: `SUBSCRIBED`, `DID_RENEW`, `DID_CHANGE_RENEWAL_STATUS`, `EXPIRED`, `REFUND`.
  - Cryptographically verifies Apple root certificates to eliminate fraudulent purchase spoofing.

---

## 4. Cross-Platform Entitlement & Guest Architecture

Users can use the app without creating an account (Guest Mode). When they subscribe, their subscription is bound to their Device ID and synced to the Vela backend:

```
[ Unauthenticated Device ] ──▶ Purchases on Google Play / App Store
                                        │
                                        ▼
                   [ Local Receipt / Signed JWS Generated ]
                                        │
                                        ▼
                  [ Server Validates with Google / Apple ]
                                        │
                                        ▼
               [ Entitlement Bound to UUID (Guest Device) ]
                                        │
                         User Later Taps "Sign in with Apple/Google"
                                        │
                                        ▼
              [ Automatic Account Merge: Guest UUID ──▶ Verified User ]
                 (Zero loss of purchases, history, or credits)
```

---

## 5. Credit Wallet Ledger & Atomic Accounting

To ensure zero credit duplication or double-charging during network drops:
1. When a user requests an AI job, the backend verifies `(balance_monthly + balance_purchased) >= job_estimated_cost`.
2. The estimated credits are temporarily reserved.
3. Upon job completion, the exact token-based cost is debited via an atomic PostgreSQL transaction:

```sql
BEGIN;
UPDATE credit_wallets 
SET balance_monthly = balance_monthly - 15,
    updated_at = NOW()
WHERE user_id = 'c4b8e210-91a3-488f-b9f1-329048a12902' 
  AND balance_monthly >= 15;

INSERT INTO credit_transactions (user_id, job_id, delta, balance_after, reason)
VALUES ('c4b8e210-91a3-488f-b9f1-329048a12902', 'job_88a7b', -15, 485, 'translation_subtitles');
COMMIT;
```
