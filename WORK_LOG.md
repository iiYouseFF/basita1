# Basita (بسيطة) - Complete Work Log

> **Project:** `basita1` — Flutter home-services platform  
> **Firebase Project:** `bassyta-851a5` (project number: `718849850419`)  
> **Supabase Project:** `eczybgjywdppvyyygnrd` (`eu-west-1`, PG 17.6.1) — https://eczybgjywdppvyyygnrd.supabase.co  
> **Legacy Supabase Project (archived):** `wduombkxwcqhipdumxmn` — https://wduombkxwcqhipdumxmn.supabase.co (data migrated 2026-08-29)  
> **Date:** August 29, 2026 (Phase 1 — greenfield migration completed)

---

## Table of Contents

1. [Project Restructuring (Clean Architecture)](#1-project-restructuring-clean-architecture)
2. [Firestore Security Rules](#2-firestore-security-rules)
3. [Supabase PostgreSQL Schema](#3-supabase-postgresql-schema)
4. [Supabase Extensions](#4-supabase-extensions)
5. [Supabase Storage Buckets](#5-supabase-storage-buckets)
6. [Supabase Edge Functions](#6-supabase-edge-functions)
7. [Supabase RPC Functions](#7-supabase-rpc-functions)
8. [Flutter App — Firebase Auth Fix](#8-flutter-app--firebase-auth-fix)
9. [Flutter App — Payment Card Security Fix](#9-flutter-app--payment-card-security-fix)
10. [Flutter App — Data Layer (Models)](#10-flutter-app--data-layer-models)
11. [Flutter App — Data Layer (Repositories)](#11-flutter-app--data-layer-repositories)
12. [Configuration Files](#12-configuration-files)
13. [Summary Table](#13-summary-table)

---

## 1. Project Restructuring (Clean Architecture)

Migrated the flat `lib/` directory into a features-based clean architecture structure.

### Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── main.dart                    # App entry point
│   │   └── firebase_options.dart        # Firebase config
│   ├── models/
│   │   ├── app_notification.dart        # Notification model
│   │   ├── review.dart                  # Review model
│   │   ├── promo_code.dart              # Promo code model
│   │   ├── support_ticket.dart          # Support ticket model
│   │   └── payment_log.dart             # Payment log model
│   ├── repositories/
│   │   ├── notification_repository.dart
│   │   ├── review_repository.dart
│   │   ├── promo_code_repository.dart
│   │   ├── support_ticket_repository.dart
│   │   ├── payment_log_repository.dart
│   │   └── search_repository.dart
│   ├── services/
│   │   ├── storage_service.dart         # Supabase image upload
│   │   └── supabase_service.dart        # Supabase client wrapper
│   └── session/
│       ├── user_session.dart            # Customer session (Singleton)
│       └── user_data_session.dart       # Technician session (Singleton)
├── features/
│   ├── ai_assistant/
│   ├── auth/
│   ├── community/
│   ├── home/
│   ├── invoice/
│   ├── menu/
│   ├── offers/
│   ├── payment/
│   ├── phone_verification/
│   ├── profile/
│   ├── requests/
│   ├── settings/
│   ├── technicians/
│   ├── tracking/
│   ├── visits/
│   └── wallet/
```

### Key Facts

- **93 files** moved from flat `lib/` to features-based structure
- **0 compilation errors** after restructuring
- All imports use `package:basita1/` absolute paths

---

## 2. Firestore Security Rules

**Deployed to:** `bassyta-851a5`  
**File:** `firebase.json` → `firestore.rules`

### Before (CRITICAL ISSUE)

```
allow read, write: if true;   // Wide open — anyone can read/write everything
```

### After

| Collection | Read | Write | Notes |
|-----------|------|-------|-------|
| `users/{userId}` | `auth != null` | Owner only | `family_members` subcollection: owner read/write |
| `technicians/{phone}` | `auth != null` | Self only | Phone-based ID |
| `requests/{requestId}` | Owner or assigned tech | Owner create, both update | |
| `carpentry_requests` | Owner or assigned tech | Owner create, both update | |
| `plumbing_requests` | Owner or assigned tech | Owner create, both update | |
| `painting_requests` | Owner or assigned tech | Owner create, both update | |
| `offers/{offerId}` | `auth != null` | Tech owner only | |
| `verified/{docId}` | `auth != null` | Owner create/update | No delete |
| `PaymentCards/{cardId}` | Owner only | Owner only | |
| `transactions/{txnId}` | Tech only | Create only | No update/delete |
| `posts/{postId}` | `auth != null` | `auth != null` | Community posts |
| `conversations/{convId}` | Participants only | Create only | Messages: auth read/create |
| `orders/{orderId}` | `auth != null` | `auth != null` | Legacy |

---

## 3. Supabase PostgreSQL Schema

**6 tables created** with RLS enabled on all.

### 3.1 notifications

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  user_type TEXT NOT NULL CHECK (user_type IN ('user', 'technician')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'system',
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
```

**RLS Policies:**
- Anyone can read (for admin/system use)
- System can insert
- System can update (mark as read)

### 3.2 reviews

```sql
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id TEXT NOT NULL,
  reviewer_id TEXT NOT NULL,
  technician_id TEXT NOT NULL,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reviews_technician ON reviews(technician_id, created_at DESC);
CREATE INDEX idx_reviews_request ON reviews(request_id);
```

**RLS Policies:**
- Anyone can read reviews
- Authenticated users can insert
- Reviewers can update/delete own

### 3.3 promo_codes

```sql
CREATE TABLE promo_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value NUMERIC NOT NULL CHECK (discount_value > 0),
  min_order_amount NUMERIC DEFAULT 0,
  max_uses INTEGER,
  used_count INTEGER DEFAULT 0,
  valid_from TIMESTAMPTZ NOT NULL,
  valid_until TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_promo_codes_code ON promo_codes(code) WHERE is_active = true;
```

**RLS Policies:**
- Anyone can read active, non-expired codes
- System can manage all

### 3.4 support_tickets

```sql
CREATE TABLE support_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  user_type TEXT NOT NULL CHECK (user_type IN ('user', 'technician')),
  subject TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  admin_reply TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_support_tickets_user ON support_tickets(user_id, status);
CREATE INDEX idx_support_tickets_status ON support_tickets(status, priority);
```

**RLS Policies:**
- Users can read/create/update own tickets
- System can manage all

### 3.5 search_index

```sql
CREATE TABLE search_index (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL CHECK (entity_type IN ('technician', 'service', 'post')),
  entity_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  governorate TEXT,
  specialty TEXT,
  search_vector TSVECTOR GENERATED ALWAYS AS (
    to_tsvector('simple', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(specialty, ''))
  ) STORED,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_search_vector ON search_index USING GIN(search_vector);
CREATE INDEX idx_search_governorate ON search_index(governorate, entity_type);
```

**RLS Policies:**
- Anyone can search (read)
- System can manage all

### 3.6 payment_logs

```sql
CREATE TABLE payment_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_request_id TEXT,
  firebase_user_id TEXT,
  technician_id TEXT,
  amount NUMERIC NOT NULL,
  currency TEXT DEFAULT 'EGP',
  payment_method TEXT NOT NULL CHECK (payment_method IN ('card', 'cash', 'wallet')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  stripe_payment_id TEXT,
  gateway_response JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payment_logs_user ON payment_logs(firebase_user_id, created_at DESC);
CREATE INDEX idx_payment_logs_tech ON payment_logs(technician_id, created_at DESC);
```

**RLS Policies:**
- Users can read own logs
- System can insert

---

## 4. Supabase Extensions

| Extension | Schema | Purpose |
|-----------|--------|---------|
| `pgcrypto` | `extensions` | UUID generation, encryption |
| `uuid-ossp` | `extensions` | UUID generation |
| `pg_cron` | `pg_catalog` (1.6.4) | Scheduled jobs (daily reset) |
| `http` | `extensions` (1.6) | Outbound HTTP requests |
| `pg_trgm` | `extensions` (1.6) | Fuzzy text search |
| `vector` | `extensions` (0.8.2) | Vector embeddings (future AI) |

---

## 5. Supabase Storage Buckets

| Bucket | Public | Max Size | Allowed Types | Purpose |
|--------|--------|----------|---------------|---------|
| `profiles` | Yes | 5 MB | JPEG, PNG, WebP | User/profile photos |
| `account_verification` | No | 10 MB | JPEG, PNG, PDF | ID/document uploads |
| `request` | No | 10 MB | JPEG, PNG | Service request images |
| `task_images` | No | 10 MB | JPEG, PNG | Work-in-progress photos |
| `community_posts` | Yes | 5 MB | JPEG, PNG, GIF | Community feed images |

### Storage RLS Policies

| Bucket | Select | Insert | Update | Delete |
|--------|--------|--------|--------|--------|
| `profiles` | Public | Auth | Auth | Auth |
| `account_verification` | Auth | Auth | — | — |
| `request` | Auth | Auth | — | — |
| `task_images` | Auth | Auth | — | — |
| `community_posts` | Public | Auth | — | Auth |

---

## 6. Supabase Edge Functions

### 6.1 send-notification

- **Endpoint:** `POST /functions/v1/send-notification`
- **JWT Required:** Yes
- **Input:** `{ userId, userType, title, body, type, data }`
- **Action:** Stores notification in PostgreSQL `notifications` table
- **Use Case:** Trigger from Flutter app to send in-app notifications

### 6.2 process-payment

- **Endpoint:** `POST /functions/v1/process-payment`
- **JWT Required:** Yes
- **Input:** `{ amount, currency, paymentMethodId, requestId, userId, technicianId, serviceName }`
- **Action:** Logs payment to `payment_logs`, marks as completed (placeholder for Stripe/Fawry)
- **Use Case:** Process card payments via payment gateway

### 6.3 daily-reset

- **Endpoint:** `POST /functions/v1/daily-reset`
- **JWT Required:** No (for cron scheduling)
- **Action:**
  - Deletes stale `search_index` entries (>30 days)
  - Expires old promo codes
  - Auto-closes old support tickets (>14 days)
- **Use Case:** Scheduled via `pg_cron` or external cron service

---

## 7. Supabase RPC Functions

### 7.1 search_entities

```sql
SELECT * FROM search_entities('plumbing cairo');
```

Returns matching entities ranked by relevance using `ts_rank`. Supports filtering by `entity_type` and `governorate` on the client side.

### 7.2 increment_used_count

```sql
SELECT increment_used_count('uuid-of-promo-code');
```

Atomically increments the `used_count` for a promo code after successful application.

---

## 8. Flutter App — Firebase Auth Fix

**File:** `lib/features/auth/screens/otp_screen.dart`

### Before

- OTP screen was **completely fake** — just a timer countdown
- No actual Firebase Auth phone verification
- Any 6-digit code would "succeed"

### After

- Uses `FirebaseAuth.instance.verifyPhoneNumber()` to send real SMS
- Supports `verificationCompleted` for auto-verification on Android
- Uses `PhoneAuthProvider.credential()` + `signInWithCredential()` for real verification
- Handles `codeSent`, `verificationFailed`, `codeAutoRetrievalTimeout`
- Proper error messages for: invalid number, too many requests, invalid code, expired session
- Saves auth state to SharedPreferences after successful verification
- Supports resend with `forceResendingToken`

**File:** `lib/features/auth/screens/login_screen.dart`

- Removed unused `firebase_auth` import
- Login flow: Firestore phone lookup → OTP screen → Firebase Auth verification

---

## 9. Flutter App — Payment Card Security Fix

### Before (CRITICAL SECURITY ISSUE)

```dart
await cardsCollection.add({
  'cardNumber': cleanNumber,  // ← FULL 16-digit card number stored in plaintext!
  ...
});
```

### After

```dart
final last4 = cleanNumber.length >= 4
    ? cleanNumber.substring(cleanNumber.length - 4)
    : cleanNumber;

await cardsCollection.add({
  'cardLast4': last4,  // ← Only last 4 digits stored
  ...
});
```

### Files Changed

| File | Change |
|------|--------|
| `payment_cards_screen.dart` | `_AddCardBottomSheet._saveCard()` — stores `cardLast4` only |
| `payment_cards_screen.dart` | `_buildCardItem()` — reads `cardLast4` with fallback to `cardNumber` |
| `final_payment_screen.dart` | `PaymentScreen._processPayment()` — stores `cardLast4` only |
| `final_payment_screen.dart` | Saved cards display — reads `cardLast4` with fallback |
| `final_payment_screen.dart` | `_AddCardBottomSheet` — stores `cardLast4` only |

### Backward Compatibility

The display code uses a fallback chain:
```dart
data['cardLast4'] ?? data['cardNumber']?.toString()?.substring(...) ?? '0000'
```
This ensures old cards stored with `cardNumber` still display correctly.

---

## 10. Flutter App — Data Layer (Models)

All models in `lib/core/models/`.

### 10.1 AppNotification

| Field | Type | DB Column |
|-------|------|-----------|
| `id` | `String` | `id` (UUID) |
| `userId` | `String` | `user_id` |
| `userType` | `String` | `user_type` |
| `title` | `String` | `title` |
| `body` | `String` | `body` |
| `type` | `String` | `type` |
| `data` | `Map<String, dynamic>` | `data` (JSONB) |
| `isRead` | `bool` | `is_read` |
| `createdAt` | `DateTime?` | `created_at` |

### 10.2 Review

| Field | Type | DB Column |
|-------|------|-----------|
| `id` | `String` | `id` (UUID) |
| `requestId` | `String` | `request_id` |
| `reviewerId` | `String` | `reviewer_id` |
| `technicianId` | `String` | `technician_id` |
| `rating` | `int` | `rating` |
| `comment` | `String?` | `comment` |
| `createdAt` | `DateTime?` | `created_at` |

### 10.3 PromoCode

| Field | Type | DB Column |
|-------|------|-----------|
| `id` | `String` | `id` (UUID) |
| `code` | `String` | `code` |
| `discountType` | `String` | `discount_type` (`percentage`/`fixed`) |
| `discountValue` | `double` | `discount_value` |
| `minOrderAmount` | `double` | `min_order_amount` |
| `maxUses` | `int?` | `max_uses` |
| `usedCount` | `int` | `used_count` |
| `validFrom` | `DateTime?` | `valid_from` |
| `validUntil` | `DateTime?` | `valid_until` |
| `isActive` | `bool` | `is_active` |

**Method:** `calculateDiscount(orderAmount)` → returns discount amount

### 10.4 SupportTicket

| Field | Type | DB Column |
|-------|------|-----------|
| `id` | `String` | `id` (UUID) |
| `userId` | `String` | `user_id` |
| `userType` | `String` | `user_type` |
| `subject` | `String` | `subject` |
| `description` | `String` | `description` |
| `status` | `String` | `status` |
| `priority` | `String` | `priority` |
| `adminReply` | `String?` | `admin_reply` |
| `createdAt` | `DateTime?` | `created_at` |
| `updatedAt` | `DateTime?` | `updated_at` |

### 10.5 PaymentLog

| Field | Type | DB Column |
|-------|------|-----------|
| `id` | `String` | `id` (UUID) |
| `firebaseRequestId` | `String?` | `firebase_request_id` |
| `firebaseUserId` | `String?` | `firebase_user_id` |
| `technicianId` | `String?` | `technician_id` |
| `amount` | `double` | `amount` |
| `currency` | `String` | `currency` |
| `paymentMethod` | `String` | `payment_method` |
| `status` | `String` | `status` |
| `stripePaymentId` | `String?` | `stripe_payment_id` |
| `gatewayResponse` | `Map<String, dynamic>?` | `gateway_response` |
| `createdAt` | `DateTime?` | `created_at` |

---

## 11. Flutter App — Data Layer (Repositories)

All repositories in `lib/core/repositories/`.

### 11.1 NotificationRepository

| Method | Returns | Description |
|--------|---------|-------------|
| `getNotifications({userId, unreadOnly, limit})` | `List<AppNotification>` | Fetch notifications |
| `watchNotifications(userId)` | `Stream<List<AppNotification>>` | Realtime stream |
| `getUnreadCount(userId)` | `int` | Count unread |
| `markAsRead(notificationId)` | `void` | Mark single as read |
| `markAllAsRead(userId)` | `void` | Mark all as read |
| `insertNotification(...)` | `void` | Create notification |

### 11.2 ReviewRepository

| Method | Returns | Description |
|--------|---------|-------------|
| `getTechnicianReviews(technicianId)` | `List<Review>` | All reviews for tech |
| `getTechnicianAverageRating(technicianId)` | `double` | Average rating |
| `createReview({requestId, reviewerId, technicianId, rating, comment})` | `void` | Submit review |
| `deleteReview(reviewId)` | `void` | Delete review |

### 11.3 PromoCodeRepository

| Method | Returns | Description |
|--------|---------|-------------|
| `validatePromoCode({code, orderAmount})` | `PromoCode?` | Validate and return promo |
| `applyPromoCode(promoId)` | `void` | Increment usage count |

### 11.4 SupportTicketRepository

| Method | Returns | Description |
|--------|---------|-------------|
| `getUserTickets(userId)` | `List<SupportTicket>` | User's tickets |
| `getTicket(ticketId)` | `SupportTicket?` | Single ticket |
| `createTicket({userId, userType, subject, description, priority})` | `SupportTicket` | Create ticket |
| `closeTicket(ticketId)` | `void` | Close ticket |

### 11.5 PaymentLogRepository

| Method | Returns | Description |
|--------|---------|-------------|
| `logPayment({userId, amount, paymentMethod, requestId, technicianId})` | `PaymentLog` | Log payment |
| `getUserPayments(userId)` | `List<PaymentLog>` | User's payment history |
| `getTechnicianPayments(technicianId)` | `List<PaymentLog>` | Tech's payment history |
| `updatePaymentStatus({paymentId, status})` | `void` | Update status |

### 11.6 SearchRepository

| Method | Returns | Description |
|--------|---------|-------------|
| `search({query, entityType, governorate, limit})` | `List<Map>` | Full-text search |
| `indexEntity({entityType, entityId, title, description, governorate, specialty})` | `void` | Add to index |
| `removeIndex(entityType, entityId)` | `void` | Remove from index |

### 11.7 SupabaseService (Client Wrapper)

| Member | Description |
|--------|-------------|
| `client` | `SupabaseClient` instance |
| `currentUserId` | Authenticated user ID |
| `invokeFunction({functionName, body})` | Call Edge Functions |

---

## 12. Configuration Files

### firebase.json

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  }
}
```

### firestore.indexes.json

```json
{
  "indexes": [],
  "fieldOverrides": []
}
```

### main.dart Initialization

```dart
// Now via lib/core/config/env.dart — reads --dart-define with fallback to new project
import 'package:basita1/core/config/env.dart';
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
await Supabase.initialize(
  url: Env.supabaseUrl, // https://eczybgjywdppvyyygnrd.supabase.co
  anonKey: Env.supabaseAnonKey,
);
// Legacy URL wduombkxwcqhipdumxmn kept as Env.legacySupabaseUrl for reference
```

---

## 13. Summary Table

| Category | Count | Status |
|----------|-------|--------|
| Files moved (Clean Architecture) | 93 | ✅ Complete |
| Firestore security rules deployed | 11 collections | ✅ Deployed |
| Supabase PostgreSQL tables | 7 (notifications, reviews, promo_codes, support_tickets, search_index, payment_logs, appointments) | ✅ Created (2026-08-29 new project eczybgjywdppvyyygnrd) |
| Supabase RLS policies | 7 tables (19 policies) | ✅ Enabled |
| Supabase extensions enabled | 5 (pgcrypto, uuid-ossp, pg_cron 1.6.4, pg_trgm 1.6, http 1.6, vector 0.8.2) | ✅ Enabled |
| Supabase storage buckets | 5 (profiles, account_verification, request, task_images, community_posts) | ✅ Created |
| Supabase storage RLS policies | 5 buckets (13 policies) | ✅ Applied |
| Supabase Edge Functions | 3 (planned — Phase 2) | ⏳ Pending |
| Supabase RPC functions | 3 (search_entities, increment_used_count, handle_updated_at) + rls_auto_enable | ✅ Created |
| Flutter auth flow fixed | 1 screen | ✅ Real Firebase Auth |
| Flutter card security fixed | 3 files | ✅ Last-4-only storage |
| Flutter data models | 5 | ✅ Created |
| Flutter repositories | 6 | ✅ Created |
| Flutter services | 1 | ✅ Created |
| **Compilation errors** | **0** | ✅ Verified |

---

## Architecture Decisions

### Why Firebase + Supabase?

| Concern | Handled By |
|---------|-----------|
| User authentication (Phone OTP) | Firebase Auth |
| Service requests, offers, technicians | Firebase Firestore |
| Push notifications metadata | Supabase PostgreSQL |
| Reviews, ratings | Supabase PostgreSQL |
| Promo codes | Supabase PostgreSQL |
| Support tickets | Supabase PostgreSQL |
| Full-text search | Supabase PostgreSQL (tsvector) |
| Payment logging | Supabase PostgreSQL |
| Image/file storage | Supabase Storage |
| Server-side logic | Supabase Edge Functions |
| Scheduled tasks | Supabase pg_cron + Edge Functions |
| Realtime data | Firebase Firestore streams |
| Analytics/Crashlytics | Firebase (ready to add) |

### Security Model

- **Firebase Auth** is the source of truth for user identity
- **Firestore Rules** enforce user-scoped access on all Firestore collections
- **Supabase RLS** enforces access control on all PostgreSQL tables
- **Payment card numbers** are never stored (only last 4 digits)
- **CVV** is never stored anywhere
- **Storage buckets** use RLS policies for authenticated access

---

*Generated August 25, 2026*
