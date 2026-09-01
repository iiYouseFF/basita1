import 'package:flutter/material.dart';
// removed: cloud_firestore - see docs/backend-prd.html
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/core/network/mock_backend.dart';

// =====================================================================
// صفحة تأكيد نجاح الدفع وتفاصيل الخدمة (PaymentSuccessScreen)
// =====================================================================
class PaymentSuccessScreen extends StatefulWidget {
  final String requestId;
  final double? fallbackAmount;
  final String? fallbackPaymentMethod;

  const PaymentSuccessScreen({
    super.key,
    required this.requestId,
    this.fallbackAmount,
    this.fallbackPaymentMethod,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  // الألوان الأساسية المطابقة للتصميم
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color lightBlueBg = Color(0xFFEFF6FF);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color greenSuccess = Color(0xFF10B981);

  // اختيار الضمان للخدمة
  int selectedWarrantyIndex = 2; // افتراضياً: 30 يوم

  final List<String> warrantyOptions = [
    "بدون ضمان",
    "7 أيام",
    "30 يوم",
    "90 يوم",
    "6 أشهر",
    "سنة واحدة",
  ];

  double _parsePrice(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      String cleaned = val.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "تفاصيل عملية الدفع",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<dynamic>(
          stream: MockFirestore.collection(
            'requests',
          ).doc(widget.requestId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            // استخراج البيانات الديناميكية من Firestore
            final data = snapshot.data?.data() ?? {};

            final String serviceName =
                data['title'] ?? data['serviceName'] ?? 'طلب خدمة صيانة';
            final String techName =
                data['technicianName'] ?? data['techName'] ?? 'الفني المختص';
            final String clientName =
                data['userName'] ?? data['clientName'] ?? 'العميل';
            final String paymentMethod =
                data['paymentMethod'] ??
                widget.fallbackPaymentMethod ??
                'نقداً';

            final double finalTotal = _parsePrice(data['finalTotal']) > 0
                ? _parsePrice(data['finalTotal'])
                : (_parsePrice(data['finalPrice']) > 0
                      ? _parsePrice(data['finalPrice'])
                      : (widget.fallbackAmount ?? 0.0));

            final double laborCost = _parsePrice(data['laborCost']);
            final double materialsCost = _parsePrice(data['materialsCost']);
            final bool isPaid = data['isPaid'] ?? true;
            final String status = data['status'] ?? 'completed';

            Timestamp? paidTimestamp =
                data['paidAt'] as Timestamp? ??
                data['invoiceIssuedAt'] as Timestamp?;
            DateTime paidDate = paidTimestamp?.toDate() ?? DateTime.now();
            String formattedDate =
                "${paidDate.day}/${paidDate.month}/${paidDate.year}";

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ----------------------------------------------------
                  // 1. أيقونة النجاح والعنوان
                  // ----------------------------------------------------
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: greenSuccess.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: greenSuccess,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    status == 'pending_cash'
                        ? "تم تأكيد طلب الدفع كاش"
                        : "تم إتمام الدفع بنجاح!",
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status == 'pending_cash'
                        ? "يرجى تحصيل المبلغ من العميل عند الانتهاء."
                        : "تم تسجيل العملية في النظام وإصدار إيصال السداد الإلكتروني.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 14, color: textGrey),
                  ),
                  const SizedBox(height: 28),

                  // ----------------------------------------------------
                  // 2. بطاقة المجموع والتفاصيل المالية
                  // ----------------------------------------------------
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "خدمة المقدمة",
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: textGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  serviceName,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? const Color(0xFFD1E7DD)
                                    : const Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                isPaid ? "مدفوع" : "في انتظار التحصيل",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isPaid
                                      ? const Color(0xFF0F5132)
                                      : const Color(0xFF856404),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        _buildDetailRow("اسم الفني", techName),
                        const SizedBox(height: 10),
                        _buildDetailRow("اسم العميل", clientName),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          "رقم الطلب",
                          "#${widget.requestId.length > 8 ? widget.requestId.substring(0, 8) : widget.requestId}",
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow("طريقة الدفع", paymentMethod),
                        const SizedBox(height: 10),
                        _buildDetailRow("تاريخ العملية", formattedDate),

                        if (laborCost > 0 || materialsCost > 0) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            "أجور المصنعية / الخدمة",
                            "${laborCost.toInt()} ج.م",
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            "تكلفة الخامات والمواد",
                            "${materialsCost.toInt()} ج.م",
                          ),
                        ],

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: lightBlueBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "المبلغ إجمالي",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                              Text(
                                "${finalTotal.toInt()} ج.م",
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ----------------------------------------------------
                  // 3. تحديد فترة الضمان المتاحة
                  // ----------------------------------------------------
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "فترة الضمان المعتمدة للخدمة",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(warrantyOptions.length, (index) {
                      bool isSelected = selectedWarrantyIndex == index;
                      return ChoiceChip(
                        label: Text(
                          warrantyOptions[index],
                          style: GoogleFonts.cairo(
                            color: isSelected ? Colors.white : textDark,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: primaryBlue,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? primaryBlue : cardBorder,
                          ),
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            selectedWarrantyIndex = index;
                          });
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 36),

                  // ----------------------------------------------------
                  // 4. زر العودة إلى الصفحة الرئيسية
                  // ----------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.home_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        "العودة للرئيسية",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 13, color: textGrey)),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ],
    );
  }
}
