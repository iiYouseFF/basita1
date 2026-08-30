import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:basita1/core/config/app_config.dart';
import 'package:basita1/core/repositories/auth_repository.dart';
import 'package:basita1/features/home/screens/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? verificationId;
  final int? resendToken;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.verificationId,
    this.resendToken,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final Color primaryBlue = const Color(0xFF0056D2);
  String otpCode = "";
  bool _isLoading = false;

  int _start = 58;
  Timer? _timer;
  bool _canResend = false;
  String? _verificationId;
  int? _resendToken;
  String? _errorMessage;
  final _authRepo = AuthRepository();

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _startTimer();
    if (!AppConfig.useMockOtp && _verificationId == null) {
      _sendCode();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _start = 58;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> _sendCode() async {
    try {
      setState(() => _errorMessage = null);
      final res = await _authRepo.requestOtp(phone: widget.phoneNumber);
      final vid = res['verificationId']?.toString();
      if (vid != null) {
        setState(() => _verificationId = vid);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['mock'] == true ? 'تم إرسال كود التحقق (Mock)' : 'تم إرسال كود التحقق عبر SMS'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'خطأ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إرسال الكود: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال كود التحقق كاملاً المكون من 6 أرقام'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Real backend: POST /auth/verify-otp {phone, code, verificationId}
      // Mock mode: any 6 digits passes (backend USE_MOCK_OTP=true)
      await _authRepo.verifyOtp(
        phone: widget.phoneNumber,
        code: otpCode,
        verificationId: _verificationId,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConfig.useMockOtp ? 'تم التحقق بنجاح! (Mock)' : 'تم التحقق بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String msg = e.toString().replaceAll('ApiException', '').replaceAll('Exception:', '').trim();
      // Map common errors to Arabic
      if (msg.contains('Invalid OTP') || msg.contains('401')) msg = 'كود التحقق غير صحيح';
      if (msg.contains('expired')) msg = 'انتهت صلاحية الكود، اطلب كوداً جديداً';
      setState(() => _errorMessage = msg);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "بسيطة",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withValues(alpha: 0.2),
                            spreadRadius: 10,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "التحقق من رقم الهاتف",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "أدخل الكود المكون من 6 أرقام المرسل إلى رقمك",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        widget.phoneNumber.isEmpty
                            ? "+20 101 **** 123"
                            : widget.phoneNumber,
                        style: TextStyle(
                          fontSize: 18,
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (AppConfig.useMockOtp)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bug_report,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Mock — أي 6 أرقام ينجح (api: basseeyta.duckdns.org)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (AppConfig.useMockOtp) const SizedBox(height: 12),
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyDecorationWith(
                          border: Border.all(color: primaryBlue, width: 2),
                        ),
                        onChanged: (value) {
                          otpCode = value;
                        },
                        onCompleted: (value) {
                          otpCode = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ستنتهي صلاحية الكود في: ",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "00:${_start.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _canResend
                          ? () {
                              _startTimer();
                              setState(() => _errorMessage = null);
                              _sendCode();
                            }
                          : null,
                      icon: Icon(
                        Icons.refresh,
                        size: 18,
                        color: _canResend ? primaryBlue : Colors.grey.shade400,
                      ),
                      label: Text(
                        "إعادة إرسال الكود",
                        style: TextStyle(
                          color: _canResend
                              ? primaryBlue
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "تحقق",
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.help_outline,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "تواجه مشكلة؟",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "تأكد من أن هاتفك متصل بالشبكة أو جرب تسجيل الدخول بطريقة أخرى.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: Text(
                "جميع الحقوق محفوظة لصالح Sanay3ya © 2024\napi: basseeyta.duckdns.org",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
