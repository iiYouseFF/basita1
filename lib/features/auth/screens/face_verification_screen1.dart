import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // مكتبة الكاميرا
import 'package:basita1/features/success/screens/success_screen1.dart'; // صفحة النجاح التالية

class FaceVerificationStepScreen1 extends StatefulWidget {
  const FaceVerificationStepScreen1({super.key});

  @override
  State<FaceVerificationStepScreen1> createState() =>
      _FaceVerificationStepScreenState();
}

class _FaceVerificationStepScreenState
    extends State<FaceVerificationStepScreen1> {
  // الألوان الأساسية المطابقة للتصميم
  static const Color primaryBlue = Color(0xFF0053AC); // الأزرق الأساسي
  static const Color backgroundLight = Color(0xFFF8FAFC); // لون الخلفية
  static const Color textDark = Color(0xFF1E293B); // لون النصوص الداكنة
  static const Color textMuted = Color(0xFF64748B); // لون النصوص الفرعية
  static const Color cardBg = Color(0xFFF8FAFC); // خلفية الكروت
  static const Color iconBgLight = Color(0xFFDBEAFE); // خلفية الأيقونات الفاتحة

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasCameraError = false;
  bool _isLoading = false; // متغير للتحكم في حالة التحميل أثناء الضغط على الزر

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  // دالة تهيئة الكاميرا الأمامية
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _hasCameraError = true);
        return;
      }

      // البحث عن الكاميرا الأمامية للتحقق من الوجه
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("خطأ في تشغيل الكاميرا: $e");
      if (mounted) {
        setState(() => _hasCameraError = true);
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // تحرير الكاميرا عند الخروج من الصفحة
    super.dispose();
  }

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

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen1()),
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
                // 1. شريط التقدم (الخطوة 3 من 3)
                _buildProgressBar(),
                const SizedBox(height: 28),

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
                    fontSize: 13,
                    height: 1.5,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 24),

                // 3. إطار مسح الوجه (الكاميرا الحية مع الأسهم والfallback)
                _buildFaceScannerArea(),
                const SizedBox(height: 28),

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
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 32),

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
            Icon(Icons.arrow_back, color: primaryBlue, size: 20),
            SizedBox(width: 6),
            Text(
              "التحقق من الهوية",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
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
                Expanded(flex: 100, child: Container(color: primaryBlue)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // منطقة إطار الوجه (عرض الكاميرا الحية أو الصورة الاحتياطية مع الأسهم الإرشادية)
  Widget _buildFaceScannerArea() {
    return SizedBox(
      height: 310,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. الإطار الدائري الأزرق المزود بالكاميرا/الصورة
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryBlue, width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(child: _buildCameraPreviewOrFallback()),
          ),

          // 2. مؤشر "للأعلى"
          Positioned(
            top: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: primaryBlue,
                  size: 22,
                ),
                Text(
                  "للأعلى",
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),

          // 3. مؤشر "يميناً"
          Positioned(
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "يميناً",
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: primaryBlue,
                  size: 14,
                ),
              ],
            ),
          ),

          // 4. مؤشر "يساراً"
          Positioned(
            left: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: primaryBlue,
                  size: 14,
                ),
                SizedBox(width: 2),
                Text(
                  "يساراً",
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // عرض فيديو الكاميرا المباشر أو الصورة الاحتياطية
  Widget _buildCameraPreviewOrFallback() {
    if (_isCameraInitialized &&
        !_hasCameraError &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      return SizedBox(
        width: 250,
        height: 250,
        child: AspectRatio(
          aspectRatio: _cameraController!.value.aspectRatio,
          child: CameraPreview(_cameraController!),
        ),
      );
    }

    // إذا لم تعمل الكاميرا يتم استدعاء الصورة الاحتياطية المسجلة
    return Image.asset(
      'assets/Scan Area.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFCBD5E1),
        child: const Icon(Icons.person, size: 110, color: Colors.white),
      ),
    );
  }

  Widget _buildInstructionCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: iconBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryBlue, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _startScan,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: primaryBlue.withValues(alpha: 0.7),
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
                        fontSize: 17,
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
