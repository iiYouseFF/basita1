---
name: firebase-integration
description: Handles Firestore queries, Firebase Auth, and Crashlytics telemetry logging.
---

# Firebase Services Workflow

When integrating Firebase services:

1. **Firestore Modeling**:
   - Maintain shallow collection structures to minimize document reads.
   - Write custom `fromFirestore` and `toFirestore` mappers.

2. **Telemetry & Crashlytics**:
   - Wrap critical business operations in error handlers that log non-fatal exceptions to `FirebaseCrashlytics.instance.recordError(...)`.