import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> search({
    required String query,
    String? entityType,
    String? governorate,
    int limit = 20,
  }) async {
    var rpcQuery = _client.rpc(
      'search_entities',
      params: {'search_query': query},
    );

    final data = await rpcQuery;
    List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
      data ?? [],
    );

    if (entityType != null) {
      results = results.where((r) => r['entity_type'] == entityType).toList();
    }
    if (governorate != null) {
      results = results.where((r) => r['governorate'] == governorate).toList();
    }

    return results.take(limit).toList();
  }

  Future<void> indexEntity({
    required String entityType,
    required String entityId,
    required String title,
    String? description,
    String? governorate,
    String? specialty,
  }) async {
    await _client.from('search_index').upsert({
      'entity_type': entityType,
      'entity_id': entityId,
      'title': title,
      'description': description,
      'governorate': governorate,
      'specialty': specialty,
    });
  }

  Future<void> removeIndex(String entityType, String entityId) async {
    await _client
        .from('search_index')
        .delete()
        .eq('entity_type', entityType)
        .eq('entity_id', entityId);
  }
}
