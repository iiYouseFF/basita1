import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/core/network/mock_backend.dart';
// removed: cloud_firestore - see docs/backend-prd.html

class PaintingBookingScreen extends StatefulWidget {
  const PaintingBookingScreen({super.key});

  @override
  State<PaintingBookingScreen> createState() => _PaintingBookingScreenState();
}

class _PaintingBookingScreenState extends State<PaintingBookingScreen> {
  // المتغيرات لحفظ البيانات
  String selectedFinishingType = 'تشطيب محل';
  String? selectedPaintType;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool isLoading = false;

  final List<String> finishingTypes = [
    'تشطيب شقة',
    'تشطيب فيلا',
    'تشطيب مكتب',
    'تشطيب محل',
    'تشطيب كامل',
    'إعادة تشطيب',
  ];

  final List<String> paintTypes = [
    'دهان بلاستيك',
    'دهان زيت',
    'قطيفة',
    'ورق حائط',
    'أخرى',
  ];

  // دالة الحفظ في فايربيز
  Future<void> _submitRequest() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedPaintType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'برجاء استكمال جميع البيانات الأساسية',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // إنشاء كولكشن جديد باسم painting_requests
      await MockFirestore.collection('painting_requests').add({
        'workType': 'نقاشة',
        'finishingType': selectedFinishingType,
        'paintType': selectedPaintType,
        'date':
            "${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}",
        'time': selectedTime!.format(context),
        'budget': _budgetController.text.trim(),
        'notes': _notesController.text.trim(),
        'status': 'pending', // حالة الطلب
        'createdAt': DateTime.now(),
      });

      // TODO: قم بإلغاء التعليق عن الكود التالي وضع اسم صفحة النجاح الخاصة بك
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const YourSuccessScreen()),
      // );

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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء إرسال الطلب',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // اختيار التاريخ
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // اختيار الوقت
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // توحيد الألوان
    const Color primaryBlue = Color(0xFF005CEE);
    const Color bgColor = Color(0xFFF8F9FA);

    return Directionality(
      textDirection: TextDirection.rtl, // لضمان عرض الواجهة باللغة العربية
      child: Scaffold(
        backgroundColor: bgColor,

        // --- تعديل الـ AppBar ليتطابق مع الصورة ---
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          // زر الرجوع على اليمين
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          // العنوان في المنتصف
          title: Text(
            'احجز تشطيب نقاشة',
            style: GoogleFonts.tajawal(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          // الأيقونة الدائرية على اليسار
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Center(
                child: CircleAvatar(
                  backgroundColor: primaryBlue.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.format_paint,
                    color: primaryBlue,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),

        // ----------------------------------------
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // كارت نوع التشطيب
              _buildCard(
                title: 'نوع التشطيب',
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: finishingTypes.map((type) {
                    final isSelected = selectedFinishingType == type;
                    return ChoiceChip(
                      label: Text(
                        type,
                        style: GoogleFonts.tajawal(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: primaryBlue,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? primaryBlue
                              : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (bool selected) {
                        setState(() => selectedFinishingType = type);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // كارت نوع الدهان
              _buildCard(
                title: 'نوع الدهان',
                child: DropdownButtonFormField<String>(
                  decoration: _inputDecoration(),
                  hint: Text('اختر نوع الدهان', style: GoogleFonts.tajawal()),
                  initialValue: selectedPaintType,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: paintTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, style: GoogleFonts.tajawal()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => selectedPaintType = newValue);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // كارت الموعد
              _buildCard(
                title: 'الموعد',
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: _inputDecoration(
                        hintText: selectedDate == null
                            ? 'mm/dd/yyyy'
                            : "${selectedDate!.year}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}",
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: _inputDecoration(
                        hintText: selectedTime == null
                            ? '--:-- --'
                            : selectedTime!.format(context),
                        icon: Icons.access_time,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // كارت الميزانية المتوقعة
              _buildCard(
                title: 'الميزانية المتوقعة',
                child: TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    hintText: 'مثال: 8000 جنيه',
                    icon: Icons.money,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // كارت ملاحظات
              _buildCard(
                title: 'ملاحظات',
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    hintText: 'أضف أي تفاصيل أخرى...',
                  ),
                ),
              ),
              const SizedBox(height: 100), // مساحة للزر السفلي
            ],
          ),
        ),

        // الزر السفلي
        bottomSheet: Container(
          color: bgColor,
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'طلب تشطيب نقاشة',
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

  // ويدجت مساعدة لبناء الكروت البيضاء
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // تصميم حقول الإدخال لتكون موحدة وشبه الصورة
  InputDecoration _inputDecoration({String? hintText, IconData? icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade500),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade600) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF005CEE)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}