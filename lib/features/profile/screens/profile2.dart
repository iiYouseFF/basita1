import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // إضافة مكتبة Google Fonts
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/features/orders/screens/orders_screen.dart';
import 'package:basita1/features/orders/screens/sale_screen.dart';
import 'package:basita1/features/home/screens/home1.dart';
import 'package:basita1/features/auth/screens/account_type_screen.dart';
import 'package:basita1/features/booking/screens/appointments_screen.dart';
import 'package:basita1/features/technician/screens/technician_dashboard.dart';
import 'package:basita1/features/feedback/screens/coming.dart';
import 'package:basita1/features/community/screens/community_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // الألوان المستخدمة في التصميم
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color redLogout = Color(0xFFDC2626);
  static const Color iconBgLight = Color(0xFFE0E7FF);

  /// جلب معرّف الفني ديناميكياً ليطابق قاعدة البيانات
  String get _technicianDocId {
    final user = FirebaseAuth.instance.currentUser;
    String rawPhone = user?.phoneNumber ?? '';

    if (rawPhone.isEmpty) {
      rawPhone = UserDataSession.phone;
    }

    if (rawPhone.isNotEmpty) {
      String cleanedPhone = rawPhone.replaceAll('+20', '0').trim();
      if (cleanedPhone.startsWith('20')) {
        cleanedPhone = '0${cleanedPhone.substring(2)}';
      }
      return cleanedPhone;
    }

    return user?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضبط الاتجاه للعربية
      child: Scaffold(
        backgroundColor: bgLight,

        // ==========================================
        // 1. شريط التنقل العلوي (AppBar)
        // ==========================================
        appBar: AppBar(
          automaticallyImplyLeading: false, // إخفاء سهم الرجوع
          backgroundColor: bgLight,
          elevation: 0,
          title: Text(
            "حسابي",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 28,
              ),
              onPressed: () {
                // الانتقال لصفحة الإشعارات
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
              },
            ),
            const SizedBox(width: 8),
          ],
        ),

        // ==========================================
        // 2. محتوى الشاشة (Body)
        // ==========================================
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // --- صورة البروفايل والاسم ---
              _buildProfileHeader(),
              const SizedBox(height: 24),

              // --- كارت المحفظة والرصيد (ديناميكي) ---
              _buildWalletCard(),
              const SizedBox(height: 24),

              // --- قسم إدارة العمل ---
              _buildSectionTitle("إدارة العمل"),
              _buildCardSection([
                _buildListTile(
                  icon: Icons.person_outline,
                  title: "المعلومات الشخصية",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComingSoonScreen1(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.photo_library_outlined,
                  title: "معرض الأعمال",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComingSoonScreen1(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.map_outlined,
                  title: "مناطق الخدمة",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComingSoonScreen1(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.people_outline, // تم التعديل لتطابق الصورة
                  title: "المجتمع", // تم التعديل لتطابق الصورة
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CommunityScreenPerfect(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // --- قسم النمو والتطوير (لم يتم حذفه بناءً على طلبك) ---
              _buildSectionTitle("النمو والتطوير"),
              _buildCardSection([
                _buildListTile(
                  icon: Icons.school_outlined,
                  title: "مركز التدريب",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComingSoonScreen1(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.emoji_events_outlined,
                  title: "الإنجازات",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TechnicianDashboardS(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // --- قسم الإعدادات والدعم ---
              _buildSectionTitle("الإعدادات والدعم"),
              _buildCardSection([
                _buildListTile(
                  icon: Icons.help_outline,
                  title: "الدعم والمساعدة",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComingSoonScreen1(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.shield_outlined,
                  title: "الخصوصية والأمان",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComingSoonScreen1(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.logout,
                  title: "تسجيل الخروج",
                  isLogout: true,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountTypeScreen(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // --- إصدار التطبيق ---
              Text(
                "إصدار التطبيق 2.4.0",
                style: GoogleFonts.cairo(color: textGrey, fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ==========================================
        // 3. شريط التنقل السفلي (Bottom Nav Bar)
        // ==========================================
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  // ------------------------------------------------------------------
  // دوال بناء واجهة المستخدم (Widgets)
  // ------------------------------------------------------------------

  Widget _buildProfileHeader() {
    String displayName = UserDataSession.fullName.isNotEmpty
        ? UserDataSession.fullName
        : "اسم المستخدم";

    ImageProvider profileImage;
    if (UserDataSession.profileImagePath.isNotEmpty) {
      if (UserDataSession.profileImagePath.startsWith('http')) {
        profileImage = NetworkImage(UserDataSession.profileImagePath);
      } else {
        profileImage = FileImage(File(UserDataSession.profileImagePath));
      }
    } else {
      profileImage = const AssetImage(
        'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
      );
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CircleAvatar(radius: 45, backgroundImage: profileImage),
            ),
            Container(
              decoration: BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.verified, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: iconBgLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                "4.9",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "•",
                style: GoogleFonts.cairo(color: textGrey, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                "فني معتمد",
                style: GoogleFonts.cairo(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    final String currentTechId = _technicianDocId;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: currentTechId.isNotEmpty
          ? FirebaseFirestore.instance
                .collection('technicians')
                .doc(currentTechId)
                .snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        double walletBalance = 0.0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() ?? {};
          walletBalance = ((data['walletBalance'] ?? 0.0) as num).toDouble();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons
                      .account_balance_wallet, // تطابق الأيقونة الممتلئة بالصورة
                  color: primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "الرصيد الحالي",
                    style: GoogleFonts.cairo(color: textGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        walletBalance.toStringAsFixed(
                          0,
                        ), // إزالة الكسور لتطابق 1,250 في الصورة
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "ج.م",
                        style: GoogleFonts.cairo(fontSize: 14, color: textDark),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BasiytaApp()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  "المحفظة",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.cairo(
            color: primaryBlue,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isLogout ? redLogout : textDark),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          color: isLogout ? redLogout : textDark,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isLogout
          ? null
          : const Icon(
              Icons.arrow_back_ios, // تم تغييره ليشير لليسار كما في الصورة `<`
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: bgLight,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              "الرئيسية",
              Icons.home_outlined,
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainTechnicianScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              "الطلبات",
              Icons.assignment_outlined,
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestsPage()),
                );
              },
            ),
            _buildNavItem(
              "المحادثات",
              Icons.chat_bubble_outline,
              isActive: false,
              onTap: () {
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SmartAssistantScreen()));
              },
            ),
            _buildNavItem(
              "المواعيد", // تم التعديل لتطابق الصورة بدلاً من المحفظة
              Icons.calendar_today_outlined, // تغيير الأيقونة للتقويم
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentsScreen(),
                  ),
                ); // استبدلها باسم صفحة المواعيد
              },
            ),
            _buildNavItem("حسابي", Icons.person, isActive: true, onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    String label,
    IconData icon, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF60A5FA).withOpacity(
                  0.8,
                ) // اللون الأزرق للعنصر النشط
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryBlue : const Color(0xFF4B5563),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isActive ? primaryBlue : const Color(0xFF4B5563),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
