import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// removed: cloud_firestore - see docs/backend-prd.html
// removed: firebase_auth
import 'package:google_fonts/google_fonts.dart';

// استدعاء ملف جلسة المستخدم لجلب معلوماته عند حفظ البطاقة
import 'package:basita1/core/session/user_session.dart';
import 'package:basita1/core/network/mock_backend.dart';

class PaymentCardsScreen extends StatefulWidget {
  const PaymentCardsScreen({super.key});

  @override
  State<PaymentCardsScreen> createState() => _PaymentCardsScreenState();
}

class _PaymentCardsScreenState extends State<PaymentCardsScreen> {
  // التحقق من معرف المستخدم عبر Firebase Auth أو UserSession لضمان عدم حدوث خطأ تسجيل الدخول
  String get _userId {
    final authUid = MockAuth.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) {
      return authUid;
    }
    return UserSession.instance.phone.trim();
  }

  bool get _isLoggedIn {
    final authUid = MockAuth.currentUser?.uid;
    final sessionPhone = UserSession.instance.phone.trim();
    return (authUid != null && authUid.isNotEmpty) || sessionPhone.isNotEmpty;
  }

  // تحديد مسار الـ Collection ليكون مجموعة رئيسية منفصلة باسم PaymentCards[cite: 23]
  CollectionReference get _cardsCollection =>
      MockFirestore.collection('PaymentCards');

  // تعيين بطاقة كبطاقة أساسية للمستخدم الحالي فقط[cite: 23]
  Future<void> _setDefaultCard(String cardId) async {
    if (!_isLoggedIn) return;

    final batch = MockFirestore.batch();

    // نجلب فقط بطاقات هذا المستخدم لتعديل حالتها[cite: 23]
    final snapshot = await _cardsCollection
        .where('userId', isEqualTo: _userId)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == cardId});
    }

    await batch.commit();
  }

  // حذف بطاقة[cite: 23]
  Future<void> _deleteCard(String cardId) async {
    await _cardsCollection.doc(cardId).delete();
  }

  // فتح نافذة إضافة بطاقة جديدة[cite: 23]
  void _openAddCardBottomSheet(BuildContext context) {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('برجاء تسجيل الدخول أولاً', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCardBottomSheet(userId: _userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeFont = GoogleFonts.cairoTextTheme();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: themeFont,
          scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0D6EFD)),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(
              'بطاقاتي',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D6EFD),
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    children: [
                      Text(
                        'إدارة بطاقات الدفع المحفوظة واستخدمها بسهولة عند الدفع.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'البطاقات المحفوظة',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // جلب البطاقات الخاصة بالمستخدم الحالي فقط من المجموعة الرئيسية[cite: 23]
                      StreamBuilder<QuerySnapshot>(
                        stream: _isLoggedIn
                            ? _cardsCollection
                                  .where('userId', isEqualTo: _userId)
                                  .snapshots()
                            : const Stream.empty(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(30.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty ||
                              !_isLoggedIn) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              alignment: Alignment.center,
                              child: Text(
                                'لا توجد بطاقات محفوظة حالياً',
                                style: GoogleFonts.cairo(
                                  color: Colors.grey[500],
                                ),
                              ),
                            );
                          }

                          // جلب البيانات وترتيبها برمجياً بالأحدث لتجنب مشاكل الـ Indexes في فايربيس[cite: 23]
                          final docs = snapshot.data!.docs;
                          docs.sort((a, b) {
                            final aData = a.data() as Map<String, dynamic>;
                            final bData = b.data() as Map<String, dynamic>;
                            final aTime = aData['createdAt'] as Timestamp?;
                            final bTime = bData['createdAt'] as Timestamp?;
                            if (aTime == null || bTime == null) return 0;
                            return bTime.compareTo(aTime);
                          });

                          return Column(
                            children: docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return _buildCardItem(doc.id, data);
                            }).toList(),
                          );
                        },
                      ),

                      GestureDetector(
                        onTap: () => _openAddCardBottomSheet(context),
                        child: CustomPaint(
                          painter: _DashedRectPainter(
                            color: const Color(0xFFCBD5E1),
                          ),
                          child: Container(
                            height: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_card_rounded,
                                  color: Color(0xFF0D6EFD),
                                  size: 26,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+ إضافة بطاقة جديدة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0D6EFD),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFF0D6EFD),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'بياناتك آمنة. يتم حفظ بيانات بطاقتك بشكل آمن، ولا يتم تخزين رمز الأمان CVV.',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: const Color(0xFF1E3A8A),
                              height: 1.4,
                            ),
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

  Widget _buildCardItem(String docId, Map<String, dynamic> data) {
    final cardLast4 =
        data['cardLast4'] ??
        data['cardNumber']?.toString().substring(
          (data['cardNumber']?.toString().length ?? 4) - 4,
        ) ??
        '0000';
    final cardHolder = data['cardHolder'] ?? '';
    final expiryDate = data['expiryDate'] ?? '';
    final isDefault = data['isDefault'] ?? false;
    final cardType = data['cardType'] ?? 'visa';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'default') {
                    _setDefaultCard(docId);
                  } else if (value == 'delete') {
                    _deleteCard(docId);
                  }
                },
                itemBuilder: (context) => [
                  if (!isDefault)
                    PopupMenuItem(
                      value: 'default',
                      child: Text(
                        'تعيين كبطاقة أساسية',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'حذف البطاقة',
                      style: GoogleFonts.cairo(color: Colors.red),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '•••• •••• •••• $cardLast4',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildBrandLogo(cardType),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ الانتهاء',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    expiryDate,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'الاسم على البطاقة',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    cardHolder.toUpperCase(),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isDefault) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'البطاقة الأساسية',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
            ),
          ],
        ],
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
                        color: const Color(0xFFF79E1B).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
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
// Bottom Sheet Component: إضافة بطاقة جديدة
// ==========================================
class _AddCardBottomSheet extends StatefulWidget {
  final String userId;
  const _AddCardBottomSheet({super.key, required this.userId});

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

    // شرط حماية للتأكد من وجود المستخدم
    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطأ: لم يتم التعرف على المستخدم. يرجى تسجيل الدخول.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // حماية أمنية: تخزين آخر 4 أرقام فقط
      final cleanNumber = _numberController.text.replaceAll(' ', '');
      final last4 = cleanNumber.length >= 4
          ? cleanNumber.substring(cleanNumber.length - 4)
          : cleanNumber;
      final cardType = cleanNumber.startsWith('4') ? 'visa' : 'mastercard';

      // الإشارة إلى المجموعة الرئيسية PaymentCards[cite: 23]
      final cardsCollection = MockFirestore.collection(
        'PaymentCards',
      );

      // إزالة البطاقة الأساسية القديمة لنفس المستخدم إن وُجدت[cite: 23]
      if (_isDefault) {
        final snapshot = await cardsCollection
            .where('userId', isEqualTo: widget.userId)
            .get();

        final batch = MockFirestore.batch();
        for (var doc in snapshot.docs) {
          batch.update(doc.reference, {'isDefault': false});
        }
        await batch.commit();
      }

      // إضافة المستند الجديد مع تخزين آمن (آخر 4 أرقام فقط)
      await cardsCollection.add({
        'cardLast4': last4,
        'cardHolder': _holderController.text.trim(),
        'expiryDate': _expiryController.text.trim(),
        'isDefault': _isDefault,
        'cardType': cardType,
        'createdAt': DateTime.now(),
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
                      activeThumbColor: const Color(0xFF0D6EFD),
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

class _DashedRectPainter extends CustomPainter {
  final Color color;

  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 1.5;
    final double gap = 5.0;
    final Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    final Path path = Path()..addRRect(rrect);
    final Path metricsPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        metricsPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(metricsPath, dashedPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}