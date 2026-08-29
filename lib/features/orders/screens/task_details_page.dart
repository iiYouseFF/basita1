import 'package:flutter/material.dart';
import 'package:basita1/features/home/screens/home1.dart';
import 'package:basita1/features/profile/screens/profile2.dart';
import 'package:basita1/features/orders/screens/sale_screen.dart';
import 'package:basita1/features/ai_assistant/screens/ai1_screen.dart';

class TaskDetailsPage extends StatefulWidget {
  const TaskDetailsPage({super.key});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  // دالة للتنقل إلى صفحة جديدة عند الضغط على الأزرار

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم اللغة العربية
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // قسم الخريطة والمسافة
              _buildMapSection(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // كارت بيانات العميل
                    _buildClientInfoCard(),
                    const SizedBox(height: 24),

                    // زر بدء العمل
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005CEE),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // الانتقال عند الضغط على "بدء العمل"

                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const RequestsPage()),
                          // );
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                        label: const Text(
                          'بدء العمل',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // قسم خطوات المهمة
                    const Text(
                      'خطوات المهمة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // شبكة الخطوات الـ 4
                    _buildTaskStepsGrid(),
                    const SizedBox(height: 24),

                    // زر إنهاء المهمة
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => CompleteTaskPage(),
                          //   ),
                          // );
                        },
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF4A5568),
                        ),
                        label: const Text(
                          'إنهاء المهمة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  // 1. الهيدر (شريط التطبيق العلوي)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2), size: 28),
        onPressed: () {
          Navigator.pop(context); // العودة للصفحة السابقة مباشرة
        },
      ),
      title: const Text(
        'بسيطة | الفني',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF005CEE),
        ),
      ),
      actions: [
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            size: 28,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          onPressed: () => (context, 'الإشعارات'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // 2. قسم الخريطة والبطاقة العائمة
  Widget _buildMapSection() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // صورة الخريطة (خلفية)
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/a.png'), // صورة خريطة كـ Placeholder
              fit: BoxFit.cover,
            ),
            color: Color(0xFFE2E8F0),
          ),
        ),
        // بطاقة المسافة المتبقية
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          transform: Matrix4.translationValues(
            0,
            20,
            0,
          ), // لجعل البطاقة تطفو بين الخريطة والمحتوى
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF005CEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_outlined,
                  color: Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'المسافة المتبقية',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
                  ),
                  Text(
                    '12 دقيقة (4.2 كم)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005CEE),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. كارت بيانات العميل
  Widget _buildClientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF82A9FF).withValues(alpha: 0.5),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF00308F),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'سارة المنصوري ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'صيانة تكييف',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
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
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'قيد التنفيذ',
                  style: TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF005CEE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => (context, 'الدردشة مع العميل'),
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF005CEE),
                    size: 20,
                  ),
                  label: const Text(
                    'دردشة',
                    style: TextStyle(
                      color: Color(0xFF005CEE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF005CEE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => (context, 'الاتصال بالعميل'),
                  icon: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF005CEE),
                    size: 20,
                  ),
                  label: const Text(
                    'اتصال',
                    style: TextStyle(
                      color: Color(0xFF005CEE),
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

  // 4. شبكة خطوات المهمة
  Widget _buildTaskStepsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4, // للتحكم في نسبة الطول للعرض لتطابق الصورة
      children: [
        _buildStepCard(
          icon: Icons.camera_alt_outlined,
          title: 'رفع صور قبل العمل',
          onTap: () => (context, 'رفع صور قبل العمل'),
        ),
        _buildStepCard(
          icon: Icons.camera_alt_outlined,
          title: 'رفع صور بعد العمل',
          onTap: () => (context, 'رفع صور بعد العمل'),
        ),
        _buildStepCard(
          icon: Icons.receipt_long_outlined,
          title: 'إصدار فاتورة',
          onTap: () => (context, 'إصدار فاتورة'),
        ),
        _buildStepCard(
          icon: Icons.payments_outlined,
          title: 'طلب الدفع',
          onTap: () => (context, 'طلب الدفع'),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF005CEE), size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // شريط التنقل السفلي التفاعلي (مخصص لصفحة الطلبات)
  // ============================================================================
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. زر الرئيسية
            _buildNavItem(
              "الرئيسية",
              Icons.home_outlined,
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MainTechnicianScreen(), // غيّر اسم الكلاس لصفحة الرئيسية لديك لو مختلف
                  ),
                );
              },
            ),

            // 2. زر الطلبات (النشط حالياً باللون الأزرق)
            _buildNavItem(
              "الطلبات",
              Icons.assignment,
              isActive: true, // مفعّل باللون الأزرق
              onTap: () {
                // أنت بالفعل داخل صفحة الطلبات
              },
            ),

            // 3. زر المحادثات
            _buildNavItem(
              "المحادثات",
              Icons.chat_bubble_outline,
              isActive: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SmartAssistantScreen(),
                  ),
                );
              },
            ),

            // 4. زر المحفظة
            _buildNavItem(
              "المحفظة",
              Icons.account_balance_wallet_outlined,
              isActive: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BasiytaApp()),
                );
              },
            ),

            // 5. زر حسابي
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

  // ودجت تصميم العنصر الفردي داخل الشريط
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
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFF93C5FD), // خلفية الزر النشط (أزرق فاتح)
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF0056D2) // لون الأيقونة النشطة (أزرق غامق)
                  : const Color(0xFF4B5563),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF0056D2) // لون النص النشط
                    : const Color(0xFF4B5563),
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
