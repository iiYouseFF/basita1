import 'package:flutter/material.dart';
import 'package:basita1/features/booking/screens/appliances_screen.dart';

// ==========================================
// 1. الشاشة الرئيسية (تأمين المنزل)
// ==========================================
class HomeInsuranceScreen extends StatelessWidget {
  const HomeInsuranceScreen({super.key});

  // ألوان التطبيق الأساسية مأخوذة من التصميم
  static const Color primaryBlue = Color(0xFF0053AC);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  // دالة مساعدة للانتقال لأي شاشة
  // void _navigateTo(BuildContext context, String screenName) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => DummyScreen(title: screenName)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم اللغة العربية بشكل كامل
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. كارت حالة التأمين الحالي (الأزرق)
                _buildCurrentInsuranceCard(context),
                const SizedBox(height: 16),

                // 2. كارت مركز المطالبات
                _buildClaimsCenterCard(context),
                const SizedBox(height: 24),

                // 3. قسم خطط التأمين
                _buildSectionHeader(
                  title: "خطط التأمين",
                  actionText: "عرض الكل",
                  onActionTap: () => (context, "جميع خطط التأمين"),
                ),
                const SizedBox(height: 16),
                _buildInsurancePlansList(context),
                const SizedBox(height: 32),

                // 4. قسم المزايا الحصرية
                const Text(
                  "مزاياك الحصرية",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 16),
                _buildBenefitsGrid(context),
                const SizedBox(height: 24),

                // 5. كارت التواصل والاستفسار
                _buildContactCard(context),
                const SizedBox(height: 20),
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

  // شريط التطبيق العلوي (AppBar)
 PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "تأمين المنزل",
        style: TextStyle(
          color: primaryBlue, // تأكد من تعريف هذا المتغير في ملفك
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          fontSize: 22,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      // تم إزالة الـ actions من هنا
    );
  }

  // الكارت الأزرق الرئيسي (حالة التأمين)
  Widget _buildCurrentInsuranceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "حالة التأمين الحالي",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399), // أخضر
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "محمي",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "نشط - الخطة البريميوم",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "رقم البوليصة: #88902-BS",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "تاريخ الانتهاء: 12 أكتوبر 2024",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 16,
                ),
                label: const Text(
                  "البطاقة الرقمية",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // كارت مركز المطالبات
  Widget _buildClaimsCenterCard(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_late_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "مركز المطالبات",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    "هل تحتاج إلى مساعدة فورية أو فتح شكوى؟",
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: primaryBlue, size: 18),
          ],
        ),
      ),
    );
  }

  // رأس القسم (عنوان + زرار)
  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
            fontFamily: 'Cairo',
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 14,
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }

  // قائمة خطط التأمين (التمرير الأفقي)
  Widget _buildInsurancePlansList(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildPlanCard(
            context,
            planName: "أساسي",
            price: "150",
            isActive: false,
            features: [
              {"text": "تغطية السباكة والكهرباء", "included": true},
              {"text": "استجابة خلال 24 ساعة", "included": true},
              {"text": "تغطية الأجهزة المنزلية", "included": false},
            ],
          ),
          const SizedBox(width: 16),
          // جزء من الكارت الثاني ليطابق التصميم (شكل البريميوم)
          _buildPlanCard(
            context,
            planName: "بريميوم",
            price: "350",
            isActive: true,
            features: [
              {"text": "تغطية شاملة لكل شيء", "included": true},
              {"text": "استجابة فورية", "included": true},
              {"text": "تغطية الأجهزة المنزلية", "included": true},
            ],
          ),
        ],
      ),
    );
  }

  // تصميم كارت الخطة الفردي
  Widget _buildPlanCard(
    BuildContext context, {
    required String planName,
    required String price,
    required bool isActive,
    required List<Map<String, dynamic>> features,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? primaryBlue : Colors.grey.shade300,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? primaryBlue.withValues(alpha: 0.1)
                  : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              planName,
              style: TextStyle(
                color: isActive ? primaryBlue : const Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Cairo',
                ),
              ),
              const Text(
                " ج.م",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Cairo',
                ),
              ),
              const Text(
                "/شهريا",
                style: TextStyle(
                  fontSize: 12,
                  color: textMuted,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(
                    feature["included"]
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: feature["included"]
                        ? const Color(0xFF10B981)
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature["text"],
                    style: TextStyle(
                      fontSize: 13,
                      color: feature["included"] ? textDark : Colors.grey,
                      decoration: feature["included"]
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAppliancesScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: isActive ? primaryBlue : Colors.transparent,
              ),
              child: const Text(
                "انتقال",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ), // أو أي محتوى للزر
            ),
          ),
        ],
      ),
    );
  }

  // شبكة المزايا الحصرية
  Widget _buildBenefitsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      children: [
        _buildBenefitCard(
          context,
          title: "استجابة طوارئ",
          subtitle: "فريق مخصص للتدخل السريع في حالات الأعطال الحرجة.",
          icon: Icons.bolt,
          iconBgColor: const Color(0xFFD1FAE5),
          iconColor: const Color(0xFF059669),
        ),
        _buildBenefitCard(
          context,
          title: "فنيون ذو أولوية",
          subtitle: "وصول أسرع لأفضل الفنيين المعتمدين في منطقتك.",
          icon: Icons.engineering,
          iconBgColor: const Color(0xFFDBEAFE),
          iconColor: primaryBlue,
        ),
        _buildBenefitCard(
          context,
          title: "تغطية أجهزة",
          subtitle: "حماية أجهزتك الكهربائية من تقلبات التيار المفاجئة.",
          icon: Icons.shield_outlined,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
        ),
        _buildBenefitCard(
          context,
          title: "تمديد ضمان",
          subtitle: "نضمن لك قطع الغيار والإصلاحات لمدة 6 أشهر إضافية.",
          icon: Icons.verified_outlined,
          iconBgColor: const Color(0xFFE2E8F0),
          iconColor: const Color(0xFF475569),
        ),
      ],
    );
  }

  // كارت الميزة الواحدة (يدعم الضغط للذهاب لتفاصيل الميزة)
  Widget _buildBenefitCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textDark,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: textMuted,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // كارت التواصل في الأسفل
  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "هل لديك استفسار؟",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textDark,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "تحدث مع مستشار التأمين الخاص بك الآن للحصول على أفضل نصيحة.",
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "تواصل",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. شاشة وهمية (Dummy Screen) للانتقالات
// ==========================================
// سيتم فتح هذه الشاشة عند الضغط على أي زر، قم باستبدالها بشاشاتك الحقيقية لاحقاً.
class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: const Color(0xFF0066CC),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "أنت الآن في شاشة:\n$title",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "العودة للصفحة الرئيسية",
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
