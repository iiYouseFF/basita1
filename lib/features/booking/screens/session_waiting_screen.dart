import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/booking/screens/consultation_ready_screen.dart';

class SessionWaitingScreen extends StatefulWidget {
  const SessionWaitingScreen({super.key});

  @override
  State<SessionWaitingScreen> createState() => _SessionWaitingScreenState();
}

class _SessionWaitingScreenState extends State<SessionWaitingScreen> {
  // متغيرات الوقت والزر
  int _secondsRemaining = 15; // الوقت المحدد بـ 15 ثانية كما طلبت
  bool _isButtonEnabled = false;
  Timer? _timer;

  // متغيرات التجهيزات (Checkboxes) الافتراضي مفعل
  bool _internetChecked = true;
  bool _cameraChecked = true;
  bool _micChecked = true;

  // الألوان الأساسية
  final Color primaryBlue = const Color(0xFF005CE6);
  final Color disabledBlue = const Color(0xFF8AB4F8); // لون الزر وهو معطل
  final Color textDark = const Color(0xFF333333);
  final Color bgGrey = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _isButtonEnabled = true; // تفعيل الزر بعد انتهاء الوقت
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // إيقاف العداد عند الخروج من الصفحة
    super.dispose();
  }

  // دالة لتحويل الثواني إلى صيغة MM:SS
  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // اتجاه الواجهة عربي
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. بطاقة العد التنازلي الزرقاء
              _buildTimerCard(),
              const SizedBox(height: 16),

              // 2. بطاقة بيانات الفني
              _buildTechnicianCard(),
              const SizedBox(height: 24),

              // 3. قسم تجهيز الجلسة
              Text(
                "تجهيز الجلسة",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildChecklistItem(
                title: "إنترنت مستقر",
                icon: Icons.wifi,
                value: _internetChecked,
                onChanged: (val) => setState(() => _internetChecked = val!),
              ),
              _buildChecklistItem(
                title: "الكاميرا مفعلة",
                icon: Icons.videocam_outlined,
                value: _cameraChecked,
                onChanged: (val) => setState(() => _cameraChecked = val!),
              ),
              _buildChecklistItem(
                title: "الميكروفون مفعل",
                icon: Icons.mic_none,
                value: _micChecked,
                onChanged: (val) => setState(() => _micChecked = val!),
              ),
              const SizedBox(height: 24),

              // 4. قسم رفع الملفات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ارفع ملفات لتوفير الوقت",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  Text(
                    "اختياري",
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildUploadButton("صور", Icons.camera_alt_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUploadButton(
                      "فيديو",
                      Icons.video_library_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildUploadButton(
                "وصف المشكلة",
                Icons.description_outlined,
                isFullWidth: true,
              ),
              const SizedBox(height: 24),

              // 5. رسالة التنبيه الصفراء
              _buildWarningBanner(),
              const SizedBox(height: 100), // مساحة أسفل الشاشة
            ],
          ),
        ),
        bottomSheet: _buildBottomButton(),
      ),
    );
  }

  // --- دوال بناء الواجهة (Widgets) ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "بسيطة",
        style: GoogleFonts.cairo(
          color: primaryBlue,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "الاستشارة ستبدأ قريباً",
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            _formattedTime,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "تبدأ الجلسة خلال $_formattedTime",
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/Background+Border (1).png', // مسار صورة الفني
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "الفني: أحمد محمد",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textDark,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "اليوم، 4:00 م",
                        style: GoogleFonts.cairo(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "30 دقيقة",
                        style: GoogleFonts.cairo(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryBlue),
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildUploadButton(
    String title,
    IconData icon, {
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(12),
        // لمحاكاة الحدود المتقطعة نستخدم خط خفيف
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryBlue, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0X00ffe088).withValues(alpha: 0.5), // لون أصفر خفيف
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "تأكد من تواجدك في منطقة هادئة وذات إضاءة جيدة لضمان جودة الاستشارة.",
              style: GoogleFonts.cairo(
                color: Colors.black87,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isButtonEnabled ? primaryBlue : disabledBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // حواف دائرية للزر
              ),
              elevation: 0,
            ),
            onPressed: _isButtonEnabled
                ? () {
                    // --- كود النافيجاتور كما طلبت ---

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConsultationReadyScreen(),
                      ),
                    );

                    // تنبيه للتجربة عند الضغط
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "جاري دخول الجلسة...",
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                : null, // الزر يكون معطل (null) إذا لم يكتمل العداد
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, color: Colors.white), // أيقونة الدخول
                const SizedBox(width: 8),
                Text(
                  "دخول الجلسة",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
