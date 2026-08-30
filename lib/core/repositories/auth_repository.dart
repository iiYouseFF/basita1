import 'dart:convert';
import 'package:basita1/core/config/app_config.dart';
import 'package:basita1/core/network/api_client.dart';
import 'package:basita1/core/session/auth_session.dart';

/// Real auth against Node.js backend at http://basseeyta.duckdns.org
/// GitHub: https://github.com/iiYouseFF/basseeyta
/// Docs: http://basseeyta.duckdns.org/api-docs.json
class AuthRepository {
  final ApiClient _api = ApiClient();

  /// POST /auth/request-otp  {phone} → {verificationId, expiresIn, mock}
  Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    final res = await _api.post('/auth/request-otp', body: {'phone': phone});
    // res is {success:true, data:{verificationId, expiresIn, mock}, message}
    return (res['data'] as Map<String, dynamic>?) ?? res;
  }

  /// POST /auth/verify-otp  {phone, code, verificationId?} → {token, user}
  /// Mock mode accepts any 6 digits when backend USE_MOCK_OTP=true.
  /// When backend is in prod (mock:false), fallback to local mock if AppConfig.useMockOtp==true.
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
    String? verificationId,
  }) async {
    try {
      final res = await _api.post('/auth/verify-otp', body: {
        'phone': phone,
        'code': code,
        if (verificationId != null) 'verificationId': verificationId,
      });
      final data = (res['data'] as Map<String, dynamic>?) ?? res;
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      if (token != null) {
        await AuthSession.instance.save(
          token: token,
          userId: user?['id']?.toString() ?? user?['phone']?.toString(),
          phone: user?['phone']?.toString() ?? phone,
          userType: user?['userType']?.toString() ?? 'user',
        );
      }
      return data;
    } on ApiException catch (e) {
      // Fallback for dev: backend is in prod mode (mock:false) but Flutter is in mock mode
      if (AppConfig.useMockOtp && e.statusCode == 401 && RegExp(r'^\d{6}$').hasMatch(code)) {
        // Generate local mock token so UI can proceed; real API calls will work for public GETs,
        // but protected POSTs will still fail until backend USE_MOCK_OTP=true — user should set it.
        final mockToken = base64Url.encode(utf8.encode('mock:$phone:${DateTime.now().millisecondsSinceEpoch}'));
        final mockUser = {'id': 'mock_${phone.hashCode}', 'phone': phone, 'userType': 'user'};
        await AuthSession.instance.save(token: mockToken, userId: mockUser['id'], phone: phone, userType: 'user');
        return {'token': mockToken, 'user': mockUser, 'mockFallback': true, 'backendError': e.message};
      }
      rethrow;
    }
  }

  /// POST /auth/register (customer)
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
    final res = await _api.post('/auth/register', body: {
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      'governorate': governorate,
      if (city != null) 'city': city,
      if (region != null) 'region': region,
      if (placeType != null) 'placeType': placeType,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    });
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final token = data['token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    if (token != null) {
      await AuthSession.instance.save(
        token: token,
        userId: user?['id']?.toString(),
        phone: user?['phone']?.toString() ?? phone,
        userType: 'user',
      );
    }
    return data;
  }

  /// POST /auth/technicians/register
  Future<Map<String, dynamic>> registerTechnician({
    required String fullName,
    required String phone,
    String? experience,
    String? specialty,
    required String governorate,
    String? area,
    String? profileImageUrl,
  }) async {
    final res = await _api.post('/auth/technicians/register', body: {
      'fullName': fullName,
      'phone': phone,
      if (experience != null) 'experience': experience,
      if (specialty != null) 'specialty': specialty,
      'governorate': governorate,
      if (area != null) 'area': area,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    });
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final token = data['token'] as String?;
    final tech = (data['technician'] as Map<String, dynamic>?) ?? data['user'] as Map<String, dynamic>?;
    if (token != null) {
      await AuthSession.instance.save(
        token: token,
        userId: tech?['phone']?.toString() ?? phone,
        phone: tech?['phone']?.toString() ?? phone,
        userType: 'technician',
      );
    }
    return data;
  }

  /// GET /users/me
  Future<Map<String, dynamic>> getMe() async {
    final res = await _api.get('/users/me');
    return (res['data'] as Map<String, dynamic>?) ?? res;
  }

  /// GET /users?phone=
  Future<List<dynamic>> lookupUsersByPhone(String phone) async {
    final res = await _api.get('/users', query: {'phone': phone});
    final data = res['data'];
    if (data is List) return data;
    if (data is Map && data['users'] is List) return data['users'] as List;
    return [];
  }

  /// GET /technicians?phone=
  Future<List<dynamic>> lookupTechniciansByPhone(String phone) async {
    final res = await _api.get('/technicians', query: {'phone': phone});
    final data = res['data'];
    if (data is List) return data;
    if (data is Map && data['technicians'] is List) return data['technicians'] as List;
    return [];
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', body: {});
    } catch (_) {}
    await AuthSession.instance.clear();
  }
}
