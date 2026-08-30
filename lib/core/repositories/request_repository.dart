import 'package:basita1/core/network/api_client.dart';

/// Real backend: Node.js at http://basseeyta.duckdns.org
/// GitHub: https://github.com/iiYouseFF/basseeyta
/// Endpoints: POST /service-requests, GET /service-requests, PATCH /service-requests/:id, DELETE, etc.
/// Was Firestore `requests` / `carpentry_requests` / ...
class RequestRepository {
  final ApiClient _api = ApiClient();

  Future<String> createRequest({
    required Map<String, dynamic> data,
    String? serviceType,
  }) async {
    // serviceType determines alias: /service-requests/carpentry etc.
    final path = serviceType != null && ['carpentry','plumbing','painting','electrical'].contains(serviceType.toLowerCase())
        ? '/service-requests/${serviceType.toLowerCase()}'
        : '/service-requests';
    // Backend expects exact keys: userId, userName, userPhone, userGovernorate, title, description, budget, serviceType, scheduledDate, images
    final res = await _api.post(path, body: data);
    final d = res['data'] as Map<String, dynamic>?;
    return (d?['id'] ?? d?['request']?['id'] ?? res['id'] ?? '').toString();
  }

  Future<void> updateRequest(
    String requestId, {
    required Map<String, dynamic> data,
    String? serviceType,
  }) async {
    await _api.patch('/service-requests/$requestId', body: data);
  }

  Future<Map<String, dynamic>?> getRequest(String requestId) async {
    try {
      final res = await _api.get('/service-requests/$requestId');
      return (res['data'] as Map<String, dynamic>?) ?? res;
    } catch (_) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> watchRequest(String requestId) async* {
    final data = await getRequest(requestId);
    yield data;
    // TODO: WebSocket for realtime if needed (Namespace /requests)
  }

  Stream<List<Map<String, dynamic>>> watchUserRequests(
    String userId, {
    String? status,
  }) async* {
    final query = <String, dynamic>{'userId': userId, 'sort': 'createdAt.desc', 'limit': 50};
    if (status != null) query['status'] = status;
    final res = await _api.get('/service-requests', query: query);
    final data = res['data'];
    final list = data is List ? List<Map<String, dynamic>>.from(data) : <Map<String, dynamic>>[];
    yield list;
  }

  Stream<List<Map<String, dynamic>>> watchAvailableRequests(
    String governorate,
  ) async* {
    final res = await _api.get('/service-requests', query: {
      'status': 'pending',
      'governorate': governorate,
      'sort': 'createdAt.desc',
      'limit': 20,
    });
    final data = res['data'];
    final list = data is List ? List<Map<String, dynamic>>.from(data) : <Map<String, dynamic>>[];
    yield list;
  }

  Future<void> updateStatus(
    String requestId,
    String status, {
    Map<String, dynamic>? extra,
  }) async {
    await _api.patch('/service-requests/$requestId/status', body: {
      'status': status,
      if (extra != null) 'extra': extra,
      ...?extra,
    });
  }

  Future<void> deleteRequest(String requestId) async {
    await _api.delete('/service-requests/$requestId');
  }
}
