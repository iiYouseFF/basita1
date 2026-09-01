import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String baseUrl = 'http://basseeyta.duckdns.org';
  String? _jwtToken;
  String? _userId;
  String? _userType;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString('api_jwt_token');
    _userId = prefs.getString('api_user_id');
    _userType = prefs.getString('api_user_type');
  }

  Future<void> setAuth({
    required String token,
    required String userId,
    required String userType,
  }) async {
    _jwtToken = token;
    _userId = userId;
    _userType = userType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_jwt_token', token);
    await prefs.setString('api_user_id', userId);
    await prefs.setString('api_user_type', userType);
  }

  Future<void> clearAuth() async {
    _jwtToken = null;
    _userId = null;
    _userType = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_jwt_token');
    await prefs.remove('api_user_id');
    await prefs.remove('api_user_type');
  }

  String? get jwtToken => _jwtToken;
  String? get userId => _userId;
  String? get userType => _userType;
  bool get isAuthenticated => _jwtToken != null;

  Map<String, String> _headers({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParams,
    );
    final response = await http.get(
      uri,
      headers: _headers(includeAuth: includeAuth),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: _headers(includeAuth: includeAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.put(
      uri,
      headers: _headers(includeAuth: includeAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.patch(
      uri,
      headers: _headers(includeAuth: includeAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(
      uri,
      headers: _headers(includeAuth: includeAuth),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadMultipart(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    
    if (includeAuth && _jwtToken != null) {
      request.headers['Authorization'] = 'Bearer $_jwtToken';
    }
    
    if (fields != null) {
      request.fields.addAll(fields);
    }
    
    final file = await http.MultipartFile.fromPath(fieldName, filePath);
    request.files.add(file);
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        if (body.containsKey('success') && body['success'] == false) {
          throw ApiException(
            statusCode: response.statusCode,
            message: body['message'] ?? 'Request failed',
            body: body,
          );
        }
      }
      return body;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] ?? body['error'] ?? 'Unknown error',
        body: body,
      );
    }
  }

  Map<String, dynamic> unwrapData(Map<String, dynamic> response) {
    if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
      return response['data'] as Map<String, dynamic>;
    }
    return response;
  }

  List<dynamic> unwrapList(Map<String, dynamic> response) {
    if (response.containsKey('data') && response['data'] is List) {
      return response['data'] as List;
    }
    if (response.containsKey('data') && response['data'] is Map) {
      final data = response['data'] as Map;
      for (final value in data.values) {
        if (value is List) return value;
      }
    }
    return [];
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? body;

  ApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}
