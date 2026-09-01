import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
// removed: cloud_firestore - see docs/backend-prd.html
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basita1/features/auth/screens/otp_screen1.dart';
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/core/network/mock_backend.dart';

class LoginScreen1 extends StatefulWidget {
  const LoginScreen1({super.key});

  @override
  State<LoginScreen1> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen1> {
  final Color primaryBlue = const Color(0xFF0056D2);
  String phoneNumber = "";
  String rawNumber = "";
  String countryCode = "";
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || phoneNumber.trim().isEmpty) {
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
      String cleanNumber = rawNumber.startsWith('0')
          ? rawNumber.substring(1)
          : rawNumber;
      String numberZero = '0$cleanNumber';

      List<String> possibleFormats = [
        countryCode + cleanNumber,
        countryCode + numberZero,
        cleanNumber,
        numberZero,
      ];

      var querySnapshot = await MockFirestore.collection(
        'technicians',
      ).where('phone', whereIn: possibleFormats).get();

      if (!mounted) return;

      if (querySnapshot.docs.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هذا الرقم غير مسجل لدينا، يرجى التأكد من الرقم'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      var userData = querySnapshot.docs.first.data();

      UserDataSession.saveUserData(
        name: userData['fullName'] ?? '',
        phoneNumber: userData['phone'] ?? '',
        exp: userData['experience'] ?? '',
        spec: userData['specialty'] ?? '',
        gov: userData['governorate'] ?? '',
        ar: userData['area'] ?? '',
        imagePath: userData['profileImagePath'] ?? '',
      );

      // 👈 حفظ بيانات الفني محلياً
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userType', 'technician');
      await prefs.setString('techName', userData['fullName'] ?? '');
      await prefs.setString('techPhone', userData['phone'] ?? '');
      await prefs.setString('techExp', userData['experience'] ?? '');
      await prefs.setString('techSpec', userData['specialty'] ?? '');
      await prefs.setString('techGov', userData['governorate'] ?? '');
      await prefs.setString('techArea', userData['area'] ?? '');
      if (userData['profileImagePath'] != null) {
        await prefs.setString('techImage', userData['profileImagePath']);
      }

      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OtpScreen1(phoneNumber: countryCode + cleanNumber),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في الاتصال بقاعدة البيانات. حاول مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "مرحباً بك ",
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
                    rawNumber = phone.number;
                    countryCode = phone.countryCode;
                    phoneNumber = phone.completeNumber;
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                              Icon(Icons.arrow_back, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                "إرسال كود التحقق",
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
