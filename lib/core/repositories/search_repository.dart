import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> search({
    required String query,
    String? entityType,
    String? governorate,
    int limit = 20,
  }) async {
    try {
      // RPC: search_entities(q text, etype text, gov text, lim int)
      final data = await _client.rpc(
        'search_entities',
        params: {
          'q': query,
          'etype': entityType,
          'gov': governorate,
          'lim': limit,
        },
      );
      List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
        data ?? [],
      );
      if (entityType != null)
        results = results.where((r) => r['entity_type'] == entityType).toList();
      if (governorate != null)
        results = results
            .where((r) => r['governorate'] == governorate)
            .toList();
      return results.take(limit).toList();
    } catch (e) {
      // Fallback to old param name if needed
      try {
        final data2 = await _client.rpc(
          'search_entities',
          params: {'search_query': query},
        );
        return List<Map<String, dynamic>>.from(
          data2 ?? [],
        ).take(limit).toList();
      } catch (e2) {
        // ignore: avoid_print
        print('[SearchRepository.search] $e / $e2');
        rethrow;
      }
    }
  }

  Future<void> indexEntity({
    required String entityType,
    required String entityId,
    required String title,
    String? description,
    String? governorate,
    String? specialty,
  }) async {
    try {
      await _client.from('search_index').upsert({
        'entity_type': entityType,
        'entity_id': entityId,
        'title': title,
        'description': description,
        'governorate': governorate,
        'specialty': specialty,
      });
    } catch (e) {
      // ignore: avoid_print
      print('[SearchRepository.indexEntity] $e');
      rethrow;
    }
  }

  Future<void> removeIndex(String entityType, String entityId) async {
    try {
      await _client
          .from('search_index')
          .delete()
          .eq('entity_type', entityType)
          .eq('entity_id', entityId);
    } catch (e) {
      // ignore: avoid_print
      print('[SearchRepository.removeIndex] $e');
      rethrow;
    }
  }
}
