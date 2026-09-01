import 'package:basita1/core/network/api_client.dart';

/// Real backend: GET /search?q=&entityType=&governorate=&limit=, POST /search/index
class SearchRepository {
  final ApiClient _api = ApiClient();

  Future<List<Map<String, dynamic>>> search({
    required String query,
    String? entityType,
    String? governorate,
    int limit = 20,
  }) async {
    final res = await _api.get(
      '/search',
      query: {
        'q': query,
        if (entityType != null) 'entityType': entityType,
        if (governorate != null) 'governorate': governorate,
        'limit': limit,
      },
    );
    final data = res['data'];
    final list = data is List
        ? data
        : (data is Map && data['results'] is List ? data['results'] : []);
    return List<Map<String, dynamic>>.from(
      (list as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  Future<void> indexEntity({
    required String entityType,
    required String entityId,
    required String title,
    String? description,
    String? governorate,
    String? specialty,
  }) async {
    await _api.post(
      '/search/index',
      body: {
        'entityType': entityType,
        'entityId': entityId,
        'title': title,
        if (description != null) 'description': description,
        if (governorate != null) 'governorate': governorate,
        if (specialty != null) 'specialty': specialty,
      },
    );
  }

  Future<void> removeIndex(String entityType, String entityId) async {
    await _api.delete('/search/index/$entityType/$entityId');
  }
}
