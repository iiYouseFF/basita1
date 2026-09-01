// Central configuration for the external backend system.
// All backend features have been extracted from the Flutter app per user request.
// See `docs/backend-prd.html` for the full PRD / API contract.

abstract class ApiConfig {
  /// Base URL of the external backend. Override at build/run time:
  ///   flutter run --dart-define=API_BASE_URL=https://api.example.com
  /// Live Node.js API: http://basseeyta.duckdns.org (GitHub: https://github.com/iiYouseFF/basseeyta)
  /// Docs at: http://basseeyta.duckdns.org/api-docs.json
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://basseeyta.duckdns.org',
  );

  /// Optional API key / bearer token placeholder (legacy).
  static const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

  /// GitHub repo for the backend
  static const githubRepo = 'https://github.com/iiYouseFF/basseeyta';

  /// API docs endpoint
  static String get apiDocsUrl => '$baseUrl/api-docs.json';

  /// Timeout for HTTP requests.
  static const timeoutSeconds = 30;

  static void init() {
    // No-op. Kept for symmetry with old Firebase init.
    // ignore: avoid_print
    print('[ApiConfig] baseUrl=$baseUrl');
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
  };
}
