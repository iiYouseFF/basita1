import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/feedback/screens/feedback_screen.dart';

class ConsultationReadyScreen extends StatefulWidget {
  const ConsultationReadyScreen({super.key});

  @override
  State<ConsultationReadyScreen> createState() =>
      _ConsultationReadyScreenState();
}

class _ConsultationReadyScreenState extends State<ConsultationReadyScreen> {
  // متغيرات الوقت (14 دقيقة و 59 ثانية = 899 ثانية)
  static const int totalDuration = 14 * 60 + 59;
  int _secondsRemaining = totalDuration;
  Timer? _timer;

  // الألوان الأساسية المطابقة للتصميم
  final Color primaryBlue = const Color(0xFF005CE6);
  final Color bgGrey = const Color(0xFFF8F9FA); // لون خلفية التطبيق
  final Color cardGrey = const Color(0xFFF3F4F6); // لون خلفية أدوات الاستشارة
  final Color textDark = const Color(0xFF1A1A1A);
  final Color textGrey = const Color(0xFF757575);
  final Color redCancel = const Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // تشغيل العداد التنازلي
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // تحويل الثواني إلى صيغة MM:SS
  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // واجهة باللغة العربية
      child: Scaffold(
        backgroundColor: bgGrey,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. بادج "متاح الآن"
              _buildStatusBadge(),
              const SizedBox(height: 16),

              // 2. نصوص العنوان
              Text(
                "الاستشارة جاهزة الآن",
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "الفني بانتظارك، يمكنك بدء الجلسة الآن.",
                style: GoogleFonts.cairo(fontSize: 14, color: textGrey),
              ),
              const SizedBox(height: 24),

              // 3. كارت الوقت المتبقي
              _buildTimerCard(),
              const SizedBox(height: 16),

              // 4. كارت بيانات الفني
              _buildTechnicianCard(),
              const SizedBox(height: 24),

              // 5. زر ابدأ الاستشارة
              _buildStartButton(),
              const SizedBox(height: 32),

              // 6. أدوات الاستشارة (الشبكة)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "أدوات الاستشارة",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildToolsGrid(),
              const SizedBox(height: 32),

              // 7. زر إلغاء الجلسة
              _buildCancelButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- الدوال المنفصلة لبناء الواجهة (Widgets) ---------------- //

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: bgGrey,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "بسيطة",
        style: GoogleFonts.cairo(
          color: primaryBlue,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [Padding(padding: const EdgeInsets.only(left: 20.0))],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "متاح الآن",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    double progressValue =
        _secondsRemaining / totalDuration; // حساب نسبة التقدم

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "الوقت المتبقي للجلسة",
            style: GoogleFonts.cairo(color: textGrey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            _formattedTime,
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 54,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // النصوص وبيانات الفني (يمين)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "أحمد محمد",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "خبير تشطيبات ومعماري",
                style: GoogleFonts.cairo(fontSize: 13, color: textGrey),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "فني معتمد",
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // صورة الفني مع التقييم (يسار)
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/Background+Border (1).png', // مسار صورة الفني
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 75,
                    height: 75,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: -8,
                right: -8, // لوضعها في الزاوية العلوية اليمنى (لأننا في RTL)
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.black, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        "4.9",
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        onPressed: () {
          // --- كود النافيجاتور للانتقال لصفحة الجلسة الجديدة ---

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FeedbackScreen()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "جاري بدء الاستشارة...",
                style: GoogleFonts.cairo(),
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              "ابدأ الاستشارة الآن",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid() {
    // قائمة الأدوات والبيانات الخاصة بها
    final List<Map<String, dynamic>> tools = [
      {"title": "إضاءة الفلاش", "icon": Icons.flashlight_on_outlined},
      {"title": "مشاركة الشاشة", "icon": Icons.screen_share_outlined},
      {"title": "تسجيل الجلسة", "icon": Icons.radio_button_checked},
      {"title": "اختبار الكاميرا", "icon": Icons.camera_alt_outlined},
      {"title": "رفع ملفات", "icon": Icons.upload_file_outlined},
      {"title": "الإعدادات", "icon": Icons.settings_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true, // مهم جداً داخل SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1, // لضبط نسبة الطول للعرض لتكون مربعة تقريباً
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            // تفاعل عند الضغط على أي أداة
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "تم اختيار: ${tools[index]['title']}",
                  style: GoogleFonts.cairo(),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: cardGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tools[index]['icon'],
                  color: textDark.withValues(alpha: 0.8),
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  tools[index]['title'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textDark.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCancelButton() {
    return TextButton.icon(
      onPressed: () {
        // إجراء إلغاء الجلسة
      },
      icon: Icon(Icons.cancel_outlined, color: redCancel, size: 20),
      label: Text(
        "اعتذار عن الجلسة",
        style: GoogleFonts.cairo(
          color: redCancel,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
