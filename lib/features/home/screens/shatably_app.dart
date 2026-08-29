import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // تم إضافة مكتبة خطوط جوجل
import 'package:basita1/features/home/screens/shatab.dart'; // تأكد من وجود هذا الملف

// ==========================================
// 1. الصفحة الرئيسية (باقات التشطيب)
// ==========================================
class ShatablyApp extends StatelessWidget {
  const ShatablyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // ضبط الاتجاه باللغة العربية
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: _buildHeader(context),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                _buildTitleSection(),
                const SizedBox(height: 20),
                _buildPackagesList(context),
                const SizedBox(height: 30),
                _buildWhyChooseUsSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FBFF),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0056D2),
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 12),
          Text(
            "شطبلي",
            style: GoogleFonts.cairo(
              color: const Color(0xFF0056D2),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

Widget _buildTitleSection() {
  return Column(
    children: [
      Text(
        'باقات التشطيب',
        style: GoogleFonts.cairo(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'اختر الباقة المناسبة لميزانيتك وابدأ رحلة تحويل منزلك',
        style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey.shade600),
      ),
    ],
  );
}

Widget _buildPackagesList(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      children: [
        // ==========================================
        // 1. الباقة الاقتصادية (تنتقل لصفحة home_screen.dart)
        // ==========================================
        PackageCard(
          title: 'اقتصادي',
          subtitle: 'تشطيب عملي وموفر',
          price: '3,500',
          topIcon: Icons.savings_outlined,
          features: const [
            {'icon': Icons.access_time, 'text': 'مدة التنفيذ: 50 يوماً'},
            {'icon': Icons.verified_outlined, 'text': 'ضمان لمدة سنتين'},
            {'icon': Icons.build_outlined, 'text': 'خامات أساسية بجودة عالية'},
          ],
          // زر عرض المواد المشمولة (الباقة الاقتصادية)
          onShowMaterials: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShatablyHomeScreen()),
          ),
          // زر احجز الآن (الباقة الاقتصادية)
          onBookNow: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShatablyHomeScreen()),
          ),
        ),
        const SizedBox(height: 20),

        // ==========================================
        // 2. باقة لوكس (الأكثر طلباً - صفحة منفصلة)
        // ==========================================
        PackageCard(
          title: 'لوكس',
          subtitle: 'توازن مثالي بين السعر والفخامة',
          price: '5,200',
          isHighlighted: true,
          hasVipBadge: true,
          features: const [
            {'icon': Icons.access_time, 'text': 'مدة التنفيذ: 120 يوماً'},
            {'icon': Icons.shield_outlined, 'text': 'ضمان شامل 10 سنوات'},
            {'icon': Icons.payments_outlined, 'text': 'نظام تقسيط متاح'},
            {
              'icon': Icons.color_lens_outlined,
              'text': 'تشطيبات ديكورية فاخرة',
            },
          ],
          // زر عرض المواد المشمولة (باقة لوكس)
          onShowMaterials: () {
            /* 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LuxMaterialsScreen(), // حط صفحتك هنا
              ),
            );
            */
          },
          // زر احجز الآن (باقة لوكس)
          onBookNow: () {
            /* 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LuxBookingScreen(), // حط صفحتك هنا
              ),
            );
            */
          },
        ),
        const SizedBox(height: 20),

        // ==========================================
        // 3. باقة سوبر لوكس (صفحة منفصلة)
        // ==========================================
        PackageCard(
          title: 'سوبر لوكس',
          subtitle: 'أرقى مستويات الرفاهية والذكاء',
          price: '8,500',
          topIcon: Icons.diamond_outlined,
          features: const [
            {
              'icon': Icons.smartphone_outlined,
              'text': 'أنظمة المنزل الذكي (Smart Home)',
            },
            {'icon': Icons.grid_view, 'text': 'رخام وخامات مستوردة'},
            {
              'icon': Icons.architecture,
              'text': 'تصميم داخلي ثلاثي الأبعاد مجاناً',
            },
            {
              'icon': Icons.support_agent,
              'text': 'مدير مشروع خاص على مدار الساعة',
            },
          ],
          // زر عرض المواد المشمولة (باقة سوبر لوكس)
          onShowMaterials: () {
            /* 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SuperLuxMaterialsScreen(), // حط صفحتك هنا
              ),
            );
            */
          },
          // زر احجز الآن (باقة سوبر لوكس)
          onBookNow: () {
            /* 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SuperLuxBookingScreen(), // حط صفحتك هنا
              ),
            );
            */
          },
        ),
      ],
    ),
  );
}

Widget _buildWhyChooseUsSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      children: [
        Text(
          'لماذا تختار شطبلي؟',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FeatureBox(
                icon: Icons.timer_outlined,
                text: 'التزام بمواعيد التسليم',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FeatureBox(
                icon: Icons.verified_user_outlined,
                text: 'عقود رسمية موثقة',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FeatureBox(
                icon: Icons.home_work_outlined,
                text: 'متابعة لحظية للتنفيذ',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FeatureBox(
                icon: Icons.engineering_outlined,
                text: 'فنيين محترفين',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ==========================================
// 2. تصميم كارت الباقة (Reusable Widget)
// ==========================================
class PackageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final IconData? topIcon;
  final List<Map<String, dynamic>> features;
  final bool isHighlighted;
  final bool hasVipBadge;
  final VoidCallback onShowMaterials;
  final VoidCallback onBookNow;

  const PackageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    this.topIcon,
    required this.features,
    this.isHighlighted = false,
    this.hasVipBadge = false,
    required this.onShowMaterials,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFFFAFCFF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFF0056D2)
                  : Colors.grey.shade300,
              width: isHighlighted ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (topIcon != null)
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    topIcon,
                    color: const Color(0xFF0056D2),
                    size: 30,
                  ),
                ),
              if (isHighlighted) const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasVipBadge)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'VIP',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star, size: 10, color: Colors.black),
                        ],
                      ),
                    ),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),

              // السعر
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.cairo(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0056D2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ج.م / م²',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // المميزات
              Column(
                children: features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          feature['icon'],
                          size: 18,
                          color: const Color(0xFF0056D2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature['text'],
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // زر عرض المواد المشمولة
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onShowMaterials,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF0056D2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'عرض المواد المشمولة',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0056D2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // زر احجز الآن
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onBookNow,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF0056D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'احجز الآن',
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

        // شريط "الأكثر طلباً" للباقة المميزة
        if (isHighlighted)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFF0056D2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
              child: Text(
                'الأكثر طلباً',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ==========================================
// 3. مكون مربعات (لماذا تختار شطبلي)
// ==========================================
class FeatureBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureBox({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF0056D2), size: 28),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// 4. الصفحة الخاصة بك (Your Custom Screen)
// =====================================================================
class YourCustomPage extends StatelessWidget {
  const YourCustomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'صفحتك المخصصة',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0056D2),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.code, size: 80, color: Color(0xFF0056D2)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'انسخ كود الصفحة اللي انت عملتها وحطها هنا مكان الكلاس ده!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                ),
                child: Text(
                  'العودة لباقات التشطيب',
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
