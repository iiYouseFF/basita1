import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:basita1/core/repositories/instapay_repository.dart';
import 'package:basita1/core/repositories/payment_log_repository.dart';
import 'package:basita1/core/session/user_session.dart';
import 'package:url_launcher/url_launcher.dart';

class InstaPayScreen extends StatefulWidget {
  final double amount;
  final String requestId;
  final String technicianId;
  final String technicianName;
  final String serviceName;

  const InstaPayScreen({
    super.key,
    required this.amount,
    required this.requestId,
    required this.technicianId,
    required this.technicianName,
    required this.serviceName,
  });

  @override
  State<InstaPayScreen> createState() => _InstaPayScreenState();
}

class _InstaPayScreenState extends State<InstaPayScreen> {
  final Color primaryBlue = const Color(0xFF005CEE);
  final Color textDark = const Color(0xFF111827);
  final Color textGrey = const Color(0xFF6B7280);
  final TextEditingController _instapayCodeController = TextEditingController();
  final TextEditingController _verificationController = TextEditingController();
  final InstaPayRepository _instapayRepo = InstaPayRepository();
  final PaymentLogRepository _paymentLogRepo = PaymentLogRepository();

  bool _isProcessing = false;
  String? _transactionId;
  bool _codeGenerated = false;

  @override
  void dispose() {
    _instapayCodeController.dispose();
    _verificationController.dispose();
    super.dispose();
  }

  Future<void> _createTransaction() async {
    setState(() => _isProcessing = true);
    try {
      final userId = UserSession.instance.phone;
      final transaction = await _instapayRepo.createTransaction(
        requestId: widget.requestId,
        senderId: userId,
        receiverId: widget.technicianId,
        amount: widget.amount,
        instapayCode: _instapayCodeController.text.trim().isEmpty
            ? null
            : _instapayCodeController.text.trim(),
      );
      setState(() {
        _transactionId = transaction.id;
        _codeGenerated = true;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchInstaPay() async {
    setState(() => _isProcessing = true);
    try {
      if (_transactionId == null) {
        await _createTransaction();
      }
      if (!mounted || _transactionId == null) return;

      final Uri uri = Uri.parse('https://ipn.eg/S/shamsnagy222gmail.co/instapay/4cWVQp');
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (mounted) setState(() => _isProcessing = false);
      if (!mounted) return;

      if (launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم فتح تطبيق InstaPay – بعد إتمام التحويل أكّد الدفع بالأسفل',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      } else {
        final bool openedInBrowser = await launchUrl(uri);
        if (!openedInBrowser && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تعذر فتح الرابط، تأكد من تثبيت تطبيق InstaPay',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyPayment() async {
    if (_verificationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال كود التحقق', style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final verified = await _instapayRepo.verifyPayment(
        transactionId: _transactionId!,
        code: _verificationController.text.trim(),
      );

      if (verified) {
        await _paymentLogRepo.logPayment(
          userId: UserSession.instance.phone,
          amount: widget.amount,
          paymentMethod: 'instapay',
          requestId: widget.requestId,
          technicianId: widget.technicianId,
        );

        await FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestId)
            .update({
          'status': 'completed',
          'paymentMethod': 'instapay',
        });

        if (mounted) {
          setState(() => _isProcessing = false);
          _showSuccessDialog();
        }
      } else {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('كود التحقق غير صحيح', style: GoogleFonts.cairo()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'تم الدفع بنجاح',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تم تحويل ${widget.amount.toStringAsFixed(0)} ج.م عبر InstaPay',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'العودة للرئيسية',
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الدفع عبر InstaPay',
            style: GoogleFonts.cairo(
              color: textDark,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: primaryBlue,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'المبلغ المطلوب',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: textGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.amount.toStringAsFixed(0)} ج.م',
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('نوع الخدمة', widget.serviceName),
                    const Divider(height: 24),
                    _buildDetailRow('الفني', widget.technicianName),
                    const Divider(height: 24),
                    _buildDetailRow('رقم الطلب', widget.requestId.substring(0, 8)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!_codeGenerated) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF005CEE), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'بالضغط على زر الدفع سيتم فتح تطبيق InstaPay لإتمام التحويل للفني. بعد إتمام الدفع فعليًا داخل التطبيق، أكّد العملية هنا لإنهاء الطلب.',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: textDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _launchInstaPay,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                    label: Text(
                      _isProcessing ? 'جاري الفتح...' : 'الدفع عبر تطبيق InstaPay',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'أكمل التحويل داخل تطبيق InstaPay، ثم أدخل كود التأكيد الظاهر لديك وأكّد الدفع لإنهاء الطلب.',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: textDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _verificationController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: '------',
                    hintStyle: GoogleFonts.cairo(
                      color: const Color(0xFFA1A1AA),
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _verifyPayment,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.verified, color: Colors.white, size: 20),
                    label: Text(
                      _isProcessing ? 'جاري التأكيد...' : 'تأكيد إتمام الدفع',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 14, color: textGrey),
        ),
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