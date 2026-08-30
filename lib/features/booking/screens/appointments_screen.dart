import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/features/home/screens/home1.dart';
import 'package:basita1/features/profile/screens/profile2.dart';
import 'package:basita1/features/orders/screens/orders_screen.dart';
import 'package:basita1/features/chat/screens/chat_screen.dart';
// استيراد صفحة إتمام المهمة والموديل الخاص بها
import 'package:basita1/features/orders/screens/complete_task_page.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0; // 0: اليوم, 1: غدًا, 2: قيد التنفيذ, 3: المكتملة
  final int _currentIndex = 3;

  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color lightBlueBg = Color(0xFFEFF5FF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color bgLight = Color(0xFFF9FAFB);

  final List<String> _tabs = ['اليوم', 'غدًا', 'قيد التنفيذ', 'المكتملة'];

  // أنيميشن للتوهج عند بدء العمل
  late AnimationController _glowController;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation =
        ColorTween(
          begin: Colors.amber.shade200.withOpacity(0.4),
          end: Colors.amber.shade500.withOpacity(0.8),
        ).animate(
          CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // جلب بيانات الفني الحالي للتصفية بشكل دقيق
    final currentUser = FirebaseAuth.instance.currentUser;
    final String currentUserId = currentUser?.uid ?? '';
    final String currentUserPhone = UserDataSession.phone;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('requests')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ في تحميل المواعيد',
                          style: GoogleFonts.cairo(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    final now = DateTime.now();
                    final todayStr =
                        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                    final tomorrow = now.add(const Duration(days: 1));
                    final tomorrowStr =
                        "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";

                    final appointments = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final assignedTechId =
                          data['technicianId'] ??
                          data['acceptedByTechId'] ??
                          '';
                      final status = data['status'] ?? 'pending';

                      // تصفية الطلبات المعلقة التي لم يتم قبولها بعد
                      if (status == 'pending') return false;

                      // تصفية المهام بناءً على التبويب
                      final scheduledDate =
                          data['scheduledDate'] ?? data['date'] ?? '';
                      final bool isWorking =
                          data['workStarted'] == true ||
                          status == 'in_progress';

                      if (_selectedTab == 0) {
                        return scheduledDate == todayStr ||
                            scheduledDate == 'الآن' ||
                            isWorking;
                      } else if (_selectedTab == 1) {
                        return scheduledDate == tomorrowStr;
                      } else if (_selectedTab == 2) {
                        return isWorking;
                      } else if (_selectedTab == 3) {
                        return status == 'completed' ||
                            status == 'task_finished_pending_invoice' ||
                            status == 'awaiting_payment';
                      }
                      return true;
                    }).toList();

                    if (appointments.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final doc = appointments[index];
                        final data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAppointmentCard(data),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مواعيدي والطلبات',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تابع مواعيدك وبدء العمل بحرّفية',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: primaryBlue,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? primaryBlue : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                _tabs[index],
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : textGrey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد مواعيد في هذا القسم',
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر الطلبات التي تقبلها أو تبدأ العمل عليها هنا.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 13, color: textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> data) {
    final String title = data['title'] ?? data['serviceType'] ?? 'خدمة صيانة';
    final String clientName =
        data['name'] ?? data['userName'] ?? data['customerName'] ?? 'العميل';
    final String description = data['description'] ?? 'لا يوجد وصف متاح';
    final String scheduledDate =
        data['scheduledDate'] ?? data['date'] ?? 'غير محدد';
    final String price = data['price'] ?? data['budget'] ?? 'غير محدد';
    final String location = data['location'] ?? data['region'] ?? 'الإسكندرية';
    final String status = data['status'] ?? 'accepted';
    final bool workStarted =
        data['workStarted'] == true || status == 'in_progress';
    final String requestId = data['id'] ?? '';
    final String imageUrl = data['image'] ?? '';

    // التحقق من حالة الاكتمال
    final bool isCompleted =
        status == 'completed' ||
        status == 'task_finished_pending_invoice' ||
        status == 'awaiting_payment';

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // توهج البطاقة عندما تكون قيد التنفيذ
            boxShadow: [
              if (workStarted && !isCompleted)
                BoxShadow(
                  color: _glowAnimation.value ?? Colors.amber.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
            border: Border.all(
              color: workStarted && !isCompleted
                  ? Colors.amber.shade400
                  : const Color(0xFFE5E7EB),
              width: workStarted && !isCompleted ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: lightBlueBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.build_circle_outlined,
                          size: 16,
                          color: primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status, workStarted, isCompleted),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage(
                                'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
                              )
                              as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: textGrey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: textGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            scheduledDate,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            price,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: GoogleFonts.cairo(fontSize: 12, color: textDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // أزرار التحكم: مخفية إذا كان الطلب مكتملاً
              if (!isCompleted)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: workStarted
                            ? null
                            : () async {
                                // تفعيل زر بدء العمل "التوهج"
                                await FirebaseFirestore.instance
                                    .collection('requests')
                                    .doc(requestId)
                                    .update({
                                      'workStarted': true,
                                      'status': 'in_progress',
                                    });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم تفعيل حالة العمل بنجاح!',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: Colors.amber.shade700,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                        icon: Icon(
                          workStarted ? Icons.sync : Icons.play_arrow_rounded,
                          color: workStarted ? textGrey : Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          workStarted ? 'العمل جاري' : 'بدء العمل',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: workStarted ? textGrey : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: workStarted
                              ? Colors.grey.shade200
                              : primaryBlue,
                          elevation: workStarted ? 0 : 2,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: !workStarted
                            ? null
                            : () {
                                // تجهيز بيانات الطلب (RequestModel) وتوجيه الفني لصفحة إتمام المهمة الحقيقية
                                RequestModel requestModel = RequestModel(
                                  id: requestId,
                                  name: clientName,
                                  time: scheduledDate,
                                  distance: 'محدد من الخريطة',
                                  rating: '5.0',
                                  serviceType: title,
                                  serviceIcon:
                                      Icons.home_repair_service_outlined,
                                  location: location,
                                  description: description,
                                  price: price,
                                  imagePath: imageUrl,
                                  status: status,
                                  isNetworkImage: imageUrl.isNotEmpty,
                                  clientPhone:
                                      data['phone'] ??
                                      data['userPhone'] ??
                                      '+20 1000000000',
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CompleteTaskPage(request: requestModel),
                                  ),
                                );
                              },
                        icon: Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: workStarted
                              ? Colors.green
                              : Colors.grey.shade400,
                        ),
                        label: Text(
                          'إنهاء المهمة',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: workStarted
                                ? Colors.green
                                : Colors.grey.shade400,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: workStarted
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Widget _buildStatusBadge(String status, bool workStarted, bool isCompleted) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    if (isCompleted) {
      bgColor = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF16A34A);
      label = 'مكتمل (Completed)';
      icon = Icons.done_all;
    } else if (workStarted || status == 'in_progress') {
      bgColor = Colors.amber.shade50;
      textColor = Colors.amber.shade900;
      label = 'نشط / قيد التنفيذ';
      icon = Icons.handyman;
    } else {
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF2563EB);
      label = 'مؤكد / في الانتظار';
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomNavItem(0, Icons.home_outlined, Icons.home, 'الرئيسية', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainTechnicianScreen(),
                ),
              );
            }),
            _bottomNavItem(
              1,
              Icons.assignment_outlined,
              Icons.assignment,
              'الطلبات',
              () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestsPage()),
                );
              },
            ),
            _bottomNavItem(
              2,
              Icons.chat_bubble_outline,
              Icons.chat_bubble,
              'المحادثات',
              () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatMainPage()),
                );
              },
            ),
            _bottomNavItem(
              3,
              Icons.calendar_today_outlined,
              Icons.calendar_today,
              'المواعيد',
              () {},
            ),
            _bottomNavItem(4, Icons.person_outline, Icons.person, 'حسابي', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    VoidCallback onTap,
  ) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? lightBlueBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryBlue : const Color(0xFF4B5563),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected ? primaryBlue : const Color(0xFF4B5563),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
