import 'package:flutter/material.dart';
import 'package:basita1/features/ai_assistant/screens/ai_screen.dart';
import 'package:basita1/features/home/screens/modern_design_app.dart';
import 'package:basita1/features/booking/screens/carpentry_booking_screen.dart';
import 'package:basita1/features/booking/screens/painting_booking_screen.dart';
import 'package:basita1/features/booking/screens/electrical_booking_screen.dart';
import 'package:basita1/features/booking/screens/plumbing_booking_screen.dart';

class ShatablyHomeScreen extends StatelessWidget {
  const ShatablyHomeScreen({super.key});

  // الألوان الأساسية المستوحاة من التصميم
  static const Color primaryBlue = Color(0xFF1A67D2);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color accentYellow = Color(0xFFFACC15);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تفعيل الـ RTL
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildPromoBanner(),
                const SizedBox(height: 24),
                _buildServicesSection(context), // 👈 تم تمرير context هنا
                const SizedBox(height: 24),
                _buildFeaturedCompaniesHeader(),
                const SizedBox(height: 16),
                _buildCompanyCard(
                  context: context,
                  name: "الشركة المتحدة للتشطيب",
                  rating: "4.9",
                  projectsCount: "+150 مشروع",
                  price: "2,500",
                  imageAsset: 'assets/Containerss.png',
                ),
                const SizedBox(height: 16),
                _buildCompanyCard(
                  context: context,
                  name: "رؤية للديكور والهندسة",
                  rating: "4.8",
                  projectsCount: "+210 مشروع",
                  price: "3,100",
                  imageAsset: 'assets/AB6AXU~2.PNG',
                  icon: Icons.home_work_outlined,
                ),
                const SizedBox(height: 16),
                _buildCompanyCard(
                  context: context,
                  name: "آرت لاين للتشطيبات",
                  rating: "4.7",
                  projectsCount: "85 مشروع",
                  price: "2,200",
                  imageAsset: 'assets/Containefr.png',
                  icon: Icons.format_paint_outlined,
                ),
                const SizedBox(height: 24),
                _buildAICalculatorBanner(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. شريط التطبيق العلوي (Header)
  // ==========================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2), size: 28),
        onPressed: () {
          Navigator.pop(context); // العودة للصفحة السابقة مباشرة
        },
      ),
      title: const Text(
        "شطبلي",
        style: TextStyle(
          color: primaryBlue,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          fontFamily: 'Cairo',
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD3E4F6), width: 2),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. شريط البحث
  // ==========================================
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: textMuted),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن شركة أو خدمة...",
                hintStyle: TextStyle(
                  color: textMuted,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            height: 40,
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "بحث",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. البانر الإعلاني (Hero Banner)
  // ==========================================
  Widget _buildPromoBanner() {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: AssetImage(
                'assets/7cc69e6e-62a0-43d5-9be2-5ffcb80d7490-ezremove.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "حصري",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "تشطيب بالتقسيط",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const Text(
                  "حول شقتك لبيت أحلامك\nبخطط سداد مرنة",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: primaryBlue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "ضمان حقيقي",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      "حتى 10 سنوات على كافة الأعمال",
                      style: TextStyle(
                        fontSize: 9,
                        color: textMuted,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4. قسم الخدمات الأساسية
  // ==========================================
  // 👈 تم التعديل هنا: تمرير context لتتمكن من استخدام Navigator
  Widget _buildServicesSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "الخدمات الأساسية",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
                fontFamily: 'Cairo',
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "عرض الكل",
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            // 👈 تم التعديل هنا: إضافة دالة onTap لكل خدمة مع تعليق الانتقال
            _buildServiceItem(
              "تشطيب كامل",
              Icons.home_repair_service_outlined,
              const Color(0xFFE0E7FF),
              primaryBlue,
              () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const CarpentryBookingScreen(),
                //   ),
                // );
              },
            ),
            _buildServiceItem(
              "دهانات",
              Icons.format_paint_outlined,
              const Color(0xFFF3E8FF),
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaintingBookingScreen(),
                  ),
                );
              },
            ),
            _buildServiceItem(
              "نجارة",
              Icons.handyman_outlined,
              const Color(0xFFFEF3C7),
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CarpentryBookingScreen(),
                  ),
                );
              },
            ),
            _buildServiceItem(
              "سباكة",
              Icons.plumbing_outlined,
              const Color(0xFFFFE4E6),
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlumbingBookingScreen(),
                  ),
                );
              },
            ),
            _buildServiceItem(
              "كهرباء",
              Icons.bolt_outlined,
              const Color(0xFFE0F2FE),
              Colors.lightBlue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ElectricalBookingScreen(),
                  ),
                );
              },
            ),
            _buildServiceItem(
              "ديكور",
              Icons.chair_outlined,
              const Color(0xFFF1F5F9),
              Colors.blueGrey,
              () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const DecorPage()));
              },
            ),
          ],
        ),
      ],
    );
  }

  // 👈 تم التعديل هنا: إضافة VoidCallback onTap لتفعيل الضغط على الأزرار
  Widget _buildServiceItem(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      // 👈 تغليفها بـ GestureDetector
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textDark,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 5. قسم الشركات المميزة
  // ==========================================
  Widget _buildFeaturedCompaniesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "شركات مميزة",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              "نخبة من أفضل شركات التشطيب الموثوقة",
              style: TextStyle(
                fontSize: 12,
                color: textMuted,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildNavArrow(Icons.arrow_forward_ios),
            const SizedBox(width: 8),
            _buildNavArrow(Icons.arrow_back_ios_new),
          ],
        ),
      ],
    );
  }

  Widget _buildNavArrow(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, size: 14, color: textDark),
    );
  }

  // تصميم كارت الشركة
  Widget _buildCompanyCard({
    required BuildContext context,
    required String name,
    required String rating,
    required String projectsCount,
    required String price,
    required String imageAsset,
    IconData icon = Icons.architecture,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // غلاف الشركة
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: AssetImage(imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentYellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "موثوقة",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // معلومات الشركة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: accentYellow,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            Text(
                              " ($projectsCount)",
                              style: const TextStyle(
                                color: textMuted,
                                fontSize: 12,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // السعر
                Row(
                  children: [
                    const Text(
                      "تبدأ الأسعار من   ",
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const Text(
                      " ج/م²",
                      style: TextStyle(
                        color: textDark,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // الأزرار
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Uncomment to navigate to Company Details Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ModernDesignPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "عرض التفاصيل",
                          style: TextStyle(
                            color: primaryBlue,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Uncomment to navigate to Booking Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ModernDesignPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          "احجز معاينة",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. بانر حاسبة الذكاء الاصطناعي
  // ==========================================
  Widget _buildAICalculatorBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB), // لون أزرق زاهي
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            "احسب تكلفة تشطيبك\nفي ثواني!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "استخدم تقنيات الذكاء الاصطناعي للحصول على تقدير دقيق لتكاليف التشطيب بناءً على مساحة شقتك والمواصفات المطلوبة.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontFamily: 'Cairo',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Uncomment to navigate to AI Calculator Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AiCalculatorScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "ابدأ الحساب الآن",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // شكل الأيقونة السفلية المزخرفة
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: Colors.white60,
                ), // أيقونة الذكاء الاصطناعي
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.circle, color: accentYellow, size: 8),
                        SizedBox(width: 4),
                        Text(
                          "دقة 99%",
                          style: TextStyle(
                            color: textDark,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.bolt, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "نتائج فورية",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
