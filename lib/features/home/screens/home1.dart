import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:basita1/features/orders/screens/orders_screen.dart';
import 'package:basita1/features/orders/screens/sale_screen.dart';
import 'package:basita1/features/profile/screens/profile2.dart';
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/features/home/screens/smart_map_screen.dart';
import 'package:basita1/features/technician/screens/technician_dashboard.dart';
import 'package:basita1/features/booking/screens/appointments_screen.dart';
import 'package:basita1/features/chat/screens/technician_chats_app.dart';

class MainTechnicianScreen extends StatefulWidget {
  const MainTechnicianScreen({super.key});

  @override
  State<MainTechnicianScreen> createState() => _MainTechnicianScreenState();
}

class _MainTechnicianScreenState extends State<MainTechnicianScreen> {
  bool isAvailable = true;

  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color stopRedBg = Color(0xFFFFE4E6);
  static const Color stopRedText = Color(0xFFE11D48);
  static const Color activeGreen = Color(0xFF10B981);

  /// جلب معرّف الفني ديناميكياً
  /// يقبل رقم الهاتف من FirebaseAuth أو UserDataSession ويقوم بتنسيقه ليطابق Firestore
  String get _technicianDocId {
    final user = FirebaseAuth.instance.currentUser;
    String rawPhone = user?.phoneNumber ?? '';

    // إذا كان رقم الهاتف فارغاً في FirebaseAuth، نجرب جلب القيمة من Session
    if (rawPhone.isEmpty) {
      rawPhone = UserDataSession.phone;
    }

    if (rawPhone.isNotEmpty) {
      // إزالة مفتاح الدولة (+20) ليتحول إلى صيغة 012...
      String cleanedPhone = rawPhone.replaceAll('+20', '0').trim();
      if (cleanedPhone.startsWith('20')) {
        cleanedPhone = '0${cleanedPhone.substring(2)}';
      }
      return cleanedPhone;
    }

    // fallback إلى uid في حال لم يتوفر رقم الهاتف
    return user?.uid ?? '';
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialAvailability();
  }

  Future<void> _fetchInitialAvailability() async {
    final String currentTechId = _technicianDocId;
    if (currentTechId.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('technicians')
            .doc(currentTechId)
            .get();
        if (doc.exists && doc.data()!.containsKey('isAvailable')) {
          if (mounted) {
            setState(() {
              isAvailable = doc.data()!['isAvailable'] ?? true;
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching availability: $e");
      }
    }
  }

  Future<void> _toggleAvailability() async {
    final String currentTechId = _technicianDocId;

    setState(() {
      isAvailable = !isAvailable;
    });

    if (currentTechId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('technicians')
            .doc(currentTechId)
            .update({'isAvailable': isAvailable});
      } catch (e) {
        if (mounted) {
          setState(() {
            isAvailable = !isAvailable;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل تحديث الحالة، تأكد من الاتصال بالإنترنت'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) return;
          SystemNavigator.pop();
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: bgLight,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: bgLight,
              elevation: 0,
              title: Row(
                children: [
                  const Text(
                    "بسيطة | الفني",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blueAccent,
                    backgroundImage:
                        UserDataSession.profileImagePath.isNotEmpty
                        ? (UserDataSession.profileImagePath.startsWith('http')
                                  ? NetworkImage(
                                      UserDataSession.profileImagePath,
                                    )
                                  : FileImage(
                                      File(UserDataSession.profileImagePath),
                                    ))
                              as ImageProvider
                        : const AssetImage(
                            'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
                          ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: textDark,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(context),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle("إجراءات سريعة"),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("إحصائيات الأداء"),
                      _buildToggleChips(context),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceChartCard(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle("الطلبات النشطة في منطقتك"),
                  const SizedBox(height: 16),
                  _buildMapCard(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            "مرحبًا، ${UserDataSession.fullName}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isAvailable ? activeGreen : stopRedText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isAvailable ? "متاح للعمل الآن" : "غير متاح للعمل",
                style: const TextStyle(fontSize: 14, color: textGrey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _toggleAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable
                    ? stopRedBg
                    : const Color(0xFFD1FAE5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isAvailable ? "إيقاف استقبال الطلبات" : "تفعيل استقبال الطلبات",
                style: TextStyle(
                  color: isAvailable
                      ? const Color.fromARGB(255, 136, 1, 30)
                      : activeGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
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
        double todayEarnings = 0.0;
        int todayOrdersCount = 0;
        String rating = "4.9";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() ?? {};
          walletBalance = ((data['walletBalance'] ?? 0.0) as num).toDouble();

          DateTime now = DateTime.now();
          String todayStr =
              "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
          String lastDateStr = data['lastEarningDateStr'] ?? '';

          if (lastDateStr == todayStr) {
            todayEarnings = ((data['todayEarnings'] ?? 0.0) as num).toDouble();
            todayOrdersCount = ((data['todayOrdersCount'] ?? 0) as num).toInt();
          } else {
            todayEarnings = 0.0;
            todayOrdersCount = 0;
          }

          if (data['rating'] != null) {
            rating = data['rating'].toString();
          }
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSingleStatCard(
                    context,
                    "رصيد المحفظة",
                    walletBalance.toStringAsFixed(1),
                    "ج.م",
                    Icons.account_balance_wallet_outlined,
                    true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BasiytaApp(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSingleStatCard(
                    context,
                    "أرباح اليوم",
                    todayEarnings.toStringAsFixed(1),
                    "ج.م",
                    Icons.payments_outlined,
                    true,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSingleStatCard(
                    context,
                    "طلبات اليوم",
                    todayOrdersCount.toString(),
                    "",
                    Icons.assignment_turned_in_outlined,
                    false,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSingleStatCard(
                    context,
                    "التقييم",
                    rating,
                    "",
                    Icons.star,
                    false,
                    iconColor: Colors.amber,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSingleStatCard(
    BuildContext context,
    String title,
    String value,
    String suffix,
    IconData icon,
    bool isBlueValue, {
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? primaryBlue, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: textGrey, fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isBlueValue ? primaryBlue : textDark,
                  ),
                ),
                if (suffix.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    suffix,
                    style: TextStyle(
                      fontSize: 12,
                      color: isBlueValue ? primaryBlue : textDark,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== تعديل إجراءات سريعة ====================
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        // زرار بدء العمل (الرئيسي والكبير)
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RequestsPage()),
              );
            },
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "بدء العمل",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // زرار الطلبات الجديدة (مربع صغير)
        Expanded(
          flex: 1,
          child: _buildSmallQuickActionBtn(
            "الطلبات\nالجديدة",
            Icons.notifications_none_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SmartMapScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        // زرار الأرباح (مربع صغير)
        Expanded(
          flex: 1,
          child: _buildSmallQuickActionBtn(
            "الأرباح",
            Icons.trending_up,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TechnicianDashboardS(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSmallQuickActionBtn(
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textDark, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ==============================================================

  Widget _buildToggleChips(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "أسبوعي",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "شهري",
              style: TextStyle(color: textGrey, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChartCard(BuildContext context) {
    final String currentTechId = _technicianDocId;

    return StreamBuilder<QuerySnapshot>(
      stream: currentTechId.isNotEmpty
          ? FirebaseFirestore.instance
                .collection('transactions')
                .where('technicianId', isEqualTo: currentTechId)
                .snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        double weeklyTotal = 0.0;
        Map<int, double> dailyEarningsMap = {
          1: 0.0,
          2: 0.0,
          3: 0.0,
          4: 0.0,
          5: 0.0,
          6: 0.0,
          7: 0.0,
        };

        if (snapshot.hasData) {
          final now = DateTime.now();
          final sevenDaysAgo = now.subtract(const Duration(days: 7));

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['type'] == 'income' && data['createdAt'] != null) {
              DateTime txDate = (data['createdAt'] as Timestamp).toDate();
              if (txDate.isAfter(sevenDaysAgo)) {
                double amount = (data['amount'] ?? 0).toDouble();
                weeklyTotal += amount;
                int weekday = txDate.weekday;
                dailyEarningsMap[weekday] =
                    (dailyEarningsMap[weekday] ?? 0.0) + amount;
              }
            }
          }
        }

        double maxVal = 1.0;
        for (var val in dailyEarningsMap.values) {
          if (val > maxVal) maxVal = val;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
                height: 140,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    DateTime dayToShow = DateTime.now().subtract(
                      Duration(days: 6 - index),
                    );
                    double dayAmount =
                        dailyEarningsMap[dayToShow.weekday] ?? 0.0;
                    double heightFactor = (dayAmount / maxVal).clamp(0.08, 1.0);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (dayAmount > 0)
                          Text(
                            "${dayAmount.toInt()}",
                            style: const TextStyle(
                              fontSize: 9,
                              color: textGrey,
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 14,
                          height: 80 * heightFactor,
                          decoration: BoxDecoration(
                            color: dayAmount > 0
                                ? primaryBlue
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  DateTime dayToShow = DateTime.now().subtract(
                    Duration(days: 6 - index),
                  );
                  List<String> arabicDays = [
                    "الإثنين",
                    "الثلاثاء",
                    "الأربعاء",
                    "الخميس",
                    "الجمعة",
                    "السبت",
                    "الأحد",
                  ];
                  String dayName = arabicDays[dayToShow.weekday - 1];
                  bool isToday = index == 6;

                  return Text(
                    isToday
                        ? "اليوم"
                        : dayName.substring(
                            0,
                            dayName.length > 3 ? 3 : dayName.length,
                          ),
                    style: TextStyle(
                      color: isToday ? textDark : textGrey,
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "إجمالي الأسبوع: ${weeklyTotal.toStringAsFixed(1)} ج.م",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "↑",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapCard(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/Image (26).png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.map, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.my_location, color: primaryBlue, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "الطلبات المحيطة بك الآن",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== تعديل شريط التنقل السفلي ====================
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              "الرئيسية",
              Icons.home_outlined,
              isActive: true,
              onTap: () {},
            ),
            _buildNavItem(
              "الطلبات",
              Icons.assignment_outlined,
              isActive: false,
              onTap: () {
                Navigator.push(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TechnicianChatsApp(),
                  ),
                );
              },
            ),
            _buildNavItem(
              "المواعيد", // تم تعديل الاسم من المحفظة إلى المواعيد
              Icons.calendar_today_outlined, // تغيير الأيقونة
              isActive: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentsScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              "حسابي",
              Icons.person_outline,
              isActive: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  // ==============================================================

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF93C5FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF0056D2)
                  : const Color(0xFF4B5563),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
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
