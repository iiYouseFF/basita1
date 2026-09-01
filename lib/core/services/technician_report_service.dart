import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Service for submitting technician maintenance reports to n8n webhook.
///
/// Endpoint: POST https://basseeyta-api.duckdns.org/webhook/technician-report
/// Content-Type: application/json
///
/// Contract:
/// ```json
/// {
///   "technician_name": "John Doe",
///   "appliance_type": "Refrigerator",
///   "model": "Samsung RT38",
///   "problem_description": "Compressor not running",
///   "solution_notes": "Replaced starting relay",
///   "cost": 1200
/// }
/// ```
/// Success is verified only when response body contains {"status":"success"}.
class TechnicianReportService {
  TechnicianReportService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _endpoint =
      'https://basseeyta-api.duckdns.org/webhook/technician-report';

  static const Duration _timeout = Duration(seconds: 30);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Submits a technician report.
  ///
  /// Throws [TechnicianReportException] on validation or network failure.
  /// Returns parsed response map on success.
  Future<Map<String, dynamic>> submitReport({
    required String technicianName,
    required String applianceType,
    required String model,
    required String problemDescription,
    required String solutionNotes,
    required num cost,
  }) async {
    // Local validation mirrors UI validation as safety net.
    if (applianceType.trim().isEmpty) {
      throw TechnicianReportException(
        'Appliance type is required',
        userMessage: 'Please fill in the appliance type.',
      );
    }
    if (model.trim().isEmpty) {
      throw TechnicianReportException(
        'Model is required',
        userMessage: 'Please fill in the model field.',
      );
    }

    // Ensure numeric casting matches Supabase schema constraints.
    final num normalizedCost = _normalizeCost(cost);

    final Map<String, dynamic> payload = {
      'technician_name': technicianName.trim(),
      'appliance_type': applianceType.trim(),
      'model': model.trim(),
      'problem_description': problemDescription.trim(),
      'solution_notes': solutionNotes.trim(),
      'cost': normalizedCost,
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
      throw TechnicianReportException(
        'SocketException: no internet',
        userMessage: 'Connection failed. Please check your internet.',
      );
    } on TimeoutException {
      throw TechnicianReportException(
        'Request timed out',
        userMessage: 'Connection timeout. Please check your internet.',
      );
    } on http.ClientException catch (e) {
      throw TechnicianReportException(
        'ClientException: ${e.message}',
        userMessage: 'Connection failed. Please check your internet.',
      );
    } on FormatException catch (e) {
      throw TechnicianReportException(
        'Invalid response format: $e',
        userMessage: 'Server returned an invalid response. Please try again.',
      );
    } on TechnicianReportException {
      rethrow;
    } catch (e) {
      throw TechnicianReportException(
        'Unknown error: $e',
        userMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? {} : jsonDecode(response.body);
    } on FormatException {
      throw TechnicianReportException(
        'Invalid JSON: ${response.body}',
        userMessage: 'Server returned an invalid response. Please try again.',
        statusCode: response.statusCode,
      );
    }

    // Non-200 is always failure, with human-readable message.
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final serverMsg = _extractServerMessage(decoded);
      throw TechnicianReportException(
        'HTTP ${response.statusCode}: $serverMsg',
        userMessage: serverMsg.isNotEmpty
            ? serverMsg
            : 'Server error (${response.statusCode}). Please try again.',
        statusCode: response.statusCode,
        body: decoded is Map<String, dynamic> ? decoded : {'raw': decoded},
      );
    }

    // 2xx but must contain {"status":"success"}
    if (decoded is Map<String, dynamic>) {
      final status = decoded['status']?.toString().toLowerCase().trim();
      if (status == 'success') {
        return decoded;
      }
      // Some n8n flows may return array with one object
      throw TechnicianReportException(
        'Missing success status: $decoded',
        userMessage: 'Submission failed. Server did not confirm success.',
        statusCode: response.statusCode,
        body: decoded,
      );
    }

    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      final first = decoded.first as Map<String, dynamic>;
      final status = first['status']?.toString().toLowerCase().trim();
      if (status == 'success') {
        return first;
      }
    }

    throw TechnicianReportException(
      'Unexpected response shape: $decoded',
      userMessage: 'Unexpected server response. Please try again.',
      statusCode: response.statusCode,
      body: decoded is Map<String, dynamic> ? decoded : {'raw': decoded},
    );
  }

  String _extractServerMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      for (final k in ['message', 'error', 'msg', 'detail']) {
        if (decoded[k] != null && decoded[k].toString().trim().isNotEmpty) {
          return decoded[k].toString();
        }
      }
    }
    return '';
  }

  /// Normalizes cost to num, handling int/double/string inputs.
  num _normalizeCost(num cost) {
    // If it's already num, ensure it's finite; string parsing is handled at UI layer.
    if (cost is int || cost is double) {
      if (cost is double && !cost.isFinite) return 0;
      return cost;
    }
    return cost;
  }

  /// Helper to parse cost from text field safely.
  /// Returns 0 if parsing fails — caller should validate separately if needed.
  static num parseCost(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 0;
    // Remove commas, currency symbols if any
    final sanitized = trimmed.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.\-]'), '');
    final asInt = int.tryParse(sanitized);
    if (asInt != null) return asInt;
    final asDouble = double.tryParse(sanitized);
    if (asDouble != null && asDouble.isFinite) return asDouble;
    return 0;
  }

  void close() => _client.close();
}

/// Domain exception for technician report flow.
/// Contains both technical message and user-facing [userMessage].
class TechnicianReportException implements Exception {
  TechnicianReportException(
    this.message, {
    required this.userMessage,
    this.statusCode,
    this.body,
  });

  final String message;
  final String userMessage;
  final int? statusCode;
  final Map<String, dynamic>? body;

  @override
  String toString() => 'TechnicianReportException($statusCode): $message';
}
