import '../models/api_misc.dart';
import '../services/api_client.dart';

class VerificationRepository {
  final ApiClient _api = ApiClient();

  Future<ApiVerification> submitVerification({
    required String userId,
    required String name,
    required String phone,
    String? email,
    String? city,
    String? governorate,
    required String frontIdPath,
    required String backIdPath,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'name': name,
      'phone': phone,
      'frontIdPath': frontIdPath,
      'backIdPath': backIdPath,
    };
    if (email != null) body['email'] = email;
    if (city != null) body['city'] = city;
    if (governorate != null) body['governorate'] = governorate;
    
    final response = await _api.post('/verification', body: body);
    return ApiVerification.fromJson(_api.unwrapData(response));
  }

  Future<ApiVerification> getVerificationStatus(String userId) async {
    final response = await _api.get(
      '/verification',
      queryParams: {'userId': userId},
    );
    return ApiVerification.fromJson(_api.unwrapData(response));
  }

  Future<ApiVerification> updateVerificationStatus(
    String userId, {
    required String status,
    DateTime? reviewedAt,
  }) async {
    final body = <String, dynamic>{
      'status': status,
    };
    if (reviewedAt != null) body['reviewedAt'] = reviewedAt.toIso8601String();
    
    final response = await _api.patch('/verification/$userId', body: body);
    return ApiVerification.fromJson(_api.unwrapData(response));
  }
}
