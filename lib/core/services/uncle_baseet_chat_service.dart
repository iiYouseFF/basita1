import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for chatting with "Uncle Baseet" AI via n8n webhook.
///
/// Endpoint: POST https://basseeyta-api.duckdns.org/webhook/chat
/// Content-Type: application/json
///
/// Request:
/// ```json
/// {
///   "sessionId": "unique_user_id_123",
///   "chatInput": "My washing machine is leaking..."
/// }
/// ```
/// Response:
/// ```json
/// {
///   "output": "AI response containing formatted text..."
/// }
/// ```
class UncleBaseetChatService {
  UncleBaseetChatService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _endpoint = 'https://basseeyta-api.duckdns.org/webhook/chat';
  static const Duration _timeout = Duration(seconds: 45); // n8n may query YouTube/DB
  static const String _sessionKey = 'uncle_baseet_session_id';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Sends a chat message and returns the AI output string.
  ///
  /// Throws [UncleBaseetChatException] on network or protocol errors.
  Future<String> sendMessage({
    required String sessionId,
    required String chatInput,
  }) async {
    if (sessionId.trim().isEmpty) {
      throw UncleBaseetChatException(
        'sessionId is empty',
        userMessage: 'Session not initialized. Please restart the chat.',
      );
    }
    if (chatInput.trim().isEmpty) {
      throw UncleBaseetChatException(
        'chatInput is empty',
        userMessage: 'Please type a message.',
      );
    }

    final payload = {
      'sessionId': sessionId.trim(),
      'chatInput': chatInput.trim(),
    };

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw UncleBaseetChatException(
        'SocketException',
        userMessage: 'Connection failed. Please check your internet.',
      );
    } on TimeoutException {
      throw UncleBaseetChatException(
        'Timeout',
        userMessage: 'Connection timeout. Please check your internet.',
      );
    } on http.ClientException catch (e) {
      throw UncleBaseetChatException(
        'ClientException: ${e.message}',
        userMessage: 'Connection failed. Please check your internet.',
      );
    } on FormatException catch (e) {
      throw UncleBaseetChatException(
        'FormatException: $e',
        userMessage: 'Server returned an invalid response. Please try again.',
      );
    } on UncleBaseetChatException {
      rethrow;
    } catch (e) {
      throw UncleBaseetChatException(
        'Unknown: $e',
        userMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  String _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? {} : jsonDecode(response.body);
    } on FormatException {
      throw UncleBaseetChatException(
        'Invalid JSON: ${response.body}',
        userMessage: 'Server returned an invalid response. Please try again.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = _extractMessage(decoded);
      throw UncleBaseetChatException(
        'HTTP ${response.statusCode}: $msg',
        userMessage: msg.isNotEmpty ? msg : 'Server error (${response.statusCode}). Please try again.',
        statusCode: response.statusCode,
      );
    }

    // Expected: {"output": "..."} — but handle variations:
    // - {"output": "..."} 
    // - [{"output": "..."}]
    // - {"data": {"output": "..."}}
    // - plain string response
    if (decoded is Map<String, dynamic>) {
      // direct output
      if (decoded['output'] is String) {
        return decoded['output'] as String;
      }
      // wrapped in data
      if (decoded['data'] is Map && (decoded['data'] as Map)['output'] is String) {
        return (decoded['data'] as Map)['output'] as String;
      }
      // alternative keys some n8n workflows use
      for (final k in ['response', 'reply', 'answer', 'text', 'message']) {
        if (decoded[k] is String && (decoded[k] as String).trim().isNotEmpty) {
          return decoded[k] as String;
        }
      }
      // If map has single string value, return it
      if (decoded.length == 1 && decoded.values.first is String) {
        return decoded.values.first as String;
      }
      throw UncleBaseetChatException(
        'Missing output field: $decoded',
        userMessage: 'AI returned an unexpected format. Please try again.',
        statusCode: response.statusCode,
      );
    }

    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map<String, dynamic> && first['output'] is String) {
        return first['output'] as String;
      }
      if (first is Map<String, dynamic>) {
        for (final k in ['output', 'response', 'reply', 'answer', 'text']) {
          if (first[k] is String) return first[k] as String;
        }
      }
      if (first is String) return first;
    }

    if (decoded is String) {
      return decoded;
    }

    throw UncleBaseetChatException(
      'Unexpected response shape: $decoded',
      userMessage: 'Unexpected server response. Please try again.',
      statusCode: response.statusCode,
    );
  }

  String _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      for (final k in ['message', 'error', 'msg', 'detail', 'output']) {
        if (decoded[k] != null && decoded[k].toString().trim().isNotEmpty) {
          return decoded[k].toString();
        }
      }
    }
    return '';
  }

  // ---------------------------------------------------------------------------
  // Session management — persistent sessionId per user throughout active session
  // ---------------------------------------------------------------------------

  /// Returns existing sessionId from SharedPreferences or creates a new one.
  /// Persists for the lifetime of the app install unless [resetSession] is called.
  Future<String> getOrCreateSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_sessionKey);
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }
    final newId = _generateSessionId();
    await prefs.setString(_sessionKey, newId);
    return newId;
  }

  /// Forces creation of a new sessionId (e.g., "New chat").
  Future<String> resetSession() async {
    final prefs = await SharedPreferences.getInstance();
    final newId = _generateSessionId();
    await prefs.setString(_sessionKey, newId);
    return newId;
  }

  /// Synchronous fallback when SharedPreferences is not available (tests).
  String generateSessionId() => _generateSessionId();

  String _generateSessionId() {
    // No uuid dependency — use timestamp + random
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rnd = (ts * 1103515245 + 12345) % 0x7fffffff;
    return 'sess_${ts}_$rnd';
  }

  /// Optional: derive sessionId from known user id if available.
  /// Keeps n8n memory per authenticated user.
  static String sessionIdForUser(String? userId, String fallback) {
    if (userId != null && userId.trim().isNotEmpty) {
      return 'user_$userId';
    }
    return fallback;
  }

  void close() => _client.close();
}

class UncleBaseetChatException implements Exception {
  UncleBaseetChatException(
    this.message, {
    required this.userMessage,
    this.statusCode,
  });

  final String message;
  final String userMessage;
  final int? statusCode;

  @override
  String toString() => 'UncleBaseetChatException($statusCode): $message';
}
