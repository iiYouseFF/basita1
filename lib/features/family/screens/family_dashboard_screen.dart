import 'package:flutter/material.dart';
import 'package:basita1/features/home/screens/home_screen.dart';
import 'package:basita1/features/chat/screens/chat_screen.dart';
import 'package:basita1/features/profile/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/booking/screens/request_service_screen.dart';

class FamilyDashboardScreen extends StatelessWidget {
  const FamilyDashboardScreen({super.key});

  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color backgroundColor = Color(0xFFF9FAFC);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildMainBlueCard(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 25),
                _buildMembersHeader(),
                const SizedBox(height: 12),
                _buildMembersList(),
                const SizedBox(height: 20),
                _buildFooterCards(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildCustomBottomNavBar(context),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. الجانب الأيمن (العنوان والوصف)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "العائلة",
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "كل أفراد أسرتك وخدماتهم في مكان واحد",
              style: GoogleFonts.cairo(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // 2. الجانب الأيسر (جرس الإشعارات والصورة الشخصية)
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 26,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 4),
          ],
        ),
      ],
    );
  }

  Widget _buildMainBlueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الجهة اليمنى: اسم العائلة وبادج الأفراد
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "عائلتي",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "5 أفراد",

                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // الجهة اليسرى: أيقونة المنزل
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatBox("الإنفاق الشهري", "2,450 ج.م"),
              const SizedBox(width: 12),
              _buildStatBox("الطلبات النشطة", "3 خدمات"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          Icons.person_add_alt_1_rounded,
          "دعوة فرد",
          const Color(0xFFEBF3FF),
          primaryBlue,
        ),
        _buildActionButton(
          Icons.share_outlined,
          "مشاركة الكود",
          const Color(0xFFE8F8F0),
          const Color(0xFF27AE60),
        ),
        _buildActionButton(
          Icons.settings_outlined,
          "إدارة العائلة",
          const Color(0xFFF2F4F8),
          const Color(0xFF5A6E85),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "أفراد العائلة",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "رؤية الكل",
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList() {
    return Column(
      children: [
        _buildMemberItem(
          "أحمد محمود",
          "الأب (مسؤول العائلة)",
          "متصل الآن",
          true,
          'assets/icon-7797704_960_720.png',
        ),
        _buildMemberItem(
          "ليلى علي",
          "الأم",
          "آخر ظهور: 10 دق",
          false,
          'assets/icon-7797704_960_720.png',
        ),
        _buildMemberItem(
          "عمر أحمد",
          "الابن",
          "متصل الآن",
          true,
          'assets/icon-7797704_960_720.png',
        ),
      ],
    );
  }

  Widget _buildMemberItem(
    String name,
    String role,
    String status,
    bool isOnline,
    String imagePath,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الانتقال المصغر يساراً
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 12,
              color: primaryBlue,
            ),
          ),
          const SizedBox(width: 10),
          // الحالة (متصل أو غير متصل)
          Text(
            status,
            style: TextStyle(
              color: isOnline ? const Color(0xFF27AE60) : Colors.grey,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          // تفاصيل الاسم والدور
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // صورة الفرد مع مؤشر الحالة
          Stack(
            children: [
              CircleAvatar(radius: 24, backgroundImage: AssetImage(imagePath)),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFBDBDBD),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterCards() {
    return Row(
      children: [
        _buildSimpleCard(
          Icons.verified_rounded,
          "نقاط العائلة",
          "850 نقطة",
          const Color(0xFF27AE60),
        ),
        const SizedBox(width: 12),
        _buildSimpleCard(
          Icons.history_rounded,
          "السجل المشترك",
          "42 خدمة",
          primaryBlue,
        ),
      ],
    );
  }

  Widget _buildSimpleCard(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context) {
    // 3 تعني أن "العائلة" هي النشطة حالياً في ترتيب العناصر (0, 1, 2, 3, 4)
    int currentIndex = 3;

    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home_filled, 'label': "الرئيسية"},
      {'icon': Icons.local_offer_outlined, 'label': "طلباتي"},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': "المحادثات"},
      {'icon': Icons.people_outline_rounded, 'label': "العائلة"},
      {'icon': Icons.person_outline_rounded, 'label': "الحساب"},
    ];

    return Container(
      height: 85, // ارتفاع شريط التنقل
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5), // ظل خفيف للأعلى
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final item = items[index];

          return Expanded(
            child: InkWell(
              onTap: () {
                // 💡 نفس كود الـ Switch الخاص بك بالظبط بدون أي تعديل
                switch (index) {
                  case 0:
                    // 💡 شاشة الحساب
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleHomeScreen(),
                      ),
                    );
                    break;
                  case 1:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RequestServiceScreen(),
                      ),
                    );
                    // 💡 شاشة العائلة (نحن فيها بالفعل بناءً على الـ currentIndex)
                    break;
                  case 2:
                    // 💡 شاشة المحادثات
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatMainPage(),
                      ),
                    );
                    break;
                  case 3:
                    // 💡 شاشة طلباتي
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const ChatMainPage(),
                    //   ),
                    // );
                    break;
                  case 4:
                    // 💡 شاشة الرئيسية
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                    break;
                  case 5:
                    break;
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    // تصميم الزر النشط (مثل الصورة)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(
                          0.15,
                        ), // اللون الأزرق الشفاف
                        borderRadius: BorderRadius.circular(
                          25,
                        ), // الحواف المقوسة
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item['icon'], color: primaryBlue, size: 26),
                          const SizedBox(height: 4),
                          Text(
                            item['label'],
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // تصميم الزر غير النشط
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'],
                          color: Colors.grey.shade500,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
