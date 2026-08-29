import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // مكتبة التقاط الصور
import "face_verification_screen1.dart"; // تأكد من استيراد الصفحة التالية

class IdentityVerificationStepOne1 extends StatefulWidget {
  const IdentityVerificationStepOne1({super.key});

  @override
  State<IdentityVerificationStepOne1> createState() =>
      _IdentityVerificationStepOne1State();
}

class _IdentityVerificationStepOne1State
    extends State<IdentityVerificationStepOne1> {
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

  // متغير لحفظ الصورة الملتقطة
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // دالة لاختيار الصورة من الكاميرا أو المعرض
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85, // تقليل حجم الصورة قليلاً لتسريع الرفع
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("حدث خطأ أثناء اختيار الصورة: $e");
    }
  }

  // نافذة منبثقة لاختيار مصدر الصورة
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "اختر مصدر الصورة",
                  style: TextStyle(
                    color: textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: primaryBlue,
                  ),
                  title: const Text(
                    "التقاط صورة بالكاميرا",
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: primaryBlue,
                  ),
                  title: const Text(
                    "اختيار من معرض الصور",
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                // 1. مؤشر تقدم الخطوات العلوي
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

                // 3. صندوق رفع الصورة المتقطع مع شارة "مطلوب" (أصبح تفاعلياً)
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

                // 5. تعليمات تجنب التغطية
                _buildAvoidCoverageCard(),
                const SizedBox(height: 24),

                // 6. صورة المثال التوضيحي
                _buildExampleImageContainer(),
                const SizedBox(height: 32),

                // 7. زر "التالي"
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
              "الخطوة2 من 3",
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
            color: const Color(0xFFE2E8F0),
            child: Row(
              children: [
                Expanded(flex: 5, child: Container(color: primaryBlue)),
                Expanded(flex: 4, child: Container(color: Colors.transparent)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // صندوق رفع الملفات (تمت إضافة GestureDetector لدعم النقر وتعديله لعرض الصورة)
  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _showImageSourceDialog, // فتح خيارات الصورة عند النقر
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            painter: _DashedBorderPainter(
              color: const Color(0xFF94A3B8),
              strokeWidth: 1.5,
              gap: 5.0,
              radius: 16.0,
            ),
            child: Container(
              width: double.infinity,
              // إذا كان هناك صورة نجعل الـ Padding صفر لكي تملأ الصورة المكان
              padding: _imageFile != null
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _imageFile!,
                        width: double.infinity,
                        height: 180, // ارتفاع مناسب لعرض البطاقة
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
          // شارة "مطلوب" أو "تم الرفع"
          Positioned(
            top: -10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // تغيير لون الشارة للأخضر إذا تم رفع الصورة
                color: _imageFile != null ? Colors.green : requiredRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _imageFile != null ? "تم الرفع - إضغط للتعديل" : "مطلوب",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildNextButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // يمكن هنا إضافة شرط للتأكد من رفع الصورة قبل الانتقال
          // if (_imageFile == null) { /* إظهار رسالة خطأ */ return; }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FaceVerificationStepScreen1(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
          shadowColor: primaryBlue.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
