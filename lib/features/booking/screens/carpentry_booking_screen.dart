import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/core/network/mock_backend.dart';
// removed: cloud_firestore - see docs/backend-prd.html

class CarpentryBookingScreen extends StatefulWidget {
  const CarpentryBookingScreen({super.key});

  @override
  State<CarpentryBookingScreen> createState() => _CarpentryBookingScreenState();
}

class _CarpentryBookingScreenState extends State<CarpentryBookingScreen> {
  // --- المتغيرات وحفظ الحالة ---
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color bgColor = const Color(0xFFF8F9FA);

  // الخيارات المتاحة
  final List<String> _workTypes = [
    'مطبخ',
    'غرفة نوم',
    'دولاب',
    'مكتبة',
    'باب',
    'شبابيك',
    'وحدة TV',
    'أثاث كامل',
  ];

  final List<String> _woodTypes = [
    'خشب زان',
    'خشب أرو',
    'خشب موسكي',
    'MDF',
    'كونتر',
    'غير متأكد / أحتاج استشارة',
  ];

  // القيم المختارة والمدخلة
  String _selectedWorkType = 'مطبخ';
  String? _selectedWoodType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;

  // --- دالة الحفظ في Firebase ---
  Future<void> _submitRequest() async {
    if (_budgetController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برجاء إدخال الميزانية وتحديد الموعد أولاً.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // إنشاء مستند جديد في مجموعة 'carpentry_requests' في Firestore
      await MockFirestore.collection('carpentry_requests').add({
        'workType': _selectedWorkType,
        'woodType': _selectedWoodType ?? 'لم يتم التحديد',
        'budget': _budgetController.text.trim(),
        'date': _dateController.text,
        'time': _timeController.text,
        'notes': _notesController.text.trim(),
        'createdAt': DateTime.now(),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الطلب بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );

        // تفريغ الحقول بعد النجاح
        setState(() {
          _budgetController.clear();
          _dateController.clear();
          _timeController.clear();
          _notesController.clear();
          _selectedWoodType = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء رفع الطلب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- دوال اختيار التاريخ والوقت ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.year}/${picked.month}/${picked.day}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,

        // --- Header (AppBar) ---
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "احجز تشطيب نجارة وأثاث",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // --- محتوى الصفحة ---
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. نوع العمل (Chips)
              _buildSectionCard(
                title: "نوع العمل",
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _workTypes.map((type) {
                    bool isSelected = _selectedWorkType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedWorkType = type;
                          });
                        }
                      },
                      labelStyle: GoogleFonts.cairo(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? primaryBlue
                              : Colors.grey.shade300,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // 2. نوع الخشب (Dropdown)
              _buildSectionCard(
                title: "نوع الخشب",
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedWoodType,
                  hint: Text(
                    "اختر نوع الخشب",
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: _woodTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: GoogleFonts.cairo()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedWoodType = newValue;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 3. الميزانية المتوقعة
              _buildSectionCard(
                title: "الميزانية المتوقعة",
                child: TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.cairo(),
                  decoration: InputDecoration(
                    hintText: "مثال: 25000 جنيه",
                    hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
                    suffixIcon: const Icon(Icons.money, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. الموعد (التاريخ والوقت)
              _buildSectionCard(
                title: "الموعد",
                child: Column(
                  children: [
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      style: GoogleFonts.cairo(),
                      decoration: InputDecoration(
                        hintText: "yyyy/mm/dd",
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: () => _selectTime(context),
                      style: GoogleFonts.cairo(),
                      decoration: InputDecoration(
                        hintText: "--:-- --",
                        prefixIcon: const Icon(
                          Icons.access_time,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 5. ملاحظات
              _buildSectionCard(
                title: "ملاحظات",
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  style: GoogleFonts.cairo(),
                  decoration: InputDecoration(
                    hintText: "أضف أي تفاصيل أخرى...",
                    hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),

        // --- الزر السفلي العائم (Bottom Action Button) ---
        bottomSheet: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
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
                        "طلب تشطيب نجارة",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
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

  // --- دالة مساعدة لبناء الـ Cards ---
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
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
}
