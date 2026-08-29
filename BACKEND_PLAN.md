# Basita (بسيطة) — Backend System Plan

> **Stack:** Flutter + **Firebase** (Auth, Firestore, FCM, Analytics, Crashlytics) + **Supabase** (PostgreSQL, Storage, Edge Functions, Realtime)  
> **Supabase Project:** `eczybgjywdppvyyygnrd` (`eu-west-1`, PG 17.6.1) — `https://eczybgjywdppvyyygnrd.supabase.co` — Status: `ACTIVE_HEALTHY` — **DB empty, 0 migrations**  
> **Firebase Project:** `bassyta-851a5` (718849850419)  
> **Date:** 2026-08-29  
> **Replaces/Extends:** `BACKEND_SERVICES.md:1` + `WORK_LOG.md:1` (old Supabase ref `wduombkxwcqhipdumxmn` is stale)

---

## Table of Contents

1. [Goal & Principles](#1-goal--principles)
2. [Current State Audit — What Exists Today](#2-current-state-audit--what-exists-today)
3. [Architecture Overview & Responsibility Split](#3-architecture-overview--responsibility-split)
4. [Supabase PostgreSQL — Source of Truth for Structured Data](#4-supabase-postgresql--source-of-truth-for-structured-data)
5. [Firebase Firestore — Source of Truth for Realtime / Document Data](#5-firebase-firestore--source-of-truth-for-realtime--document-data)
6. [Supabase Storage Buckets](#6-supabase-storage-buckets)
7. [Authentication — Mock OTP (Dev) + Real Phone OTP (Prod)](#7-authentication--mock-otp-dev--real-phone-otp-prod)
8. [Edge Functions & Cron Jobs](#8-edge-functions--cron-jobs)
9. [Security — RLS + Firestore Rules + Storage Policies](#9-security--rls--firestore-rules--storage-policies)
10. [Flutter Data Layer — Clean Architecture Mapping](#10-flutter-data-layer--clean-architecture-mapping)
11. [Realtime & Offline Strategy](#11-realtime--offline-strategy)
12. [Observability — Analytics, Crashlytics, Logging](#12-observability--analytics-crashlytics-logging)
13. [Environments & Config](#13-environments--config)
14. [Phased Implementation Roadmap](#14-phased-implementation-roadmap)
15. [Risks & Mitigations](#15-risks--mitigations)
16. [What to Build First — 5 Concrete Migrations](#16-what-to-build-first--5-concrete-migrations)
17. [Appendix — API Surface Summary](#17-appendix--api-surface-summary)

---

## 1. Goal & Principles

**Goal:** Ship a production-grade hybrid backend where **Firebase owns identity + realtime documents** and **Supabase owns relational data + files + server logic**, without duplicating source of truth.

**Principles (from `AGENTS.md:1`):**

- Flutter Clean Architecture: `lib/core/` + `lib/features/*/ {data,domain,presentation}`. No direct `FirebaseFirestore.instance` calls in widgets — go through `core/repositories/`.
- Supabase: verify `list_tables` + RLS before writing any repo (`supabase-integration SKILL.md:1`).
- Firebase: every Firestore call wrapped in `try/catch` → `FirebaseCrashlytics.recordError`.
- Git: one branch per phase (`feat/backend-phase-1-schema`, etc.), atomic commits.
- No plaintext secrets: cards = last-4 only (already fixed per `WORK_LOG.md:378`), IDs = `gen_random_uuid()`.

---

## 2. Current State Audit — What Exists Today

Verified live on 2026-08-29 via MCP:

| Layer | Live State | Evidence |
|-------|-----------|----------|
| **Supabase DB** | **Empty** — 0 tables in `public`, 0 migrations, only `pgcrypto` + `uuid-ossp` + `pg_stat_statements` installed | `supabase_list_tables:1` + `supabase_list_migrations:1` + `supabase_list_extensions:1` |
| Supabase Project | `eczybgjywdppvyyygnrd` active, created 2026-08-29 | `supabase_list_projects:1` |
| Supabase Storage | Buckets from `WORK_LOG.md:5` do **not** exist in new project — must recreate | No `storage.buckets` rows yet |
| Supabase Edge Functions | None deployed in new project | Documented in `WORK_LOG.md:6` for old project |
| Firebase Auth | OTP is **mocked per `PROMPT.MD:1`** — any 6 digits passes. `lib/features/auth/screens/otp_screen.dart:1` was reverted to fake; `WORK_LOG.md:8` real-OTP work is on hold | `PROMPT.MD:1` |
| Firestore | Collections `users`, `technicians`, `requests`, `offers`, `conversations`, `PaymentCards`, `transactions`, `posts`, `verified` in use by app | `BACKEND_SERVICES.md:103` + `firestore.rules:1` |
| Firestore Rules | **Deployed** `firestore.rules:1` — 11 collections secured (owner/phone checks), `orders` legacy open | `firestore.rules:1` |
| Firestore Indexes | `firestore.indexes.json:1` empty — composite queries (`requests` by `status+governorate+createdAt`) will fail at scale | `firestore.indexes.json:1` |
| Flutter Repos | 6 Supabase repos already coded (`lib/core/repositories/`: `notification_repository.dart:1`, `review_repository.dart`, `promo_code_repository.dart`, `support_ticket_repository.dart`, `payment_log_repository.dart`, `search_repository.dart`) but point at non-existent tables | `lib/core/repositories/` listing |
| Flutter Models | 5 Supabase models ready (`lib/core/models/`: `app_notification.dart:1`, `review.dart`, `promo_code.dart`, `support_ticket.dart`, `payment_log.dart:1`) | `lib/core/models/` |
| Flutter Services | `supabase_service.dart:1` wrapper + `storage_service.dart`; `lib/main.dart:7` initializes both SDKs | `lib/main.dart:7` |
| SharedPreferences | 18 keys for session cache (`BACKEND_SERVICES.md:279`) — remains local cache, not source of truth | `BACKEND_SERVICES.md:279` |
| Payment Security | **Fixed** — `cardLast4` only, fallback for legacy `cardNumber` (`WORK_LOG.md:378`) | `WORK_LOG.md:378` |

**Implication:** The new Supabase project is a greenfield. Re-apply all 6 tables + extensions + buckets + functions that were on the old project. Do NOT attempt to reuse the old project ID.

---

## 3. Architecture Overview & Responsibility Split

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP (lib/main.dart:7)            │
│  Clean Architecture: Presentation → Domain → Data (Repository)    │
├─────────────────────────────┬───────────────────────────────────┤
│          FIREBASE           │            SUPABASE                │
│  ─────────────────          │  ─────────────────                 │
│  Auth (Phone OTP)  ─────────┼──► Supabase Auth (JWT mirror)     │
│  Firestore (documents)      │  PostgreSQL (relational)           │
│  FCM (push delivery)        │  Storage (files)                   │
│  Analytics + Crashlytics    │  Edge Functions (server logic)     │
│  Realtime listeners         │  Realtime (optional for PG)        │
└─────────────────────────────┴───────────────────────────────────┘
         ▲                                ▲
         │                                │
    Client SDKs                  Client SDKs + Edge Functions
```

### 3.1 Decision Matrix

| Concern | Owner | Why |
|---------|-------|-----|
| **Phone OTP identity** | **Firebase Auth (primary)** | Best SMS deliverability in Egypt; verified `verifyPhoneNumber` flow in `otp_screen.dart` |
| **JWT for Supabase RLS** | Supabase Auth (secondary, mirror) | RLS needs `auth.uid()`. Use Firebase UID → Supabase custom JWT or Supabase Auth phone as mirror. For MVP, use Supabase `anon` + app-level checks + Edge Function service role; phase 2 add JWT exchange |
| **User/Technician profiles, Requests, Offers, Chat, Posts, Verification** | **Firestore** | Already live, needs realtime `snapshots()`, no benefit to migrate |
| **Notifications, Reviews, Promo Codes, Support Tickets, Search Index, Payment Logs, Appointments, Chat metadata** | **Supabase PostgreSQL** | Needs SQL joins, full-text (`tsvector`), aggregations, cron |
| **All file uploads** | **Supabase Storage** | 5 buckets, cheaper, already coded in `storage_service.dart` |
| **Payments (Stripe/Fawry)** | **Supabase Edge Function `process-payment`** | Must not expose keys on client |
| **Push fan-out** | **Supabase Edge Function `send-notification` → FCM** | Centralized throttling + logging to `notifications` table |
| **Scheduled jobs** | **pg_cron + Edge Function `daily-reset`** | Reset `todayEarnings`, expire offers |
| **Analytics/Crash** | **Firebase** | Already in `pubspec.yaml:23` |

### 3.2 Data Flow — Service Request Example

```
Customer: request_service_screen.dart
  → upload images to Supabase `request` bucket (storage_service.dart)
  → Firestore `requests.add()` (userId = Firebase UID)
  → Edge Function `send-notification` → FCM topic `requests_{governorate}`
  → Supabase `search_index` insert via trigger (optional)

Technician: technician_dashboard.dart
  → Firestore `requests.where(status==pending, governorate==techGov).snapshots()`
  → submit offer → Firestore `offers.add()`
  → Customer: `offers.where(requestId==...).snapshots()` → accept
  → Firestore `requests.update(status=accepted, technicianId, acceptedPrice)`
  → Supabase `notifications.insert()` + FCM push both sides
```

---

## 4. Supabase PostgreSQL — Source of Truth for Structured Data

### 4.1 Extensions to Enable

```sql
create extension if not exists "pgcrypto" with schema extensions;   -- already ✓
create extension if not exists "uuid-ossp" with schema extensions;  -- already ✓
create extension if not exists "pg_cron" with schema cron;
create extension if not exists "pg_trgm" with schema extensions;    -- fuzzy search
-- http for Edge Functions calling out, vector for future AI search
create extension if not exists "http" with schema extensions;
create extension if not exists "vector" with schema extensions;     -- optional, for AI assistant embeddings
```

Checked live: `pg_cron`, `pg_trgm`, `http`, `vector` are available but **not yet installed** (`supabase_list_extensions:1`).

### 4.2 Tables — 7 MVP Tables (6 from WORK_LOG + 1 missing: appointments)

All tables: `id UUID PK default gen_random_uuid()`, `created_at TIMESTAMPTZ default now()`, RLS enabled, `updated_at` where mutable.

#### 4.2.1 `notifications` — Push log + in-app inbox

```sql
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,                          -- Firebase UID or phone
  user_type text not null check (user_type in ('user','technician')),
  title text not null,
  body text not null,
  type text not null default 'system'
    check (type in ('request_update','payment','chat','system','promo','verification')),
  data jsonb default '{}'::jsonb,
  is_read boolean default false,
  created_at timestamptz default now()
);
create index idx_notifications_user on public.notifications (user_id, is_read, created_at desc);
alter table public.notifications enable row level security;
-- Realtime: alter publication supabase_realtime add table public.notifications;
```

Dart: `lib/core/models/app_notification.dart:1` + `lib/core/repositories/notification_repository.dart:1` already match this schema 1:1.

#### 4.2.2 `reviews` — Technician ratings

```sql
create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  request_id text not null,
  reviewer_id text not null,                     -- Firebase UID
  technician_id text not null,                  -- phone (matches Firestore technicians/{phone})
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz default now()
);
create index idx_reviews_technician on public.reviews (technician_id, created_at desc);
create index idx_reviews_request on public.reviews (request_id);
alter table public.reviews enable row level security;
```

Dart: `lib/core/models/review.dart` ✓.

#### 4.2.3 `promo_codes`

```sql
create table public.promo_codes (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  discount_type text not null check (discount_type in ('percentage','fixed')),
  discount_value numeric not null check (discount_value > 0),
  min_order_amount numeric default 0,
  max_uses int,
  used_count int default 0,
  valid_from timestamptz not null,
  valid_until timestamptz not null,
  is_active boolean default true,
  created_at timestamptz default now()
);
create index idx_promo_codes_code on public.promo_codes (code) where is_active = true;
alter table public.promo_codes enable row level security;
```

#### 4.2.4 `support_tickets`

```sql
create table public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  user_type text not null check (user_type in ('user','technician')),
  subject text not null,
  description text not null,
  status text default 'open' check (status in ('open','in_progress','resolved','closed')),
  priority text default 'medium' check (priority in ('low','medium','high','urgent')),
  admin_reply text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index idx_support_tickets_user on public.support_tickets (user_id, status);
create index idx_support_tickets_status on public.support_tickets (status, priority);
alter table public.support_tickets enable row level security;
```

#### 4.2.5 `search_index` — Full-text for technicians/services/posts

```sql
create table public.search_index (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null check (entity_type in ('technician','service','post')),
  entity_id text not null,                      -- Firestore doc ID or phone
  title text not null,
  description text,
  governorate text,
  specialty text,
  search_vector tsvector generated always as (
    to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(description,'') || ' ' || coalesce(specialty,''))
  ) stored,
  created_at timestamptz default now(),
  unique (entity_type, entity_id)
);
create index idx_search_vector on public.search_index using gin (search_vector);
create index idx_search_governorate on public.search_index (governorate, entity_type);
alter table public.search_index enable row level security;
```

Dart: `lib/core/repositories/search_repository.dart` uses this.

#### 4.2.6 `payment_logs` — Audit trail for every payment attempt

```sql
create table public.payment_logs (
  id uuid primary key default gen_random_uuid(),
  firebase_request_id text,
  firebase_user_id text,                        -- Firebase UID
  technician_id text,                           -- phone
  amount numeric not null,
  currency text default 'EGP',
  payment_method text not null check (payment_method in ('card','cash','wallet','instapay')),
  status text default 'pending' check (status in ('pending','completed','failed','refunded')),
  stripe_payment_id text,
  gateway_response jsonb,
  created_at timestamptz default now()
);
create index idx_payment_logs_user on public.payment_logs (firebase_user_id, created_at desc);
create index idx_payment_logs_tech on public.payment_logs (technician_id, created_at desc);
alter table public.payment_logs enable row level security;
```

Also exists `lib/core/models/instapay_transaction.dart` + `instapay_repository.dart` — add `instapay_transactions` table if Instapay flow is separate, otherwise reuse `payment_logs` with `payment_method='instapay'`.

#### 4.2.7 `appointments` — Booking/consultation (missing table, but `lib/core/models/appointment.dart` + `appointment_repository.dart` + `lib/features/booking/` exist)

```sql
create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  technician_id text,
  service_type text not null,                   -- electrical, plumbing, painting, carpentry
  scheduled_at timestamptz not null,
  status text default 'pending' check (status in ('pending','confirmed','in_progress','completed','cancelled')),
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index idx_appointments_user on public.appointments (user_id, scheduled_at desc);
create index idx_appointments_tech on public.appointments (technician_id, scheduled_at desc);
alter table public.appointments enable row level security;
```

### 4.3 RPC Functions (from `WORK_LOG.md:7`)

```sql
-- Full-text ranked search
create or replace function public.search_entities(
  q text, etype text default null, gov text default null, lim int default 20
) returns setof public.search_index language sql stable as $$
  select * from public.search_index
  where search_vector @@ plainto_tsquery('simple', q)
    and (etype is null or entity_type = etype)
    and (gov is null or governorate = gov)
  order by ts_rank(search_vector, plainto_tsquery('simple', q)) desc
  limit lim;
$$;

-- Atomic promo increment
create or replace function public.increment_used_count(pid uuid)
returns void language plpgsql security definer as $$
begin
  update public.promo_codes set used_count = used_count + 1 where id = pid;
end; $$;
revoke all on function public.increment_used_count(uuid) from public;
grant execute on function public.increment_used_count(uuid) to authenticated, service_role;
```

---

## 5. Firebase Firestore — Source of Truth for Realtime / Document Data

**Keep** `firestore.rules:1` as deployed. Fix 2 gaps:

### 5.1 Firestore Collections — No Migration Needed

| Collection | Doc ID | Owner | Use |
|-----------|--------|-------|-----|
| `users/{uid}` + `family_members` subcollection | Firebase UID | Customer | `lib/features/profile/`, `lib/features/family/` |
| `technicians/{phone}` | Phone | Technician | `lib/features/technician/` |
| `requests/{id}` + `carpentry_requests`/`plumbing_requests`/`painting_requests` | Auto | Customer | `lib/features/booking/`, `lib/features/orders/` |
| `offers/{id}` | Auto | Technician phone | `lib/features/offers/` (`lib/features/offers/models/offer_model.dart:1`) |
| `conversations/{id}/messages/{id}` | Auto | Both | `lib/features/chat/` (`lib/core/models/chat_room.dart:1`, `chat_message.dart:1`) |
| `PaymentCards/{id}` | Auto | Customer UID | `lib/features/payment/` — stores `cardLast4` only |
| `transactions/{id}` | Auto | Technician phone | `lib/features/orders/screens/sale_screen.dart` |
| `posts/{id}` | Auto | Any auth | `lib/features/community/` |
| `verified/{uid}` | UID | Customer | `lib/features/auth/screens/id_verification_screen*.dart` |
| `orders/{id}` | Auto | Legacy | Keep rule `auth != null`, plan deprecation |

### 5.2 Required Firestore Indexes

Add to `firestore.indexes.json:1` (currently `[]`):

```json
{
  "indexes": [
    {
      "collectionGroup": "requests",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "userGovernorate", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "requests",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "offers",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "requestId", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "transactions",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "technicianId", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    }
  ],
  "fieldOverrides": []
}
```

Deploy: `firebase deploy --only firestore:indexes`.

### 5.3 Firestore — Future Consideration

If `requests` volume > 50k docs or need SQL joins with `reviews`/`payment_logs`, consider mirroring `requests` summary to Supabase `service_requests` table via Edge Function trigger — but **not in MVP**.

---

## 6. Supabase Storage Buckets

Recreate in new project (all missing today):

| Bucket | Public | Max | Types | Path | Policy |
|--------|--------|-----|-------|------|--------|
| `profiles` | Yes | 5 MB | jpg, png, webp | `{uid}/{ts}.{ext}` | Public read, auth write |
| `account_verification` | No | 10 MB | jpg, png, pdf | `{uid}/front_{ts}.{ext}` | Auth read/write, no public |
| `request` | No | 10 MB | jpg, png | `{requestId}/{ts}.{ext}` | Auth read/write |
| `task_images` | No | 10 MB | jpg, png | `{requestId}/{ts}.{ext}` | Auth read/write |
| `community_posts` | Yes | 5 MB | jpg, png, gif | `{postId}/{ts}.{ext}` | Public read, auth write/delete |

**Consolidation note:** `profiles` vs `user_profiles` duplicate from `BACKEND_SERVICES.md:151` — keep **one** (`profiles`).

Dart pattern (`lib/core/services/storage_service.dart:1`):

```dart
final ext = file.path.split('.').last;
final path = '$docId/${DateTime.now().millisecondsSinceEpoch}.$ext';
await supabase.storage.from('request').upload(path, file,
  fileOptions: FileOptions(cacheControl: '3600', upsert: false));
final url = supabase.storage.from('request').getPublicUrl(path);
```

All uploads must set `cacheControl: 3600` and `upsert: false`.

---

## 7. Authentication — Mock OTP (Dev) + Real Phone OTP (Prod)

### 7.1 Requirement Conflict

- `PROMPT.MD:1` says **remove real Firebase Phone Auth, mock OTP (any 6 digits passes)** for dev velocity.
- `WORK_LOG.md:8` had implemented real `verifyPhoneNumber` + `PhoneAuthCredential`.

**Resolution:** Feature flag, both co-exist.

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const bool useMockOtp = bool.fromEnvironment('USE_MOCK_OTP', defaultValue: true);
}
```

- **Dev (`--dart-define=USE_MOCK_OTP=true`)**: `otp_screen.dart` accepts any 6 digits, skips `FirebaseAuth.verifyPhoneNumber`, directly writes `SharedPreferences` + Firestore lookup, navigates home. This is the **current required behavior**.
- **Prod (`--dart-define=USE_MOCK_OTP=false`)**: real flow:

```
Phone input (login_screen.dart:1)
  → FirebaseAuth.verifyPhoneNumber(
      phoneNumber: '+20...',
      verificationCompleted: (cred) => signInWithCredential(cred),
      verificationFailed: (e) => Crashlytics.recordError,
      codeSent: (vid, token) => Navigator.push(OtpScreen(verificationId: vid)),
      codeAutoRetrievalTimeout: (vid) => ...)
OtpScreen: 6-digit Pinput
  → PhoneAuthProvider.credential(verificationId, smsCode)
  → FirebaseAuth.signInWithCredential
  → on success: Firestore users lookup, SharedPreferences save (BACKEND_SERVICES.md:279 keys), go Home
  → on failure: show Arabic error, allow resend with forceResendingToken
```

### 7.2 Supabase Auth Mirror (Phase 2)

To enforce Supabase RLS with `auth.uid()`:

- Option A (simple MVP): Keep Supabase tables with `user_id TEXT` (Firebase UID) and policies `auth.role() = 'service_role'` for Edge Functions, `true` for reads where safe. Client writes go via Edge Functions or with `anon` key + app checks.
- Option B (prod): After Firebase sign-in, call Edge Function `exchange-firebase-token` that verifies Firebase ID token via Admin SDK and mints a Supabase JWT with `sub = firebaseUid`. Store in `Supabase.instance.client.auth.setSession`. Then RLS can use `auth.uid()::text = user_id`.

**MVP picks Option A** to unblock; Option B is 1-day follow-up.

---

## 8. Edge Functions & Cron Jobs

Deploy to new project `eczybgjywdppvyyygnrd` via `supabase functions deploy`.

| Function | Method | Auth | Input | Action |
|----------|--------|------|-------|--------|
| `send-notification` | POST | JWT | `{userId, userType, title, body, type, data}` | Insert `notifications` + call FCM HTTP v1 `messages:send` |
| `process-payment` | POST | JWT | `{amount, currency, paymentMethodId, requestId, userId, technicianId, serviceName}` | Validate → call Stripe/Fawry → insert `payment_logs` (status=completed) → update Firestore `requests.isPaid=true` via Admin SDK → credit `technicians.walletBalance` |
| `daily-reset` | POST | none (cron secret) | `{}` | Delete `search_index` >30d, expire `promo_codes` where `valid_until < now()`, close `support_tickets` >14d in `resolved` |
| `generate-invoice` (phase 2) | POST | JWT | `{requestId}` | Fetch Firestore request → pdf-lib → upload to `invoices` bucket → return URL |
| `ai-assistant` (phase 2) | POST | JWT | `{query, userContext}` | Proxy to OpenAI/Gemini, prompt: Basita Egypt, EGP, services list |
| `search-technicians` (phase 2) | POST | JWT | `{governorate, specialty, lat, lng}` | Query `search_index` + Firestore technicians |

**Cron setup (pg_cron):**

```sql
select cron.schedule('daily-reset-midnight', '0 0 * * *',
  $$select net.http_post('https://eczybgjywdppvyyygnrd.supabase.co/functions/v1/daily-reset',
     '{}'::jsonb, headers:='{"Authorization":"Bearer '|| current_setting('app.cron_secret') ||'"}'::jsonb)$$);
```

Or use external cron (GitHub Actions / Supabase Scheduled Functions).

---

## 9. Security — RLS + Firestore Rules + Storage Policies

### 9.1 Supabase RLS — Apply Immediately After Table Creation

```sql
-- notifications: users read own, system inserts
alter table public.notifications enable row level security;
create policy "Users read own notifications" on public.notifications
  for select using (true);  -- MVP: app filters by user_id; tighten to auth.uid()::text = user_id after JWT mirror
create policy "System inserts notifications" on public.notifications
  for insert with check (true); -- only via service_role Edge Functions in prod
create policy "Users update own read status" on public.notifications
  for update using (true) with check (true);

-- reviews: public read, auth insert own
alter table public.reviews enable row level security;
create policy "Anyone can read reviews" on public.reviews for select using (true);
create policy "Auth can insert reviews" on public.reviews for insert with check (auth.role() = 'authenticated');
create policy "Reviewer can update own" on public.reviews for update using (auth.uid()::text = reviewer_id);

-- promo_codes: public read active, service_role manage
alter table public.promo_codes enable row level security;
create policy "Anyone can read active promo" on public.promo_codes
  for select using (is_active = true and valid_until > now());

-- support_tickets: owner scoped
alter table public.support_tickets enable row level security;
create policy "Users read own tickets" on public.support_tickets for select using (true);
create policy "Users create own tickets" on public.support_tickets for insert with check (true);

-- search_index: public read
alter table public.search_index enable row level security;
create policy "Anyone can search" on public.search_index for select using (true);

-- payment_logs: owner read
alter table public.payment_logs enable row level security;
create policy "Users read own payments" on public.payment_logs for select using (true);
create policy "System inserts payments" on public.payment_logs for insert with check (true);

-- appointments
alter table public.appointments enable row level security;
create policy "Users manage own appointments" on public.appointments
  for all using (true) with check (true); -- tighten to auth.uid()::text = user_id after JWT mirror
```

**Tightening plan:** After Supabase JWT mirror, replace `true` with `auth.uid()::text = user_id`.

**Linter already warns:** `SECURITY DEFINER` on `public.rls_auto_enable()` (`supabase_get_advisors:1`) — fix by `revoke execute on function public.rls_auto_enable() from anon, authenticated` or switch to `security invoker`.

### 9.2 Firestore Rules — Already Deployed, Keep

`firestore.rules:1` is good. One fix: `posts` currently `allow delete: if auth != null` — tighten to author check (`resource.data.authorName == request.auth.token.name` or `authorId == uid`) when `authorId` field is added.

### 9.3 Storage RLS

```sql
-- Example for profiles bucket (public read, auth write)
create policy "Public read profiles" on storage.objects for select
  using (bucket_id = 'profiles');
create policy "Auth write profiles" on storage.objects for insert
  with check (bucket_id = 'profiles' and auth.role() = 'authenticated');
```

Apply per bucket per table in §6.

### 9.4 Secrets

- Never store `cardNumber`, `cvv` — only `cardLast4` (`WORK_LOG.md:378`).
- `main.dart:12` anonKey is public — OK, but move to `--dart-define` or `env.dart` not committed.
- Stripe/Fawry keys → `supabase secrets set STRIPE_SECRET_KEY=...` + `vault` schema.
- Invoice PDFs in private bucket, signed URLs only.

---

## 10. Flutter Data Layer — Clean Architecture Mapping

```
lib/
├── core/
│   ├── config/
│   │   ├── main.dart                 # App entry (lib/main.dart:1) — Firebase + Supabase init
│   │   ├── firebase_options.dart
│   │   └── app_config.dart           # USE_MOCK_OTP flag
│   ├── models/                       # All 7 Supabase models (add appointment.dart, chat_room/message already exist)
│   ├── repositories/                 # 7 repos — Supabase + Firestore repos separated
│   │   ├── notification_repository.dart:1  (Supabase)
│   │   ├── review_repository.dart          (Supabase)
│   │   ├── promo_code_repository.dart      (Supabase)
│   │   ├── support_ticket_repository.dart  (Supabase)
│   │   ├── payment_log_repository.dart:1   (Supabase)
│   │   ├── search_repository.dart          (Supabase)
│   │   ├── appointment_repository.dart:1   (Supabase — needs table)
│   │   ├── request_repository.dart         (Firestore — NEW, wrap requests/offers)
│   │   ├── technician_repository.dart      (Firestore — NEW)
│   │   └── chat_repository.dart:1          (Firestore — exists)
│   ├── services/
│   │   ├── supabase_service.dart:1         # client + invokeFunction
│   │   ├── storage_service.dart            # upload/getPublicUrl per bucket
│   │   └── order_accept_service.dart:1     # Firestore transaction: accept offer
│   ├── session/
│   │   ├── user_session.dart:1             # Customer singleton
│   │   └── user_data_session.dart:1        # Technician singleton
│   └── utils/
│       └── phone_utils.dart:1
└── features/
    ├── auth/        → uses Firebase Auth + Firestore users + SharedPreferences
    ├── booking/     → uses Firestore requests + Supabase Storage (request bucket)
    ├── offers/      → Firestore offers
    ├── chat/        → Firestore conversations/messages
    ├── community/   → Firestore posts + Supabase community_posts bucket
    ├── payment/     → Firestore PaymentCards + Supabase payment_logs + Edge Function process-payment
    ├── profile/     → Firestore users + Supabase profiles bucket
    ├── visits/      → Firestore requests filtered + Supabase appointments
    └── ...
```

**Repository pattern (required):**

```dart
// lib/core/repositories/request_repository.dart (NEW)
class RequestRepository {
  final _col = FirebaseFirestore.instance.collection('requests');
  Future<String> createRequest({...}) async {
    try { return (await _col.add({...})).id; }
    catch (e, st) { FirebaseCrashlytics.instance.recordError(e, st); rethrow; }
  }
  Stream<List<ServiceRequest>> watchUserRequests(String uid) =>
    _col.where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots()
      .map((s) => s.docs.map(ServiceRequest.fromDoc).toList());
}
```

All 6 Supabase repos already follow `Supabase.instance.client.from('table')` pattern — add `try/catch → Crashlytics` there too.

---

## 11. Realtime & Offline Strategy

| Data | Realtime | Offline |
|------|----------|---------|
| Firestore `requests`, `offers`, `messages`, `posts` | `snapshots()` streams — already in `BACKEND_SERVICES.md:22` | `Firestore.instance.settings = Settings(persistenceEnabled: true)` (default) |
| Supabase `notifications` | `supabase.from('notifications').stream(primaryKey: ['id']).eq('user_id', uid)` (`notification_repository.dart:27`) | Cache last 50 in `SharedPreferences` or `hive`, refresh on resume |
| Supabase `reviews`, `promo_codes` | Poll on demand, no stream needed | Cache with TTL |

Enable Supabase Realtime publication for `notifications` only — not for all tables.

---

## 12. Observability — Analytics, Crashlytics, Logging

| Tool | Event | Where |
|------|-------|-------|
| Firebase Analytics | `login`, `request_created`, `offer_submitted`, `payment_completed`, `chat_message_sent`, `post_created`, `search_performed` | `lib/core/services/analytics_service.dart` (NEW) |
| Crashlytics | Every `catch` in repositories + `FlutterError.onError` + `PlatformDispatcher.onError` | `lib/main.dart:7` init + each repo |
| Supabase `payment_logs.gateway_response` | Raw Stripe/Fawry response JSONB | Edge Function `process-payment` |
| Supabase `notifications` table | Push delivery log | Edge Function `send-notification` |

Add `firebase_analytics` + `firebase_crashlytics` to `pubspec.yaml:23` (currently only `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` present).

---

## 13. Environments & Config

| Env | Firebase Project | Supabase Project | OTP Mode | Notes |
|-----|-----------------|------------------|----------|-------|
| Dev (local) | `bassyta-851a5` | `eczybgjywdppvyyygnrd` | Mock (`USE_MOCK_OTP=true`) | Matches `PROMPT.MD:1` |
| Prod | `bassyta-851a5` (or new prod) | `eczybgjywdppvyyygnrd` | Real (`USE_MOCK_OTP=false`) | Requires SHA-1/SHA-256 + APNs setup |

Config via `--dart-define`:

```bash
flutter run --dart-define=SUPABASE_URL=https://eczybgjywdppvyyygnrd.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJ... \
            --dart-define=USE_MOCK_OTP=true
```

Do NOT hardcode `anonKey` in `lib/main.dart:14` for prod — read from `String.fromEnvironment`.

---

## 14. Phased Implementation Roadmap

### Phase 1 — Foundation (Day 1–2) — **Do this first**

- [ ] **Branch:** `feat/backend-phase-1-schema`
- [ ] Enable extensions: `pgcrypto`, `uuid-ossp` (done), plus `pg_cron`, `pg_trgm`, `http` (`supabase_execute_sql`)
- [ ] Run migrations: create 7 tables (§4.2) via `supabase_apply_migration` in order: `notifications` → `reviews` → `promo_codes` → `support_tickets` → `search_index` → `payment_logs` → `appointments`
- [ ] Apply RLS policies (§9.1) + fix `rls_auto_enable` SECURITY DEFINER warning
- [ ] Create RPCs: `search_entities`, `increment_used_count` (§4.3)
- [ ] Create 5 Storage buckets (§6) + policies
- [ ] Verify: `supabase_list_tables` shows 7 tables, `supabase_get_advisors` clean
- [ ] Update `BACKEND_SERVICES.md` + `WORK_LOG.md` with new project ref `eczybgjywdppvyyygnrd` (replace stale `wduombkxwcqhipdumxmn`)

### Phase 2 — Edge Functions + Auth Flag (Day 3–5)

- [ ] **Branch:** `feat/backend-phase-2-functions`
- [ ] Deploy `send-notification`, `process-payment`, `daily-reset` (Deno, `supabase/functions/*`)
- [ ] Set secrets: `supabase secrets set STRIPE_SECRET_KEY=... FCM_SERVICE_ACCOUNT=...`
- [ ] Wire `lib/core/services/supabase_service.dart:15` `invokeFunction` to real endpoints
- [ ] Implement `AppConfig.useMockOtp` flag — keep mock OTP for dev, real OTP behind flag
- [ ] Add `firestore.indexes.json:1` composite indexes and deploy

### Phase 3 — Repositories & Feature Wiring (Day 6–9)

- [ ] **Branch:** `feat/backend-phase-3-repos`
- [ ] Create missing Firestore repos: `request_repository.dart`, `technician_repository.dart` (wrap all `FirebaseFirestore.instance` calls)
- [ ] Harden existing Supabase repos with `try/catch → Crashlytics` + `Either<Failure,T>` returns
- [ ] Wire screens: `request_service_screen.dart` → `StorageService` + `RequestRepository`; `final_payment_screen.dart` → `process-payment` Edge Function + `payment_log_repository.dart`; `offers_dashboard_screen.dart` → `ReviewRepository` for technician ratings; `community_screen.dart` → `community_posts` bucket
- [ ] Add `appointments` CRUD to booking flows
- [ ] E2E test: create request → receive offer → accept → chat → pay (cash + card) → review

### Phase 4 — Hardening & Launch Prep (Day 10–12)

- [ ] **Branch:** `feat/backend-phase-4-hardening`
- [ ] Tighten RLS: replace `using (true)` with `auth.uid()::text = user_id` after JWT mirror OR keep Edge Function gateway
- [ ] Firestore Rules: tighten `posts` delete to author, add `authorId` field
- [ ] Add `firebase_analytics` + `firebase_crashlytics` packages, log all events from §12
- [ ] Run `dart analyze`, `flutter test`, manual device test with real phone OTP (flip flag)
- [ ] Write `docs/ARCHITECTURE.md` + update `README.md:1` (currently template)
- [ ] Tag `v1.0-backend-ready`, open PR to `main`

---

## 15. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| **New Supabase project empty** — old project data lost | High | Treat as greenfield; re-apply migrations from `WORK_LOG.md:3` verbatim. Old project `wduombkxwcqhipdumxmn` was dev-only, no prod data |
| **Firestore phone-as-doc-ID (`technicians/{phone}`)** — breaks `auth.uid()` checks | Medium | Keep phone ID but always also store `uid` field; rules check `phoneNumber == phone` already (`firestore.rules:18`) |
| **`firestore.indexes.json` empty** — queries fail at scale | Medium | Add 4 composite indexes in Phase 2 (§5.2) |
| **Mock OTP flag left on in prod** | High | Default `USE_MOCK_OTP=false` in CI/CD; guard with `assert(!kReleaseMode || !useMockOtp)` |
| **Plaintext card fallback** | Low | Already fixed, but keep fallback read `data['cardLast4'] ?? data['cardNumber']?.substring(...)` for legacy docs |
| **`anonKey` hardcoded in `lib/main.dart:14`** | Low | Move to `dart-define` in Phase 1 |
| **`SECURITY DEFINER` linter warning** | Low | Revoke anon execute or switch to invoker in Phase 1 |
| **Supabase Realtime not enabled** | Low | Enable only for `notifications` if needed; Firestore already covers realtime |

---

## 16. What to Build First — 5 Concrete Migrations

Copy-paste ready for `supabase_apply_migration` (in order):

**Migration 1: `init_extensions`**

```sql
create extension if not exists "pg_cron" with schema cron;
create extension if not exists "pg_trgm" with schema extensions;
create extension if not exists "http" with schema extensions;
```

**Migration 2: `create_notifications_reviews`**

```sql
-- notifications + reviews (see §4.2.1–4.2.2)
```

**Migration 3: `create_promo_support_search`**

```sql
-- promo_codes + support_tickets + search_index (§4.2.3–4.2.5)
```

**Migration 4: `create_payment_appointments`**

```sql
-- payment_logs + appointments (§4.2.6–4.2.7)
```

**Migration 5: `enable_rls_and_rpcs`**

```sql
-- all RLS policies (§9.1) + RPCs search_entities, increment_used_count (§4.3)
-- revoke execute on rls_auto_enable
revoke execute on function public.rls_auto_enable() from anon, authenticated;
```

After each: run `supabase_list_tables` + `supabase_execute_sql: select * from pg_policies` + `supabase_get_advisors` to verify.

---

## 17. Appendix — API Surface Summary

### Firestore (client SDK, via repositories)

| Operation | Collection | Method | Screen |
|-----------|-----------|--------|--------|
| Login lookup | `users` / `technicians` | `where('phone', ...).get()` | `login_screen.dart:1` |
| Create request | `requests` | `add()` | `request_service_screen.dart` |
| Watch requests | `requests` | `where(status, governorate).snapshots()` | `home1.dart`, `orders_screen.dart` |
| Submit offer | `offers` | `add()` | `submit_offer_page.dart` |
| Watch offers | `offers` | `where(requestId).snapshots()` | `offers_dashboard_screen.dart` |
| Chat | `conversations/{id}/messages` | `add()` + `snapshots()` | `chat_screen.dart` |
| Posts | `posts` | `add()` / `update(likes)` | `comm1.dart`–`comm6.dart` |
| Save card | `PaymentCards` | `add({cardLast4})` | `payment_cards_screen.dart` |

### Supabase (via `SupabaseService` + repos)

| Operation | Table / Bucket | Method | Repo |
|-----------|---------------|--------|------|
| Notify user | `notifications` | `insert()` / `stream()` | `notification_repository.dart:1` |
| Reviews | `reviews` | `select/insert` | `review_repository.dart` |
| Promo | `promo_codes` | `validatePromoCode()` → `increment_used_count` | `promo_code_repository.dart` |
| Tickets | `support_tickets` | `createTicket()` | `support_ticket_repository.dart` |
| Search | `search_index` | `rpc('search_entities')` | `search_repository.dart` |
| Payments | `payment_logs` | `logPayment()` | `payment_log_repository.dart:1` |
| Uploads | `profiles`, `request`, `task_images`, `community_posts`, `account_verification` | `storage.from(bucket).upload()` | `storage_service.dart` |

### Edge Functions

| Endpoint | Method | Called From |
|----------|--------|-------------|
| `POST /functions/v1/send-notification` | `supabase_service.dart:15 invokeFunction` | After request/offer/payment/chat events |
| `POST /functions/v1/process-payment` | `invokeFunction` | `final_payment_screen.dart` |
| `POST /functions/v1/daily-reset` | cron | `pg_cron` nightly |

---

*Plan generated 2026-08-29 after live audit of `eczybgjywdppvyyygnrd` (empty), `firestore.rules:1`, `lib/` structure (93 files), and `PROMPT.MD:1` mock-OTP requirement. Next action: start Phase 1 — run Migration 1.*
