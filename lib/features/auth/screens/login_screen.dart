import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basita1/core/repositories/auth_repository.dart';
import 'package:basita1/features/auth/screens/otp_screen.dart';
import 'package:basita1/features/home/screens/home_screen.dart';
import 'package:basita1/core/session/user_session.dart';
import 'package:basita1/core/utils/phone_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color primaryBlue = const Color(0xFF0056D2);
  String rawPhoneDigits = "";
  String countryCode = "20";
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _authRepo = AuthRepository();

  Future<void> _checkPhoneNumberInFirestore() async {
    bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || rawPhoneDigits.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم هاتف صحيح أولاً'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String cleanNumber = rawPhoneDigits.trim();
      if (cleanNumber.startsWith('0')) {
        cleanNumber = cleanNumber.substring(1);
      }
      final rawPhone = '+$countryCode$cleanNumber';
      final normalizedPhone = normalizeEgyptPhone(rawPhone);

      // Check existence via Node API: GET /users?phone= and /technicians?phone=
      bool exists = false;
      Map<String, dynamic>? userData;
      try {
        final users = await _authRepo.lookupUsersByPhone(normalizedPhone);
        if (users.isNotEmpty) {
          exists = true;
          userData = Map<String, dynamic>.from(users.first as Map);
        } else {
          final techs = await _authRepo.lookupTechniciansByPhone(
            normalizedPhone,
          );
          if (techs.isNotEmpty) {
            exists = true;
            final t = Map<String, dynamic>.from(techs.first as Map);
            // Normalize technician shape to user shape
            userData = {
              'name': t['fullName'] ?? t['name'] ?? '',
              'phone': t['phone'] ?? normalizedPhone,
              'email': t['email'] ?? '',
              'governorate': t['governorate'] ?? '',
              'city': t['city'] ?? '',
              'region': t['area'] ?? t['region'] ?? '',
              'placeType': t['placeType'] ?? '',
              'profileImagePath': t['profileImageUrl'] ?? t['profileImagePath'],
            };
          }
        }
      } catch (_) {
        // If lookup fails, allow OTP anyway (backend will handle)
        exists = true;
      }

      if (!exists || userData == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رقم الهاتف غير مسجل لدينا، يرجى إنشاء حساب جديد'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Save to session
      UserSession.instance.saveUserData(
        name: userData['name'] ?? '',
        phone: userData['phone'] ?? normalizedPhone,
        email: userData['email'] ?? '',
        governorate: userData['governorate'] ?? '',
        city: userData['city'] ?? '',
        region: userData['region'] ?? '',
        placeType: userData['placeType'] ?? '',
        profileImagePath: userData['profileImagePath'],
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userType', 'user');
      await prefs.setString('userName', userData['name'] ?? '');
      await prefs.setString('userPhone', userData['phone'] ?? normalizedPhone);
      await prefs.setString('userEmail', userData['email'] ?? '');
      await prefs.setString('userGov', userData['governorate'] ?? '');
      await prefs.setString('userCity', userData['city'] ?? '');
      await prefs.setString('userRegion', userData['region'] ?? '');
      await prefs.setString('userPlaceType', userData['placeType'] ?? '');
      if (userData['profileImagePath'] != null) {
        await prefs.setString('userImage', userData['profileImagePath']);
      }

      // Request OTP via Node API: POST /auth/request-otp
      String? verificationId;
      try {
        final otpRes = await _authRepo.requestOtp(phone: normalizedPhone);
        verificationId = otpRes['verificationId']?.toString();
      } catch (e) {
        // Even if request-otp fails, still allow mock OTP flow in dev
        debugPrint('[Login] request-otp failed: $e');
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'أهلاً بك يا ${userData['name'] ?? 'مستخدم'}، يرجى إدخال رمز التحقق',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            phoneNumber: normalizedPhone,
            verificationId: verificationId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء التحقق: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Image.asset(
                      'assets/Gemini_Generated_Image_rlqvx4rlqvx4rlqv (1).png',
                      height: 40,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "مرحباً بك",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "سجل دخولك للمتابعة",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      counterText: "",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    initialCountryCode: 'EG',
                    invalidNumberMessage: 'رقم الهاتف غير صحيح',
                    validator: (phone) {
                      if (phone == null || phone.number.trim().isEmpty) {
                        return 'يرجى كتابة رقم الهاتف';
                      }
                      return null;
                    },
                    onChanged: (phone) {
                      rawPhoneDigits = phone.number;
                      countryCode = phone.countryCode;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _checkPhoneNumberInFirestore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "التحقق من الحساب",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "أو سجل بواسطة",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIconButton(Icons.facebook),
                      const SizedBox(width: 15),
                      _buildSocialIconButton(Icons.apple),
                      const SizedBox(width: 15),
                      _buildSocialIconButton(Icons.g_mobiledata),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "بالاستمرار، أنت توافق على شروط الخدمة وسياسة الخصوصية الخاصة بـ بسيطة.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton(IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: Colors.black, size: 30),
      ),
    );
  }
}
