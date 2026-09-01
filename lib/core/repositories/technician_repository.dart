import 'package:basita1/core/network/api_client.dart';

/// Real backend: GET /technicians, GET /technicians/:phone, PUT /technicians/:phone
/// Also GET /technicians/:phone/wallet
class TechnicianRepository {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>?> getTechnician(String phone) async {
    try {
      final res = await _api.get('/technicians/$phone');
      return (res['data'] as Map<String, dynamic>?) ?? res;
    } catch (_) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> watchTechnician(String phone) async* {
    yield await getTechnician(phone);
  }

  Future<void> createOrUpdateTechnician({
    required String phone,
    required Map<String, dynamic> data,
  }) async {
    await _api.put('/technicians/$phone', body: data);
  }

  Future<List<dynamic>> searchTechnicians({
    String? governorate,
    String? specialty,
  }) async {
    final res = await _api.get(
      '/technicians',
      query: {
        if (governorate != null) 'governorate': governorate,
        if (specialty != null) 'specialty': specialty,
      },
    );
    final d = res['data'];
    if (d is List) return d;
    if (d is Map && d['technicians'] is List) return d['technicians'];
    return [];
  }
}
