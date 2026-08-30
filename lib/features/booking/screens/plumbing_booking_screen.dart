import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/core/network/mock_backend.dart';
// removed: cloud_firestore - see docs/backend-prd.html

class PlumbingBookingScreen extends StatefulWidget {
  const PlumbingBookingScreen({super.key});

  @override
  State<PlumbingBookingScreen> createState() => _PlumbingBookingScreenState();
}

class _PlumbingBookingScreenState extends State<PlumbingBookingScreen> {
  // --- المتغيرات وحفظ الحالة ---
  final Color primaryBlue = const Color(0xFF005CEE); // لون الزر والعنوان
  final Color bgColor = const Color(0xFFF7F8FA); // لون الخلفية الرمادي الفاتح

  String _selectedFinishingType = 'تشطيب حمام';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;

  final List<String> _finishingTypes = [
    'تشطيب شقة كاملة',
    'تشطيب حمام',
    'تشطيب مطبخ',
    'تشطيب فيلا',
    'تشطيب مكتب',
    'تشطيب محل',
  ];

  // دالة الحفظ في Firebase Firestore
  Future<void> _submitRequest() async {
    // التحقق من إدخال البيانات الأساسية
    if (_areaController.text.trim().isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'برجاء استكمال جميع البيانات الأساسية والموعد',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. حفظ البيانات في كولكشن جديد مخصص للسباكة
      await MockFirestore.collection('plumbing_requests').add({
        'workCategory': 'سباكة',
        'finishingType': _selectedFinishingType,
        'area': "${_areaController.text.trim()} م²",
        'date':
            "${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}",
        'time': _selectedTime!.format(context),
        'budget': _budgetController.text.trim(),
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'createdAt': DateTime.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تسجيل الطلب بنجاح!',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // ===============================================================
        // TODO: حط هنا كود الانتقال للصفحة التانية اللي انت عاملها
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const YourSuccessPage()),
        // );
        // ===============================================================
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء إرسال الطلب',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // اختيار التاريخ
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // اختيار الوقت
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // واجهة عربية
      child: Scaffold(
        backgroundColor: bgColor,

        // الـ AppBar المتطابق مع الصورة
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'احجز تشطيب سباكة',
            style: GoogleFonts.tajawal(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),

        // المحتوى الأساسي
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. كارت نوع التشطيب
              _buildSectionCard(
                title: 'نوع التشطيب',
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 12.0,
                  alignment: WrapAlignment.start,
                  children: _finishingTypes.map((type) {
                    final isSelected = _selectedFinishingType == type;
                    return InkWell(
                      onTap: () =>
                          setState(() => _selectedFinishingType = type),
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryBlue
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          type,
                          style: GoogleFonts.tajawal(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 2. كارت مساحة المكان
              _buildSectionCard(
                title: 'مساحة المكان',
                child: TextFormField(
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.tajawal(),
                  decoration: InputDecoration(
                    hintText: 'مثال: 120',
                    hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade400),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text(
                        'م²',
                        style: GoogleFonts.tajawal(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. كارت الموعد
              _buildSectionCard(
                title: 'الموعد',
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: _buildInputDecoration(
                        hintText: _selectedDate == null
                            ? 'mm/dd/yyyy'
                            : "${_selectedDate!.year}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}",
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: _buildInputDecoration(
                        hintText: _selectedTime == null
                            ? '--:-- --'
                            : _selectedTime!.format(context),
                        icon: Icons.access_time,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. كارت الميزانية المتوقعة
              _buildSectionCard(
                title: 'الميزانية المتوقعة',
                child: TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'مثال: 15000',
                    hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade400),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text(
                        'جنيه',
                        style: GoogleFonts.tajawal(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. كارت ملاحظات
              _buildSectionCard(
                title: 'ملاحظات',
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: _buildInputDecoration(
                    hintText: 'أضف أي تفاصيل أخرى هنا...',
                  ),
                ),
              ),
              const SizedBox(height: 100), // مساحة للزر السفلي
            ],
          ),
        ),

        // الزر السفلي (Sticky Bottom Button)
        bottomSheet: Container(
          color: bgColor,
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 24.0,
            top: 12.0,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'طلب تشطيب سباكة',
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // --- دوال مساعدة للتصميم ---

  // دالة بناء الكارت الأبيض لكل قسم
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // دالة توحيد شكل حقول الإدخال
  InputDecoration _buildInputDecoration({String? hintText, IconData? icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade400),
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.grey.shade500, size: 22)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}