import 'package:flutter/material.dart';
import 'package:basita1/features/chat/screens/chat_screen.dart';
import 'package:basita1/features/technician/screens/technician_profile_screen.dart';
import 'package:basita1/features/technician/screens/technician_profile_screen2.dart';

// ==========================================
// 1. شاشة الفنيون الرئيسية
// ==========================================
class TechniciansScreen extends StatelessWidget {
  const TechniciansScreen({super.key});

  // الألوان الأساسية مأخوذة من التصميم
  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color bgLightBlue = Color(0xFFDBEAFE);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color greenVerified = Color(0xFF10B981);

  // دالة مساعدة للانتقال للشاشة الوهمية (أو شاشاتك الحقيقية لاحقاً)
  void _navigateTo(BuildContext context, String screenName) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => DummyScreen(title: screenName)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم كامل للغة العربية
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // لون خلفية التطبيق الفاتح
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. كارت فني الشهر المميز (Hero Image) باستخدام الصورة المحلية
                _buildHeroCard(context),
                const SizedBox(height: 16),

                // 2. بانر دليل المحترفين
                _buildProfessionalsBanner(context),
                const SizedBox(height: 24),

                // 3. عنوان قسم الأفضل تقييماً
                const Text(
                  "الأفضل تقييماً",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 16),

                // 4. قائمة الفنيين
                // ==========================================
                // كارت أحمد محمود
                // ==========================================
                _buildTechnicianCard(
                  context,
                  name: "أحمد محمود",
                  rating: "4.9",
                  reviewsCount: "(120 تقييم)",
                  experience: "10 سنوات خبرة",
                  completedRequests: "+500 طلب مكتمل",
                  location: "القاهرة، المعادي",
                  responseTime: "يرد خلال 30 دقيقة",
                  isVerified: true,
                  imageAssetPath:
                      'assets/Container (31).png', // المسار المحلي للصورة
                  onProfileTap: () {
                    // 💡 هنا تحط اسم كلاس الصفحة الخاصة بـ أحمد محمود 💡
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TechnicianProfileScreen1(), // صفحة أحمد
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ==========================================
                // كارت إبراهيم حسن
                // ==========================================
                _buildTechnicianCard(
                  context,
                  name: "إبراهيم حسن",
                  rating: "4.8",
                  reviewsCount: "(95 تقييم)",
                  experience: "15 سنة خبرة",
                  completedRequests: "+850 طلب مكتمل",
                  location: "الجيزة، الدقي",
                  responseTime: "يرد خلال 15 دقيقة",
                  isVerified: true,
                  imageAssetPath:
                      'assets/Image (33).png', // المسار المحلي للصورة
                  onProfileTap: () {
                    // 💡 هنا تحط اسم كلاس الصفحة الخاصة بـ إبراهيم حسن 💡
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TechnicianProfileScreen(), // صفحة إبراهيم
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24), // مسافة سفلية قبل الـ Nav Bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // أدوات بناء الواجهة (Widgets)
  // ==========================================

  // 1. شريط التطبيق العلوي (AppBar)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "الفنيون",
        style: TextStyle(
          color: Color.fromARGB(255, 4, 60, 116),
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          fontSize: 22,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2), size: 28),
        onPressed: () {
          Navigator.pop(context); // العودة للصفحة السابقة مباشرة
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: textDark),
          onPressed: () => _navigateTo(context, "البحث"),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: textDark),
          onPressed: () => _navigateTo(context, "الفلاتر"),
        ),
      ],
    );
  }

  // 2. كارت فني الشهر (الـ Hero)
  Widget _buildHeroCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateTo(context, "فني الشهر المميز"),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            // استخدام الصورة المحلية بدلاً من رابط الإنترنت
            image: AssetImage('assets/Overlay+Shadow (1).png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [],
          ),
        ),
      ),
    );
  }

  // 3. بانر دليل المحترفين
  Widget _buildProfessionalsBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateTo(context, "دليل المحترفين"),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgLightBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "دليل المحترفين",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "تواصل مع أكثر من ٥٠٠ فني سباكة معتمد في\nمنطقتك.",
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 13,
                fontFamily: 'Cairo',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStackedAvatars(),
                const SizedBox(width: 8),
                const Text(
                  "+١٥٠ متاح الآن",
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // دوائر الصور المتداخلة في البانر (باستخدام صور محلية)
  Widget _buildStackedAvatars() {
    return SizedBox(
      width: 70,
      height: 30,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: _buildMiniAvatar('assets/Container (13).png'),
          ),
          Positioned(
            right: 20,
            child: _buildMiniAvatar('assets/Container (14).png'),
          ),
          // كررت إحدى الصور كمثال لصورة ثالثة
          Positioned(
            right: 40,
            child: _buildMiniAvatar('assets/Container (13).png'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String assetPath) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: bgLightBlue, width: 2),
      ),
      child: CircleAvatar(
        radius: 12,
        backgroundImage: AssetImage(
          assetPath,
        ), // التعديل هنا لاستخدام AssetImage
      ),
    );
  }

  // 4. تصميم كارت الفني
  Widget _buildTechnicianCard(
    BuildContext context, {
    required String name,
    required String rating,
    required String reviewsCount,
    required String experience,
    required String completedRequests,
    required String location,
    required String responseTime,
    required bool isVerified,
    required String imageAssetPath, // مسار محلي للصورة
    required VoidCallback
    onProfileTap, // 👈 الإضافة الجديدة هنا: عشان كل فني يروح لصفحته
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الجزء العلوي: الصورة، الاسم، التقييم
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الفني مع علامة التوثيق
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(imageAssetPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isVerified)
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.verified,
                          color: greenVerified,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reviewsCount,
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
              ),
              // بادج معتمد
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "معتمد",
                  style: TextStyle(
                    color: greenVerified,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          // معلومات الخبرة والطلبات المكتملة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow(Icons.work_history_outlined, experience, textDark),
              _buildInfoRow(
                Icons.check_circle_outline,
                completedRequests,
                primaryBlue,
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          // وقت الاستجابة والمكان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow(Icons.bolt, responseTime, greenVerified),
              Text(
                location,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // الأزرار السفلية (عرض الملف + الرسائل)
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: primaryBlue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: primaryBlue,
                  ),
                  onPressed: () {
                    // 💡 يفضل هنا استخدام push بدل pushReplacement عشان اليوزر يقدر يرجع لصفحة الفنيين
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatMainPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onProfileTap, // 👈 استخدمنا الـ Parameter هنا
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    "عرض الملف الشخصي",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ويدجت مساعدة لصفوف المعلومات (الأيقونة + النص)
  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: textDark, fontSize: 12, fontFamily: 'Cairo'),
        ),
      ],
    );
  }
}
