import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/technician/screens/technician_report_screen.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  // الألوان الأساسية المطابقة للتصميم
  final Color primaryBlue = const Color(0xFF1D4ED8);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color urgentRed = const Color(0xFFEF4444);

  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildMapSection(),
                    const SizedBox(height: 16),
                    _buildTechnicianReportEntry(context),
                    const SizedBox(height: 20),
                    _buildFiltersSection(),
                    const SizedBox(height: 16),
                    _buildUrgentCard(),
                    const SizedBox(height: 16),
                    _buildStandardCard(
                      tagText: "تركيب أجهزة",
                      tagColor: const Color(0xFFD97706),
                      tagBgColor: const Color(0xFFFEF3C7),
                      tagIcon: Icons.build_circle_outlined,
                      timeAgo: "منذ 5 دقائق",
                      title: "تركيب تكييف 2.25 حصان",
                      subtitle: "كريم علي • التجمع الخامس، الياسمين",
                      price: "800 ج.م",
                      distance: "5.8 كم",
                      imageUrl:
                          "assets/AB6AXuAlCcWbAAcRp62vor82SAIgGfaM8hObA1wi2a0MGyYtscgEV-HzWpWFi2If0m_DKx_BZGTGtdy2HV2V1tciurHT4wDyovIMHsCrTxEZ4BUCQLrl1yhkPWKPnCZN_Tzb_xxbmC4nzsmbX4iA3W5aKK73hzq7MwnuSf9hzIOXseY_QHN9Tv4gH-KVkqs2fYQXxBBEs86nP (1).png",
                    ),
                    const SizedBox(height: 16),
                    _buildScheduledCard(),
                    const SizedBox(height: 16),
                    _buildCarpentryCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. App Bar (الهيدر)
  // ==========================================
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: bgLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF0056D2),
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pop(context); // العودة للصفحة السابقة مباشرة
                },
              ),
              const SizedBox(width: 12),
              Text(
                "بسيطة",
                style: GoogleFonts.cairo(
                  color: primaryBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryBlue, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. Map Section (قسم الخريطة)
  // ==========================================
  Widget _buildMapSection() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        // يمكنك استبدال اللون بصورة الخريطة الحقيقية عبر الكود التالي:
        image: DecorationImage(
          image: AssetImage(
            'assets/AB6AXuA2pE4lJ8tfluuVm5gV_D6hV9q_IQXdllOZxw4ikTNMqW-w7Z0SPmFxUObzikq2KIcYpJh-Snh_odUx86U_tLQdpr__e8qcaVgXgne0YTGZSJIBgFpbEqOTmz_eWI3qwUxuV5P4Nyjt5cKXBRUvT4ptqQlX8E0fkxgs4ByVqGUA5VsRgyPbckOxzBhm4bVHFyXKGEX3N (1).png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // لوضع خلفية مؤقتة تشبه الخريطة في حال عدم وجود صورة
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                "https://www.mapquestapi.com/staticmap/v5/map?key=YOUR_KEY&center=30.0444,31.2357&zoom=14&size=600,400",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981), // أخضر
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "أنت متصل الآن",
                    style: GoogleFonts.cairo(
                      color: textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "أقرب طلب يبعد",
                          style: GoogleFonts.cairo(
                            color: textMuted,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "1.2 كم • 5 دقائق",
                          style: GoogleFonts.cairo(
                            color: textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.near_me, color: Colors.white),
                      onPressed: () {},
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

  // ==========================================
  // 3. Filters & Tabs Section
  // ==========================================
  Widget _buildFiltersSection() {
    List<String> tabs = ["الكل (12)", "عاجل (3)", "مجدولة"];
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(tabs.length, (index) {
                bool isSelected = selectedTabIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTabIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryBlue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      tabs[index],
                      style: GoogleFonts.cairo(
                        color: isSelected ? Colors.white : textMuted,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(Icons.tune, color: primaryBlue, size: 20),
        ),
      ],
    );
  }

  // ==========================================
  // 4. Urgent Card (الكارت العاجل الأحمر)
  // ==========================================
  Widget _buildUrgentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: urgentRed.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: urgentRed.withValues(alpha: 0.05),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: urgentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emergency, color: urgentRed, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "عاجل جداً",
                      style: GoogleFonts.cairo(
                        color: urgentRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: urgentRed, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  "1:45",
                  style: GoogleFonts.cairo(
                    color: urgentRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "إصلاح عطل كهربائي مفاجئ",
                      style: GoogleFonts.cairo(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "أحمد محمود • الشيخ زايد، الحي الثاني",
                      style: GoogleFonts.cairo(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/AB6AXuCJxvx1ZP6kEMD9Keh1-h9e342VFB2ZK_6YYdfH6ivdCykrOi-ROXupVtlB1sXhZGGzGZqccjNttQlcSHs2TBsrXxhIjYzaCbqDjJz6ZphTsz8bvzvCix_QeyYCWzRYcSkpKtB9gsPeCRk_RMG3-sstHdk04Tlk0Md20crDpH2ihn78i85RG51BwbxAFOWdoSz5kLfCWRa2m.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn("الأجر المتوقع", "450", " ج.م", primaryBlue),
              Container(height: 30, width: 1, color: Colors.grey.shade200),
              _buildStatColumn("المسافة", "2.4", " كم", textDark),
              Container(height: 30, width: 1, color: Colors.grey.shade200),
              _buildStatColumn("الوصول", "12", " دقيقة", textDark),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "قبول الطلب",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "عرض سعر آخر",
                    style: GoogleFonts.cairo(
                      color: textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. Standard Card (الكارت العادي - تكييف)
  // ==========================================
  Widget _buildStandardCard({
    required String tagText,
    required Color tagColor,
    required Color tagBgColor,
    required IconData tagIcon,
    required String timeAgo,
    required String title,
    required String subtitle,
    required String price,
    required String distance,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(tagIcon, color: tagColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      tagText,
                      style: GoogleFonts.cairo(
                        color: tagColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                timeAgo,
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconStat(Icons.payments_outlined, "الأجر", price),
              Container(height: 20, width: 1, color: Colors.grey.shade300),
              _buildIconStat(Icons.location_on_outlined, "المسافة", distance),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "قبول",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "التفاصيل",
                    style: GoogleFonts.cairo(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. Scheduled Card (الكارت المجدول)
  // ==========================================
  Widget _buildScheduledCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 2,
        ), // إطار مميز كالتصميم
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.black54,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "مجدول غداً",
                      style: GoogleFonts.cairo(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "10:00 صباحاً",
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "صيانة دورية للسباكة",
                      style: GoogleFonts.cairo(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "سارة يوسف • مدينتي، منطقة B1",
                      style: GoogleFonts.cairo(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/Background1.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.black54, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "مطلوب فحص كافة وصلات المطبخ والحمام الرئيسي.",
                    style: GoogleFonts.cairo(
                      color: textMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "تعديل الموعد",
                    style: GoogleFonts.cairo(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.blue,
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

  // ==========================================
  // 7. Carpentry Card (كارت النجارة)
  // ==========================================
  Widget _buildCarpentryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chair_alt_outlined,
                      color: Color(0xFFB45309),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "نجارة",
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFB45309),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "منذ 15 دقيقة",
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "إصلاح باب مكتب زجاجي",
                      style: GoogleFonts.cairo(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "مكتب هورايزون • المعادي",
                      style: GoogleFonts.cairo(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/Background (17).png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "الأجر المقترح",
                      style: GoogleFonts.cairo(color: textMuted, fontSize: 12),
                    ),
                    Text(
                      "1,200 ج.م",
                      style: GoogleFonts.cairo(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text(
                      "مدة العمل",
                      style: GoogleFonts.cairo(color: textMuted, fontSize: 12),
                    ),
                    Text(
                      "~ 2 ساعة",
                      style: GoogleFonts.cairo(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "قبول",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.block, color: Colors.grey),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildStatColumn(
    String label,
    String value,
    String unit,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: GoogleFonts.cairo(color: textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: GoogleFonts.cairo(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: GoogleFonts.cairo(
                color: valueColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.cairo(color: textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: primaryBlue),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.cairo(
                color: textDark,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Technician Report entry — n8n integration
  Widget _buildTechnicianReportEntry(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TechnicianReportScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryBlue.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.assignment_add, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إرسال تقرير صيانة', style: GoogleFonts.cairo(color: textDark, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('توثيق العمل للعميل عبر n8n', style: GoogleFonts.cairo(color: textMuted, fontSize: 11, height: 1.3)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}
