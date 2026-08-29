import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  SupabaseClient get client => _client;

  // Current authenticated user ID (Firebase Auth UID synced to Supabase)
  String? get currentUserId => _client.auth.currentUser?.id;

  // Helper: invoke an Edge Function with JSON body
  Future<Map<String, dynamic>> invokeFunction({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.functions.invoke(functionName, body: body);
    return response.data as Map<String, dynamic>;
  }
}
