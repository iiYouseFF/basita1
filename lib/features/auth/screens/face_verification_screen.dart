import 'package:flutter/material.dart';
import 'package:basita1/features/success/screens/success_screen.dart'; // تأكد من وجود هذا الملف

class FaceVerificationStepScreen extends StatefulWidget {
  const FaceVerificationStepScreen({super.key});

  @override
  State<FaceVerificationStepScreen> createState() =>
      _FaceVerificationStepScreenState();
}

class _FaceVerificationStepScreenState
    extends State<FaceVerificationStepScreen> {
  // الألوان الأساسية المطابقة للتصميم
  static const Color primaryBlue = Color(0xFF0053AC); // الأزرق الأساسي
  static const Color backgroundLight = Color(0xFFF8FAFC); // لون الخلفية
  static const Color textDark = Color(0xFF1E293B); // لون النصوص الداكنة
  static const Color textMuted = Color(0xFF64748B); // لون النصوص الفرعية
  static const Color cardBg = Color(0xFFF8FAFC); // خلفية الكروت
  static const Color iconBgLight = Color(0xFFDBEAFE); // خلفية الأيقونات الفاتحة

  bool _isLoading = false; // متغير للتحكم في حالة التحميل

  // دالة زر بدء المسح
  void _startScan() async {
    setState(() {
      _isLoading = true; // تشغيل حالة التحميل
    });

    // محاكاة عملية الفحص (انتظار ثانيتين)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false; // إيقاف حالة التحميل
      });

      // TODO: قم بإزالة التعليق (Uncomment) عن الكود بالأسفل للانتقال لصفحتك

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SuccessScreen(),
        ), // ضع اسم صفحتك هنا
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // توجيه الواجهة بالكامل للغة العربية
      child: Scaffold(
        backgroundColor: backgroundLight,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. شريط التقدم (الخطوة 3 من 5)
                _buildProgressBar(),
                const SizedBox(height: 32),

                // 2. العناوين والنصوص الإرشادية
                const Text(
                  "التحقق من الوجه",
                  style: TextStyle(
                    color: textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "ضع وجهك داخل الإطار وقم بتحريك رأسك كما هو موضح لضمان\nجودة المسح",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 32),

                // 3. إطار مسح الوجه (الإطار الأزرق الثابت مع الأسهم)
                _buildFaceScannerArea(),
                const SizedBox(height: 32),

                // 4. كروت الإرشادات (إضاءة جيدة والمسافة المناسبة)
                _buildInstructionCard(
                  title: "إضاءة جيدة",
                  subtitle: "تأكد من تواجدك في مكان مضاء جيداً",
                  icon: Icons.light_mode_outlined,
                ),
                const SizedBox(height: 12),
                _buildInstructionCard(
                  title: "المسافة المناسبة",
                  subtitle: "أبق هاتفك على مستوى العين",
                  icon: Icons.location_on_outlined, // أقرب أيقونة للتصميم
                ),
                const SizedBox(height: 40),

                // 5. زر بدء المسح (مع دعم حالة التحميل)
                _buildScanButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================== أدوات بناء الواجهة (Widgets) ======================

  // شريط التطبيق العلوي (AppBar)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundLight,
      elevation: 0,
      leadingWidth: 160,
      leading: InkWell(
        onTap: () => Navigator.maybePop(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "التحقق من الهوية",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward, color: primaryBlue, size: 20),
          ],
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(left: 20.0, top: 14.0),
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

  // شريط التقدم التفاعلي (الخطوة 3 من 5)
  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "التحقق من الوجه",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              "الخطوة 3 من 3",
              style: TextStyle(
                color: textMuted,
                fontSize: 13,
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
                Expanded(
                  flex: 20, // يمثل الخطوة 3
                  child: Container(color: primaryBlue),
                ),
                Expanded(
                  flex: 0, // المتبقي من 5
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // منطقة إطار الوجه والأسهم
  Widget _buildFaceScannerArea() {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الإطار الدائري الأزرق الثابت للوجه
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryBlue,
                width: 3.5,
              ), // إطار أزرق ثابت
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/Scan Area.png', // مسار صورة الوجه (يفضل وضعها في مشروعك)
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // سهم ونص "للأعلى"

          // سهم ونص "يميناً"
        ],
      ),
    );
  }

  // كروت الإرشادات (إضاءة والمسافة)
  Widget _buildInstructionCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Row(
        children: [
          // النصوص (على اليمين)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // الأيقونة (على اليسار)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: iconBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryBlue, size: 24),
          ),
        ],
      ),
    );
  }

  // زر بدء المسح التفاعلي
  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        // تعطيل الزر أثناء التحميل لمنع التكرار
        onPressed: _isLoading ? null : _startScan,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: primaryBlue.withValues(
            alpha: 0.7,
          ), // لون الزر وهو معطل
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? Row(
                  key: const ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "جاري الفحص...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('idle'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.crop_free_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "بدء المسح",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
