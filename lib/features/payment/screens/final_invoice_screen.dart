import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinalInvoiceScreen extends StatefulWidget {
  const FinalInvoiceScreen({super.key});

  @override
  State<FinalInvoiceScreen> createState() => _FinalInvoiceScreenState();
}

class _FinalInvoiceScreenState extends State<FinalInvoiceScreen> {
  // الألوان الأساسية المستوحاة من التصميم
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color lightBlueBg = Color(0xFFEFF6FF);
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color redIcon = Color(0xFFDC2626);
  static const Color lightRedBg = Color(0xFFFEE2E2);

  // متغير لحفظ وسيلة الدفع المحددة (0 افتراضياً يعني "نقداً")
  int _selectedPaymentMethodIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم اللغة العربية بالكامل
      child: Scaffold(
        backgroundColor: bgLight,

        // ==========================================
        // 1. شريط التنقل العلوي (AppBar)
        // ==========================================
        appBar: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlue),
            onPressed: () {
              Navigator.pop(context); // الرجوع للصفحة السابقة
            },
          ),
          title: Text(
            "الفاتورة النهائية",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),

        // ==========================================
        // 2. محتوى الصفحة (Body)
        // ==========================================
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 12,
              ), // تم حذف مؤشر التقدم هنا بناءً على طلبك
              // --- قسم الرسوم الإضافية ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "الرسوم الإضافية",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // كود التعديل
                    },
                    child: Text(
                      "تعديل",
                      style: GoogleFonts.cairo(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAdditionalFeeCard(
                "رسوم الانتقالات",
                "150 ج.م",
                Icons.local_shipping,
                primaryBlue,
                lightBlueBg,
              ),
              const SizedBox(height: 12),
              _buildAdditionalFeeCard(
                "خدمة طارئة",
                "200 ج.م",
                Icons.flash_on,
                redIcon,
                lightRedBg,
              ),
              const SizedBox(height: 28),

              // --- قسم تفاصيل الحساب ---
              Text(
                "تفاصيل الحساب",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildAccountDetailsCard(),
              const SizedBox(height: 28),

              // --- قسم وسيلة الدفع ---
              Text(
                "وسيلة الدفع",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodsGrid(),
              const SizedBox(height: 32),
            ],
          ),
        ),

        // ==========================================
        // 3. الأزرار السفلية (Footer Action Bar)
        // ==========================================
        bottomNavigationBar: _buildBottomConfirmButton(context),
      ),
    );
  }

  // ---------------------------------------------------------
  // دوال بناء العناصر (Widgets)
  // ---------------------------------------------------------

  // 1. كارت الرسوم الإضافية
  Widget _buildAdditionalFeeCard(
    String title,
    String price,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. كارت تفاصيل الحساب والإجمالي
  Widget _buildAccountDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          // الهيدر (رقم الفاتورة والتاريخ)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "رقم الفاتورة",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: textGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "#SH-5521-2024",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "التاريخ",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: textGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "24 مايو 2024",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // الخط المتقطع
          CustomPaint(
            painter: DashedLinePainter(),
            child: const SizedBox(width: double.infinity, height: 1),
          ),
          const SizedBox(height: 20),

          // بنود الفاتورة
          _buildInvoiceRow("تكلفة العمالة", "2,450 ج.م"),
          const SizedBox(height: 12),
          _buildInvoiceRow("تكلفة الخامات", "1,800 ج.م"),
          const SizedBox(height: 12),
          _buildInvoiceRow("الرسوم الإضافية", "350 ج.م"),
          const SizedBox(height: 12),
          _buildInvoiceRow("الخصم (برومو كود)", "- 400 ج.م", isDiscount: true),
          const SizedBox(height: 12),
          _buildInvoiceRow("الضريبة (14%)", "588 ج.م"),
          const SizedBox(height: 20),

          // الإجمالي الكلي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: lightBlueBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "الإجمالي الكلي",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "4,788",
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "ج.م",
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(
    String title,
    String value, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: isDiscount ? primaryBlue : textGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isDiscount ? primaryBlue : textDark,
          ),
        ),
      ],
    );
  }

  // 3. شبكة وسائل الدفع (تدعم الـ Select الآن)
  Widget _buildPaymentMethodsGrid() {
    final List<Map<String, dynamic>> paymentMethods = [
      {"title": "نقداً", "icon": Icons.payments_outlined},
      {"title": "بطاقة ائتمان", "icon": Icons.credit_card},
      {"title": "محفظة", "icon": Icons.account_balance_wallet_outlined},
      {"title": "إنستا باي", "icon": Icons.account_balance},
      {"title": "فودافون كاش", "icon": Icons.phone_android},
      {"title": "Apple Pay", "icon": Icons.grid_view_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 أعمدة
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1, // للتحكم في نسبة طول الكارت لعرضه
      ),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        return _buildPaymentMethodItem(
          index,
          paymentMethods[index]["title"],
          paymentMethods[index]["icon"],
        );
      },
    );
  }

  Widget _buildPaymentMethodItem(int index, String title, IconData icon) {
    bool isSelected = _selectedPaymentMethodIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethodIndex = index; // تحديث الوسيلة المختارة
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? lightBlueBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primaryBlue : textGrey, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                color: isSelected ? primaryBlue : textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. زر تأكيد وإصدار الفاتورة (الفوتر)
  Widget _buildBottomConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ), // استخدمنا withOpacity بدلاً من withValues
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // كود الانتقال للصفحة الجديدة عند التأكيد
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const PaymentSuccessScreen(),
            //   ),
            // );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ), // حواف دائرية بالكامل
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "تأكيد وإصدار الفاتورة",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// كلاس CustomPainter لرسم الخط الفاصل المتقطع (Dashed Line) في الفاتورة
// =====================================================================
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 4, startX = 0;
    final paint = Paint()
      ..color =
          const Color(0xFFD1D5DB) // لون رمادي للخط
      ..strokeWidth = 1.5;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
