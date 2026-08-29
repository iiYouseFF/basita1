import 'package:flutter/material.dart';

// ==========================================
// 1. نموذج بيانات الجهاز (Appliance Model)
// ==========================================
class ApplianceItem {
  final String id;
  final String name;
  final String room;
  final String purchaseDate;
  final String warrantyEnd;
  final int progressPercent;
  final String statusText;
  final Color statusColor;
  final Color statusBgColor;
  final IconData icon;

  ApplianceItem({
    required this.id,
    required this.name,
    required this.room,
    required this.purchaseDate,
    required this.warrantyEnd,
    required this.progressPercent,
    required this.statusText,
    required this.statusColor,
    required this.statusBgColor,
    required this.icon,
  });
}

// ==========================================
// 2. مدير الأجهزة (Singleton Pattern للحفظ عند الخروج والعودة)
// ==========================================
class AppliancesManager {
  AppliancesManager._privateConstructor();
  static final AppliancesManager instance =
      AppliancesManager._privateConstructor();

  // القائمة الابتدائية للأجهزة (تظل محفوظة طوال فترة تشغيل التطبيق)
  final List<ApplianceItem> devices = [
    ApplianceItem(
      id: '1',
      name: 'تكييف شارب 2.25 حصان',
      room: 'غرفة المعيشة',
      purchaseDate: '15 مايو 2022',
      warrantyEnd: '15 مايو 2027',
      progressPercent: 35,
      statusText: 'يعمل بكفاءة',
      statusColor: const Color(0xFF10B981),
      statusBgColor: const Color(0xFFD1FAE5),
      icon: Icons.ac_unit_rounded,
    ),
    ApplianceItem(
      id: '2',
      name: 'ثلاجة سامسونج No-Frost',
      room: 'المطبخ',
      purchaseDate: '10 يناير 2019',
      warrantyEnd: '10 يناير 2024',
      progressPercent: 92,
      statusText: 'الضمان قارب للانتهاء',
      statusColor: const Color(0xFFEF4444),
      statusBgColor: const Color(0xFFFEE2E2),
      icon: Icons.kitchen_rounded,
    ),
    ApplianceItem(
      id: '3',
      name: 'غسالة LG Front Load',
      room: 'الحمام الرئيسي',
      purchaseDate: '22 مارس 2023',
      warrantyEnd: '22 مارس 2026',
      progressPercent: 15,
      statusText: 'حالة ممتازة',
      statusColor: const Color(0xFF6366F1),
      statusBgColor: const Color(0xFFE0E7FF),
      icon: Icons.local_laundry_service_rounded,
    ),
    ApplianceItem(
      id: '4',
      name: 'راوتر TP-Link Archer',
      room: 'المكتب',
      purchaseDate: '05 نوفمبر 2023',
      warrantyEnd: '05 نوفمبر 2024',
      progressPercent: 50,
      statusText: 'متصل',
      statusColor: const Color(0xFF10B981),
      statusBgColor: const Color(0xFFD1FAE5),
      icon: Icons.router_rounded,
    ),
  ];

  // دالة لإضافة جهاز جديد للقائمة الحية
  void addDevice(ApplianceItem newItem) {
    devices.insert(0, newItem); // إضافة الجهاز الجديد في أول القائمة
  }
}

// ==========================================ئ
// 3. شاشة أجهزتي المنزلية الرئيسية
// ==========================================
class MyAppliancesScreen extends StatefulWidget {
  const MyAppliancesScreen({super.key});

  @override
  State<MyAppliancesScreen> createState() => _MyAppliancesScreenState();
}

class _MyAppliancesScreenState extends State<MyAppliancesScreen> {
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color bgLight = const Color(0xFFF8F9FA);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    // جلب القائمة من الـ Singleton
    final myDevices = AppliancesManager.instance.devices;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWarrantyAlertsSection(),
              const SizedBox(height: 12),
              _buildViewBillsLink(),
              const SizedBox(height: 8),
              // قائمة الأجهزة
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myDevices.length,
                itemBuilder: (context, index) {
                  return _buildApplianceCard(myDevices[index]);
                },
              ),
              const SizedBox(
                height: 80,
              ), // مساحة إضافية لتجنب تغطية الزر العائم
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddApplianceBottomSheet(context),
          backgroundColor: primaryBlue,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
        // تم تغيير الموقع إلى endFloat ليظهر على الشمال في واجهة RTL
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // ==========================================
  // شريط التطبيق العلوي
  // ==========================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "أجهزتي المنزلية",
        style: TextStyle(
          color: primaryBlue,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [Padding(padding: const EdgeInsets.only(left: 16.0))],
    );
  }

  // ==========================================
  // قسم تنبيهات الضمان
  // ==========================================
  Widget _buildWarrantyAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "تنبيهات الضمان",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "2 تنبيه",
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // التنبيه الأول (أحمر)
        _buildAlertBox(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFECACA),
          title: "ضمان التكييف ينتهي قريباً!",
          subtitle: "متبقي 14 يوماً فقط على انتهاء فترة الضمان الرسمية.",
        ),
        const SizedBox(height: 10),
        // التنبيه الثاني (أخضر)
        _buildAlertBox(
          icon: Icons.verified_rounded,
          iconColor: const Color(0xFF059669),
          bgColor: const Color(0xFFECFDF5),
          borderColor: const Color(0xFFA7F3D0),
          title: "تذكير صيانة الثلاجة",
          subtitle: "موعد الفحص الدوري المقترح هو الأسبوع القادم.",
        ),
      ],
    );
  }

  Widget _buildAlertBox({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: textGrey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // رابط عرض الفواتير
  // ==========================================
  Widget _buildViewBillsLink() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {},
        child: Text(
          "عرض الفواتير",
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // كارت الجهاز (Appliance Card)
  // ==========================================
  Widget _buildApplianceCard(ApplianceItem item) {
    bool isUrgent = item.progressPercent > 85;

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
        children: [
          // الجزء العلوي: أيقونة الجهاز + الاسم + الحالة
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: primaryBlue, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.room,
                      style: TextStyle(color: textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.statusText,
                  style: TextStyle(
                    color: item.statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // تواريخ الشراء ونهاية الضمان
          Row(
            children: [
              Expanded(child: _buildDateBox("تاريخ الشراء", item.purchaseDate)),
              const SizedBox(width: 12),
              Expanded(child: _buildDateBox("نهاية الضمان", item.warrantyEnd)),
            ],
          ),
          const SizedBox(height: 16),
          // شريط تقدم الضمان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "حالة الضمان",
                style: TextStyle(color: textGrey, fontSize: 12),
              ),
              Text(
                "${item.progressPercent}% منقضي",
                style: TextStyle(
                  color: isUrgent ? const Color(0xFFDC2626) : primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: item.progressPercent / 100,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent ? const Color(0xFFDC2626) : primaryBlue,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          // أزرار التحكم: أريد الصيانة - سجل الصيانة
          Row(
            children: [
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: const Text(
                    "اريد الصيانة",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: BorderSide(color: primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text(
                    "سجل الصيانة",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String title, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textGrey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: textDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // نافذة إضافة جهاز جديد (تسمع في الـ Singleton)
  // ==========================================
  void _showAddApplianceBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final roomController = TextEditingController();
    final purchaseController = TextEditingController(text: "20 يوليو 2026");
    final warrantyController = TextEditingController(text: "20 يوليو 2028");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "إضافة جهاز جديد",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "اسم الجهاز (مثال: شاشة سامسونج 55 بوصة)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roomController,
                  decoration: InputDecoration(
                    labelText: "الغرفة (مثال: غرفة النوم)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: purchaseController,
                        decoration: InputDecoration(
                          labelText: "تاريخ الشراء",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: warrantyController,
                        decoration: InputDecoration(
                          labelText: "نهاية الضمان",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          roomController.text.isNotEmpty) {
                        // إنشاء الجهاز الجديد
                        final newDevice = ApplianceItem(
                          id: DateTime.now().toString(),
                          name: nameController.text,
                          room: roomController.text,
                          purchaseDate: purchaseController.text,
                          warrantyEnd: warrantyController.text,
                          progressPercent: 10, // نسبة ابتدائية للضمان الجديد
                          statusText: 'يعمل بكفاءة',
                          statusColor: const Color(0xFF10B981),
                          statusBgColor: const Color(0xFFD1FAE5),
                          icon: Icons.devices_other_rounded,
                        );

                        // حفظ الجهاز في الـ Singleton ليبقى مسجلاً بعد الخروج
                        setState(() {
                          AppliancesManager.instance.addDevice(newDevice);
                        });

                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "تمت إضافة الجهاز بنجاح وسيبقى محفوظاً في القائمة",
                            ),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "حفظ وإضافة الجهاز",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
