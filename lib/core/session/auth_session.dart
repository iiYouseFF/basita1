import 'package:shared_preferences/shared_preferences.dart';

/// JWT session for the external Node.js backend (http://basseeyta.duckdns.org).
/// Persists token + userId/phone after OTP verify.
/// Used by ApiClient to attach Authorization header.
class AuthSession {
  static final AuthSession _instance = AuthSession._internal();
  factory AuthSession() => _instance;
  AuthSession._internal();

  static AuthSession get instance => _instance;

  String? _token;
  String? _userId;
  String? _phone;
  String? _userType; // 'user' | 'technician'

  String? get token => _token;
  String? get userId => _userId;
  String? get phone => _phone;
  String? get userType => _userType;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// Load from SharedPreferences on app start
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('auth_userId');
    _phone = prefs.getString('auth_phone');
    _userType = prefs.getString('auth_userType');
  }

  /// Save after successful OTP verify / register
  Future<void> save({
    required String token,
    String? userId,
    String? phone,
    String? userType,
  }) async {
    _token = token;
    if (userId != null) _userId = userId;
    if (phone != null) _phone = phone;
    if (userType != null) _userType = userType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    if (_userId != null) await prefs.setString('auth_userId', _userId!);
    if (_phone != null) await prefs.setString('auth_phone', _phone!);
    if (_userType != null) await prefs.setString('auth_userType', _userType!);
  }

  Future<void> clear() async {
    _token = null;
    _userId = null;
    _phone = null;
    _userType = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_userId');
    await prefs.remove('auth_phone');
    await prefs.remove('auth_userType');
  }

  Map<String, String> get authHeader => _token != null && _token!.isNotEmpty
      ? {'Authorization': 'Bearer $_token'}
      : {};
}
