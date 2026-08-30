import 'dart:io'; // للتعامل مع ملفات الصور المحلية إن وجدت
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // للتحكم في الخروج من التطبيق
import 'package:google_fonts/google_fonts.dart';
// removed: cloud_firestore - see docs/backend-prd.html
// removed: firebase_auth

import 'package:basita1/features/booking/screens/request_service_screen.dart';
import 'package:basita1/features/profile/screens/profile_screen.dart';
import 'package:basita1/features/family/screens/family_join_screen.dart';
import 'package:basita1/features/chat/screens/chat_screen.dart';
import 'package:basita1/features/community/screens/community_screen.dart';
import 'package:basita1/features/feedback/screens/dummy_screen.dart';
import 'package:basita1/features/offers/screens/offers_screen.dart';
import 'package:basita1/features/visits/screens/visits_screen.dart';
import 'package:basita1/features/home/screens/shatably_app.dart';
import 'package:basita1/features/ai_assistant/screens/ai_assistant_screen.dart';
import 'package:basita1/core/session/user_session.dart';
import 'package:basita1/features/profile/screens/personal_data_screen.dart';
import 'package:basita1/features/feedback/screens/coming_soon_screen.dart';
import 'package:basita1/features/payment/screens/final_payment_screen.dart';
import 'package:basita1/core/network/mock_backend.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  static const Color brandBlue = Color(0xFF0053AC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bgLightGrey = Color(0xFFF8FAFC);

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLatestUserData(); // جلب أحدث بيانات المستخدم من فايربيز عند الفتح
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // دالة لجلب أحدث البيانات من Firestore وتحديث الـ UserSession
  Future<void> _fetchLatestUserData() async {
    try {
      String userPhone = UserSession.instance.phone.trim();
      String? currentUid = MockAuth.currentUser?.uid;

      QuerySnapshot? querySnapshot;

      if (currentUid != null && currentUid.isNotEmpty) {
        var doc = await MockFirestore
            .collection('users')
            .doc(currentUid)
            .get();
        if (doc.exists && doc.data() != null) {
          _updateSessionFromMap(doc.data() as Map<String, dynamic>);
          return;
        }
      }

      if (userPhone.isNotEmpty) {
        querySnapshot = await MockFirestore
            .collection('users')
            .where('phone', isEqualTo: userPhone)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          _updateSessionFromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      debugPrint("خطأ في جلب بيانات المستخدم: $e");
    }
  }

  void _updateSessionFromMap(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      UserSession.instance.name = data['name'] ?? UserSession.instance.name;
      UserSession.instance.email = data['email'] ?? UserSession.instance.email;
      UserSession.instance.city = data['city'] ?? UserSession.instance.city;
      UserSession.instance.profileImagePath =
          data['profileImagePath'] ?? UserSession.instance.profileImagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: bgLightGrey,
            appBar: _buildCustomAppBar(context),
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: 20),
                    _buildDiscountsSection(context),
                    const SizedBox(height: 24),
                    _buildHeroButtonsSection(context),
                    const SizedBox(height: 24),
                    _buildSimpleServicesSection(context),
                    const SizedBox(height: 28),
                    _buildCommunityPromoCard(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildCustomBottomNavBar(context),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    String rawName = UserSession.instance.name.trim();
    String firstName = rawName.isNotEmpty
        ? rawName.split(' ').first
        : 'يا فندم';

    String? userProfileImage = UserSession.instance.profileImagePath;

    // تحديد نوع الصورة (رابط سحابي أونلاين أو مسار محلي)
    ImageProvider profileImageProvider;
    if (userProfileImage != null && userProfileImage.isNotEmpty) {
      if (userProfileImage.startsWith('http')) {
        profileImageProvider = NetworkImage(userProfileImage);
      } else {
        profileImageProvider = FileImage(File(userProfileImage));
      }
    } else {
      profileImageProvider = const AssetImage(
        'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
      );
    }

    return AppBar(
      backgroundColor: bgLightGrey,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalDataScreen(),
                    ),
                  );
                  // تحديث الواجهة عند العودة من صفحة البيانات الشخصية
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: profileImageProvider,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "مرحباً، $firstName",
                style: GoogleFonts.cairo(
                  color: brandBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              const Text("👋", style: TextStyle(fontSize: 18)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                height: 36,
                child: Image.asset(
                  'assets/logs.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      "بسيطة",
                      style: GoogleFonts.cairo(
                        color: brandBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientRequestsScreen(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: textDark,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: textMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(color: textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: "ابحث عن خدمة أو فني",
                hintStyle: GoogleFonts.cairo(color: textMuted, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none_outlined, color: textMuted),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountsSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "خصومات اليوم",
              style: GoogleFonts.cairo(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OffersApp()),
                );
              },
              child: Text(
                "عرض الكل",
                style: GoogleFonts.cairo(
                  color: brandBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildDiscountCard(
                context,
                title: "تنظيف عميق للمنازل",
                badgeText: "خصم 20%",
                imageUrl: "assets/Gemini_Generated_Image_6mz3236mz3236mz3.png",
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildDiscountCard(
                context,
                title: "صيانة التكييف المركزي",
                badgeText: "عرض محدود",
                imageUrl: "assets/Gemini_Generated_Image_mgsdqtmgsdqtmgsd.png",
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountCard(
    BuildContext context, {
    required String title,
    required String badgeText,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: brandBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 16,
              left: 16,
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroButtonsSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestServiceScreen(),
                ),
              );
            },
            child: Container(
              height: 132,
              decoration: BoxDecoration(
                color: brandBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.build_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "اطلب فني",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "أفضل الفنيين في خدمتك",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShatablyApp()),
              );
            },
            child: Container(
              height: 132,
              decoration: BoxDecoration(
                color: brandBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.architecture_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "شطبلي",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "شطب شقتك علي مزاجك",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleServicesSection(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        "title": "طلب فني",
        "icon": Icons.build_outlined,
        "onTap": () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RequestServiceScreen(),
            ),
          );
        },
      },
      {
        "title": "التأمين",
        "icon": Icons.verified_user_outlined,
        "onTap": () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeInsuranceScreen(),
            ),
          );
        },
      },
      {
        "title": "المساعد الذكي",
        "icon": Icons.smart_toy_outlined,
        "onTap": () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
          );
        },
      },
      {
        "title": "استشارة",
        "icon": Icons.chat_bubble_outline_rounded,
        "onTap": () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ComingSoonScreen()),
          );
        },
      },
      {
        "title": "المجتمع",
        "icon": Icons.people_outline_rounded,
        "onTap": () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunityScreenPerfect(),
            ),
          );
        },
      },
      {
        "title": "شطبلي",
        "icon": Icons.home_work_outlined,
        "onTap": () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShatablyApp()),
          );
        },
      },
      {
        "title": "سجل",
        "icon": Icons.bookmark_border,
        "onTap": () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BasseytaVisitsApp()),
          );
        },
      },
      {
        "title": "العروض",
        "icon": Icons.local_offer_outlined,
        "onTap": () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OffersApp()),
          );
        },
      },
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "خدمات بسيطة",
              style: GoogleFonts.cairo(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "المزيد >",
                style: GoogleFonts.cairo(
                  color: brandBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final service = services[index];
            return GestureDetector(
              onTap: service["onTap"],
              child: Column(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.015),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(service["icon"], color: brandBlue, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service["title"],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: textDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommunityPromoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FE),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            bottom: -20,
            left: -20,
            child: Opacity(
              opacity: 0.08,
              child: const Icon(
                Icons.people_alt_rounded,
                size: 110,
                color: brandBlue,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "مجتمع بسيطة",
                style: GoogleFonts.cairo(
                  color: brandBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "شارك تجاربك مع جيرانك واحصل على توصيات لأفضل الفنيين في منطقتك.",
                style: GoogleFonts.cairo(
                  color: textMuted,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunityScreenPerfect(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  "استكشف المجتمع",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCapsuleNavItem(
                label: "الرئيسية",
                icon: Icons.home_filled,
                onTap: () {},
              ),
              _buildStandardNavItem(
                label: "طلباتي",
                icon: Icons.local_offer_outlined,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestServiceScreen(),
                    ),
                  );
                },
              ),
              _buildStandardNavItem(
                label: "المحادثات",
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatMainPage(),
                    ),
                  );
                },
              ),
              _buildStandardNavItem(
                label: "العائلة",
                icon: Icons.family_restroom_rounded,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FamilyGateScreen(),
                    ),
                  );
                },
              ),
              _buildStandardNavItem(
                label: "الحساب",
                icon: Icons.person_outline_rounded,
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfileScreen(),
                    ),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapsuleNavItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF7FA3E8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF004FB6), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: const Color(0xFF004FB6),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardNavItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF475569), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: const Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}