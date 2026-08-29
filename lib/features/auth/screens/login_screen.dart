import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basita1/core/config/app_config.dart';
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

      String formatWithCountryAndZero = '+${countryCode}0$cleanNumber';
      String formatWithCountryNoZero = '+$countryCode$cleanNumber';
      String formatLocalWithZero = '0$cleanNumber';
      String formatLocalNoZero = cleanNumber;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'phone',
            whereIn: [
              formatWithCountryAndZero,
              formatWithCountryNoZero,
              formatLocalWithZero,
              formatLocalNoZero,
            ],
          )
          .get();

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        var data = userDoc.data();

        // حفظ في الجلسة المؤقتة
        UserSession.instance.saveUserData(
          name: data['name'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          governorate: data['governorate'] ?? '',
          city: data['city'] ?? '',
          region: data['region'] ?? '',
          placeType: data['placeType'] ?? '',
          profileImagePath: data['profileImagePath'],
        );

        // 👈 حفظ حالة الدخول + بياناتك بالكامل محلياً لكي لا تختفي أبداً
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userType', 'user');
        await prefs.setString('userName', data['name'] ?? '');
        await prefs.setString('userPhone', data['phone'] ?? '');
        await prefs.setString('userEmail', data['email'] ?? '');
        await prefs.setString('userGov', data['governorate'] ?? '');
        await prefs.setString('userCity', data['city'] ?? '');
        await prefs.setString('userRegion', data['region'] ?? '');
        await prefs.setString('userPlaceType', data['placeType'] ?? '');
        if (data['profileImagePath'] != null) {
          await prefs.setString('userImage', data['profileImagePath']);
        }

        String userName = data['name'] ?? 'مستخدم';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('أهلاً بك يا $userName، يرجى إدخال رمز التحقق'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        final normalizedPhone = normalizeEgyptPhone(
          data['phone'] ?? formatWithCountryNoZero,
        );

        if (AppConfig.useMockOtp) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(phoneNumber: normalizedPhone),
            ),
          );
        } else {
          // Real Firebase Phone Auth — set loading true until codeSent
          if (mounted) setState(() => _isLoading = true);
          try {
            await FirebaseAuth.instance.verifyPhoneNumber(
              phoneNumber: normalizedPhone.startsWith('+')
                  ? normalizedPhone
                  : '+2$normalizedPhone',
              verificationCompleted: (PhoneAuthCredential credential) async {
                try {
                  await FirebaseAuth.instance.signInWithCredential(credential);
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleHomeScreen(),
                    ),
                    (route) => false,
                  );
                } catch (_) {}
              },
              verificationFailed: (FirebaseAuthException e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? 'فشل إرسال كود التحقق'),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() => _isLoading = false);
              },
              codeSent: (String verificationId, int? resendToken) {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpScreen(
                      phoneNumber: normalizedPhone,
                      verificationId: verificationId,
                      resendToken: resendToken,
                    ),
                  ),
                );
                setState(() => _isLoading = false);
              },
              codeAutoRetrievalTimeout: (String verificationId) {},
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
            );
            setState(() => _isLoading = false);
          }
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رقم الهاتف غير مسجل لدينا، يرجى إنشاء حساب جديد'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
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
