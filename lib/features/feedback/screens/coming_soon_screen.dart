import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 👈 قم باستيراد صفحة الرئيسية الخاصة بك هنا
import 'package:basita1/features/home/screens/home_screen.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  // الألوان الأساسية الخاصة بالهوية
  final Color primaryBlue = const Color(0xFF005CEE);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);
  final Color badgeBg = const Color(0xFFEBF3FF);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          // زر الرجوع في جهة اليمين (جهة الـ Leading في وضع الـ RTL)
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back, // سهم يتجه لليمين في وضع RTL
              color: primaryBlue,
              size: 26,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "الخدمة قريباً",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),

                        // 1. الصورة الخاصة بالتصميم
                        Image.asset(
                          'assets/Illustration.png', // 👈 التأكد من إضافة الصورة في ملف pubspec.yaml
                          height: 260,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 32),

                        // 2. كبسولة الشعار "قريباً"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "قريباً",
                            style: GoogleFonts.cairo(
                              color: primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 3. العنوان الرئيسي
                        Text(
                          "الخدمة دي هتتوفر قريب",
                          style: GoogleFonts.cairo(
                            color: textDark,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // 4. النص الفرعي
                        Text(
                          "نعمل حاليًا على تجهيز الخدمة لتقديم تجربة بسيطة وموثوقة.",
                          style: GoogleFonts.cairo(
                            color: textGrey,
                            fontSize: 15,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // 5. زر الانتقال إلى الصفحة الرئيسية
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // =========================================================
                        // 👈 استبدل SimpleHomeScreen() باسم الكلاس الخاص بصفحتك الرئيسية
                        // =========================================================

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SimpleHomeScreen(),
                          ),
                          (route) => false,
                        );

                        // مؤقتاً يقوم بالرجوع للصفحة السابقة لحين وضع الشاشة الخاصة بك
                        // Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        "الصفحة الرئيسية",
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
