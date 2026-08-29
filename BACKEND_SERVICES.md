# Basita (بسيطة) - Backend Services Specification

> Complete backend architecture using **Firebase** (Auth, Firestore, Analytics) + **Supabase** (PostgreSQL, Storage, Edge Functions).

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Firebase Services](#2-firebase-services)
3. [Supabase Services](#3-supabase-services)
4. [Feature: Authentication & Onboarding](#4-feature-authentication--onboarding)
5. [Feature: User Profile](#5-feature-user-profile)
6. [Feature: Service Requests](#6-feature-service-requests)
7. [Feature: Offers & Negotiation](#7-feature-offers--negotiation)
8. [Feature: Chat & Messaging](#8-feature-chat--messaging)
9. [Feature: Payments & Wallet](#9-feature-payments--wallet)
10. [Feature: Community](#10-feature-community)
11. [Feature: Visits & History](#11-feature-visits--history)
12. [Feature: AI Assistant](#12-feature-ai-assistant)
13. [Feature: Family Dashboard](#13-feature-family-dashboard)
14. [Feature: Account Verification](#14-feature-account-verification)
15. [Supabase Storage Buckets](#15-supabase-storage-buckets)
16. [Firestore Collections Schema](#16-firestore-collections-schema)
17. [Supabase PostgreSQL Tables](#17-supabase-postgresql-tables)
18. [Row Level Security (RLS) Policies](#18-row-level-security-rls-policies)
19. [Edge Functions](#19-edge-functions)
20. [Firebase Security Rules](#20-firebase-security-rules)
21. [API Endpoints Summary](#21-api-endpoints-summary)
22. [Real-time Subscriptions](#22-real-time-subscriptions)
23. [Scheduled Functions / Cron Jobs](#23-scheduled-functions--cron-jobs)
24. [Third-Party Integrations](#24-third-party-integrations)

---

## 1. Architecture Overview

```
┌──────────────────────────────────────────────────────┐
│                   FLUTTER APP                        │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌─────────────┐    ┌─────────────┐                 │
│  │   Firebase   │    │   Supabase  │                 │
│  ├─────────────┤    ├─────────────┤                 │
│  │ Firebase Auth│    │ PostgreSQL  │                 │
│  │ Firestore   │    │ Storage     │                 │
│  │ Analytics   │    │ Edge Funcs  │                 │
│  │ Crashlytics │    │ Auth (SSO)  │                 │
│  └─────────────┘    └─────────────┘                 │
│                                                      │
│  RESPONSIBILITY SPLIT:                               │
│  Firebase = Auth, Realtime DB, Analytics             │
│  Supabase = File Storage, SQL queries, Edge Logic    │
└──────────────────────────────────────────────────────┘
```

### Current Backend Usage (Audit Summary)

| Service | Currently Used | Purpose |
|---------|---------------|---------|
| Firebase Auth | Read-only (currentUser) | UID lookup, no sign-in flow |
| Firestore | Full CRUD | All app data (users, requests, offers, posts, payments) |
| Firebase Storage | **Not used** | - |
| Supabase Storage | 5 buckets | All image/file uploads |
| Supabase Database | **Not used** | - |
| SharedPreferences | 18 keys | Local session caching |

### Proposed Backend Responsibility Split

| Responsibility | Firebase | Supabase |
|---------------|----------|----------|
| User Authentication | **Primary** (Phone OTP) | Secondary (SSO token exchange) |
| User Profiles | **Firestore** (users, technicians) | - |
| Service Requests | **Firestore** (requests) | - |
| Offers & Negotiation | **Firestore** (offers) | - |
| Chat Messages | **Firestore** (conversations) | - |
| Payments & Wallet | **Firestore** (PaymentCards, transactions) | **Edge Functions** (payment processing) |
| Community Posts | **Firestore** (posts) | - |
| File/Image Storage | - | **Primary** (all buckets) |
| Analytics & Crash | **Primary** | - |
| Push Notifications | **FCM** | - |
| Scheduled Tasks | **Cloud Functions** | **Edge Functions** (cron) |
| Payment Gateway | - | **Edge Functions** (Stripe/Fawry) |
| SMS Verification | **Firebase Auth** | - |

---

## 2. Firebase Services

### 2.1 Firebase Authentication

| Method | Use Case | Status |
|--------|----------|--------|
| `signInWithPhoneNumber` | User/Technician login | **TODO - Currently bypassed** |
| `verifyPhoneNumber` | OTP sending | **TODO** |
| `confirmSignIn` | OTP verification | **TODO** |
| `signOut` | Logout | Implemented |
| `currentUser` | Session check | Implemented |
| Anonymous Auth | Guest browsing | Optional |

### 2.2 Cloud Firestore

| Collection | Document ID | CRUD | Realtime |
|-----------|-------------|------|----------|
| `users` | Firebase Auth UID | R/U | Yes |
| `technicians` | Phone number | C/R/U | Yes |
| `requests` | Auto-generated | C/R/U/D | Yes |
| `offers` | Auto-generated | C/R/U/D | Yes |
| `conversations` | Auto-generated | C/R/U | Yes |
| `messages` | Auto-generated | C/R | Yes |
| `verified` | User UID | C/R/U | Yes |
| `PaymentCards` | Auto-generated | C/R/U/D | Yes |
| `transactions` | Auto-generated | C/R | Yes |
| `posts` | Auto-generated | C/R/U/D | Yes |
| `invoices` | Auto-generated | C/R | Yes |
| `family_members` | Auto-generated | C/R/D | Yes |

### 2.3 Firebase Cloud Messaging (FCM)

| Topic/Token | Purpose |
|------------|---------|
| `user_{uid}` | Push to specific user |
| `technician_{phone}` | Push to specific technician |
| `requests_{governorate}` | Push to technicians in area |

### 2.4 Firebase Analytics Events

| Event | Parameters | Purpose |
|-------|-----------|---------|
| `login` | method, user_type | Track login method |
| `request_created` | service_type, governorate, budget | Track demand |
| `offer_submitted` | price, technician_id | Track supply |
| `payment_completed` | amount, method, request_id | Track revenue |
| `chat_message_sent` | conversation_id | Track engagement |
| `post_created` | category, has_image | Track community |
| `search_performed` | query, results_count | Track discovery |

### 2.5 Firebase Crashlytics

- Log non-fatal errors on all Firestore operations
- Track user flows that lead to crashes
- Custom keys: `user_type`, `governorate`, `app_version`

---

## 3. Supabase Services

### 3.1 Supabase Storage Buckets

| Bucket | Access | Purpose | Files |
|--------|--------|---------|-------|
| `profiles` | Public read, Auth write | Profile images | Avatar photos |
| `user_profiles` | Public read, Auth write | Profile images (legacy) | Avatar photos |
| `account_verification` | Private | National ID images | Front/back ID |
| `request` | Auth read, Auth write | Service request images | Before photos |
| `task_images` | Auth read, Auth write | Task completion images | After photos |
| `community_posts` | Public read, Auth write | Community post images | Post photos |

### 3.2 Supabase PostgreSQL (Proposed)

Tables for data that benefits from SQL queries:

- `notifications` - Push notification log
- `analytics_events` - Structured event data
- `reviews` - Technician reviews/ratings
- `search_index` - Full-text search cache
- `promo_codes` - Discount code management
- `support_tickets` - Customer support

### 3.3 Supabase Edge Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `process-payment` | HTTP | Stripe/Fawry payment processing |
| `send-otp` | HTTP | Twilio/Clinchbot SMS OTP |
| `send-notification` | HTTP | FCM push notification dispatch |
| `generate-invoice` | HTTP | PDF invoice generation |
| `cron-daily-reset` | Schedule | Reset daily earnings counters |
| `cron-expire-offers` | Schedule | Auto-expire old pending offers |
| `search-technicians` | HTTP | Proximity-based tech search |

---

## 4. Feature: Authentication & Onboarding

### 4.1 User Login Flow

```
Phone Number Input
    │
    ▼
Firebase Auth: verifyPhoneNumber()
    │
    ▼
OTP Screen: confirmSignIn(credential)
    │
    ├── Success → Check Firestore 'users' collection
    │       │
    │       ├── Exists → Load user data → SharedPreferences → Home
    │       │
    │       └── New → Navigate to Registration
    │
    └── Failure → Show error, retry
```

### 4.2 Technician Onboarding Flow

```
Phone + Personal Info + Specialty + Location
    │
    ▼
Firebase Auth: verifyPhoneNumber()
    │
    ▼
OTP Verification
    │
    ▼
Upload Profile Image → Supabase 'profiles' bucket
    │
    ▼
Save to Firestore 'technicians' collection
    │
    ▼
Save to SharedPreferences → Technician Dashboard
```

### 4.3 Firestore Operations

```dart
// ── Collection: users ──────────────────────────────
// Read (Login)
FirebaseFirestore.instance
    .collection('users')
    .where('phone', isEqualTo: phoneNumber)
    .get()

// Write (Registration)
FirebaseFirestore.instance
    .collection('users')
    .doc(firebaseAuth.currentUser!.uid)
    .set({
      'name': '',
      'phone': '',
      'email': '',
      'governorate': '',
      'city': '',
      'region': '',
      'placeType': '',
      'profileImagePath': '',
      'createdAt': FieldValue.serverTimestamp(),
    })

// ── Collection: technicians ────────────────────────
// Write (Onboarding)
FirebaseFirestore.instance
    .collection('technicians')
    .doc(phone)  // Phone as document ID
    .set({
      'fullName': '',
      'phone': '',
      'experience': '',
      'specialty': '',
      'governorate': '',
      'area': '',
      'profileImagePath': '',
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'technician',
      'isVerified': false,
      'completedOrdersCount': 0,
      'totalEarnings': 0.0,
      'todayEarnings': 0.0,
      'todayOrdersCount': 0,
      'walletBalance': 0.0,
      'rating': 0.0,
    }, SetOptions(merge: true))
```

### 4.4 SharedPreferences Keys

| Key | Type | Written By | Read By |
|-----|------|-----------|---------|
| `isLoggedIn` | bool | login_screen, login_screen1, technician_onboarding | splash_screen |
| `userType` | String | login_screen, login_screen1, technician_onboarding | splash_screen |
| `userName` | String | login_screen | splash_screen, home_screen |
| `userPhone` | String | login_screen | splash_screen, request_service |
| `userEmail` | String | login_screen | splash_screen |
| `userGov` | String | login_screen | splash_screen |
| `userCity` | String | login_screen | splash_screen |
| `userRegion` | String | login_screen | splash_screen |
| `userPlaceType` | String | login_screen | splash_screen |
| `userImage` | String | login_screen, personal_data | splash_screen |
| `userId` | String | personal_data | final_payment, bills, invoices |
| `techName` | String | login_screen1, technician_onboarding | splash_screen |
| `techPhone` | String | login_screen1, technician_onboarding | splash_screen |
| `techExp` | String | login_screen1, technician_onboarding | splash_screen |
| `techSpec` | String | login_screen1, technician_onboarding | splash_screen |
| `techGov` | String | login_screen1, technician_onboarding | splash_screen |
| `techArea` | String | login_screen1, technician_onboarding | splash_screen |
| `techImage` | String | login_screen1, technician_onboarding | splash_screen |

---

## 5. Feature: User Profile

### 5.1 Operations

| Operation | Collection | Method |
|-----------|-----------|--------|
| Read profile | `users/{uid}` | `.get()` / `.snapshots()` |
| Update profile | `users/{uid}` | `.update()` |
| Upload avatar | Supabase `user_profiles` bucket | `.upload()` → `.getPublicUrl()` |
| Save avatar URL | `users/{uid}` | `.update({'profileImagePath': url})` |

### 5.2 Profile Data Model

```dart
class UserProfile {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String governorate;
  final String city;
  final String region;
  final String placeType;
  final String? profileImagePath;
  final DateTime? createdAt;
}
```

### 5.3 Firestore Operations

```dart
// Read
FirebaseFirestore.instance.collection('users').doc(uid).get()

// Update
FirebaseFirestore.instance.collection('users').doc(uid).update({
  'profileImagePath': supabaseUrl,
  'email': newEmail,
  'city': newCity,
})
```

---

## 6. Feature: Service Requests

### 6.1 Request Lifecycle

```
PENDING → OFFER_SUBMITTED → ACCEPTED → IN_PROGRESS → COMPLETED → PAID
   │                            │                         │
   └── CANCELLED                └── REJECTED              └── DISPUTED
```

### 6.2 Status Values

| Status | Description | Set By |
|--------|-------------|--------|
| `pending` | Customer created request | System |
| `offer_submitted` | Technician submitted offer | Technician |
| `accepted` | Customer accepted an offer | Customer |
| `in_progress` | Technician started work | Technician |
| `completed` | Work finished, awaiting payment | Technician |
| `task_finished_pending_invoice` | Task done, invoice pending | System |
| `awaiting_payment` | Invoice sent to customer | System |
| `ready_to_pay` | Customer can pay | System |
| `pending_cash` | Cash payment pending | System |
| `paid` | Payment completed | System |
| `cancelled` | Request cancelled | Either party |

### 6.3 Request Data Model

```dart
class ServiceRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userRegion;
  final String userGovernorate;
  final String title;
  final String description;
  final String budget;
  final String? scheduledDate;
  final String status;
  final List<String> images;         // Before-task images
  final List<String> taskImages;     // After-task images
  final String? technicianId;
  final String? technicianName;
  final String? acceptedPrice;
  final DateTime? acceptedAt;
  final DateTime? createdAt;
  final String? paymentMethod;
  final double? finalPrice;
  final bool isPaid;
  final String? technicianNotes;
  final String? draftNotes;
}
```

### 6.4 Specialized Request Collections

| Collection | Service Type | Fields |
|-----------|-------------|--------|
| `carpentry_requests` | Carpentry | Same as requests + specialty fields |
| `plumbing_requests` | Plumbing | Same as requests + specialty fields |
| `painting_requests` | Painting | Same as requests + specialty fields |

### 6.5 Firestore Operations

```dart
// Create request
FirebaseFirestore.instance.collection('requests').add({
  'userId': currentUser.uid,
  'userName': UserSession.instance.name,
  'userPhone': UserSession.instance.phone,
  'userRegion': UserSession.instance.region,
  'userGovernorate': UserSession.instance.governorate,
  'title': serviceTitle,
  'description': description,
  'budget': budget,
  'scheduledDate': selectedDate,
  'status': 'pending',
  'images': uploadedImageUrls,
  'createdAt': FieldValue.serverTimestamp(),
})

// Technician reads available requests
FirebaseFirestore.instance
    .collection('requests')
    .where('status', isEqualTo: 'pending')
    .where('userGovernorate', isEqualTo: techGovernorate)
    .orderBy('createdAt', descending: true)
    .snapshots()

// Update request status
FirebaseFirestore.instance
    .collection('requests')
    .doc(requestId)
    .update({'status': newStatus})
```

### 6.6 Supabase Image Uploads

```dart
// Upload request images
await supabase.storage.from('request').upload(
  '$requestId/$fileName',
  imageFile,
  fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
);

final publicUrl = supabase.storage.from('request').getPublicUrl('$requestId/$fileName');
```

---

## 7. Feature: Offers & Negotiation

### 7.1 Offer Lifecycle

```
Technician submits offer
    │
    ▼
PENDING → Customer views
    │
    ├── ACCEPTED → Request status → accepted
    │
    └── REJECTED → Request status → pending (other techs can offer)
```

### 7.2 Offer Data Model

```dart
class Offer {
  final String id;
  final String requestId;
  final String technicianId;
  final String technicianName;
  final double price;
  final String duration;
  final String arrivalTime;
  final String warranty;
  final String? message;
  final bool provideMaterials;
  final bool priceIncludesMaterials;
  final double rating;
  final int reviewsCount;
  final int experienceYears;
  final bool isVerified;
  final String? imagePath;
  final String status; // "pending" | "accepted" | "rejected"
  final DateTime? createdAt;
}
```

### 7.3 Firestore Operations

```dart
// Technician submits offer
FirebaseFirestore.instance.collection('offers').add({
  'requestId': requestId,
  'technicianId': currentPhone,
  'technicianName': UserDataSession.fullName,
  'price': price,
  'duration': duration,
  'arrivalTime': arrivalTime,
  'warranty': warranty,
  'message': message,
  'provideMaterials': provideMaterials,
  'priceIncludesMaterials': priceIncludesMaterials,
  'rating': 0.0,
  'reviewsCount': 0,
  'experienceYears': experienceYears,
  'isVerified': false,
  'status': 'pending',
  'createdAt': FieldValue.serverTimestamp(),
})

// Customer views offers for a request
FirebaseFirestore.instance
    .collection('offers')
    .where('requestId', isEqualTo: requestId)
    .snapshots()

// Customer accepts offer
FirebaseFirestore.instance.collection('offers').doc(offerId).update({
  'status': 'accepted',
})
FirebaseFirestore.instance.collection('requests').doc(requestId).update({
  'status': 'accepted',
  'technicianId': offer.technicianId,
  'technicianName': offer.technicianName,
  'acceptedPrice': offer.price,
  'acceptedAt': FieldValue.serverTimestamp(),
})
```

---

## 8. Feature: Chat & Messaging

### 8.1 Chat Data Model

```dart
// ── Conversation ──
class Conversation {
  final String id;
  final String requestId;
  final String customerId;
  final String customerName;
  final String technicianId;
  final String technicianName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCustomer;
  final int unreadTechnician;
  final DateTime createdAt;
}

// ── Message ──
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;
}
```

### 8.2 Firestore Structure

```
conversations/{conversationId}
    ├── customerId: string
    ├── customerName: string
    ├── technicianId: string
    ├── technicianName: string
    ├── requestId: string
    ├── lastMessage: string
    ├── lastMessageAt: timestamp
    ├── unreadCustomer: number
    └── unreadTechnician: number

conversations/{conversationId}/messages/{messageId}
    ├── senderId: string
    ├── senderName: string
    ├── text: string
    ├── imageUrl: string (optional)
    ├── timestamp: timestamp
    └── isRead: boolean
```

### 8.3 Firestore Operations

```dart
// Create/get conversation
FirebaseFirestore.instance.collection('conversations').add({
  'requestId': requestId,
  'customerId': userId,
  'customerName': userName,
  'technicianId': techId,
  'technicianName': techName,
  'lastMessage': '',
  'lastMessageAt': FieldValue.serverTimestamp(),
  'unreadCustomer': 0,
  'unreadTechnician': 0,
  'createdAt': FieldValue.serverTimestamp(),
})

// Send message
FirebaseFirestore.instance
    .collection('conversations')
    .doc(conversationId)
    .collection('messages')
    .add({
      'senderId': currentUserId,
      'senderName': currentUserName,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    })

// Update conversation last message
FirebaseFirestore.instance
    .collection('conversations')
    .doc(conversationId)
    .update({
      'lastMessage': messageText,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unread${isCustomer ? "Technician" : "Customer"}': FieldValue.increment(1),
    })

// Listen to messages
FirebaseFirestore.instance
    .collection('conversations')
    .doc(conversationId)
    .collection('messages')
    .orderBy('timestamp', descending: true)
    .snapshots()
```

---

## 9. Feature: Payments & Wallet

### 9.1 Payment Flow

```
Task Completed
    │
    ▼
Invoice Generated (servicePrice + extraFees - discount = total)
    │
    ▼
Customer Selects Payment Method
    │
    ├── Credit Card → Supabase Edge Function → Stripe/Fawry
    │       │
    │       ├── Success → Update request status → paid
    │       │            → Credit technician wallet
    │       │            → Create transaction record
    │       │
    │       └── Failure → Show error, retry
    │
    └── Cash → Status → pending_cash → Technician collects
                         → Manual confirmation later
```

### 9.2 Payment Data Models

```dart
// ── Payment Card ──
class PaymentCard {
  final String id;
  final String userId;
  final String cardNumber;      // ⚠️ SECURITY RISK: Currently stored in plaintext
  final String cardHolder;
  final String expiryDate;
  final String cardType;        // "visa" | "mastercard"
  final bool isDefault;
  final DateTime? createdAt;
}

// ── Transaction ──
class Transaction {
  final String id;
  final String technicianId;
  final String requestId;
  final String serviceName;
  final double amount;
  final bool isPositive;        // true = income, false = expense
  final String type;            // "income" | "cash_collection"
  final String paymentMethod;
  final DateTime? createdAt;
}

// ── Invoice ──
class Invoice {
  final String id;
  final String invoiceNumber;
  final String serviceName;
  final String technicianName;
  final DateTime date;
  final double servicePrice;
  final double extraFees;
  final double discount;
  final double totalAmount;
  final String status;
  final String paymentMethod;
}
```

### 9.3 Firestore Operations

```dart
// ── Collection: PaymentCards ──
// Save card
FirebaseFirestore.instance.collection('PaymentCards').add({
  'userId': userId,
  'userName': userName,
  'userPhone': userPhone,
  'cardNumber': cardNumber,      // ⚠️ Should be tokenized
  'cardHolder': cardHolder,
  'expiryDate': expiryDate,
  'cardType': cardType,
  'isDefault': isDefault,
  'createdAt': FieldValue.serverTimestamp(),
})

// Read user's cards
FirebaseFirestore.instance
    .collection('PaymentCards')
    .where('userId', isEqualTo: userId)
    .snapshots()

// Delete card
FirebaseFirestore.instance.collection('PaymentCards').doc(cardId).delete()

// ── Collection: transactions ──
// Create transaction (on payment success)
FirebaseFirestore.instance.collection('transactions').add({
  'technicianId': techId,
  'requestId': requestId,
  'serviceName': serviceName,
  'amount': amount,
  'isPositive': true,
  'type': 'income',
  'paymentMethod': 'card',
  'createdAt': FieldValue.serverTimestamp(),
  'dateStr': DateFormat('yyyy-MM-dd').format(DateTime.now()),
})

// Read technician transactions
FirebaseFirestore.instance
    .collection('transactions')
    .where('technicianId', isEqualTo: techId)
    .orderBy('createdAt', descending: true)
    .snapshots()

// ── Technician Wallet Update ──
FirebaseFirestore.instance.collection('technicians').doc(techId).update({
  'walletBalance': FieldValue.increment(amount),
  'totalEarnings': FieldValue.increment(amount),
  'todayEarnings': FieldValue.increment(amount),
  'todayOrdersCount': FieldValue.increment(1),
  'lastEarningTimestamp': FieldValue.serverTimestamp(),
})
```

### 9.4 Security Concerns

> **CRITICAL:** Credit card numbers are currently stored in plaintext in the `PaymentCards` Firestore collection. This must be fixed:

| Current (Insecure) | Proposed (Secure) |
|--------------------|--------------------|
| Store full card number | Tokenize via Stripe, store only last 4 digits |
| No encryption | Use Supabase Vault or Stripe tokenization |
| Client-side storage | PCI-compliant payment processor |

---

## 10. Feature: Community

### 10.1 Post Categories

| Category | Collection Suffix | Description |
|----------|------------------|-------------|
| General | `posts` | General community posts |
| Electricity | `electricity_posts` | Electrical service discussions |
| Plumbing | `plumbing_posts` | Plumbing service discussions |
| Painting | `painting_posts` | Painting service discussions |
| Finishing | `finishing_posts` | Finishing/renovation discussions |

### 10.2 Post Data Model

```dart
class CommunityPost {
  final String id;
  final String authorName;
  final String authorRole;     // "user" | "technician"
  final String? title;
  final String content;
  final String? imagePath;
  final int likes;
  final int comments;
  final bool isQuestion;
  final List<String> likedBy;
  final DateTime? createdAt;
}
```

### 10.3 Firestore Operations

```dart
// Create post
FirebaseFirestore.instance.collection('posts').add({
  'authorName': UserSession.instance.name,
  'authorRole': 'user',
  'title': title,
  'content': content,
  'imagePath': uploadedImageUrl,
  'likes': 0,
  'comments': 0,
  'isQuestion': isQuestion,
  'likedBy': [],
  'createdAt': FieldValue.serverTimestamp(),
})

// Like/unlike toggle
FirebaseFirestore.instance.collection('posts').doc(postId).update({
  'likes': FieldValue.increment(isLiked ? -1 : 1),
  'likedBy': isLiked
      ? FieldValue.arrayRemove([userId])
      : FieldValue.arrayUnion([userId]),
})

// Delete post
FirebaseFirestore.instance.collection('posts').doc(postId).delete()

// Upload post image → Supabase 'community_posts' bucket
await supabase.storage.from('community_posts').upload(
  '$postId/$fileName',
  imageFile,
);
```

---

## 11. Feature: Visits & History

### 11.1 Visit Data Model

```dart
class Visit {
  final String id;
  final String requestId;
  final String userId;
  final String technicianId;
  final String technicianName;
  final String serviceName;
  final String status;        // "completed" | "cancelled"
  final double? amount;
  final DateTime visitDate;
  final DateTime? completedAt;
}
```

### 11.2 Firestore Operations

```dart
// Read user visits (filtered from requests)
FirebaseFirestore.instance
    .collection('requests')
    .where('userId', isEqualTo: userId)
    .where('status', isEqualTo: 'completed')
    .orderBy('createdAt', descending: true)
    .snapshots()
```

---

## 12. Feature: AI Assistant

### 12.1 Integration Options

| Provider | Use Case | API |
|----------|----------|-----|
| OpenAI (GPT-4) | Service recommendations | REST API |
| Google Gemini | Diagnostic assistance | Vertex AI |
| Custom ML | Price estimation | Firebase ML / TFLite |

### 12.2 Proposed Edge Function

```typescript
// supabase/functions/ai-assistant/index.ts
Deno.serve(async (req) => {
  const { query, userContext } = await req.json()

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: `You are a home maintenance assistant for the Basita app in Egypt.
                    Help users diagnose issues, estimate costs in EGP, and recommend services.
                    Available services: electrical, plumbing, painting, carpentry, AC maintenance.`,
        },
        { role: 'user', content: query },
      ],
    }),
  })

  return new Response(JSON.stringify({ reply: response.choices[0].message }))
})
```

---

## 13. Feature: Family Dashboard

### 13.1 Data Model

```dart
class FamilyMember {
  final String id;
  final String userId;
  final String memberName;
  final String memberPhone;
  final String relationship;
  final String role;        // "admin" | "member"
  final DateTime joinedAt;
}
```

### 13.2 Firestore Operations

```dart
// ── Family subcollection under users/{uid} ──
// Add family member
FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .collection('family_members')
    .add({
      'memberName': name,
      'memberPhone': phone,
      'relationship': relationship,
      'role': 'member',
      'joinedAt': FieldValue.serverTimestamp(),
    })

// Read family members
FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .collection('family_members')
    .snapshots()

// Join family (by phone lookup)
FirebaseFirestore.instance
    .collection('users')
    .where('phone', isEqualTo: memberPhone)
    .get()
```

---

## 14. Feature: Account Verification

### 14.1 Verification Flow

```
User submits ID images + personal info
    │
    ▼
Upload front/back ID → Supabase 'account_verification' bucket
    │
    ▼
Save to Firestore 'verified' collection (status: "pending")
    │
    ▼
Admin reviews (manual or via Edge Function + AI)
    │
    ├── Approved → status: "approved" → Verified badge shown
    │
    └── Rejected → status: "rejected" → User notified
```

### 14.2 Firestore Operations

```dart
// Submit verification
FirebaseFirestore.instance.collection('verified').doc(uid).set({
  'userId': uid,
  'verificationStatus': 'pending',
  'name': name,
  'phone': phone,
  'email': email,
  'city': city,
  'governorate': governorate,
  'frontIdPath': supabaseFrontUrl,
  'backIdPath': supabaseBackUrl,
  'submittedAt': FieldValue.serverTimestamp(),
})

// Check verification status (realtime)
FirebaseFirestore.instance
    .collection('verified')
    .where('userId', isEqualTo: uid)
    .snapshots()
```

---

## 15. Supabase Storage Buckets

### 15.1 Bucket Configuration

| Bucket | Public | File Size Limit | Allowed Types | Path Structure |
|--------|--------|----------------|---------------|----------------|
| `profiles` | Yes | 5MB | jpg, png, webp | `{userId}/{timestamp}.{ext}` |
| `user_profiles` | Yes | 5MB | jpg, png, webp | `{userId}/{timestamp}.{ext}` |
| `account_verification` | No | 10MB | jpg, png, pdf | `{userId}/front_{timestamp}.{ext}` |
| `request` | No | 10MB | jpg, png | `{requestId}/{timestamp}.{ext}` |
| `task_images` | No | 10MB | jpg, png | `{requestId}/{timestamp}.{ext}` |
| `community_posts` | Yes | 5MB | jpg, png, gif | `{postId}/{timestamp}.{ext}` |

### 15.2 Bucket Consolidation (Recommended)

Current state has duplicate buckets. Consolidate to:

```
profiles/           ← Merge 'profiles' + 'user_profiles' into one
verification/       ← Rename 'account_verification'
requests/           ← Rename 'request'
task-completions/   ← Rename 'task_images'
community/          ← New dedicated bucket for posts
```

### 15.3 Upload Code Pattern

```dart
// Standard upload pattern
final fileExt = imageFile.path.split('.').last;
final fileName = '${docId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

await supabase.storage.from('bucket_name').upload(
  fileName,
  imageFile,
  fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
);

final publicUrl = supabase.storage.from('bucket_name').getPublicUrl(fileName);
```

---

## 16. Firestore Collections Schema

### Complete Schema Reference

```
firestore/
├── users/{uid}
│   ├── name: string
│   ├── phone: string
│   ├── email: string
│   ├── governorate: string
│   ├── city: string
│   ├── region: string
│   ├── placeType: string
│   ├── profileImagePath: string
│   ├── joinedCommunities: array<string>
│   ├── createdAt: timestamp
│   └── family_members/{memberId} (subcollection)
│       ├── memberName: string
│       ├── memberPhone: string
│       ├── relationship: string
│       ├── role: string
│       └── joinedAt: timestamp
│
├── technicians/{phone}
│   ├── fullName: string
│   ├── phone: string
│   ├── experience: string
│   ├── specialty: string
│   ├── governorate: string
│   ├── area: string
│   ├── profileImagePath: string
│   ├── role: "technician"
│   ├── isVerified: boolean
│   ├── completedOrdersCount: number
│   ├── totalEarnings: number
│   ├── todayEarnings: number
│   ├── todayOrdersCount: number
│   ├── lastEarningDateStr: string
│   ├── lastEarningTimestamp: timestamp
│   ├── walletBalance: number
│   ├── rating: number
│   └── createdAt: timestamp
│
├── requests/{requestId}
│   ├── userId: string
│   ├── userName: string
│   ├── userPhone: string
│   ├── userRegion: string
│   ├── userGovernorate: string
│   ├── title: string
│   ├── description: string
│   ├── budget: string
│   ├── scheduledDate: string
│   ├── status: string
│   ├── images: array<string>
│   ├── taskImages: array<string>
│   ├── technicianId: string
│   ├── technicianName: string
│   ├── acceptedPrice: string
│   ├── acceptedAt: timestamp
│   ├── hasOffers: boolean
│   ├── clientAccepted: boolean
│   ├── lastOfferTime: timestamp
│   ├── draftNotes: string
│   ├── draftSavedAt: timestamp
│   ├── technicianNotes: string
│   ├── finalPrice: number
│   ├── servicePrice: number
│   ├── isPaid: boolean
│   ├── paidAt: timestamp
│   ├── paymentMethod: string
│   ├── paidAmount: number
│   └── createdAt: timestamp
│
├── offers/{offerId}
│   ├── requestId: string
│   ├── technicianId: string
│   ├── technicianName: string
│   ├── name: string
│   ├── price: string
│   ├── duration: string
│   ├── arrivalTime: string
│   ├── warranty: string
│   ├── message: string
│   ├── provideMaterials: boolean
│   ├── priceIncludesMaterials: boolean
│   ├── rating: number
│   ├── reviewsCount: number
│   ├── experienceYears: number
│   ├── isVerified: boolean
│   ├── imagePath: string
│   ├── hasGreenArrivalTag: boolean
│   ├── status: string
│   └── createdAt: timestamp
│
├── verified/{uid}
│   ├── userId: string
│   ├── verificationStatus: string
│   ├── name: string
│   ├── phone: string
│   ├── email: string
│   ├── city: string
│   ├── governorate: string
│   ├── frontIdPath: string
│   ├── backIdPath: string
│   └── submittedAt: timestamp
│
├── PaymentCards/{cardId}
│   ├── userId: string
│   ├── userName: string
│   ├── userPhone: string
│   ├── userEmail: string
│   ├── userCity: string
│   ├── userGovernorate: string
│   ├── cardNumber: string          ← ⚠️ SECURITY RISK
│   ├── cardHolder: string
│   ├── expiryDate: string
│   ├── cardType: string
│   ├── isDefault: boolean
│   └── createdAt: timestamp
│
├── transactions/{transactionId}
│   ├── technicianId: string
│   ├── requestId: string
│   ├── serviceName: string
│   ├── amount: number
│   ├── isPositive: boolean
│   ├── type: string
│   ├── paymentMethod: string
│   ├── dateStr: string
│   └── createdAt: timestamp
│
├── posts/{postId}
│   ├── authorName: string
│   ├── authorRole: string
│   ├── time: string
│   ├── title: string
│   ├── content: string
│   ├── imagePath: string
│   ├── likes: number
│   ├── comments: number
│   ├── isQuestion: boolean
│   ├── likedBy: array<string>
│   └── createdAt: timestamp
│
├── conversations/{conversationId}
│   ├── requestId: string
│   ├── customerId: string
│   ├── customerName: string
│   ├── technicianId: string
│   ├── technicianName: string
│   ├── lastMessage: string
│   ├── lastMessageAt: timestamp
│   ├── unreadCustomer: number
│   ├── unreadTechnician: number
│   ├── createdAt: timestamp
│   └── messages/{messageId} (subcollection)
│       ├── senderId: string
│       ├── senderName: string
│       ├── text: string
│       ├── imageUrl: string
│       ├── timestamp: timestamp
│       └── isRead: boolean
│
├── carpentry_requests/{requestId}   ← Same schema as requests
├── plumbing_requests/{requestId}    ← Same schema as requests
└── painting_requests/{requestId}    ← Same schema as requests
```

---

## 17. Supabase PostgreSQL Tables

> Recommended tables for data that benefits from SQL queries, full-text search, or complex joins.

```sql
-- ── Notifications ──
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  user_type TEXT NOT NULL CHECK (user_type IN ('user', 'technician')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL,          -- 'request_update', 'payment', 'chat', 'system'
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Reviews & Ratings ──
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id TEXT NOT NULL,
  reviewer_id TEXT NOT NULL,
  technician_id TEXT NOT NULL,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Promo Codes ──
CREATE TABLE promo_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value NUMERIC NOT NULL,
  min_order_amount NUMERIC DEFAULT 0,
  max_uses INTEGER,
  used_count INTEGER DEFAULT 0,
  valid_from TIMESTAMPTZ NOT NULL,
  valid_until TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Support Tickets ──
CREATE TABLE support_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  user_type TEXT NOT NULL,
  subject TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Search Index (Full-text) ──
CREATE TABLE search_index (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL,    -- 'technician', 'service', 'post'
  entity_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  governorate TEXT,
  specialty TEXT,
  search_vector TSVECTOR GENERATED ALWAYS AS (
    to_tsvector('arabic', coalesce(title, '') || ' ' || coalesce(description, ''))
  ) STORED,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_search ON search_index USING GIN (search_vector);
```

---

## 18. Row Level Security (RLS) Policies

```sql
-- ── Notifications ──
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own notifications"
  ON notifications FOR SELECT
  USING (auth.uid()::text = user_id);

CREATE POLICY "System inserts notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);  -- Only via Edge Functions

-- ── Reviews ──
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read reviews"
  ON reviews FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert reviews"
  ON reviews FOR INSERT
  WITH CHECK (auth.uid()::text = reviewer_id);

CREATE POLICY "Users can update own reviews"
  ON reviews FOR UPDATE
  USING (auth.uid()::text = reviewer_id);

-- ── Promo Codes ──
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read active promo codes"
  ON promo_codes FOR SELECT
  USING (is_active = true AND valid_until > NOW());

-- ── Support Tickets ──
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own tickets"
  ON support_tickets FOR SELECT
  USING (auth.uid()::text = user_id);

CREATE POLICY "Users create own tickets"
  ON support_tickets FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

-- ── Search Index ──
ALTER TABLE search_index ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can search"
  ON search_index FOR SELECT
  USING (true);
```

---

## 19. Edge Functions

### 19.1 Process Payment

```typescript
// supabase/functions/process-payment/index.ts
import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  const { amount, currency, paymentMethodId, requestId, userId } = await req.json()

  // 1. Validate request
  // 2. Call Stripe/Fawry API
  // 3. On success: update Firestore via Admin SDK
  // 4. Return result

  return new Response(JSON.stringify({ success: true, transactionId: "..." }))
})
```

### 19.2 Send Push Notification

```typescript
// supabase/functions/send-notification/index.ts
import { serve } from "https://deno.land/std@0.177.0/http/server.ts"

serve(async (req) => {
  const { token, title, body, data } = await req.json()

  // Send via FCM HTTP v1 API
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/YOUR_PROJECT/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await getAccessToken()}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data,
        },
      }),
    }
  )

  return new Response(JSON.stringify({ success: true }))
})
```

### 19.3 Generate Invoice PDF

```typescript
// supabase/functions/generate-invoice/index.ts
serve(async (req) => {
  const { requestId } = await req.json()

  // 1. Fetch request data from Firestore
  // 2. Generate PDF using pdf-lib
  // 3. Upload to Supabase Storage
  // 4. Return download URL

  return new Response(JSON.stringify({ invoiceUrl: "..." }))
})
```

### 19.4 Daily Earnings Reset (Cron)

```typescript
// supabase/functions/cron-daily-reset/index.ts
serve(async (req) => {
  // Runs daily at midnight via pg_cron or external cron

  // 1. Get all technicians with todayOrdersCount > 0
  // 2. Archive yesterday's data
  // 3. Reset todayEarnings = 0, todayOrdersCount = 0
  // 4. Update lastEarningDateStr

  return new Response(JSON.stringify({ reset: true }))
})
```

---

## 20. Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── Users ──
    match /users/{userId} {
      allow read: if request.auth != null && (
        request.auth.uid == userId ||
        resource.data.phone == request.auth.phoneNumber
      );
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.auth.uid == userId;

      match /family_members/{memberId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // ── Technicians ──
    match /technicians/{phone} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.auth.phoneNumber == phone;
    }

    // ── Requests ──
    match /requests/{requestId} {
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        resource.data.technicianId == request.auth.phoneNumber
      );
      allow create: if request.auth != null;
      allow update: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        resource.data.technicianId == request.auth.phoneNumber
      );
    }

    // ── Offers ──
    match /offers/{offerId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && (
        resource.data.technicianId == request.auth.phoneNumber ||
        request.resource.data.status == 'accepted'
      );
    }

    // ── Conversations & Messages ──
    match /conversations/{convId} {
      allow read: if request.auth != null && (
        resource.data.customerId == request.auth.uid ||
        resource.data.technicianId == request.auth.phoneNumber
      );
      allow create: if request.auth != null;

      match /messages/{msgId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
      }
    }

    // ── Verified ──
    match /verified/{docId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && request.auth.uid == docId;
    }

    // ── Payment Cards ──
    match /PaymentCards/{cardId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // ── Transactions ──
    match /transactions/{txnId} {
      allow read: if request.auth != null && resource.data.technicianId == request.auth.phoneNumber;
      allow create: if request.auth != null;
    }

    // ── Posts ──
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null && (
        resource.data.authorName == request.auth.displayName
      );
    }
  }
}
```

---

## 21. API Endpoints Summary

### Firestore Direct Access (Client SDK)

| Operation | Collection | Method |
|-----------|-----------|--------|
| Login lookup | `users` / `technicians` | `.where('phone', ...)` |
| Create request | `requests` | `.add()` |
| View requests | `requests` | `.where(...).snapshots()` |
| Submit offer | `offers` | `.add()` |
| Accept offer | `offers` + `requests` | `.update()` |
| Send message | `conversations/{id}/messages` | `.add()` |
| Create post | `posts` | `.add()` |
| Like/unlike | `posts` | `.update()` |
| Save card | `PaymentCards` | `.add()` |
| Read transactions | `transactions` | `.where(...).snapshots()` |
| Submit verification | `verified` | `.set()` |

### Supabase Edge Function Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/functions/v1/process-payment` | POST | Process credit card payment |
| `/functions/v1/send-notification` | POST | Send FCM push notification |
| `/functions/v1/generate-invoice` | POST | Generate PDF invoice |
| `/functions/v1/ai-assistant` | POST | AI-powered help |
| `/functions/v1/search-technicians` | POST | Location-based search |
| `/functions/v1/cron-daily-reset` | GET | Daily counter reset |
| `/functions/v1/cron-expire-offers` | GET | Expire stale offers |

### Supabase Storage Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/storage/v1/object/profiles/{path}` | POST | Upload profile image |
| `/storage/v1/object/verification/{path}` | POST | Upload ID images |
| `/storage/v1/object/requests/{path}` | POST | Upload request images |
| `/storage/v1/object/task-completions/{path}` | POST | Upload task images |
| `/storage/v1/object/community/{path}` | POST | Upload post images |

---

## 22. Real-time Subscriptions

| Collection | Listener | Screen | Refresh Trigger |
|-----------|----------|--------|-----------------|
| `requests` | `.snapshots()` | orders_screen, home1, final_payment, user_invoices, bills | New request / status change |
| `offers` | `.snapshots()` | offers_dashboard | New offer / offer accepted |
| `conversations/{id}/messages` | `.snapshots()` | chat_screen | New message |
| `posts` | `.snapshots()` | comm1-6 | New post / like |
| `verified` | `.snapshots()` | profile_screen, account_verification | Verification status change |
| `PaymentCards` | `.snapshots()` | payment_cards, final_payment | Card added/removed |
| `transactions` | `.snapshots()` | sale_screen | New transaction |
| `technicians/{phone}` | `.snapshots()` | technician_dashboard, home1 | Earnings/orders update |
| `users/{uid}` | `.snapshots()` | family_join | Family data change |

---

## 23. Scheduled Functions / Cron Jobs

| Job | Schedule | Action |
|-----|----------|--------|
| Daily earnings reset | 00:00 daily | Reset `todayEarnings`, `todayOrdersCount` for all technicians |
| Expire old offers | Every 6 hours | Mark offers older than 48h as `expired` |
| Cleanup drafts | Weekly | Delete draft notes older than 30 days |
| Invoice reminder | Daily 09:00 | Send push notification for unpaid invoices |
| Analytics aggregation | Hourly | Aggregate request/offer stats for dashboard |

---

## 24. Third-Party Integrations

| Service | Purpose | Status |
|---------|---------|--------|
| Firebase Auth (Phone OTP) | User authentication | **Needs implementation** |
| Firebase Analytics | Usage tracking | Configured |
| Firebase Crashlytics | Error tracking | Configured |
| Firebase Cloud Messaging | Push notifications | **Needs implementation** |
| Supabase Storage | File uploads | Implemented |
| Supabase PostgreSQL | Structured data | **Needs implementation** |
| Supabase Edge Functions | Backend logic | **Needs implementation** |
| Stripe / Fawry | Payment processing | **Needs implementation** |
| Google Maps SDK | Location display | Configured (unused) |
| Geolocator | GPS coordinates | Implemented (technician registration) |
| OpenAI / Gemini | AI assistant | **Needs implementation** |

---

## Appendix: Current Issues to Fix

| Issue | Severity | Description |
|-------|----------|-------------|
| No Firebase Auth sign-in | **Critical** | Login bypasses Firebase Auth, uses Firestore phone lookup only |
| Plaintext credit cards | **Critical** | Full card numbers stored in Firestore `PaymentCards` |
| No security rules | **Critical** | All Firestore collections are wide open |
| Inconsistent bucket names | Medium | `profiles` vs `user_profiles` for same purpose |
| Duplicate OfferModel | Low | Defined in both `offer_model.dart` and `offers_dashboard_screen.dart` |
| No real backend for chat | Medium | Chat uses mock data, not Firestore subcollections |
| No image compression | Low | Raw images uploaded without resizing |
| SharedPreferences overflow | Low | 18+ keys stored, should use a proper session manager |
