# Basita (بسيطة) — Home Services Platform

> Flutter frontend → Node.js backend · Live API: **http://basseeyta.duckdns.org** · Backend repo: **https://github.com/iiYouseFF/basseeyta**

[![CI](https://github.com/iiYouseFF/basita1/actions/workflows/ci.yml/badge.svg)](https://github.com/iiYouseFF/basita1/actions/workflows/ci.yml)
[![Backend CI](https://github.com/iiYouseFF/basseeyta/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/iiYouseFF/basseeyta/actions)

**Status:** Frontend wired to live Node API. PRD at `docs/backend-prd.html` · API docs at `http://basseeyta.duckdns.org/api-docs.json`

---

## Quick Start

### Frontend (this repo)

```bash
flutter pub get

# Against live backend (recommended) — any 6 digits pass when backend USE_MOCK_OTP=true
flutter run --dart-define=API_BASE_URL=http://basseeyta.duckdns.org --dart-define=USE_MOCK_OTP=true

# Or mock-only (no network)
flutter run --dart-define=USE_MOCK_OTP=true

# Health check
curl http://basseeyta.duckdns.org/health
# {"status":"ok","version":"1.0.0","db":"connected","env":"production"}
```

Config via `lib/core/network/api_config.dart`:
- `API_BASE_URL` — default `http://basseeyta.duckdns.org` (override with `--dart-define`)
- `API_KEY` — optional bearer (now `AuthSession.token` from `/auth/verify-otp`)
- `USE_MOCK_OTP` — `true` ⇒ Flutter + backend accept any 6 digits; `false` ⇒ real Firebase OTP

**Note:** Live API is `http` (not `https`). Android has `usesCleartextTraffic=true` (`android/app/src/main/AndroidManifest.xml:11`), iOS has `NSAllowsArbitraryLoads` (`ios/Runner/Info.plist`).

### Backend (Node.js repo)

Repo: **https://github.com/iiYouseFF/basseeyta** — Express 4 + Socket.io 4 + Supabase PG 17 + Firebase Admin + BullMQ + Redis

```bash
git clone https://github.com/iiYouseFF/basseeyta
cd basseeyta
cp .env.example .env  # set SUPABASE_URL, JWT_SECRET, etc.
npm install
npm run dev    # http://localhost:3000  (or VPS : PM2 + Nginx)
npm test       # 37 tests
curl http://localhost:3000/health
curl http://basseeyta.duckdns.org/api-docs.json  # 88 endpoints
```

---

## Architecture

```
Flutter (lib/main.dart → ApiConfig + AuthSession)
    │
    ├─ lib/core/network/api_client.dart  (http, JWT bearer, 30s timeout)
    ├─ lib/core/session/auth_session.dart (SharedPreferences JWT)
    ├─ lib/core/repositories/*  (now real: Auth, Requests, Chat, Payments, etc. → http://basseeyta.duckdns.org)
    │
    └─► Node.js Express at http://basseeyta.duckdns.org
         ├─ Supabase PG 17 (9+ tables + RLS) — sql/migrations/
         ├─ Supabase Storage (5 buckets: profiles, account_verification, request, task_images, community_posts)
         ├─ Firebase Admin (Phone OTP + FCM)
         ├─ BullMQ + Redis (cron workers)
         └─ Socket.io (/chat, /notifications, /requests)
```

**Old backend removed:**

| Previously | Now |
|---|---|
| `firebase_*`, `supabase_flutter` in `pubspec.yaml` | Replaced by `http` + `ApiConfig` |
| `firebase_options.dart`, `env.dart`, `firebase.json`, `firestore.*` | Stubbed / archived to `docs/archive_*` |
| `lib/main.dart` Firebase/Supabase init | Now `ApiConfig.init()` + `AuthSession.load()` |
| Repos with `MockFirestore` | Now `AuthRepository`, `RequestRepository` etc. call live API; fallback mock if `USE_MOCK_OTP` |
| `MockAuth.verifyPhoneNumber` in `login_screen`/`otp_screen` | Now `AuthRepository.requestOtp`/`verifyOtp` → JWT |

---

## Project Structure

```
lib/
├── core/
│   ├── network/ { api_client.dart, api_config.dart (→ basseeyta.duckdns.org), mock_backend.dart (fallback) }
│   ├── repositories/ { auth_repository.dart, request_repository.dart, chat_repository.dart, notification_repository.dart, technician_repository.dart, appointment_repository.dart, payment_log_repository.dart, promo_code_repository.dart, review_repository.dart, search_repository.dart, support_ticket_repository.dart, instapay_repository.dart } // wired to live API
│   ├── services/ { storage_service.dart → POST /storage/upload, supabase_service (shim), analytics/crash (no-op) }
│   └── session/ { auth_session.dart (JWT), user_session.dart, user_data_session.dart }
├── features/ { auth (login/otp now real), booking, chat, community, family, home, offers, orders, payment, profile, technician, visits }
└── main.dart  # ApiConfig + AuthSession

Backend repo: https://github.com/iiYouseFF/basseeyta
├── src/modules/ auth, service-requests, offers, chat, storage, payments, community, search, notifications, support, reviews, visits, appointments, family, verification, ai
├── src/config/ env, supabase, firebase, redis
├── sql/migrations/ 001..006
└── docs/ API docs, VPS setup
```

---

## Live API — 88 Endpoints

Base: `http://basseeyta.duckdns.org` — Docs: `http://basseeyta.duckdns.org/api-docs.json`

| Module | Key endpoints |
|---|---|
| Auth & Users (11) | `POST /auth/request-otp`, `POST /auth/verify-otp` → JWT, `POST /auth/register`, `POST /auth/technicians/register`, `GET /users/me`, `GET /users?phone=`, `GET /technicians/:phone` |
| Service Requests (8) | `POST /service-requests`, `POST /service-requests/carpentry|plumbing|painting|electrical`, `GET /service-requests?userId&status&governorate`, `PATCH /service-requests/:id/status` |
| Offers (3) | `POST /service-requests/:id/offers`, `GET /service-requests/:id/offers`, `PATCH /offers/:id` (transactional: offer→request→chat→appointment→push) |
| Chat (6) | `POST /chat/rooms`, `GET /chat/rooms?userId=`, `GET /chat/rooms/:id/messages`, `POST /chat/rooms/:id/messages` (+ Socket.io `join_room`, `send_message`) |
| Storage (3) | `POST /storage/upload` (multipart `bucket,documentId,file`), `GET /storage/:bucket/:path`, `DELETE` |
| Payments (10) | `POST /payment-cards` (cardLast4 only), `POST /payments` (6-step atomic), `POST /payments/instapay`, `GET /promo-codes/validate` |
| Community (5) | `POST /posts`, `GET /posts?category=`, `POST /posts/:id/like` |
| Search (3) | `GET /search?q=سباكة&entityType=technician&governorate=القاهرة`, `POST /search/index` |
| Notifications (6) | `GET /notifications?userId=`, `POST /notifications`, `POST /push/send` → FCM |
| Others | `POST /support-tickets`, `POST /reviews`, `GET /visits`, `POST /appointments`, `GET /users/:uid/family-members`, `POST /verification`, `POST /ai/assistant`, `POST /jobs/:name` (CRON_SECRET) |

**E2E happy path:** register → upload → request → tech register → GET pending → offer → `PATCH /offers/:id` accepted → chat → pay → review

```bash
# Flutter switch (already default)
flutter run --dart-define=API_BASE_URL=http://basseeyta.duckdns.org --dart-define=USE_MOCK_OTP=true
```

---

## Verification

```bash
flutter pub get
dart analyze          # 0 errors
flutter test          # 17/17 passed (auth, requests, notifications, etc.)

# Live API smoke
curl http://basseeyta.duckdns.org/health
curl http://basseeyta.duckdns.org/service-requests
curl http://basseeyta.duckdns.org/api-docs.json | jq '.totalEndpoints'  # 88
```

---

## Docs

- **Live API docs:** `http://basseeyta.duckdns.org/api-docs.json` (88 endpoints) + `https://github.com/iiYouseFF/basseeyta#api` (README table)
- **Flutter PRD (frontend-only spec):** `docs/backend-prd.html` (and `backend-prd.html` at root) — printable, 17 sections, now references `http://basseeyta.duckdns.org`
- **Backend PRD & plan:** `https://github.com/iiYouseFF/basseeyta/blob/main/docs/BASITA_BACKEND_PLAN.md`, `docs/PROJECT_DETAILS.md`
- Old `BACKEND_PLAN.md`, `BACKEND_SERVICES.md`, `backend-plan.html`, `firestore.*` → `docs/archive_*` (kept for reference)
- `WORK_LOG.md` — work log

## License

Private — Basita team.
