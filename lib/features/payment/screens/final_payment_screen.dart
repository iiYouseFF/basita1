import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// استدعاء ملف جلسة المستخدم لجلب معلوماته عند حفظ البطاقة
import 'package:basita1/core/session/user_session.dart';

// ==========================================
// 1. نموذج بيانات طلب العميل (Client Request Model)
// ==========================================
class ClientRequestModel {
  final String id;
  final String serviceName;
  final String technicianName;
  final String technicianId;
  final double finalTotal;
  final String status;
  final DateTime? createdAt;

  ClientRequestModel({
    required this.id,
    required this.serviceName,
    required this.technicianName,
    required this.technicianId,
    required this.finalTotal,
    required this.status,
    this.createdAt,
  });

  factory ClientRequestModel.fromFirestore(DocumentSnapshot doc) {
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

    // [تصحيح المشكلة الأولى]:
    // تجاهلنا حقل finalTotal تماماً لأنه كان يجمع الميزانية (Budget) مع سعر الخدمة بالخطأ.
    // الاعتماد الأساسي سيكون على السعر النهائي الذي قدمه الفني.
    double finalPrice = parsePrice(data['finalPrice']);
    double acceptedPrice = parsePrice(data['acceptedPrice']);
    double servicePrice = parsePrice(data['servicePrice']);
    double priceVal = parsePrice(data['price']);

    // أولوية السعر: السعر النهائي > السعر المقبول > سعر الخدمة > السعر العادي
    double correctTotal = finalPrice > 0
        ? finalPrice
        : (acceptedPrice > 0
              ? acceptedPrice
              : (servicePrice > 0 ? servicePrice : priceVal));

    return ClientRequestModel(
      id: doc.id,
      serviceName: data['title'] ?? data['serviceName'] ?? 'طلب خدمة صيانة',
      technicianName:
          data['technicianName'] ??
          data['techName'] ??
          data['assignedTechnician'] ??
          'جاري تحديد الفني',
      technicianId:
          data['technicianId'] ??
          data['techId'] ??
          data['assignedTechnicianId'] ??
          '',
      finalTotal: correctTotal, // إرسال السعر المصحح بدون الميزانية
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

// ==========================================
// 2. صفحة طلباتي للعميل (Client Requests Screen)
// ==========================================
class ClientRequestsScreen extends StatefulWidget {
  const ClientRequestsScreen({super.key});

  @override
  State<ClientRequestsScreen> createState() => _ClientRequestsScreenState();
}

class _ClientRequestsScreenState extends State<ClientRequestsScreen> {
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color bgLight = const Color(0xFFF8F9FA);

  bool _isAwaitingPayment(String status) {
    return [
      'awaiting_payment',
      'task_finished_pending_invoice',
      'ready_to_pay',
    ].contains(status);
  }

  String _getStatusLabel(String status) {
    if (_isAwaitingPayment(status)) return "جاهز للدفع";
    if (status == 'completed' || status == 'paid') return "مكتمل";
    if (status == 'in_progress' || status == 'accepted') return "قيد التنفيذ";
    if (status == 'pending_cash') return "قيد التحصيل نقداً";
    return "قيد الانتظار";
  }

  Color _getStatusBgColor(String status) {
    if (_isAwaitingPayment(status)) return const Color(0xFFE0F2FE);
    if (status == 'completed' || status == 'paid') {
      return const Color(0xFFD1E7DD);
    }
    if (status == 'in_progress' ||
        status == 'accepted' ||
        status == 'pending_cash') {
      return const Color(0xFFFFF3CD);
    }
    return const Color(0xFFF8F9FA);
  }

  Color _getStatusTextColor(String status) {
    if (_isAwaitingPayment(status)) return primaryBlue;
    if (status == 'completed' || status == 'paid') {
      return const Color(0xFF0F5132);
    }
    if (status == 'in_progress' ||
        status == 'accepted' ||
        status == 'pending_cash') {
      return const Color(0xFF856404);
    }
    return const Color(0xFF6C757D);
  }

  void _handleCardTap(ClientRequestModel request) {
    if (_isAwaitingPayment(request.status)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            amount: request.finalTotal,
            serviceName: request.serviceName,
            technicianName: request.technicianName,
            technicianId: request.technicianId,
            requestId: request.id,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            request.status == 'completed' || request.status == 'paid'
                ? 'تم دفع هذا الطلب وإكماله بنجاح.'
                : (request.status == 'pending_cash'
                      ? 'في انتظار تحصيل المبلغ نقداً لإكمال الطلب.'
                      : 'الطلب ما زال قيد المتابعة ولم يتم إصدار فاتورته بعد.'),
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: primaryBlue,
        ),
      );
    }
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
          title: Text(
            "طلباتي",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
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
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0056D2)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ أثناء تحميل البيانات',
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "لا توجد طلبات حالية",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: const Color(0xFF6C757D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            final requests = docs
                .map((doc) => ClientRequestModel.fromFirestore(doc))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final bool isReadyToPay = _isAwaitingPayment(request.status);

                return GestureDetector(
                  onTap: () => _handleCardTap(request),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isReadyToPay
                            ? primaryBlue
                            : const Color(0xFFDEE2E6),
                        width: isReadyToPay ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                request.serviceName,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1D1D1D),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusBgColor(request.status),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                _getStatusLabel(request.status),
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusTextColor(request.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Color(0xFF6C757D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "الفني: ${request.technicianName}",
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: const Color(0xFF6C757D),
                              ),
                            ),
                          ],
                        ),
                        if (isReadyToPay) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "المطلوب سداده:",
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: const Color(0xFF1D1D1D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${request.finalTotal.toInt()} ج.م",
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _handleCardTap(request),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "ادفع الآن",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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
}

// ==========================================
// 3. صفحة الدفع الإلكتروني (Payment Screen)
// ==========================================
class PaymentScreen extends StatefulWidget {
  final double amount;
  final String serviceName;
  final String technicianName;
  final String technicianId;
  final String requestId;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.serviceName,
    required this.technicianName,
    this.technicianId = '',
    required this.requestId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color bgLight = const Color(0xFFF8F9FA);
  final Color textDark = const Color(0xFF1D1D1D);
  final Color textGrey = const Color(0xFF6C757D);
  final Color borderGrey = const Color(0xFFDEE2E6);

  int _selectedMethod = 0; // 0: بطاقة بنكية, 1: محفظة, 2: كاش
  String? _selectedSavedCardId;
  bool _useNewCard = false;
  bool _saveNewCard = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _holderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String get _userId {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) {
      return authUid;
    }
    return UserSession.instance.phone.trim();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _openAddCardBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCardBottomSheet(userId: _userId),
    );
  }

  // دالة بناء فورم البطاقة الجديدة لمنع التكرار واستدعائها في حالات متعددة
  Widget _buildNewCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _numberController,
            label: "رقم البطاقة",
            hint: "0000 0000 0000 0000",
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: (v) => (v == null || v.replaceAll(' ', '').length < 16)
                ? 'أدخل رقم بطاقة صحيح'
                : null,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _holderController,
            label: "اسم حامل البطاقة",
            hint: "الاسم كما هو مكتوب على البطاقة",
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'أدخل اسم حامل البطاقة'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _expiryController,
                  label: "تاريخ الانتهاء",
                  hint: "MM / YY",
                  keyboardType: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _CardExpiryFormatter(),
                  ],
                  validator: (v) =>
                      (v == null || v.length < 5) ? 'غير صحيح' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _cvvController,
                  label: "CVV",
                  hint: "•••",
                  icon: Icons.info_outline,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (v) =>
                      (v == null || v.length < 3) ? 'غير صحيح' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _saveNewCard,
                activeColor: primaryBlue,
                onChanged: (val) {
                  setState(() => _saveNewCard = val ?? false);
                },
              ),
              Text(
                "حفظ بيانات البطاقة لاستخدامها مستقبلاً",
                style: GoogleFonts.cairo(fontSize: 12, color: textDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    // [تصحيح المشكلة الثانية]: إجبار العميل على إضافة أو إختيار بطاقة
    if (_selectedMethod == 0) {
      // إذا لم يختار بطاقة، أو كان هناك طلب لاستخدام بطاقة جديدة (أو لا يملك بطاقات أساساً)
      if (_selectedSavedCardId == null || _useNewCard) {
        // نتحقق بقوة من صحة بيانات البطاقة الجديدة قبل المرور للخطوة التالية
        if (_formKey.currentState == null ||
            !_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'يجب إدخال بيانات بطاقة دفع صالحة لإتمام الدفع.',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return; // منع عملية الدفع بالكامل
        }

        if (_saveNewCard) {
          try {
            final cleanNumber = _numberController.text.replaceAll(' ', '');
            final cardLast4 = cleanNumber.length >= 4
                ? cleanNumber.substring(cleanNumber.length - 4)
                : cleanNumber;
            final cardType = cleanNumber.startsWith('4')
                ? 'visa'
                : 'mastercard';

            await FirebaseFirestore.instance.collection('PaymentCards').add({
              'cardLast4': cardLast4,
              'cardHolder': _holderController.text.trim(),
              'expiryDate': _expiryController.text.trim(),
              'isDefault': false,
              'cardType': cardType,
              'createdAt': FieldValue.serverTimestamp(),
              'userId': _userId,
              'userName': UserSession.instance.name,
              'userPhone': UserSession.instance.phone,
              'userEmail': UserSession.instance.email,
              'userCity': UserSession.instance.city,
              'userGovernorate': UserSession.instance.governorate,
            });
          } catch (e) {
            print("Error saving card: $e");
          }
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      String methodTitle = _selectedMethod == 0
          ? "بطاقة بنكية"
          : _selectedMethod == 1
          ? "محفظة إلكترونية"
          : "كاش";

      bool isCash = _selectedMethod == 2;

      if (widget.requestId.isNotEmpty) {
        final reqRef = FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestId);

        final reqDoc = await reqRef.get();
        String techId = widget.technicianId;

        if (techId.isEmpty && reqDoc.exists) {
          final data = reqDoc.data() ?? {};
          techId =
              data['technicianId'] ??
              data['techId'] ??
              data['assignedTechnicianId'] ??
              data['tech_id'] ??
              '';
        }

        Map<String, dynamic> updateData = {
          'status': isCash ? 'pending_cash' : 'completed',
          'isPaid': !isCash,
          'paidAt': FieldValue.serverTimestamp(),
          'paymentMethod': methodTitle,
          'paidAmount': widget.amount,
        };
        if (techId.isNotEmpty) {
          updateData['technicianId'] = techId;
        }
        await reqRef.update(updateData);

        if (techId.isNotEmpty) {
          final techRef = FirebaseFirestore.instance
              .collection('technicians')
              .doc(techId);

          final techSnap = await techRef.get();

          DateTime now = DateTime.now();
          String todayStr =
              "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

          if (techSnap.exists) {
            Map<String, dynamic>? techData = techSnap.data();
            String lastDateStr = techData?['lastEarningDateStr'] ?? '';

            double currentTodayEarnings = 0.0;
            int currentTodayOrders = 0;

            if (lastDateStr == todayStr) {
              currentTodayEarnings =
                  ((techData?['todayEarnings'] ?? 0.0) as num).toDouble() +
                  widget.amount;
              currentTodayOrders =
                  ((techData?['todayOrdersCount'] ?? 0) as num).toInt() + 1;
            } else {
              currentTodayEarnings = widget.amount.toDouble();
              currentTodayOrders = 1;
            }

            Map<String, dynamic> updates = {
              'totalEarnings': FieldValue.increment(widget.amount),
              'todayEarnings': currentTodayEarnings,
              'todayOrdersCount': currentTodayOrders,
              'lastEarningDateStr': todayStr,
              'lastEarningTimestamp': FieldValue.serverTimestamp(),
            };

            if (!isCash) {
              updates['walletBalance'] = FieldValue.increment(widget.amount);
            }

            await techRef.update(updates);
          } else {
            Map<String, dynamic> setData = {
              'walletBalance': isCash ? 0.0 : widget.amount,
              'totalEarnings': widget.amount,
              'todayEarnings': widget.amount,
              'todayOrdersCount': 1,
              'lastEarningDateStr': todayStr,
              'lastEarningTimestamp': FieldValue.serverTimestamp(),
            };
            await techRef.set(setData, SetOptions(merge: true));
          }

          await FirebaseFirestore.instance.collection('transactions').add({
            'technicianId': techId,
            'requestId': widget.requestId,
            'serviceName': widget.serviceName,
            'amount': widget.amount,
            'isPositive': !isCash,
            'type': isCash ? 'cash_collection' : 'income',
            'paymentMethod': methodTitle,
            'createdAt': FieldValue.serverTimestamp(),
            'dateStr': todayStr,
          });
        }
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            amount: widget.amount,
            paymentMethod: methodTitle,
            requestId: widget.requestId,
          ),
        ),
      );
    } catch (e) {
      print("Payment Error: $e");
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PaymentFailedScreen()),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "الدفع الإلكتروني",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceSummaryCard(),
              const SizedBox(height: 24),
              Text(
                "اختر طريقة الدفع",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildBankCardSection(),
              const SizedBox(height: 12),
              _buildSimpleOption(
                index: 1,
                title: "محفظة إلكترونية",
                subtitle: "الدفع باستخدام محفظتك الإلكترونية",
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 12),
              _buildSimpleOption(
                index: 2,
                title: "الدفع عند إتمام الخدمة",
                subtitle: "الدفع نقداً للفني مباشرة",
                icon: Icons.payments_outlined,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: textGrey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "بيانات الدفع الخاصة بك مشفرة وآمنة.",
                    style: GoogleFonts.cairo(color: textGrey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomPayBar(),
      ),
    );
  }

  Widget _buildServiceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "دفع مقابل الخدمة",
                    style: GoogleFonts.cairo(fontSize: 13, color: textGrey),
                  ),
                  Text(
                    widget.serviceName,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: textGrey),
                      const SizedBox(width: 4),
                      Text(
                        widget.technicianName,
                        style: GoogleFonts.cairo(fontSize: 13, color: textGrey),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "#${widget.requestId.length > 8 ? widget.requestId.substring(0, 8) : widget.requestId}",
                    style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.amount.toInt().toString(),
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "جنيه",
                        style: GoogleFonts.cairo(
                          fontSize: 14,
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
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الإجمالي النهائي",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Text(
                "${widget.amount.toInt()} جنيه",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankCardSection() {
    bool isSelected = _selectedMethod == 0;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : borderGrey,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? primaryBlue : borderGrey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "بطاقة بنكية",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        "الدفع باستخدام بطاقاتك المحفوظة أو بطاقة جديدة",
                        style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.credit_card, color: primaryBlue, size: 28),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('PaymentCards')
                    .where('userId', isEqualTo: _userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    // إجبار المستخدم على رؤية وتعبئة استمارة البطاقة إن لم يمتلك بطاقات محفوظة
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            "لا توجد بطاقات محفوظة حالياً. يرجى إدخال بيانات بطاقة جديدة لإتمام عملية الدفع.",
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                        _buildNewCardForm(),
                      ],
                    );
                  }

                  // فرز البطاقات: البطاقة الأساسية أولاً ثم الأحدث
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> sortedDocs =
                      List.from(docs);
                  sortedDocs.sort((a, b) {
                    final aData = a.data();
                    final bData = b.data();
                    final aDefault = aData['isDefault'] ?? false;
                    final bDefault = bData['isDefault'] ?? false;
                    if (aDefault && !bDefault) return -1;
                    if (!aDefault && bDefault) return 1;
                    final aTime = aData['createdAt'] as Timestamp?;
                    final bTime = bData['createdAt'] as Timestamp?;
                    if (aTime == null || bTime == null) return 0;
                    return bTime.compareTo(aTime);
                  });

                  if (_selectedSavedCardId == null && !_useNewCard) {
                    QueryDocumentSnapshot<Map<String, dynamic>> defaultDoc =
                        sortedDocs.first;
                    for (var d in sortedDocs) {
                      if (d.data()['isDefault'] == true) {
                        defaultDoc = d;
                        break;
                      }
                    }
                    _selectedSavedCardId = defaultDoc.id;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "البطاقات المحفوظة",
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...sortedDocs.map((doc) {
                        final data = doc.data();
                        final docId = doc.id;
                        final last4 = (data['cardLast4'] ?? data['cardNumber'] ?? '0000').toString();
                        final displayLast4 = last4.length >= 4 ? last4.substring(last4.length - 4) : last4;
                        final cardHolder = data['cardHolder'] ?? '';
                        final expiryDate = data['expiryDate'] ?? '';
                        final cardType = data['cardType'] ?? 'visa';
                        final isDefault = data['isDefault'] ?? false;
                        final isCardSelected =
                            !_useNewCard && _selectedSavedCardId == docId;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _useNewCard = false;
                              _selectedSavedCardId = docId;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCardSelected
                                  ? Colors.white
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCardSelected
                                    ? primaryBlue
                                    : const Color(0xFFE2E8F0),
                                width: isCardSelected ? 1.5 : 1,
                              ),
                              boxShadow: isCardSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryBlue.withOpacity(0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: docId,
                                      groupValue: _useNewCard
                                          ? null
                                          : _selectedSavedCardId,
                                      activeColor: primaryBlue,
                                      onChanged: (val) {
                                        setState(() {
                                          _useNewCard = false;
                                          _selectedSavedCardId = val;
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "•••• •••• •••• $displayLast4",
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        color: textDark,
                                      ),
                                    ),
                                    const Spacer(),
                                    _buildBrandLogo(cardType),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        cardHolder.toUpperCase(),
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textGrey,
                                        ),
                                      ),
                                      if (expiryDate.isNotEmpty)
                                        Text(
                                          "Exp: $expiryDate",
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: textGrey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isDefault) ...[
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'البطاقة الأساسية',
                                        style: GoogleFonts.cairo(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _useNewCard = !_useNewCard;
                                if (_useNewCard) {
                                  _selectedSavedCardId = null;
                                }
                              });
                            },
                            icon: Icon(
                              _useNewCard ? Icons.credit_card : Icons.add,
                              color: primaryBlue,
                              size: 20,
                            ),
                            label: Text(
                              _useNewCard
                                  ? "استخدام بطاقة محفوظة"
                                  : "إدخال بطاقة جديدة مباشرة",
                              style: GoogleFonts.cairo(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _openAddCardBottomSheet,
                            icon: const Icon(
                              Icons.add_card,
                              color: Color(0xFF0D6EFD),
                            ),
                            tooltip: 'إضافة بطاقة وإدارتها',
                          ),
                        ],
                      ),
                      if (_useNewCard) ...[
                        const SizedBox(height: 12),
                        _buildNewCardForm(),
                      ],
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo(String cardType) {
    bool isVisa = cardType.toLowerCase() == 'visa';
    return Container(
      width: 42,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: isVisa
            ? Text(
                'VISA',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF1A1F71),
                  fontSize: 12,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEB001B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-4, 0),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF79E1B).withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSimpleOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : borderGrey,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? primaryBlue : borderGrey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                  ),
                ],
              ),
            ),
            Icon(icon, color: textGrey, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: textGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
            suffixIcon: icon != null
                ? Icon(icon, color: textGrey, size: 20)
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPayBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgLight,
        border: Border(top: BorderSide(color: borderGrey, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "المبلغ الكلي",
                  style: GoogleFonts.cairo(fontSize: 13, color: textGrey),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.amount.toInt().toString(),
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "جنيه",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        "ادفع ${widget.amount.toInt()} جنيه",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

// ==========================================
// 4. صفحة نجاح الدفع (Payment Success Screen)
// ==========================================
class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String paymentMethod;
  final String requestId;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF0056D2);
    final Color textDark = const Color(0xFF1D1D1D);
    final Color textGrey = const Color(0xFF6C757D);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  paymentMethod == "كاش"
                      ? "تم تسجيل الدفع نقداً"
                      : "تم الدفع بنجاح",
                  style: GoogleFonts.cairo(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  paymentMethod == "كاش"
                      ? "تم تأكيد طلب الدفع النقدي وتحديث حالة الطلب."
                      : "تم تأكيد عملية الدفع وتحديث حالة الطلب.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 16, color: textGrey),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        "المبلغ",
                        "${amount.toInt()} ج.م",
                        textDark,
                        true,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "طريقة الدفع",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: textGrey,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                paymentMethod,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                paymentMethod == "كاش"
                                    ? Icons.money
                                    : Icons.credit_card,
                                size: 20,
                                color: textGrey,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      _buildDetailRow(
                        "رقم الطلب",
                        "#${requestId.length > 8 ? requestId.substring(0, 8) : requestId}",
                        textDark,
                        false,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      _buildDetailRow(
                        "الحالة",
                        paymentMethod == "كاش"
                            ? "في انتظار التحصيل"
                            : "مكتمـل ومدفوع",
                        primaryBlue,
                        false,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "العودة للرئيسية",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor,
    bool isBold,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: const Color(0xFF6C757D),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 5. صفحة فشل الدفع (Payment Failed Screen)
// ==========================================
class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF0056D2);
    final Color redColor = const Color(0xFFDC3545);
    final Color textDark = const Color(0xFF1D1D1D);
    final Color textGrey = const Color(0xFF6C757D);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: redColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: redColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "تعذر إتمام الدفع",
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "لم نتمكن من إتمام عملية الدفع. حاول مرة\nأخرى أو اختر طريقة دفع أخرى.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: textGrey,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "إعادة المحاولة",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: Text(
                      "العودة للصفحة الرئيسية",
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: textGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

// ==========================================
// 6. Bottom Sheet Component: إضافة بطاقة جديدة
// ==========================================
class _AddCardBottomSheet extends StatefulWidget {
  final String userId;
  const _AddCardBottomSheet({Key? key, required this.userId}) : super(key: key);

  @override
  State<_AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<_AddCardBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _numberController = TextEditingController();
  final _holderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _numberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cleanNumber = _numberController.text.replaceAll(' ', '');
      final cardType = cleanNumber.startsWith('4') ? 'visa' : 'mastercard';

      final cardsCollection = FirebaseFirestore.instance.collection(
        'PaymentCards',
      );

      if (_isDefault) {
        final snapshot = await cardsCollection
            .where('userId', isEqualTo: widget.userId)
            .get();

        final batch = FirebaseFirestore.instance.batch();
        for (var doc in snapshot.docs) {
          batch.update(doc.reference, {'isDefault': false});
        }
        await batch.commit();
      }

      await cardsCollection.add({
        'cardLast4': cleanNumber.length >= 4 ? cleanNumber.substring(cleanNumber.length - 4) : cleanNumber,
        'cardHolder': _holderController.text.trim(),
        'expiryDate': _expiryController.text.trim(),
        'isDefault': _isDefault,
        'cardType': cardType,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': widget.userId,
        'userName': UserSession.instance.name,
        'userPhone': UserSession.instance.phone,
        'userEmail': UserSession.instance.email,
        'userCity': UserSession.instance.city,
        'userGovernorate': UserSession.instance.governorate,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ البطاقة بنجاح', style: GoogleFonts.cairo()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء الحفظ: $e',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'إضافة بطاقة جديدة',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D6EFD),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('رقم البطاقة'),
                TextFormField(
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  decoration: _inputDecoration(
                    hint: '0000 0000 0000 0000',
                    prefixIcon: const Icon(
                      Icons.credit_card_rounded,
                      color: Colors.grey,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.replaceAll(' ', '').length < 16)
                      ? 'أدخل رقم بطاقة صحيح'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('اسم حامل البطاقة'),
                TextFormField(
                  controller: _holderController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _inputDecoration(
                    hint: 'الاسم كما هو مكتوب على البطاقة',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'أدخل اسم حامل البطاقة'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('تاريخ الانتهاء'),
                          TextFormField(
                            controller: _expiryController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _CardExpiryFormatter(),
                            ],
                            decoration: _inputDecoration(hint: 'MM / YY'),
                            validator: (v) =>
                                (v == null || v.length < 5) ? 'غير صحيح' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('CVV'),
                          TextFormField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: _inputDecoration(hint: '• • •'),
                            validator: (v) =>
                                (v == null || v.length < 3) ? 'غير صحيح' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تعيين كبطاقة أساسية',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    Switch(
                      value: _isDefault,
                      activeColor: const Color(0xFF0D6EFD),
                      onChanged: (val) => setState(() => _isDefault = val),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'حفظ البطاقة',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(
        color: const Color(0xFF94A3B8),
        fontSize: 13,
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}

// ==========================================
// 7. Formatters
// ==========================================
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(' ', '');
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write(' / ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
