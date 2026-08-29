import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/orders/screens/technical_report_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // الألوان الأساسية الخاصة بتطبيق "بسيطة"
  final Color primaryBlue = const Color(0xFF005CE6);
  final Color bgGrey = const Color(0xFFF9F9F9);
  final Color textDark = const Color(0xFF1A1A1A);
  final Color textGrey = const Color(0xFF757575);
  final Color lightBlueBg = const Color(0xFFEEF4FF); // لون خلفية المربع السفلي

  // متغيرات الحالة (State Variables)
  int _rating = 0; // التقييم بالنجوم
  final List<String> _options = [
    'احترافية',
    'سرعة',
    'وضوح الشرح',
    'حل المشكلة',
  ];
  final List<String> _selectedOptions = []; // الخيارات المحددة
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم الواجهة باللغة العربية
      child: Scaffold(
        backgroundColor: bgGrey,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. الصورة العلوية الدائرية
              _buildHeaderImage(),
              const SizedBox(height: 16),

              // 2. نصوص الشكر
              Text(
                "شكرًا لك!",
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "تمت المهمة بنجاح، رأيك يهمنا جدًا لتطوير خدماتنا.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 14, color: textGrey),
              ),
              const SizedBox(height: 24),

              // 3. كارت التقييم الرئيسي
              _buildRatingCard(),
              const SizedBox(height: 24),

              // 4. رسالة التنبيه السفلية
              _buildInfoBox(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ================= الدوال المساعدة لبناء الواجهة (Widgets) ================= //

  // شريط التطبيق العلوي مطابق لصورة (Header - Top App Bar)
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: primaryBlue,
          size: 28,
        ), // القائمة يمين (RTL)
        onPressed: () {},
      ),
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
            Icons.notifications_none,
            color: primaryBlue,
            size: 28,
          ), // الإشعارات يسار
          onPressed: () {},
        ),
      ],
    );
  }

  // الصورة الدائرية العلوية
  Widget _buildHeaderImage() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipOval(
          child: Image.asset(
            'assets/Gemini_Generated_Image_v6y5amv6y5amv6y5.png', // ضع مسار صورتك هنا
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.image, size: 50, color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  // كارت التقييم الأبيض الكبير
  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "كيف كانت تجربتك؟",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),

          // النجوم التفاعلية
          _buildInteractiveStars(),
          const SizedBox(height: 24),

          // خيارات الإعجاب
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "ما الذي نال إعجابك؟",
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildChoiceChips(),
          const SizedBox(height: 24),

          // مربع النص
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "اكتب تقييمك هنا (اختياري)",
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildTextField(),
          const SizedBox(height: 24),

          // رفع الصورة
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "أضف صورًا للعمل",
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildImageUploadBox(),
          const SizedBox(height: 32),

          // زر الإرسال
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // بناء النجوم التفاعلية
  Widget _buildInteractiveStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: index < _rating ? Colors.amber : Colors.grey.shade400,
            size: 40,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }

  // بناء الأزرار (Chips) المتجاوبة
  Widget _buildChoiceChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _options.map((option) {
        final isSelected = _selectedOptions.contains(option);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedOptions.remove(option);
              } else {
                _selectedOptions.add(option);
              }
            });
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? primaryBlue.withOpacity(0.08) : Colors.white,
              border: Border.all(
                color: isSelected ? primaryBlue : Colors.grey.shade400,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              option,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? primaryBlue : textDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // مربع كتابة التقييم
  Widget _buildTextField() {
    return TextField(
      controller: _reviewController,
      maxLines: 4,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: InputDecoration(
        hintText: "أخبرنا بالمزيد عن تجربتك...",
        hintStyle: GoogleFonts.cairo(color: textGrey, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  // مربع رفع الصورة المتقطع (Dashed Box) ذكي ومبني برمجياً
  Widget _buildImageUploadBox() {
    return CustomPaint(
      painter: DashedRectPainter(
        color: Colors.grey.shade400,
        strokeWidth: 1.5,
        gap: 5.0,
      ),
      child: InkWell(
        onTap: () {
          // إجراء رفع الصورة
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 90,
          height: 90,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: Colors.grey.shade500,
                size: 30,
              ),
              const SizedBox(height: 4),
              Text(
                "رفع صورة",
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // زر إرسال التقييم مع كود النافيجاتور
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () {
          // ==========================================
          // كود النافيجاتور للانتقال للصفحة الجديدة
          // ==========================================
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TechnicalReportScreen(), 
            ),
          );
        

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "تم إرسال التقييم بنجاح!",
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "إرسال التقييم",
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            // استخدام Transform لعكس الأيقونة لتلائم اللغة العربية (RTL) إذا لزم الأمر
            const Icon(Icons.send, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // الصندوق السفلي الأزرق (رسالة التنبيه)
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: lightBlueBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: primaryBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "تقييمك يساعد الآخرين في اختيار المحترف المناسب لمشاريعهم القادمة.",
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: primaryBlue.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= كلاس ذكي لرسم الإطار المتقطع (Dashed Border) ================= //
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(x, 0)
      ..lineTo(x, y)
      ..lineTo(0, y)
      ..close();

    Path dashPath = Path();
    double distance = 0.0;
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0; // إعادة التعيين للخط التالي
    }

    // رسم زوايا دائرية (Radius) للإطار المتقطع
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, x, y),
        const Radius.circular(12),
      ),
      dashedPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
