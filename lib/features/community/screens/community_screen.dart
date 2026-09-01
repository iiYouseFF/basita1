import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// removed: cloud_firestore - see docs/backend-prd.html
// removed: firebase_auth

// الفايلات المرتبطة والمستوردة في المشروع
import 'package:basita1/core/session/user_session.dart';
import 'package:basita1/features/community/screens/comm1.dart';
import 'package:basita1/features/home/screens/home_screen.dart';
import 'package:basita1/features/family/screens/family_join_screen.dart';
import 'package:basita1/features/profile/screens/profile_screen.dart';
import 'package:basita1/features/booking/screens/request_service_screen.dart';
import 'package:basita1/features/community/screens/comm2.dart';
import 'package:basita1/features/community/screens/comm3.dart';
import 'package:basita1/features/community/screens/comm4.dart';
import 'package:basita1/features/community/screens/comm5.dart';
import 'package:basita1/features/community/screens/comm6.dart';
import 'package:basita1/core/network/mock_backend.dart';

// =========================================================
// شاشة المجتمع المحدثة والمربوطة بالكامل بـ Firebase User Account
// =========================================================
class CommunityScreenPerfect extends StatefulWidget {
  const CommunityScreenPerfect({super.key});

  @override
  State<CommunityScreenPerfect> createState() => _CommunityScreenPerfectState();
}

class _CommunityScreenPerfectState extends State<CommunityScreenPerfect> {
  // لوحة الألوان المعتمدة
  static const Color primaryBlue = Color(0xFF0053AC);
  static const Color activePillBlue = Color(0xFF8FB9EE);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color onlineGreen = Color(0xFF10B981);
  static const Color bgColor = Color(0xFFF9FAFB);

  // قائمة حفظ المجتمعات المنضم لها المستخدم
  List<String> joinedCommunities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJoinedCommunities();
  }

  // دالة لجلب معرّف المستخدم (UID) الحالي
  Future<String?> _getUserId() async {
    // 1. تجربة جلب ID من حساب Firebase Auth الحالي
    String? uid = MockAuth.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) return uid;

    // 2. البحث برقم الهاتف كخيار احتياطي من الجلسة
    String phone = UserSession.instance.phone.trim();
    if (phone.isNotEmpty) {
      try {
        var query = await MockFirestore.collection(
          'users',
        ).where('phone', isEqualTo: phone).limit(1).get();
        if (query.docs.isNotEmpty) {
          return query.docs.first.id;
        }
      } catch (e) {
        debugPrint("خطأ في جلب معرف المستخدم برقم الهاتف: $e");
      }
    }
    return null;
  }

  // دالة جلب المجتمعات المنضم لها من Firestore
  Future<void> _fetchJoinedCommunities() async {
    try {
      String? userId = await _getUserId();
      if (userId != null) {
        var doc = await MockFirestore.collection('users').doc(userId).get();

        if (doc.exists && doc.data() != null) {
          var data = doc.data()!;
          if (data.containsKey('joinedCommunities') &&
              data['joinedCommunities'] != null) {
            setState(() {
              joinedCommunities = List<String>.from(data['joinedCommunities']);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("خطأ أثناء جلب مجتمعات المستخدم: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // دالة الانضمام لمجتمع وحفظه في Firebase
  Future<void> _joinCommunity(String communityId, String title) async {
    // تحديث الواجهة فوراً لتجربة مستخدم سريعة
    if (!joinedCommunities.contains(communityId)) {
      setState(() {
        joinedCommunities.add(communityId);
      });
    }

    try {
      String? userId = await _getUserId();
      if (userId != null) {
        await MockFirestore.collection('users').doc(userId).set({
          'joinedCommunities': MockFieldValue.arrayUnion([communityId]),
        }, MockSetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("خطأ أثناء الانضمام للمجتمع في الفايربيس: $e");
    }

    // الانتقال للشاشة الخاصة بالمجتمع
    _navigateToCommunity(communityId, title);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // 1. الهيدر العلوي
              _buildHeaderComponent(),

              // 2. المحتوى القابل للتمرير
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildBanner(),
                            const SizedBox(height: 20),

                            // قائمة المجتمعات التفاعلية
                            _buildCommunityCards(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBarComponent(),
      ),
    );
  }

  // ==================== الهيدر العلوي ====================
  Widget _buildHeaderComponent() {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2), size: 28),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        "المجتمع",
        style: TextStyle(
          color: primaryBlue,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          fontFamily: 'Cairo',
        ),
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

  // ==================== البانر الأزرق ====================
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "جديد",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "انضم لنقاشات الخبراء اليوم",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "تواصل مع أكثر من 50,000\nفني وخبير في مكان واحد.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== قائمة المجتمعات ====================
  Widget _buildCommunityCards() {
    final List<Map<String, dynamic>> communities = [
      {
        "id": "electricity",
        "title": "مجتمع الكهرباء",
        "subtitle":
            "نقاشات حول التمديدات الكهربائية، لوحات\nالتوزيع، وأنظمة الطاقة الذكية.",
        "icon": "assets/Background+Shadow.png",
        "online": "230",
        "members": "15k",
      },
      {
        "id": "plumbing",
        "title": "مجتمع السباكة",
        "subtitle":
            "كل ما يتعلق بتمديدات المياه والصرف، وصيانة\nالأجهزة الصحية المنزلية.",
        "icon": "assets/Background+Shadow (1).png",
        "online": "142",
        "members": "12k",
      },
      {
        "id": "carpentry",
        "title": "مجتمع النجارة",
        "subtitle":
            "تصنيع الأثاث، أنواع الأخشاب، وتقنيات النجارة\nالحديثة والديكور الخشبي.",
        "icon": "assets/Background+Shadow (2).png",
        "online": "89",
        "members": "8.4k",
      },
      {
        "id": "painting",
        "title": "مجتمع الدهانات",
        "subtitle":
            "عالم الألوان، تقنيات الدهان الحديثة، ومعالجة\nعيوب الحوائط.",
        "icon": "assets/Background+Shadow (3).png",
        "online": "115",
        "members": "9.1k",
      },
      {
        "id": "finishing",
        "title": "مجتمع التشطيبات",
        "subtitle":
            "دليل شامل لتشطيب المنازل من المحارة وحتى\nالديكور النهائي.",
        "icon": "assets/Background+Shadow (4).png",
        "online": "340",
        "members": "22k",
      },
      {
        "id": "ac",
        "title": "مجتمع التكييف",
        "subtitle":
            "صيانة التكييفات، تركيب الأنظمة المركزية، وحلول\nالتبريد المتقدمة.",
        "icon": "assets/Background+Shadow (5).png",
        "online": "67",
        "members": "5.2k",
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: communities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildSingleCard(communities[index]);
      },
    );
  }

  Widget _buildSingleCard(Map<String, dynamic> item) {
    bool isJoined = joinedCommunities.contains(item["id"]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الصف العلوي (الأيقونة وإحصائيات المتواجدين)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                item["icon"],
                width: 55,
                height: 55,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.groups_rounded,
                  size: 50,
                  color: primaryBlue,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 8, color: onlineGreen),
                      const SizedBox(width: 6),
                      Text(
                        "${item['online']} متواجد",
                        style: GoogleFonts.cairo(
                          color: onlineGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${item['members']} عضو",
                    style: GoogleFonts.cairo(color: textGrey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // العنوان والوصف
          Text(
            item["title"],
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item["subtitle"],
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: textGrey,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // زر الانضمام / الدخول المتغير بحسب حالة المستخدم
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isJoined) {
                  _navigateToCommunity(item["id"], item["title"]);
                } else {
                  _joinCommunity(item["id"], item["title"]);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isJoined ? Colors.white : primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: isJoined
                      ? const BorderSide(color: primaryBlue, width: 1.5)
                      : BorderSide.none,
                ),
                elevation: 0,
              ),
              icon: Icon(
                isJoined ? Icons.login_rounded : Icons.person_add_alt_1,
                color: isJoined ? primaryBlue : Colors.white,
                size: 20,
              ),
              label: Text(
                isJoined ? "دخول" : "انضمام",
                style: GoogleFonts.cairo(
                  color: isJoined ? primaryBlue : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== دالة التوجيه للمجتمعات ====================
  void _navigateToCommunity(String id, String title) {
    debugPrint("الانتقال إلى مجتمع: $title (ID: $id)");

    switch (id) {
      case "electricity":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ElectricityCommunityScreen(),
          ),
        );
        break;
      case "plumbing":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CommunityScreen()),
        );
        break;
      case "carpentry":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CarpentryCommunityScreen(),
          ),
        );
        break;
      case "painting":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaintsCommunityScreen(),
          ),
        );
        break;
      case "finishing":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FinishesCommunityScreen(),
          ),
        );
        break;
      case "ac":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const acCommunityScreen()),
        );
        break;
    }
  }

  // ==================== شريط التنقل السفلي ====================
  Widget _buildBottomNavBarComponent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, "الرئيسية", Icons.home_outlined, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
            );
          }),
          _buildNavItem(1, "طلباتي", Icons.local_offer_outlined, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RequestServiceScreen(),
              ),
            );
          }),
          _buildActiveNavPill(2, "المجتمع", Icons.chat_bubble_outline, () {
            debugPrint("أنت بالفعل داخل صفحة المجتمع");
          }),
          _buildNavItem(3, "العائلة", Icons.people_outline_rounded, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FamilyGateScreen()),
            );
          }),
          _buildNavItem(4, "الحساب", Icons.person_outline, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const UserProfileScreen(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveNavPill(
    int index,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: activePillBlue,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryBlue, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
