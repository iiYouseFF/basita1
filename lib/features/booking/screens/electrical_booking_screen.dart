import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:basita1/features/booking/screens/electrical_bookings_service.dart'; // استدعاء ملف خدمة الفايربيس

class ElectricalBookingScreen extends StatefulWidget {
  const ElectricalBookingScreen({super.key});

  @override
  State<ElectricalBookingScreen> createState() =>
      _ElectricalBookingScreenState();
}

class _ElectricalBookingScreenState extends State<ElectricalBookingScreen> {
  final ElectricalBookingService _bookingService = ElectricalBookingService();

  // عناصر التحكم وحفظ الحالات
  String? _selectedFinishingType;
  String? _selectedRoomsCount;
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isLoading = false;

  final List<String> _finishingOptions = [
    'تشطيب شقة',
    'تشطيب فيلا',
    'تشطيب مكتب',
    'تشطيب محل',
    'تشطيب كامل',
    'تشطيب جزئي',
  ];

  final List<String> _roomsOptions = [
    'غرفة واحدة',
    'غرفتين',
    '3 غرف',
    '4 غرف',
    '5 غرف أو أكثر',
  ];

  // اختيار التاريخ
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // اختيار الوقت
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // إرسال البيانات إلى Firebase والتنقل
  Future<void> _submitBooking() async {
    if (_selectedFinishingType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('برجاء اختيار نوع التشطيب')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formattedDate = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : 'غير محدد';
      final formattedTime = _selectedTime != null
          ? _selectedTime!.format(context)
          : 'غير محدد';

      // حفظ البيانات في الفايربيس
      await _bookingService.saveBookingData(
        finishingType: _selectedFinishingType!,
        roomsCount: _selectedRoomsCount ?? 'غير محدد',
        budget: _budgetController.text,
        bookingDate: formattedDate,
        bookingTime: formattedTime,
        notes: _notesController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تسجيل الطلب بنجاح!')));

      // ===============================================================
      // TODO: الانتقال إلى الصفحة الثانية (Next Page Navigation)
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const NextScreen()),
      // );
      // ===============================================================
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال البيانات: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // تطبيق خط Cairo المتطابق مع تصميم الصورة
    final textStyleBase = GoogleFonts.cairo();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        // 1. App Bar (تطابق الشاشة الأولى)
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            'احجز تشطيب كهرباء',
            style: GoogleFonts.cairo(
              color: const Color(0xFF0066FF),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.power_outlined,
                color: const Color(0xFF0066FF),
                size: 28,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey.shade200, height: 1.0),
          ),
        ),

        // 2. Main Content (تطابق الشاشة الثانية)
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم نوع التشطيب
              Text(
                'نوع التشطيب',
                style: textStyleBase.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: _finishingOptions.map((type) {
                  final isSelected = _selectedFinishingType == type;
                  return InkWell(
                    onTap: () => setState(() => _selectedFinishingType = type),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0066FF).withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0066FF)
                              : const Color(0xFFDCDFE6),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        type,
                        style: textStyleBase.copyWith(
                          color: isSelected
                              ? const Color(0xFF0066FF)
                              : const Color(0xFF606266),
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // قسم عدد الغرف
              Text(
                'عدد الغرف',
                style: textStyleBase.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedRoomsCount,
                hint: Text(
                  'اختر عدد الغرف',
                  style: textStyleBase.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFDCDFE6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFDCDFE6)),
                  ),
                ),
                items: _roomsOptions.map((room) {
                  return DropdownMenuItem(
                    value: room,
                    child: Text(room, style: textStyleBase),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRoomsCount = val),
              ),

              const SizedBox(height: 24),

              // قسم الميزانية المتوقعة
              Text(
                'الميزانية المتوقعة',
                style: textStyleBase.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'مثال: 10000 جنيه',
                  hintStyle: textStyleBase.copyWith(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  suffixIcon: const Icon(
                    Icons.money_outlined,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFDCDFE6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFDCDFE6)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // قسم الموعد
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الموعد',
                      style: textStyleBase.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // حقل التاريخ
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE4E7ED)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? 'mm/dd/yyyy'
                                  : DateFormat(
                                      'MM/dd/yyyy',
                                    ).format(_selectedDate!),
                              style: textStyleBase.copyWith(
                                color: _selectedDate == null
                                    ? Colors.grey.shade400
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // حقل الوقت
                    InkWell(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE4E7ED)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedTime == null
                                  ? '--:-- --'
                                  : _selectedTime!.format(context),
                              style: textStyleBase.copyWith(
                                color: _selectedTime == null
                                    ? Colors.grey.shade400
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // قسم ملاحظات
              Text(
                'ملاحظات',
                style: textStyleBase.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'أضف أي تفاصيل أخرى هنا...',
                  hintStyle: textStyleBase.copyWith(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFDCDFE6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFDCDFE6)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // 3. Sticky Bottom Action Button (تطابق الشاشة الثالثة)
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16.0),
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
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'طلب تشطيب كهرباء',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
