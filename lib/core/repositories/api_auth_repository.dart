import '../models/api_user.dart';
import '../services/api_client.dart';

class AuthRepository {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> requestOtp(String phone) async {
    final response = await _api.post(
      '/auth/request-otp',
      body: {'phone': phone},
      includeAuth: false,
    );
    return _api.unwrapData(response);
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
    String? verificationId,
    String? idToken,
  }) async {
    final body = <String, dynamic>{
      'phone': phone,
      'code': code,
    };
    if (verificationId != null) body['verificationId'] = verificationId;
    if (idToken != null) body['idToken'] = idToken;
    
    final response = await _api.post(
      '/auth/verify-otp',
      body: body,
      includeAuth: false,
    );
    return _api.unwrapData(response);
  }

  Future<Map<String, dynamic>> verifyFirebaseToken(String idToken) async {
    final response = await _api.post(
      '/auth/verify-firebase-token',
      body: {'idToken': idToken},
      includeAuth: false,
    );
    return _api.unwrapData(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
    required String governorate,
    String? city,
    String? region,
    String? placeType,
    String? profileImageUrl,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'phone': phone,
      'governorate': governorate,
    };
    if (email != null) body['email'] = email;
    if (city != null) body['city'] = city;
    if (region != null) body['region'] = region;
    if (placeType != null) body['placeType'] = placeType;
    if (profileImageUrl != null) body['profileImageUrl'] = profileImageUrl;
    
    final response = await _api.post(
      '/auth/register',
      body: body,
      includeAuth: false,
    );
    return _api.unwrapData(response);
  }

  Future<Map<String, dynamic>> registerTechnician({
    required String fullName,
    required String phone,
    String? experience,
    String? specialty,
    required String governorate,
    String? area,
    String? profileImageUrl,
  }) async {
    final body = <String, dynamic>{
      'fullName': fullName,
      'phone': phone,
      'governorate': governorate,
    };
    if (experience != null) body['experience'] = experience;
    if (specialty != null) body['specialty'] = specialty;
    if (area != null) body['area'] = area;
    if (profileImageUrl != null) body['profileImageUrl'] = profileImageUrl;
    
    final response = await _api.post(
      '/auth/technicians/register',
      body: body,
      includeAuth: false,
    );
    return _api.unwrapData(response);
  }

  Future<ApiUser> getMe() async {
    final response = await _api.get('/users/me');
    return ApiUser.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiUser>> getUsersByPhone(String phone) async {
    final response = await _api.get(
      '/users',
      queryParams: {'phone': phone},
    );
    final users = _api.unwrapList(response);
    return users.map((u) => ApiUser.fromJson(u)).toList();
  }

  Future<ApiUser> updateMe({
    String? name,
    String? email,
    String? governorate,
    String? city,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (governorate != null) body['governorate'] = governorate;
    if (city != null) body['city'] = city;
    
    final response = await _api.put('/users/me', body: body);
    return ApiUser.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiTechnician>> getTechnicians({String? phone}) async {
    final queryParams = <String, String>{};
    if (phone != null) queryParams['phone'] = phone;
    
    final response = await _api.get(
      '/technicians',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final technicians = _api.unwrapList(response);
    return technicians.map((t) => ApiTechnician.fromJson(t)).toList();
  }

  Future<ApiTechnician> getTechnicianByPhone(String phone) async {
    final response = await _api.get('/technicians/$phone');
    return ApiTechnician.fromJson(_api.unwrapData(response));
  }

  Future<ApiTechnician> updateTechnician(
    String phone, {
    String? fullName,
    String? specialty,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (specialty != null) body['specialty'] = specialty;
    
    final response = await _api.put('/technicians/$phone', body: body);
    return ApiTechnician.fromJson(_api.unwrapData(response));
  }

  Future<ApiTechnicianWallet> getTechnicianWallet(String phone) async {
    final response = await _api.get('/technicians/$phone/wallet');
    return ApiTechnicianWallet.fromJson(_api.unwrapData(response));
  }

  Future<void> logout() async {
    await _api.post('/auth/logout');
    await _api.clearAuth();
  }
}
