import '../models/api_misc.dart';
import '../services/api_client.dart';

class SearchRepository {
  final ApiClient _api = ApiClient();

  Future<List<ApiSearchResult>> search({
    required String query,
    String? entityType,
    String? governorate,
    int? limit,
  }) async {
    final queryParams = <String, String>{
      'q': query,
    };
    if (entityType != null) queryParams['entityType'] = entityType;
    if (governorate != null) queryParams['governorate'] = governorate;
    if (limit != null) queryParams['limit'] = limit.toString();
    
    final response = await _api.get(
      '/search',
      queryParams: queryParams,
      includeAuth: false,
    );
    final results = _api.unwrapList(response);
    return results.map((r) => ApiSearchResult.fromJson(r)).toList();
  }

  Future<void> indexEntity({
    required String entityType,
    required String entityId,
    required String title,
    required String description,
    String? governorate,
    String? specialty,
  }) async {
    final body = <String, dynamic>{
      'entityType': entityType,
      'entityId': entityId,
      'title': title,
      'description': description,
    };
    if (governorate != null) body['governorate'] = governorate;
    if (specialty != null) body['specialty'] = specialty;
    
    await _api.post('/search/index', body: body);
  }

  Future<void> removeIndex(String type, String id) async {
    await _api.delete('/search/index/$type/$id');
  }
}
