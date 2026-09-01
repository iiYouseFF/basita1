// LEGACY SHIM — previously wrapped MockSupabase.
// Now delegates to ApiClient. Keeping class name to avoid churn in old imports.
// New code should use `ApiClient` directly.
// This file will be removed once all callers migrate.
//
// See docs/backend-prd.html for the external backend contract.

import 'package:basita1/core/network/api_client.dart';
import 'package:basita1/core/network/mock_backend.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final ApiClient _api = ApiClient();
  ApiClient get client => _api;

  String? get currentUserId => null;

  Future<Map<String, dynamic>> invokeFunction({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
    // TODO(backend): POST /functions/$functionName
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true, 'mock': true, 'function': functionName};
  }
}
