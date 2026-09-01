import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/booking/screens/session_waiting_screen.dart';

class BookingConsultationScreen extends StatefulWidget {
  const BookingConsultationScreen({super.key});

  @override
  State<BookingConsultationScreen> createState() =>
      _BookingConsultationScreenState();
}

class _BookingConsultationScreenState extends State<BookingConsultationScreen> {
  // متغيرات لحفظ حالة الاختيارات
  int _selectedDurationIndex = 1; // الافتراضي 30 دقيقة
  int _selectedDateIndex = 0; // الافتراضي أول يوم
  int _selectedTimeIndex = 3; // الافتراضي 02:00 م

  // الألوان الأساسية
  final Color primaryBlue = const Color(0xFF005CE6);
  final Color textDark = const Color(0xFF333333);
  final Color textGrey = const Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان اتجاه الواجهة من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // نصوص العنوان
              Text(
                "احجز جلستك الآن",
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "تواصل مباشرة مع فني متخصص لحل مشكلتك بأعلى\nكفاءة.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: textGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // بطاقة الفني
              _buildTechnicianCard(),
              const SizedBox(height: 24),

              // اختيار مدة الاستشارة
              _buildSectionTitle("مدة الاستشارة", price: "150 ج.م"),
              const SizedBox(height: 16),
              _buildDurationsList(),
              const SizedBox(height: 24),

              // اختيار التاريخ
              _buildSectionTitle("اختر التاريخ والوقت"),
              const SizedBox(height: 16),
              _buildDatesList(),
              const SizedBox(height: 16),

              // اختيار الوقت
              _buildTimesList(),
              const SizedBox(height: 32),

              // ملخص الدفع
              _buildPaymentSummary(),
              const SizedBox(height: 100), // مساحة أسفل الشاشة للبار السفلي
            ],
          ),
        ),
        bottomSheet: _buildBottomActionBar(),
      ),
    );
  }

  // ---------------- الويدجتس المنفصلة لتنظيم الكود ---------------- //

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "الاستشارة أونلاين",
        style: GoogleFonts.cairo(
          color: primaryBlue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_forward, color: textDark), // السهم معكوس للـ RTL
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: textDark,
            size: 28,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTechnicianCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة الفني مع نقطة الأونلاين
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/Background+Border (1).png', // ضع مسار صورتك هنا
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // تفاصيل الفني
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "أحمد محمد",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "خبير سباكة وأجهزة منزلية",
                  style: GoogleFonts.cairo(color: textGrey, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, color: primaryBlue, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "4.9",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.work_outline,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "12 سنة خبرة",
                      style: GoogleFonts.cairo(color: textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // علامة نشط الآن
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "نشط الآن",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? price}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        if (price != null)
          Text(
            price,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
      ],
    );
  }

  Widget _buildDurationsList() {
    List<String> durations = ["15 دقيقة", "30 دقيقة", "60 دقيقة"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(durations.length, (index) {
        bool isSelected = _selectedDurationIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDurationIndex = index),
            child: Container(
              margin: EdgeInsets.only(
                left: index == 2 ? 0 : 8,
              ), // مسافة بين الأزرار
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? primaryBlue : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        durations[index],
                        style: GoogleFonts.cairo(
                          color: isSelected ? primaryBlue : textDark,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  // بادج "المقترح"
                  if (index == 1)
                    Positioned(
                      top: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "المقترح",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDatesList() {
    List<Map<String, String>> dates = [
      {"dayName": "الأحد", "dayNum": "24"},
      {"dayName": "الاثنين", "dayNum": "25"},
      {"dayName": "الثلاثاء", "dayNum": "26"},
      {"dayName": "الأربعاء", "dayNum": "27"},
      {"dayName": "الخميس", "dayNum": "28"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(dates.length, (index) {
          bool isSelected = _selectedDateIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = index),
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryBlue : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    dates[index]["dayName"]!,
                    style: GoogleFonts.cairo(
                      color: isSelected ? primaryBlue : textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dates[index]["dayNum"]!,
                    style: GoogleFonts.cairo(
                      color: isSelected ? primaryBlue : textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimesList() {
    List<String> times = [
      "10:00 ص",
      "11:30 ص",
      "02:00 م",
      "03:30 م",
      "05:00 م",
      "07:30 م",
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(times.length, (index) {
        bool isSelected = _selectedTimeIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeIndex = index),
          child: Container(
            width: (MediaQuery.of(context).size.width - 56) / 3, // 3 أعمدة
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primaryBlue : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                times[index],
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white : textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ملخص الدفع",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "سعر الجلسة (30 دقيقة)",
                style: GoogleFonts.cairo(color: textGrey, fontSize: 14),
              ),
              Text(
                "150.00 ج.م",
                style: GoogleFonts.cairo(color: textDark, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "رسوم الخدمة",
                style: GoogleFonts.cairo(color: textGrey, fontSize: 14),
              ),
              Text(
                "15.00 ج.م",
                style: GoogleFonts.cairo(color: textDark, fontSize: 14),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.grey),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الإجمالي",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textDark,
                ),
              ),
              Text(
                "165.00 ج.م",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // السعر الإجمالي
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الإجمالي المستحق",
                  style: GoogleFonts.cairo(color: textGrey, fontSize: 12),
                ),
                Text(
                  "165 ج.م",
                  style: GoogleFonts.cairo(
                    color: primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // زر الحجز
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // --- كود النافيجاتور للانتقال للصفحة الجديدة ---

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SessionWaitingScreen(),
                    ),
                  );

                  // رسالة توضيحية للتجربة (يمكنك مسحها)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "تم الضغط على الحجز بنجاح!",
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "احجز الجلسة",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
