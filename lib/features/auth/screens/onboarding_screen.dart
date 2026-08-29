import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/search/screens/search_screen.dart';

// ==========================================
// 1. شاشة البداية (Onboarding Screen)
// ==========================================
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  // اللون الأزرق الأساسي المأخوذ من التصميم
  final Color primaryBlue = const Color(0xFF0C54BE);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لدعم اللغة العربية
      child: Scaffold(
        backgroundColor: primaryBlue, // لون الخلفية الأزرق
        body: SafeArea(
          bottom: false, // لكي ينزل الجزء الأبيض لآخر الشاشة من تحت
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. اللوجو (Frame 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset(
                  'assets/WhatsApp Image 2026-07-21 at 16.20.48.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),

              // 2. صورة الفنيين (Frame 4) - تأخذ المساحة المتبقية وتتوسط الشاشة
              Expanded(
                child: Image.asset(
                  'assets/or.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),

              // 3. الجزء الأبيض السفلي (النصوص والزر)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان الرئيسي
                    Text(
                      "خدمات منزلية تثق بها",
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // النص الفرعي
                    const Text(
                      "احجز فنيين معتمدين في دقائق. تجربة سريعة،\nآمنة، وموثوقة.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B), // لون رمادي
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // نقاط المؤشر (Dots Indicator)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(isActive: true), // النقطة الزرقاء النشطة
                        const SizedBox(width: 8),
                        _buildDot(isActive: false), // النقطة الرمادية
                      ],
                    ),
                    const SizedBox(height: 30),

                    // زر "ابدأ الان"
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          // الانتقال للصفحة الجديدة عند الضغط
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "ابدأ الان",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة صغيرة لرسم النقاط (Dots)
  Widget _buildDot({required bool isActive}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive
            ? primaryBlue
            : const Color(0xFFCBD5E1), // أزرق للنشط، رمادي فاتح لغير النشط
        shape: BoxShape.circle,
      ),
    );
  }
}

// ==========================================
// 2. الصفحة الجديدة (التي تفتح بعد الضغط على ابدأ الان)
// ==========================================
class NextScreen extends StatelessWidget {
  const NextScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الصفحة الرئيسية"),
          backgroundColor: const Color(0xFF0C54BE),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF0C54BE),
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                "أهلاً بك في تطبيق بسيطة!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "تم الانتقال بنجاح",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
