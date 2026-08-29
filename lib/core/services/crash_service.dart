import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Phase 4: Crashlytics wiring — call setup() from main() after Firebase init.
class CrashService {
  static Future<void> setup() async {
    // Flutter errors
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    // Async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    // Optional: set custom keys
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );
    } catch (_) {}
  }

  static Future<void> setUserContext({
    String? userId,
    String? userType,
    String? governorate,
  }) async {
    try {
      if (userId != null)
        await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      await FirebaseCrashlytics.instance.setCustomKey(
        'user_type',
        userType ?? 'unknown',
      );
      if (governorate != null)
        await FirebaseCrashlytics.instance.setCustomKey(
          'governorate',
          governorate,
        );
      await FirebaseCrashlytics.instance.setCustomKey('app_version', '1.0.0+1');
    } catch (_) {}
  }

  static Future<void> recordRepoError(
    dynamic error,
    StackTrace stack, {
    String? reason,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        printDetails: false,
      );
    } catch (_) {}
  }
}
