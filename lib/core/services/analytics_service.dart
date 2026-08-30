import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Previously Firebase Analytics.
// Now stubbed — wire to your external analytics provider (PostHog, Mixpanel, or your backend's /analytics/events).
// See docs/backend-prd.html § Observability.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Kept for MaterialApp.navigatorObservers compatibility — now no-op observer.
  NavigatorObserver get observer => _NoopObserver();

  Future<void> logLogin({required String method, required String userType}) async {
    _log('login', {'method': method, 'user_type': userType});
  }

  Future<void> logRequestCreated({required String serviceType, required String governorate, String? budget}) async {
    _log('request_created', {'service_type': serviceType, 'governorate': governorate, 'budget': budget});
  }

  Future<void> logOfferSubmitted({required String price, required String technicianId}) async {
    _log('offer_submitted', {'price': price, 'technician_id': technicianId});
  }

  Future<void> logPaymentCompleted({required double amount, required String method, required String requestId}) async {
    _log('payment_completed', {'amount': amount, 'method': method, 'request_id': requestId});
  }

  Future<void> logChatMessageSent({required String conversationId}) async {
    _log('chat_message_sent', {'conversation_id': conversationId});
  }

  Future<void> logPostCreated({required String category, required bool hasImage}) async {
    _log('post_created', {'category': category, 'has_image': hasImage});
  }

  Future<void> logSearch({required String query, required int resultsCount}) async {
    _log('search_performed', {'query': query, 'results_count': resultsCount});
  }

  void _log(String name, Map<String, dynamic> params) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Analytics] $name $params — TODO: POST /analytics/events');
    }
    // TODO(backend): ApiClient().post('/analytics/events', body: {'name': name, 'params': params})
  }
}

class _NoopObserver extends NavigatorObserver {}
