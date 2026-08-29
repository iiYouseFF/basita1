import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// استدعاء ملف جلسة المستخدم لجلب معلوماته للتحقق الأمني
import 'package:basita1/core/session/user_session.dart';

// ==========================================
// 1. نموذج بيانات الفاتورة
// ==========================================
class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String serviceName;
  final String technicianName;
  final DateTime date;
  final double servicePrice;
  final double extraFees;
  final double discount;
  final double totalAmount;
  final String status;
  final String paymentMethod;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.serviceName,
    required this.technicianName,
    required this.date,
    required this.servicePrice,
    required this.extraFees,
    required this.discount,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
  });

  factory InvoiceModel.fromFirestore(DocumentSnapshot doc) {
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

    double total = parsePrice(data['finalTotal']) > 0
        ? parsePrice(data['finalTotal'])
        : (parsePrice(data['finalPrice']) > 0
              ? parsePrice(data['finalPrice'])
              : (parsePrice(data['acceptedPrice']) > 0
                    ? parsePrice(data['acceptedPrice'])
                    : parsePrice(data['price'])));

    String rawStatus = data['status'] ?? 'pending';
    String mappedStatus = 'pending';
    if (rawStatus == 'completed' ||
        rawStatus == 'paid' ||
        data['isPaid'] == true) {
      mappedStatus = 'paid';
    } else if (rawStatus == 'cancelled') {
      mappedStatus = 'cancelled';
    } else {
      mappedStatus = 'pending';
    }

    return InvoiceModel(
      id: doc.id,
      invoiceNumber:
          data['invoiceNumber'] ??
          '#INV-${doc.id.substring(0, min(doc.id.length, 5))}',
      serviceName: data['title'] ?? data['serviceName'] ?? 'خدمة عامة',
      technicianName:
          data['technicianName'] ??
          data['techName'] ??
          data['assignedTechnician'] ??
          'فني غير محدد',
      date:
          (data['invoiceIssuedAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      // تم التصحيح هنا لاستخدام parsePrice لتجنب الخطأ إذا كان laborCost يساوي null
      servicePrice: parsePrice(data['laborCost']) > 0
          ? parsePrice(data['laborCost'])
          : total,
      extraFees: parsePrice(data['materialsCost'] ?? 0.0),
      discount: 0.0,
      totalAmount: total > 0 ? total : parsePrice(data['amount']),
      status: mappedStatus,
      paymentMethod: data['paymentMethod'] ?? 'غير محدد',
    );
  }
}

// ==========================================
// 2. شاشة قائمة الفواتير
// ==========================================
class InvoicesListScreen extends StatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  State<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends State<InvoicesListScreen> {
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color bgLight = const Color(0xFFF8F9FA);
  final Color textDark = const Color(0xFF1D1D1D);
  final Color textGrey = const Color(0xFF6C757D);
  final Color borderGrey = const Color(0xFFDEE2E6);

  String _searchQuery = "";
  String _selectedFilter = 'all';

  String _formatArabicDate(DateTime date) {
    List<String> arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return "${date.day} ${arabicMonths[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String currentUserPhone = UserSession.instance.phone;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "فواتيري",
                style: GoogleFonts.cairo(
                  color: primaryBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "إدارة ومتابعة جميع فواتيرك",
                style: GoogleFonts.cairo(color: textGrey, fontSize: 12),
              ),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where(
                Filter.or(
                  Filter('userId', isEqualTo: currentUserId),
                  Filter('userPhone', isEqualTo: currentUserPhone),
                  Filter('phone', isEqualTo: currentUserPhone),
                ),
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }
            if (snapshot.hasError) {
              debugPrint("Firestore Error: ${snapshot.error}");
              return Center(
                child: Text(
                  'حدث خطأ في تحميل الفواتير\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            List<InvoiceModel> allInvoices = docs
                .map((doc) => InvoiceModel.fromFirestore(doc))
                .toList();

            allInvoices.sort((a, b) => b.date.compareTo(a.date));

            double totalPaid = 0;
            for (var inv in allInvoices) {
              if (inv.status == 'paid') {
                totalPaid += inv.totalAmount;
              }
            }
            int totalInvoicesCount = allInvoices.length;

            List<InvoiceModel> filteredInvoices = allInvoices.where((inv) {
              final matchesSearch =
                  inv.serviceName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  inv.invoiceNumber.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  inv.technicianName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
              final matchesFilter =
                  _selectedFilter == 'all' || inv.status == _selectedFilter;
              return matchesSearch && matchesFilter;
            }).toList();

            return Column(
              children: [
                _buildStatsHeader(totalInvoicesCount, totalPaid),
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: filteredInvoices.isEmpty
                      ? Center(
                          child: Text(
                            "لا توجد فواتير مطابقة",
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: textGrey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: filteredInvoices.length,
                          itemBuilder: (context, index) {
                            return _buildInvoiceCard(filteredInvoices[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsHeader(int count, double totalPaid) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGrey, width: 0.5),
              ),
              child: Column(
                children: [
                  Text(
                    "إجمالي الفواتير",
                    style: GoogleFonts.cairo(color: textGrey, fontSize: 13),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "$count",
                        style: GoogleFonts.cairo(
                          color: primaryBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "فاتورة",
                        style: GoogleFonts.cairo(
                          color: primaryBlue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGrey, width: 0.5),
              ),
              child: Column(
                children: [
                  Text(
                    "إجمالي المدفوع",
                    style: GoogleFonts.cairo(color: textGrey, fontSize: 13),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        totalPaid.toStringAsFixed(0),
                        style: GoogleFonts.cairo(
                          color: primaryBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "ج.م",
                        style: GoogleFonts.cairo(
                          color: primaryBlue,
                          fontSize: 14,
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: GoogleFonts.cairo(fontSize: 14),
        decoration: InputDecoration(
          hintText: "ابحث عن فاتورة",
          hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: borderGrey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: primaryBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildFilterChip('all', 'الكل'),
          const SizedBox(width: 8),
          _buildFilterChip('paid', 'مدفوعة'),
          const SizedBox(width: 8),
          _buildFilterChip('pending', 'قيد الانتظار'),
          const SizedBox(width: 8),
          _buildFilterChip('cancelled', 'ملغاة'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSelected ? primaryBlue : borderGrey),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;
    String statusLabel;

    if (invoice.status == 'paid') {
      statusBgColor = const Color(0xFFE6F4EA);
      statusTextColor = const Color(0xFF1E8E3E);
      statusIcon = Icons.check_circle_outline;
      statusLabel = "مدفوعة";
    } else if (invoice.status == 'pending') {
      statusBgColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFE65100);
      statusIcon = Icons.access_time;
      statusLabel = "قيد الانتظار";
    } else {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFD32F2F);
      statusIcon = Icons.cancel_outlined;
      statusLabel = "ملغاة";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailsScreen(invoice: invoice),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderGrey, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: GoogleFonts.cairo(
                          color: primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusTextColor, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              statusLabel,
                              style: GoogleFonts.cairo(
                                color: statusTextColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invoice.serviceName,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: textGrey),
                      const SizedBox(width: 4),
                      Text(
                        invoice.technicianName,
                        style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatArabicDate(invoice.date),
                        style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      invoice.totalAmount.toStringAsFixed(0),
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "ج.م",
                      style: GoogleFonts.cairo(fontSize: 14, color: textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. شاشة تفاصيل الفاتورة
// ==========================================
class InvoiceDetailsScreen extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  String _formatArabicDate(DateTime date) {
    List<String> arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return "${date.day} ${arabicMonths[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF0056D2);
    final Color textDark = const Color(0xFF1D1D1D);
    final Color textGrey = const Color(0xFF6C757D);

    Color statusBgColor = const Color(0xFFE6F4EA);
    Color statusTextColor = const Color(0xFF1E8E3E);
    IconData statusIcon = Icons.check_circle_outline;
    String statusLabel = "مدفوعة";

    if (invoice.status == 'pending') {
      statusBgColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFE65100);
      statusIcon = Icons.access_time;
      statusLabel = "قيد الانتظار";
    } else if (invoice.status == 'cancelled') {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFD32F2F);
      statusIcon = Icons.cancel_outlined;
      statusLabel = "ملغاة";
    } else if (invoice.status == 'paid') {
      statusBgColor = primaryBlue;
      statusTextColor = Colors.white;
      statusIcon = Icons.check_circle_outline;
      statusLabel = "مدفوعة";
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9FAFB),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "تفاصيل الفاتورة",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                invoice.invoiceNumber,
                style: GoogleFonts.cairo(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusLabel,
                      style: GoogleFonts.cairo(
                        color: statusTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(statusIcon, color: statusTextColor, size: 16),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Color(0xFFE5E7EB), thickness: 1),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "معلومات الخدمة",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow("الخدمة", invoice.serviceName),
              const SizedBox(height: 16),
              _buildInfoRow("الفني", invoice.technicianName),
              const SizedBox(height: 16),
              _buildInfoRow("التاريخ", _formatArabicDate(invoice.date)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "وسيلة الدفع",
                    style: GoogleFonts.cairo(color: textGrey, fontSize: 14),
                  ),
                  Row(
                    children: [
                      Text(
                        invoice.paymentMethod,
                        style: GoogleFonts.cairo(
                          color: textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        invoice.paymentMethod.contains('بطاقة')
                            ? Icons.credit_card
                            : Icons.money,
                        size: 18,
                        color: textDark,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "الملخص المالي",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFinanceRow(
                      "سعر الخدمة",
                      "${invoice.servicePrice.toStringAsFixed(0)} جنيه",
                      false,
                    ),
                    const SizedBox(height: 12),
                    _buildFinanceRow(
                      "رسوم إضافية",
                      "${invoice.extraFees.toStringAsFixed(0)} جنيه",
                      false,
                    ),
                    const SizedBox(height: 12),
                    _buildFinanceRow(
                      "الخصم",
                      "${invoice.discount.toStringAsFixed(0)} جنيه",
                      false,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFFD1D5DB), thickness: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "الإجمالي النهائي",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              invoice.totalAmount.toStringAsFixed(0),
                              style: GoogleFonts.cairo(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "جنيه",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "عرض الفاتورة",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: textGrey.withOpacity(0.5),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    "تحميل الفاتورة",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            color: const Color(0xFF6C757D),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: const Color(0xFF1D1D1D),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceRow(String title, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            color: const Color(0xFF4B5563),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: const Color(0xFF1F2937),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
