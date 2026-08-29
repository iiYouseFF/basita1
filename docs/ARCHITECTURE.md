# Basita Architecture — Distilled

> Complement to `BACKEND_PLAN.md` (full) and `README.md` (quick start). Generated 2026-08-29.

## 1. Stack

- **App:** Flutter 3.44.4 / Dart 3.12.2, Clean Architecture, `lib/core` shared + `lib/features/*`
- **Firebase:** Auth (Phone OTP mock/real via `AppConfig.useMockOtp`), Firestore (11 collections, RLS via `firestore.rules`), FCM (via Edge), Analytics + Crashlytics (`lib/core/services/*`)
- **Supabase:** `eczybgjywdppvyyygnrd` eu-west-1 PG 17, PostgreSQL 9 tables, Storage 5 buckets, Edge Functions 3, `pg_cron`/`pg_trgm`/`http`/`vector`

## 2. Data Ownership

```
Flutter (lib/main.dart: Env + CrashService + Analytics)
  ├─ Firebase Auth → UID/phone
  ├─ Firestore (realtime): users, technicians (phone docID), requests (+carpentry/plumbing/painting), offers, conversations/messages, PaymentCards (cardLast4), transactions, posts (authorId), verified, orders (legacy)
  └─ Supabase:
      ├─ PG: notifications, reviews, promo_codes, support_tickets, search_index (tsvector GIN), payment_logs, appointments (+chat_rooms/messages mirror)
      ├─ Storage: profiles (public), account_verification (private), request, task_images, community_posts (public)
      ├─ Edge: send-notification, process-payment, daily-reset
      └─ RPC: search_entities, increment_used_count
```

## 3. Key Flows

**Auth:** `login_screen → Firestore where(phone) → SharedPreferences + UserSession → OTP (mock 6 digits or real verifyPhoneNumber → PhoneAuthCredential) → Home`. Flag `AppConfig.useMockOtp` (default true).

**Request:** `request_service_screen → Supabase request bucket upload → RequestRepository.createRequest (firestore) → ChatRepository.getOrCreateRoom → offers_dashboard`.

**Payment:** `final_payment_screen → Edge Function process-payment (mock Stripe) + PaymentLogRepository.logPayment → Firestore requests status paid/completed + technicians wallet increment + transactions`.

**Search:** `SearchRepository.search → rpc search_entities ts_rank`.

## 4. Security

- **Firestore Rules:** owner/phone checks, posts `authorId==uid` (Phase 4), PaymentCards owner, transactions tech-only.
- **Supabase RLS:** all tables `ENABLE ROW LEVEL SECURITY`, 19→22 policies, `multiple_permissive` fixed by service_role write policies for promo/search.
- **Secrets:** no card numbers (cardLast4 only), `Env.supabaseUrl/AnonKey` via dart-define, Stripe/Fawry via `supabase secrets set` + `vault`.

## 5. Observability

- `AnalyticsService` (firebase_analytics): login, request_created, offer_submitted, payment_completed, chat_message_sent, post_created, search_performed + `logSearch`.
- `CrashService` (firebase_crashlytics): `FlutterError.onError`, `PlatformDispatcher.onError`, `setUserIdentifier`, `setCustomKey(user_type, governorate)`. Enabled only in release.

## 6. CI/CD

`.github/workflows/ci.yml` — 4 jobs: `analyze` (dart format + flutter analyze continue-on-error), `test` (flutter test --coverage, 17 tests), `verify-backend` (docs, firestore indexes JSON, Env wiring), `build-check` (web/apk on main). Triggers push to `main`/`feat/**` and PRs.

## 7. Phases

- **Phase 1:** 7→9 tables, extensions, buckets, RLS, RPCs, indexes, Env
- **Phase 2:** OTP flag, 3 Edge Functions ACTIVE
- **Phase 3:** Firestore repos (Request, Technician), hardening 6 Supabase repos, wiring 2 screens, chat tables
- **Phase 4:** RLS hardening, Firestore authorId, Analytics/Crashlytics, docs, tag `v1.0-backend-ready`

## 8. Run

```bash
flutter pub get
flutter test --coverage  # 17 passing
dart format --set-exit-if-changed --output=none .
flutter run --dart-define=USE_MOCK_OTP=true   # mock
flutter run --dart-define=USE_MOCK_OTP=false  # real
```

## 9. Next

- JWT mirror Firebase→Supabase for strict `auth.uid()` RLS
- Stripe/Fawry real gateway in `process-payment`
- FCM HTTP v1 fan-out in `send-notification`
- `generate-invoice`/`ai-assistant`/`search-technicians` Edge Functions (Phase 2 stretch)
