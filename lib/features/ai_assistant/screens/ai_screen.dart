import 'package:flutter/material.dart';

class AiCalculatorScreen extends StatefulWidget {
  const AiCalculatorScreen({super.key});

  @override
  State<AiCalculatorScreen> createState() => _AiCalculatorScreenState();
}

class _AiCalculatorScreenState extends State<AiCalculatorScreen> {
  // ==========================================
  // المتغيرات (State Variables)
  // ==========================================
  double _area = 120; // المساحة الافتراضية
  int _selectedFinishIndex = 1; // 0: اقتصادي, 1: لوكس, 2: سوبر لوكس
  final List<String> _finishLevels = ['اقتصادي', 'لوكس', 'سوبر لوكس'];
  int _rooms = 3;
  int _bathrooms = 2;

  // الألوان الأساسية
  static const Color primaryBlue = Color(0xFF1A67D2);
  static const Color resultCardBlue = Color(
    0xFF7A9EFE,
  ); // الأزرق الفاتح لكارت النتيجة
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  // دالة مساعدة لتنسيق الرقم وإضافة فواصل الآلاف
  String _formatCurrency(int amount) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amount.toString().replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  // دالة لحساب التكلفة التقريبية (بناءً على التغييرات)
  int _calculateTotalCost() {
    int basePricePerMeter;
    if (_selectedFinishIndex == 0) {
      basePricePerMeter = 2500;
    } else if (_selectedFinishIndex == 1)
      basePricePerMeter = 4125; // الرقم اللي بيطلع 495,000 مع 120 متر
    else
      basePricePerMeter = 6000;

    return (_area * basePricePerMeter).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تفعيل الـ RTL
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTitle(),
              const SizedBox(height: 24),
              _buildAreaSliderCard(),
              const SizedBox(height: 20),
              _buildSectionTitle("مستوى التشطيب"),
              _buildFinishingLevelSelector(),
              const SizedBox(height: 20),
              _buildSectionTitle("المدينة"),
              _buildCityDropdown(),
              const SizedBox(height: 20),
              _buildSectionTitle("عدد الغرف"),
              _buildCounter(
                value: _rooms,
                onAdd: () => setState(() => _rooms++),
                onRemove: () => setState(() {
                  if (_rooms > 1) _rooms--;
                }),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("عدد الحمامات"),
              _buildCounter(
                value: _bathrooms,
                onAdd: () => setState(() => _bathrooms++),
                onRemove: () => setState(() {
                  if (_bathrooms > 1) _bathrooms--;
                }),
              ),
              const SizedBox(height: 28),
              _buildResultCard(),
              const SizedBox(height: 24),
              _buildBottomImagesGrid(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // أدوات بناء الواجهة (Widgets)
  // ==========================================

  // 1. شريط التطبيق (AppBar)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgLight, // تأكد من تعريف هذا المتغير في ملفك
      elevation: 0,

      // 1. زر الرجوع (يظهر على اليمين في الـ RTL)
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2), size: 28),
        onPressed: () {
          Navigator.pop(context); // العودة للصفحة السابقة مباشرة
        },
      ),
      centerTitle: true,
      title: const Text(
        "شطبلي",
        style: TextStyle(
          color: primaryBlue, // تأكد من تعريف هذا المتغير
          fontSize: 26,
          fontWeight: FontWeight.w900,
          fontFamily: 'Cairo',
        ),
      ),

      // 2. العناصر الإضافية (تظهر على اليسار في الـ RTL)
      actions: [
        // جرس الإشعارات
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: textDark, // تأكد من تعريف هذا المتغير
            size: 28,
          ),
          onPressed: () {},
        ),

        // صورة الحساب
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD3E4F6), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // 2. العنوان والنص الترحيبي
  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "حاسبة التكلفة بالذكاء\nالاصطناعي ⭐",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textDark,
            fontFamily: 'Cairo',
            height: 1.3,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "احصل على تقدير دقيق لتكلفة تشطيب وحدتك في ثوانٍ\nمعدودة.",
          style: TextStyle(
            fontSize: 14,
            color: textMuted,
            fontFamily: 'Cairo',
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // 3. كارت شريط اختيار المساحة (Slider)
  Widget _buildAreaSliderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "مساحة الوحدة (م²)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  fontFamily: 'Cairo',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_area.toInt()} م²",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primaryBlue,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: primaryBlue,
              overlayColor: primaryBlue.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _area,
              min: 50,
              max: 500,
              divisions: 90, // القفزات كل 5 متر تقريباً
              onChanged: (value) => setState(() => _area = value),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "50 م²",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                "500 م²",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. عنوان الأقسام الصغيرة
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  // 5. محدد مستوى التشطيب (Segmented Control)
  Widget _buildFinishingLevelSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_finishLevels.length, (index) {
          bool isSelected = _selectedFinishIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFinishIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _finishLevels[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : textMuted,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 6. القائمة المنسدلة للمدينة (شكل فقط)
  Widget _buildCityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on_outlined, color: textMuted, size: 20),
              SizedBox(width: 8),
              Text(
                "القاهرة",
                style: TextStyle(
                  color: textDark,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const Icon(Icons.keyboard_arrow_down, color: textMuted),
        ],
      ),
    );
  }

  // 7. العداد (الغرف والحمامات)
  Widget _buildCounter({
    required int value,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الجمع (الأزرق) - في الـ RTL بيكون على الشمال
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          // زر الطرح (الرمادي) - في الـ RTL بيكون على اليمين
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove, color: textDark, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // 8. كارت النتيجة النهائي (الأزرق)
  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: resultCardBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bar_chart, color: Colors.white),
            ),
          ),
          const Text(
            "التكلفة الإجمالية المتوقعة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(_calculateTotalCost()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6.0, right: 8.0),
                child: Text(
                  "ج.م",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildResultInfoBox(
                  title: "الباقة المرشحة",
                  value: "باقة ${_finishLevels[_selectedFinishIndex]}",
                  icon: Icons.star_border,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultInfoBox(
                  title: "مدة التنفيذ",
                  value: "90 يوم",
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Uncomment to navigate or start project
                // print("بدء تنفيذ المشروع");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_back, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "ابدأ تنفيذ مشروعك",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // مربعات المعلومات داخل كارت النتيجة
  Widget _buildResultInfoBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 9. شبكة الصور السفلية
  Widget _buildBottomImagesGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildImageCard(
            imagePath: 'assets/Gemini_Generated_Image_b2wji4b2wji4b2wj.png',
            title: "معاينة الخامات",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildImageCard(
            imagePath: 'assets/Gemini_Generated_Image_lxgizzlxgizzlxgi.png',
            title: "نموذج تشطيب لوكس",
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard({required String imagePath, required String title}) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(12),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
