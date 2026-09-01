import 'package:flutter/material.dart';
// استورد الصفحات الخاصة بيك هنا:
import 'package:basita1/features/home/screens/home_screen.dart';
import 'package:basita1/features/profile/screens/profile_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  // الألوان الأساسية
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // ==========================================
            // 1. تصميم الخلفية المضيئة (Light Background Gradient)
            // ==========================================
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE4EDFA), // لون أزرق مائل للثلجي في الأعلى
                    Color(0xFFF8FAFC), // أبيض مائل للرمادي الفاتح في المنتصف
                    Color(0xFFF0F2F8), // لون رمادي/أرجواني فاتح جداً في الأسفل
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // ==========================================
            // 2. المحتوى الرئيسي داخل الكارت الأبيض
            // ==========================================
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // الكارت الأبيض الداخلي المنحني
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 28.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.06,
                                ), // ظل ناعم جداً يناسب الخلفية الفاتحة
                                blurRadius: 25,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // أيقونة مفتاح الربط الديكورية
                              const Positioned(
                                top: -8,
                                left: 8,
                                child: Icon(
                                  Icons.build_outlined,
                                  color: Color(0xFFD0E1FD),
                                  size: 28,
                                ),
                              ),
                              // أيقونة التوثيق الصغيرة الديكورية
                              const Positioned(
                                top: 120,
                                right: -4,
                                child: Icon(
                                  Icons.verified_outlined,
                                  color: Color(0xFFE5E7EB),
                                  size: 22,
                                ),
                              ),

                              // محتويات الكارت
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 12),

                                  // دائرة التحقق الزرقاء الكبيرة
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryBlue,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryBlue.withValues(
                                            alpha: 0.25,
                                          ),
                                          blurRadius: 16,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 70,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // عنوان التم التحقق بنجاح
                                  const Text(
                                    "تم التحقق بنجاح!",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // النص الوصفي
                                  const Text(
                                    "حسابك الآن قيد المراجعة، سنقوم بإشعارك فور تفعيله لتتمكن من استقبال الطلبات.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textGrey,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // مؤشر خطوط الحالة
                                  _buildProgressIndicators(),
                                  const SizedBox(height: 28),

                                  // ==========================================
                                  // زر الذهاب للرئيسية
                                  // ==========================================
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SimpleHomeScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      icon: const Icon(
                                        Icons.home_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      label: const Text(
                                        "الذهاب للرئيسية",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // ==========================================
                                  // رابط عرض ملفي الشخصي
                                  // ==========================================
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const UserProfileScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "عرض ملفي الشخصي",
                                      style: TextStyle(
                                        color: textGrey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // صورة فريق العمل
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/Overlay+Image.png', // تأكد من مسار الصورة لديك
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 130,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image_outlined,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // حقوق الملكية والتوثيق أسفل الكارت (لون رمادي ليناسب الخلفية الفاتحة)
                        const Text(
                          "نظام التحقق الذكي © Sanay3ya 2024",
                          style: TextStyle(color: textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء مؤشر الخطوط الزرقاء
  Widget _buildProgressIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLine(isActive: true),
        const SizedBox(width: 6),
        _buildLine(isActive: true),
        const SizedBox(width: 6),
        _buildLine(isActive: false, isSemiActive: true),
        const SizedBox(width: 6),
        _buildLine(isActive: false),
      ],
    );
  }

  Widget _buildLine({required bool isActive, bool isSemiActive = false}) {
    return Container(
      width: 42,
      height: 5,
      decoration: BoxDecoration(
        color: isActive
            ? primaryBlue
            : isSemiActive
            ? primaryBlue.withValues(alpha: 0.4)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// =========================================================================
// صفحات الانتقال
// =========================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الصفحة الرئيسية"),
          backgroundColor: const Color(0xFF0056D2),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "الصفحة الرئيسية",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الملف الشخصي"),
          backgroundColor: const Color(0xFF0056D2),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "صفحة الملف الشخصي",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
