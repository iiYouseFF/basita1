import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized analytics — Phase 4 hardening.
/// All Firestore/Supabase repo successes should log here.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalytics get instance => _analytics;
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logLogin({
    required String method,
    required String userType,
  }) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      await _analytics.logEvent(
        name: 'login',
        parameters: {'method': method, 'user_type': userType},
      );
    } catch (_) {}
  }

  Future<void> logRequestCreated({
    required String serviceType,
    required String governorate,
    String? budget,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'request_created',
        parameters: {
          'service_type': serviceType,
          'governorate': governorate,
          if (budget != null) 'budget': budget,
        },
      );
    } catch (_) {}
  }

  Future<void> logOfferSubmitted({
    required String price,
    required String technicianId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'offer_submitted',
        parameters: {'price': price, 'technician_id': technicianId},
      );
    } catch (_) {}
  }

  Future<void> logPaymentCompleted({
    required double amount,
    required String method,
    required String requestId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'payment_completed',
        parameters: {
          'amount': amount,
          'method': method,
          'request_id': requestId,
        },
      );
    } catch (_) {}
  }

  Future<void> logChatMessageSent({required String conversationId}) async {
    try {
      await _analytics.logEvent(
        name: 'chat_message_sent',
        parameters: {'conversation_id': conversationId},
      );
    } catch (_) {}
  }

  Future<void> logPostCreated({
    required String category,
    required bool hasImage,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'post_created',
        parameters: {'category': category, 'has_image': hasImage},
      );
    } catch (_) {}
  }

  Future<void> logSearch({
    required String query,
    required int resultsCount,
  }) async {
    try {
      await _analytics.logSearch(searchTerm: query);
      await _analytics.logEvent(
        name: 'search_performed',
        parameters: {'query': query, 'results_count': resultsCount},
      );
    } catch (_) {}
  }
}
