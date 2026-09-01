import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:basita1/core/services/technician_report_service.dart';

/// Technician Flow: Submit a maintenance report
/// 
/// Connects to n8n: POST https://basseeyta-api.duckdns.org/webhook/technician-report
/// 
/// Features:
/// - Validation: blocks if appliance_type or model empty → SnackBar
/// - Loading: disables button + CircularProgressIndicator
/// - Response verification: success only if {"status":"success"}
/// - Post-submit: success SnackBar + reset fields
/// - Error handling: try-catch → human-readable SnackBar
class TechnicianReportScreen extends StatefulWidget {
  const TechnicianReportScreen({super.key});

  @override
  State<TechnicianReportScreen> createState() => _TechnicianReportScreenState();
}

class _TechnicianReportScreenState extends State<TechnicianReportScreen> {
  // Design tokens (align with design_system.md)
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color primaryDark = Color(0xFF0053AC);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color errorRed = Color(0xFFDC2626);

  final _formKey = GlobalKey<FormState>();
  final _technicianNameController = TextEditingController();
  final _applianceTypeController = TextEditingController();
  final _modelController = TextEditingController();
  final _problemDescriptionController = TextEditingController();
  final _solutionNotesController = TextEditingController();
  final _costController = TextEditingController();

  final TechnicianReportService _service = TechnicianReportService();
  bool _isLoading = false;

  @override
  void dispose() {
    _technicianNameController.dispose();
    _applianceTypeController.dispose();
    _modelController.dispose();
    _problemDescriptionController.dispose();
    _solutionNotesController.dispose();
    _costController.dispose();
    _service.close();
    super.dispose();
  }

  Future<void> _submitReport() async {
    // Validation: block if appliance_type or model empty (spec requirement)
    final applianceType = _applianceTypeController.text.trim();
    final model = _modelController.text.trim();

    if (applianceType.isEmpty || model.isEmpty) {
      _showSnackBar(
        'يرجى ملء حقل نوع الجهاز والموديل',
        backgroundColor: errorRed,
        icon: Icons.error_outline,
      );
      return;
    }

    // Additional form validation if needed
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cost = TechnicianReportService.parseCost(_costController.text);

      final response = await _service.submitReport(
        technicianName: _technicianNameController.text,
        applianceType: applianceType,
        model: model,
        problemDescription: _problemDescriptionController.text,
        solutionNotes: _solutionNotesController.text,
        cost: cost,
      );

      if (!mounted) return;

      // Response verification: success only if {"status":"success"}
      final status = response['status']?.toString().toLowerCase();
      if (status == 'success') {
        _showSnackBar(
          'تم إرسال التقرير بنجاح ✓',
          backgroundColor: const Color(0xFF10B981),
          icon: Icons.check_circle_outline,
        );
        _resetFields();
      } else {
        // Defensive — service already throws if not success, but handle edge
        _showSnackBar(
          'فشل الإرسال: لم يتم تأكيد النجاح من الخادم',
          backgroundColor: errorRed,
          icon: Icons.warning_amber_rounded,
        );
      }
    } on TechnicianReportException catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.userMessage,
        backgroundColor: errorRed,
        icon: Icons.wifi_off_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        'حدث خطأ غير متوقع. حاول مرة أخرى.',
        backgroundColor: errorRed,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetFields() {
    _technicianNameController.clear();
    _applianceTypeController.clear();
    _modelController.clear();
    _problemDescriptionController.clear();
    _solutionNotesController.clear();
    _costController.clear();
    // Reset form validation state
    _formKey.currentState?.reset();
    setState(() {});
  }

  void _showSnackBar(
    String message, {
    required Color backgroundColor,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 16),
                  _buildHelperText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: primaryBlue, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'تقرير الصيانة',
        style: GoogleFonts.cairo(
          color: primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_rounded, color: primaryBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إرسال تقرير صيانة',
                  style: GoogleFonts.cairo(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'املأ بيانات الصيانة وسيتم حفظها تلقائياً',
                  style: GoogleFonts.cairo(color: textMuted, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('بيانات الفني والجهاز'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _technicianNameController,
            label: 'اسم الفني',
            hint: 'مثال: أحمد محمد',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _applianceTypeController,
            label: 'نوع الجهاز *',
            hint: 'مثال: ثلاجة، غسالة، تكييف',
            icon: Icons.devices_other_outlined,
            isRequired: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _modelController,
            label: 'الموديل *',
            hint: 'مثال: Samsung RT38',
            icon: Icons.model_training_outlined,
            isRequired: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
              return null;
            },
          ),
          const SizedBox(height: 20),
          Divider(color: borderColor.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: 20),
          _buildSectionTitle('تفاصيل الصيانة'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _problemDescriptionController,
            label: 'وصف المشكلة',
            hint: 'مثال: الضاغط لا يعمل، تسريب مياه...',
            icon: Icons.bug_report_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _solutionNotesController,
            label: 'ملاحظات الحل',
            hint: 'مثال: تم استبدال الريلاي، تنظيف الفلتر...',
            icon: Icons.build_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _costController,
            label: 'التكلفة (ج.م)',
            hint: 'مثال: 1200',
            icon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v != null && v.trim().isNotEmpty) {
                final sanitized = v.replaceAll(',', '').trim();
                if (double.tryParse(sanitized) == null) {
                  return 'أدخل رقماً صحيحاً';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.cairo(color: textDark, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: GoogleFonts.cairo(color: textDark, fontSize: 13, fontWeight: FontWeight.w600)),
            if (isRequired) Text(' *', style: GoogleFonts.cairo(color: errorRed, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.cairo(color: textDark, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(color: textMuted, fontSize: 13),
            prefixIcon: Icon(icon, color: textMuted, size: 20),
            filled: true,
            fillColor: bgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: errorRed)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: errorRed, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: primaryBlue.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('إرسال التقرير', style: GoogleFonts.cairo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Widget _buildHelperText() {
    return Center(
      child: Text(
        'الحقول المميزة بـ * إلزامية',
        style: GoogleFonts.cairo(color: textMuted, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }
}
