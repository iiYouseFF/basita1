// اسم الملف: user_invoices_screen.dart

import 'package:flutter/material.dart';
// removed: cloud_firestore - see docs/backend-prd.html
// removed: firebase_auth
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:basita1/core/network/mock_backend.dart';

// ==========================================
// 1. نموذج بيانات الفاتورة (Invoice Model)
// ==========================================
class UserInvoiceModel {
  final String id;
  final String invoiceNumber;
  final String serviceName;
  final String technicianName;
  final double laborCost;
  final double materialsCost;
  final double finalTotal;
  final double discount;
  final double additionalFees;
  final double tax;
  final String status;
  final String paymentMethod;
  final DateTime? createdAt;
  final DateTime? invoiceIssuedAt;

  UserInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.serviceName,
    required this.technicianName,
    required this.laborCost,
    required this.materialsCost,
    required this.finalTotal,
    required this.discount,
    required this.additionalFees,
    required this.tax,
    required this.status,
    required this.paymentMethod,
    this.createdAt,
    this.invoiceIssuedAt,
  });

  factory UserInvoiceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    double parsePrice(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) {
        String cleaned = val.replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    double labor = parsePrice(data['laborCost'] ?? data['price']);
    double materials = parsePrice(data['materialsCost']);
    double finalTot = parsePrice(data['finalTotal'] ?? data['finalPrice']);

    // حسابات تقريبية بناءً على الكود السابق الخاص بالفني إذا لم تكن محفوظة بشكل منفصل
    double fees = 350.0; // 150 انتقال + 200 طوارئ (كما في كود الفني)
    double disc = 400.0; // برومو كود (كما في كود الفني)
    double calculatedTax = (labor + materials) * 0.14; // ضريبة 14%

    return UserInvoiceModel(
      id: doc.id,
      invoiceNumber:
          data['invoiceNumber'] ??
          '#BS-${doc.id.substring(0, 6).toUpperCase()}',
      serviceName: data['title'] ?? data['serviceName'] ?? 'خدمة صيانة',
      technicianName: data['technicianName'] ?? data['techName'] ?? 'غير محدد',
      laborCost: labor,
      materialsCost: materials,
      finalTotal: finalTot > 0 ? finalTot : labor,
      discount: disc,
      additionalFees: fees,
      tax: calculatedTax,
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'غير محدد',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      invoiceIssuedAt:
          (data['invoiceIssuedAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

// ==========================================
// 2. صفحة قائمة الفواتير (قائمة الفواتير - بسيطة.png)
// ==========================================
class UserInvoicesListScreen extends StatefulWidget {
  const UserInvoicesListScreen({super.key});

  @override
  State<UserInvoicesListScreen> createState() => _UserInvoicesListScreenState();
}

class _UserInvoicesListScreenState extends State<UserInvoicesListScreen> {
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color bgLight = const Color(0xFFF8F9FA);

  // دالة لتحديد حالة الفاتورة ولونها
  Map<String, dynamic> _getInvoiceStatusInfo(String status) {
    if (status == 'completed' || status == 'paid') {
      return {
        'label': 'مدفوعة',
        'color': const Color(0xFF0F5132),
        'bg': const Color(0xFFD1E7DD),
      };
    } else if (status == 'awaiting_payment' ||
        status == 'ready_to_pay' ||
        status == 'task_finished_pending_invoice') {
      return {
        'label': 'مستحقة الدفع',
        'color': const Color(0xFF856404),
        'bg': const Color(0xFFFFF3CD),
      };
    } else if (status == 'pending_cash') {
      return {
        'label': 'قيد التحصيل (كاش)',
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFEF3C7),
      };
    } else {
      return {
        'label': 'قيد الانتظار',
        'color': const Color(0xFF6C757D),
        'bg': const Color(0xFFE9ECEF),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = MockAuth.currentUser?.uid ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "فواتيري",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE5E7EB), height: 1),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: MockFirestore.collection('requests')
              .where('userId', isEqualTo: currentUserId)
              // جلب الطلبات التي لها فواتير فقط أو انتهت
              .where(
                'status',
                whereIn: [
                  'awaiting_payment',
                  'ready_to_pay',
                  'completed',
                  'paid',
                  'pending_cash',
                  'task_finished_pending_invoice',
                ],
              )
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ في تحميل الفواتير',
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return _buildEmptyState();
            }

            final invoices = docs
                .map((doc) => UserInvoiceModel.fromFirestore(doc))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                final statusInfo = _getInvoiceStatusInfo(invoice.status);
                final dateStr = invoice.invoiceIssuedAt != null
                    ? intl.DateFormat(
                        'yyyy/MM/dd - hh:mm a',
                      ).format(invoice.invoiceIssuedAt!)
                    : 'غير محدد';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InvoiceDetailsScreen(invoice: invoice),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              invoice.invoiceNumber,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusInfo['bg'],
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                statusInfo['label'],
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: statusInfo['color'],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          invoice.serviceName,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "الإجمالي",
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              "${invoice.finalTotal.toStringAsFixed(2)} ج.م",
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "لا توجد فواتير حالية",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "جميع فواتير خدماتك المكتملة ستظهر هنا",
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. صفحة تفاصيل الفاتورة (تفاصيل الفاتورة - بسيطة.png)
// ==========================================
class InvoiceDetailsScreen extends StatelessWidget {
  final UserInvoiceModel invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0056D2);
    const Color textDark = Color(0xFF111827);
    const Color textGrey = Color(0xFF6B7280);
    const Color bgLight = Color(0xFFF8F9FA);

    bool isUnpaid =
        invoice.status == 'awaiting_payment' ||
        invoice.status == 'ready_to_pay' ||
        invoice.status == 'task_finished_pending_invoice';

    final dateStr = invoice.invoiceIssuedAt != null
        ? intl.DateFormat('yyyy/MM/dd').format(invoice.invoiceIssuedAt!)
        : 'غير محدد';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlue),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "تفاصيل الفاتورة",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE5E7EB), height: 1),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // كارت الفاتورة الرئيسي
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // رأس الفاتورة
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryBlue.withValues(alpha: 0.03),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "رقم الفاتورة",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: textGrey,
                                ),
                              ),
                              Text(
                                invoice.invoiceNumber,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "تاريخ الإصدار",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: textGrey,
                                ),
                              ),
                              Text(
                                dateStr,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // بيانات الخدمة
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.handyman,
                                  color: primaryBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invoice.serviceName,
                                      style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                      ),
                                    ),
                                    Text(
                                      "مقدم الخدمة: ${invoice.technicianName}",
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const CustomDashedDivider(),
                          const SizedBox(height: 24),

                          // التفاصيل المالية (الحسابات)
                          Text(
                            "تفاصيل الحساب",
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildInvoiceItem(
                            "تكلفة العمالة والخدمة",
                            invoice.laborCost,
                            textDark,
                          ),
                          if (invoice.materialsCost > 0) ...[
                            const SizedBox(height: 12),
                            _buildInvoiceItem(
                              "تكلفة الخامات وقطع الغيار",
                              invoice.materialsCost,
                              textDark,
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildInvoiceItem(
                            "رسوم إضافية (انتقالات وطوارئ)",
                            invoice.additionalFees,
                            textDark,
                          ),
                          const SizedBox(height: 12),
                          _buildInvoiceItem(
                            "ضريبة القيمة المضافة (14%)",
                            invoice.tax,
                            textDark,
                          ),

                          if (invoice.discount > 0) ...[
                            const SizedBox(height: 12),
                            _buildInvoiceItem(
                              "الخصم (برومو كود)",
                              -invoice.discount,
                              Colors.green,
                            ),
                          ],

                          const SizedBox(height: 24),
                          const CustomDashedDivider(),
                          const SizedBox(height: 20),

                          // الإجمالي النهائي
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryBlue.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "الإجمالي المطلوب",
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: primaryBlue,
                                  ),
                                ),
                                Text(
                                  "${invoice.finalTotal.toStringAsFixed(2)} ج.م",
                                  style: GoogleFonts.cairo(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // حالة الدفع
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isUnpaid
                                    ? Icons.info_outline
                                    : Icons.check_circle,
                                color: isUnpaid
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF0F5132),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isUnpaid
                                    ? "الفاتورة بانتظار الدفع لتأكيد إتمام الخدمة"
                                    : "تم دفع الفاتورة بنجاح بواسطة ${invoice.paymentMethod}",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isUnpaid
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF0F5132),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),

        // زر الدفع يظهر فقط إذا كانت الفاتورة غير مدفوعة
        bottomNavigationBar: isUnpaid
            ? _buildPayButton(context)
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildInvoiceItem(String title, double amount, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          "${amount > 0 ? '' : '- '}${amount.abs().toStringAsFixed(2)} ج.م",
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // هنا يجب التوجيه لصفحة الدفع (PaymentScreen) الموجودة في الكود الخاص بك [source: 31]
            // Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(amount: invoice.finalTotal, ...)));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'سيتم توجيهك لصفحة الدفع...',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: const Color(0xFF0056D2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0056D2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                "المتابعة للدفع (${invoice.finalTotal.toStringAsFixed(0)} ج.م)",
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

// ==========================================
// ويدجت مساعدة لرسم خط متقطع (Dashed Divider)
// ==========================================
class CustomDashedDivider extends StatelessWidget {
  final double height;
  final Color color;

  const CustomDashedDivider({
    super.key,
    this.height = 1,
    this.color = const Color(0xFFE5E7EB),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
