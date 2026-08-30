import 'dart:async';
import 'package:flutter/foundation.dart';

// Previously Firebase Crashlytics.
// Now stubbed — route to your external error reporting (Sentry, etc.) or backend /logs.
// See docs/backend-prd.html § Observability.
class CrashService {
  static Future<void> setup() async {
    FlutterError.onError = (details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
      } else {
        // TODO(backend): report to external service
      }
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[CrashService] $error\n$stack');
      }
      return true;
    };
  }

  static Future<void> setUserContext({String? userId, String? userType, String? governorate}) async {
    // TODO(backend): associate logs with user
  }

  static Future<void> recordRepoError(dynamic error, StackTrace stack, {String? reason}) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[CrashService] $reason: $error\n$stack');
    }
  }
}
