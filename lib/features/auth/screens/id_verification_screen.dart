import 'package:flutter/material.dart';
import "face_verification_screen.dart"; // تأكد من استيراد الصفحة التالية

class IdentityVerificationStepOne extends StatelessWidget {
  const IdentityVerificationStepOne({super.key});

  // الألوان الرسمية المطابقة للصور المرفقة بدقة عالية
  static const Color primaryBlue = Color(
    0xFF0053AC,
  ); // الأزرق الملكي الأساسي للتطبيق
  static const Color backgroundLight = Color(
    0xFFF8FAFC,
  ); // خلفية الصفحة الفاتحة
  static const Color textDark = Color(
    0xFF1E293B,
  ); // لون النصوص الأساسية والروابط
  static const Color textMuted = Color(
    0xFF64748B,
  ); // لون النصوص الفرعية والتوضيحية
  static const Color requiredRed = Color(
    0xFFC01C1C,
  ); // لون شارة "مطلوب" الحمراء
  static const Color lightRedBg = Color(
    0xFFFEE2E2,
  ); // خلفية أيقونة تجنب التغطية الحمراء الفاتحة
  static const Color cardBg = Color(0xFFF8FAFC); // لون خلفية البطاقات الإرشادية

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection
          .rtl, // دعم التوجيه العربي بالكامل لتتطابق الواجهة مع الصور
      child: Scaffold(
        backgroundColor: backgroundLight,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. مؤشر تقدم الخطوات العلوي (الخطوة 1 من 5 - 20% مكتمل)
                _buildProgressBar(),
                const SizedBox(height: 28),

                // 2. ترويسة الصفحة (العنوان الرئيسي والفرعي)
                const Text(
                  "توثيق الهوية - الخطوة 1",
                  style: TextStyle(
                    color: textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "يرجى رفع صورة واضحة لوجه بطاقة الرقم القومي",
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 24),

                // 3. صندوق رفع الصورة المتقطع مع شارة "مطلوب"
                _buildUploadArea(),
                const SizedBox(height: 18),

                // 4. التعليمات الإرشادية (إضاءة جيدة & تركيز واضح)
                Row(
                  children: [
                    Expanded(
                      child: _buildGuidelineCard(
                        icon: Icons.light_mode_outlined,
                        title: "إضاءة جيدة",
                        description: "تأكد من وجود إضاءة كافية دون انعكاسات.",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGuidelineCard(
                        icon: Icons.filter_center_focus_rounded,
                        title: "تركيز واضح",
                        description: "يجب أن تكون جميع البيانات مقروءة بوضوح.",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. تعليمات تجنب التغطية (العرض الكامل للبطاقة)
                _buildAvoidCoverageCard(),
                const SizedBox(height: 24),

                // 6. صورة المثال التوضيحي (مثال للصورة الصحيحة)
                _buildExampleImageContainer(),
                const SizedBox(height: 32),

                // 7. زر "التالي" المصمت مع السهم المتجه لليسار ونظام الانتقال المحفوظ
                _buildNextButton(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =================== أشرطة وأدوات الواجهة المستقلة ===================

  // شريط التطبيق العلوي (بسيطة وزر العودة)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: primaryBlue, size: 26),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(left: 20.0, top: 12.0),
          child: Text(
            "بسيطة",
            style: TextStyle(
              color: primaryBlue,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }

  // شريط التقدم التفاعلي العلوي (الخطوة 1 من 5)
  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "60% مكتمل",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              "الخطوة 2 من 3",
              style: TextStyle(
                color: textMuted,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 6,
            width: double.infinity,
            color: const Color(0xFFE2E8F0), // الخلفية الرمادية الفاتحة للشريط
            child: Row(
              children: [
                Expanded(
                  flex: 5, // تمثل الـ 20%
                  child: Container(color: primaryBlue),
                ),
                Expanded(
                  flex: 4, // المتبقي من الـ 100%
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // صندوق رفع الملفات ذو الإطار المقطع وشارة المطلوب
  Widget _buildUploadArea() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFF94A3B8), // لون الإطار المتقطع المعتمد
            strokeWidth: 1.5,
            gap: 5.0,
            radius: 16.0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة الكاميرا والزائد الزرقاء
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "إضغط لالتقاط الصورة",
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "أو اسحب الملف هنا",
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
        // شارة "مطلوب" الحمراء في الزاوية العلوية اليمنى
        Positioned(
          top: -10,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: requiredRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "مطلوب",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // بناء كروت الإرشادات (إضاءة جيدة / تركيز واضح)
  Widget _buildGuidelineCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      height: 120,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, color: primaryBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: textDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: textMuted,
                fontSize: 10,
                height: 1.4,
                fontFamily: 'Cairo',
              ),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  // كرت تجنب التغطية بإصبعك أو بظل
  Widget _buildAvoidCoverageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "تجنب التغطية",
                  style: TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "لا تغط أي جزء من البطاقة بإصبعك أو بظل.",
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // أيقونة منع التصوير الحمراء الفاتحة
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightRedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.no_photography_outlined,
              color: Color(0xFFDC2626),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // صندوق عرض المثال التوضيحي الصحيح للصورة
  Widget _buildExampleImageContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // محاولة جلب الصورة التوضيحية محلياً مع توفير بديل ذكي في حال لم تضف بعد
            Image.asset(
              'assets/Border.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image_outlined, color: textMuted, size: 40),
                      SizedBox(height: 4),
                      Text(
                        "[صورة الهاتف والبطاقة التوضيحية]",
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // لوحة التوضيح العائمة في منتصف الصورة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "مثال للصورة الصحيحة",
                style: TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // زر "التالي" المخصص بالكامل مع ميزة الانتقال المعلق بـ Comment
  Widget _buildNextButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // TODO: الانتقال إلى صفحة الخطوة التالية التي قمت بإنشائها
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FaceVerificationStepScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              30,
            ), // مظهر الحبة البيضاوي الأنيق للتطبيق
          ),
          elevation: 3,
          shadowColor: primaryBlue.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // السهم المتجه لليسار والموجود في الصور
            Icon(Icons.arrow_back, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "التالي",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== رسام الإطار المتقطع المخصص (Custom Painter) ===================
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double end = distance + gap;
        canvas.drawPath(
          pathMetric.extractPath(
            distance,
            end < pathMetric.length ? end : pathMetric.length,
          ),
          paint,
        );
        distance += gap * 2.0;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
