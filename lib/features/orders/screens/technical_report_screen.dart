import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/home/screens/home_screen.dart';
import 'package:basita1/features/technician/screens/technicians_screen.dart';

class TechnicalReportScreen extends StatelessWidget {
  const TechnicalReportScreen({super.key});

  // الألوان الأساسية للتصميم
  static const Color primaryBlue = Color(0xFF0058CA);
  static const Color accentBlue = Color(0xFF5B92E5);
  static const Color bgLight = Color(0xFFF8FAFD);
  static const Color cardBg = Color(0xFFF2F5F9);
  static const Color dangerRed = Color(0xFFD32F2F);
  static const Color warningAmber = Color(0xFFB78103);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الهيدر والترويسة
              Text(
                "التقرير الفني للاستشارة",
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "بناءً على طلب المعاينة الفنية، إليكم تفاصيل التشخيص المتخصص",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // بطاقات البيانات الأساسية (اسم العميل، الفني، التاريخ، رقم التقرير)
              _buildInfoCard(
                icon: Icons.person_outline_rounded,
                iconBg: const Color(0xFFE3F2FD),
                iconColor: primaryBlue,
                label: "اسم العميل",
                value: "أحمد محمد الرفاعي",
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.engineering_outlined,
                iconBg: const Color(0xFFE3F2FD),
                iconColor: primaryBlue,
                label: "الفني المسؤول",
                value: "م/ محمد كمال",
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.calendar_today_outlined,
                iconBg: const Color(0xFFFFF8E1),
                iconColor: const Color(0xFFF57F17),
                label: "التاريخ",
                value: "24 أكتوبر 2023",
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.fingerprint_rounded,
                iconBg: const Color(0xFFECEFF1),
                iconColor: Colors.blueGrey,
                label: "رقم التقرير",
                value: "#REP-99231",
              ),
              const SizedBox(height: 24),

              // ملخص المشكلة
              _buildSectionCard(
                barColor: primaryBlue,
                icon: Icons.warning_amber_rounded,
                iconColor: primaryBlue,
                title: "ملخص المشكلة",
                content:
                    "شكوى من تسريب مياه خلف الحائط الرئيسي للحمام، مما أدى إلى ظهور رطوبة في الغرفة المجاورة وتلف في طبقة الدهان.",
              ),
              const SizedBox(height: 16),

              // التشخيص
              _buildSectionCard(
                barColor: primaryBlue,
                icon: Icons.plumbing_outlined,
                iconColor: primaryBlue,
                title: "التشخيص",
                content:
                    "بعد الفحص الميداني، تبين وجود تأكل في الوصلات الداخلية المغذية للسخان ووجود كسر بسيط في ماسورة الصرف الرئيسية بقطر 1.5 بوصة.",
              ),
              const SizedBox(height: 16),

              // السبب الرئيسي
              _buildSectionCard(
                barColor: dangerRed,
                icon: Icons.account_tree_outlined,
                iconColor: dangerRed,
                title: "السبب الرئيسي",
                content:
                    "استخدام خامات غير مطابقة للمواصفات في التاسيس الأول (وصلات بلاستيكية ضعيفة التحمل لدرجات الحرارة العالية).",
              ),
              const SizedBox(height: 16),

              // التوصيات
              _buildSectionCard(
                barColor: warningAmber,
                icon: Icons.check_circle_outline_rounded,
                iconColor: warningAmber,
                title: "التوصيات",
                content:
                    "استبدال الوصلات المتآكلة بأخرى نحاسية عالية الجودة.\n"
                    "تغيير الجزء المتضرر من ماسورة الصرف.\n"
                    "عمل طبقة عزل مائي \"بيتومين\" خلف الحائط المتضرر.",
              ),
              const SizedBox(height: 28),

              // قطع الغيار المقترحة
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "قطع الغيار المقترحة",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildSparePartItem(
                icon: Icons.tune_rounded,
                title: "وصلات نحاس (2)",
                price: "450 ج.م",
              ),
              const SizedBox(height: 10),
              _buildSparePartItem(
                icon: Icons.border_color_outlined,
                title: "ماسورة صرف 1.5\"",
                price: "200 ج.م",
              ),
              const SizedBox(height: 10),
              _buildSparePartItem(
                icon: Icons.format_paint_outlined,
                title: "مواد عزل ودهان",
                price: "600 ج.م",
              ),
              const SizedBox(height: 24),

              // كارت إجمالي التكاليف المتوقعة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "إجمالي التكاليف المتوقعة: 1,250 ج.م",
                            style: GoogleFonts.cairo(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "شامل المصنعيات والضريبة",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // كبسولة هل تحتاج لزيارة منزلية؟
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: accentBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "هل تحتاج لزيارة منزلية؟ نعم (YES)",
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // توقيع الفني المعتمد
              Text(
                "توقيع الفني المعتمد",
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              CustomPaint(
                painter: DashedBorderPainter(color: Colors.grey.shade400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 30,
                  ),
                  child: Text(
                    "م/ محمد كمال",
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // تحقق من التقرير أونلاين
              Text(
                "تحقق من التقرير أونلاين",
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Image.network(
                  'https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=https://basita.app/report/REP-99231',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.qr_code_2_rounded,
                    size: 80,
                    color: primaryBlue,
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ), // مسافة فارغة لتجنب تغطية الفوتر للمحتوى
            ],
          ),
        ),
        // الفوتر السفلي العائم المثبت
        bottomSheet: _buildBottomActionButtons(context),
      ),
    );
  }

  // --- WIDGETS BUILDERS ---

  // 1. App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgLight,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الجهة اليمنى: اسم التطبيق والأيقونة
          Row(
            children: [
              Text(
                "بسيطة",
                style: GoogleFonts.cairo(
                  color: primaryBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          // الجهة اليسرى: العنوان والأيقونة
          Row(
            children: [
              Text(
                "التقرير الفني",
                style: GoogleFonts.cairo(
                  color: primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. بطاقة البيانات الأساسية
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. كارت الأقسام مع الشريط الجانبي الملون
  Widget _buildSectionCard({
    required Color barColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // الشريط الملون الأيمن (لأن الواجهة RTL)
              Container(width: 6, color: barColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: iconColor, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        content,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. عنصر قطعة غيار
  Widget _buildSparePartItem({
    required IconData icon,
    required String title,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: primaryBlue, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Text(
                price,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(width: 22), // للحفاظ على التوازن والتوسط
        ],
      ),
    );
  }

  // 5. الفوتر الأخير (Footer Action Buttons)
  Widget _buildBottomActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 1. زر تحميل PDF
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () {
                  // كود تحميل الـ PDF هنا

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SimpleHomeScreen(), // استبدل اسم الصفحة هنا باسم صفحتك
                    ),
                  );
                },
                icon: const Icon(
                  Icons.home_filled,
                  color: primaryBlue,
                  size: 20,
                ),
                label: Text(
                  " الذهاب الي الرئيسية",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryBlue, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 2. زر حجز الفني للزيارة
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () {
                  // ==========================================
                  // 🚀 كود النافيجيتور للصفحة الجديدة الخاصة بك:
                  // ==========================================

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TechniciansScreen(), // استبدل اسم الصفحة هنا باسم صفحتك
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "جارِ الانتقال لصفحة حجز الفني...",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: primaryBlue,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  "حجز الفني للزيارة",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// كلاس رسم الحدود المقطعة (Dashed Border) المخصص للتوقيع
class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10),
      ),
    );

    var metrics = path.computeMetrics();
    for (var metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
