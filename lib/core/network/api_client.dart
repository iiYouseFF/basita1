import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:basita1/core/network/api_config.dart';
import 'package:basita1/core/session/auth_session.dart';

/// Lightweight HTTP client for the external backend.
///
/// Every feature that previously used Firebase/Supabase should now go
/// through this client. See `docs/backend-prd.html` for endpoint specs.
///
/// Usage:
/// ```dart
/// final client = ApiClient();
/// final res = await client.get('/users/me');
/// final data = await client.post('/service-requests', body: {...});
/// ```
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _http;
  final String _baseUrl;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalizedPath');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, '$v')));
  }

  Map<String, String> get _headers => {
        ...ApiConfig.headers,
        ...AuthSession.instance.authHeader,
      };

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _http
        .get(_uri(path, query), headers: _headers)
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    final res = await _http
        .post(
          _uri(path, query),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(res);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _http
        .put(
          _uri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(res);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _http
        .patch(
          _uri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(res);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final res = await _http
        .delete(_uri(path), headers: _headers)
        .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
    return _decode(res);
  }

  /// Upload a file via multipart/form-data.
  /// Endpoint should accept `file` field — see PRD Storage section.
  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    final uri = _uri(path);
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(_headers);
    // Remove json content-type for multipart
    req.headers.remove('Content-Type');
    if (fields != null) req.fields.addAll(fields);
    req.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    final streamed = await req.send().timeout(
          const Duration(seconds: ApiConfig.timeoutSeconds * 2),
        );
    final res = await http.Response.fromStream(streamed);
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    final body = res.body.isEmpty ? '{}' : res.body;
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      if (res.statusCode >= 200 && res.statusCode < 300) return decoded;
      throw ApiException(
        statusCode: res.statusCode,
        message: decoded['message']?.toString() ?? 'Request failed',
        details: decoded,
      );
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return {'data': decoded};
    }
    throw ApiException(statusCode: res.statusCode, message: body);
  }

  void close() => _http.close();
}

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message, this.details});
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
