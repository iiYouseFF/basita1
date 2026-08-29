# Basita (بسيطة) — Home Services Platform

> Flutter · Firebase (Auth, Firestore, FCM, Analytics, Crashlytics) + Supabase (PostgreSQL, Storage, Edge Functions)

[![CI](https://github.com/iiYouseFF/basita1/actions/workflows/ci.yml/badge.svg)](https://github.com/iiYouseFF/basita1/actions/workflows/ci.yml)

**Supabase:** `eczybgjywdppvyyygnrd` (eu-west-1, PG 17) · **Firebase:** `bassyta-851a5` · **Branch:** `feat/backend-phase-4-hardening`

---

## Quick Start

```bash
# 1. Get packages
flutter pub get

# 2. Run with mock OTP (dev, any 6 digits passes per PROMPT.MD)
flutter run --dart-define=SUPABASE_URL=https://eczybgjywdppvyyygnrd.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi... \
            --dart-define=USE_MOCK_OTP=true

# 3. Run with real Firebase Phone Auth (prod)
flutter run --dart-define=USE_MOCK_OTP=false
```

No hard-coded keys in `lib/main.dart` — all via `lib/core/config/env.dart` (`String.fromEnvironment`).

---

## Architecture

- **Frontend:** Flutter Clean Architecture (`lib/core` + `lib/features/*/ {data,domain,presentation}`)
- **Backend - Relational:** Supabase PostgreSQL (9 tables), Storage (5 buckets), Edge Functions (3), Realtime
- **Backend - Document/Realtime:** Firebase Firestore (11 collections), Auth (Phone OTP), FCM, Analytics, Crashlytics
- See `docs/ARCHITECTURE.md` and `BACKEND_PLAN.md` (and interactive `backend-plan.html`)

### Responsibility Split

| Concern | Owner | Why |
|---------|-------|-----|
| Phone OTP | Firebase Auth | SMS deliverability Egypt |
| Profiles / Requests / Offers / Chat / Posts | Firestore | Realtime `snapshots()` |
| Notifications / Reviews / Promos / Tickets / Search / Payments / Appointments / Chat (supabase mirror) | Supabase PG | Joins, tsvector, cron |
| Files | Supabase Storage | `profiles`, `request`, `task_images`, `community_posts`, `account_verification` |
| Payments / Push | Edge Functions → Stripe/Fawry & FCM | Secrets not on client |

---

## Project Structure

```
lib/
├── core/
│   ├── config/ {env.dart, app_config.dart, firebase_options.dart}
│   ├── models/ {app_notification, review, promo_code, support_ticket, payment_log, appointment, chat_*}
│   ├── repositories/ {notification, review, promo_code, support_ticket, search, payment_log, appointment, chat, request, technician}
│   ├── services/ {supabase_service, storage_service, analytics_service, crash_service, order_accept_service}
│   └── session/ {user_session, user_data_session}
├── features/ {auth, booking, chat, community, family, home, offers, orders, payment, profile, technician, visits, ...}
└── main.dart  # Firebase + Supabase init + Crashlytics + Analytics observer
```

---

## Backend Setup (already deployed on `eczybgjywdppvyyygnrd`)

- **Tables (9, RLS):** `notifications`, `reviews`, `promo_codes`, `support_tickets`, `search_index` (GIN), `payment_logs`, `appointments` (+ backfilled `request_id/client_id`), `chat_rooms`, `chat_messages`
- **Extensions:** `pgcrypto`, `uuid-ossp`, `pg_cron 1.6.4`, `pg_trgm 1.6`, `http 1.6`, `vector 0.8.2`
- **RPCs:** `search_entities(q, etype, gov, lim)`, `increment_used_count(pid)`
- **Buckets (5):** `profiles` public 5MB, `account_verification` private 10MB, `request`/`task_images` private 10MB, `community_posts` public 5MB
- **Edge Functions (ACTIVE):** `send-notification` (JWT), `process-payment` (JWT, mock), `daily-reset` (no JWT, cron)
- **Firestore indexes:** 7 composites in `firestore.indexes.json`
- **Rules:** `firestore.rules` — posts now `authorId==uid` on create/update/delete

Run `flutter test --coverage` (17 tests) and `dart format --set-exit-if-changed --output=none .` — CI at `.github/workflows/ci.yml` runs analyze + test + verify-backend + build-check.

---

## Environment

| Env | SUPABASE_URL | USE_MOCK_OTP | Notes |
|-----|--------------|--------------|-------|
| Dev | `https://eczybgjywdppvyyygnrd.supabase.co` | `true` | Mock per PROMPT.MD |
| Prod | same | `false` | Real `verifyPhoneNumber` + SHA certs/APNs required |

Secrets (`STRIPE_SECRET_KEY`, `FCM_SERVICE_ACCOUNT`, `CRON_SECRET`) → `supabase secrets set` (not in repo). `vault` for sensitive.

---

## Docs

- `BACKEND_PLAN.md` — full 17-section plan with SQL, RLS, edge code
- `BACKEND_SERVICES.md` — auto-generated services spec
- `WORK_LOG.md` — work log (updated 2026-08-29, 7→9 tables, new project ref)
- `backend-plan.html` — interactive tracker (open in browser, localStorage)
- `docs/ARCHITECTURE.md` — distilled architecture

## License

Private — Basita team.
