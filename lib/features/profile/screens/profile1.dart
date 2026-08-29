import 'package:flutter/material.dart';
import 'package:basita1/features/home/screens/home1.dart'; // تأكد من وجود هذا الملف

class BasiytaTechApp extends StatelessWidget {
  const BasiytaTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بسيطة | الفني',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D54DA),
        scaffoldBackgroundColor: const Color(
          0xFFF9FAFC,
        ), // لون خلفية فاتح ومريح
        fontFamily: 'Cairo', // يفضل إضافة خط Cairo أو Tajawal في pubspec.yaml
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // التطبيق باللغة العربية
          child: child!,
        );
      },
      home: const MainDashboardScreen(),
    );
  }
}

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // 0: الرئيسية، 1: الطلبات، 2: المحادثات، 3: المواعيد، 4: حسابي
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 25),
              _buildStatsGrid(),
              const SizedBox(height: 30),
              _buildSectionTitle('إجراءات سريعة'),
              const SizedBox(height: 15),
              _buildQuickActions(),
              const SizedBox(height: 30),
              _buildSectionTitle('إحصائيات الأداء'),
              const SizedBox(height: 15),
              _buildPerformanceSection(), // تم حل مشكلة التجاوز (Overflow) هنا!
              const SizedBox(height: 30),
              _buildSectionTitle('الطلبات النشطة في منطقتك'),
              const SizedBox(height: 15),
              _buildMapSection(),
              const SizedBox(height: 30), // مساحة سفلية
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ==========================================
  // 1. Header App Bar (الهيدر)
  // ==========================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9FAFC),
      elevation: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Navigate to Profile Page
              print('الذهاب لصفحة الملف الشخصي');
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0D54DA), width: 2),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'بسيطة | الفني',
            style: TextStyle(
              color: Color(0xFF0D54DA),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.black87,
            size: 28,
          ),
          onPressed: () {
            // TODO: Navigate to Notifications
            print('الذهاب لصفحة الإشعارات');
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // ==========================================
  // 2. Welcome & Status Section (الترحيب والحالة)
  // ==========================================
  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const Text(
          'مرحبًا، محمد',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'متاح للعمل الآن',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {
            // TODO: Action for stopping work requests
            print('إيقاف استقبال الطلبات');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFEBEE), // أحمر فاتح
            foregroundColor: const Color(0xFFD32F2F), // نص أحمر
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'إيقاف استقبال الطلبات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. Stats Grid (الشبكة الرباعية للإحصائيات)
  // ==========================================
  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        _statCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'رصيد المحفظة',
          value: '1,250 ج.م',
          onTap: () {
            // TODO: Navigate to Wallet
          },
        ),
        _statCard(
          icon: Icons.payments_outlined,
          title: 'أرباح اليوم',
          value: '480 ج.م',
          onTap: () {
            // TODO: Navigate to Today's Earnings
          },
        ),
        _statCard(
          icon: Icons.assignment_turned_in_outlined,
          title: 'طلبات اليوم',
          value: '6',
          onTap: () {
            // TODO: Navigate to Today's Orders
          },
        ),
        _statCard(
          icon: Icons.star,
          iconColor: Colors.amber,
          title: 'التقييم',
          value: '4.9',
          onTap: () {
            // TODO: Navigate to Reviews/Ratings
          },
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? const Color(0xFF0D54DA), size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. Quick Actions (الإجراءات السريعة)
  // ==========================================
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(
          icon: Icons.play_circle_fill,
          title: 'بدء العمل',
          isActive: true,
          onTap: () {
            // TODO: Start work action
          },
        ),
        _actionButton(
          icon: Icons.notifications_active_outlined,
          title: 'الطلبات\nالجديدة',
          onTap: () {
            // TODO: Navigate to New Orders
          },
        ),
        _actionButton(
          icon: Icons.map_outlined,
          title: 'الخريطة',
          onTap: () {
            // TODO: Navigate to Map View
          },
        ),
        _actionButton(
          icon: Icons.trending_up,
          title: 'الأرباح',
          onTap: () {
            // TODO: Navigate to Earnings page
          },
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0D54DA) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF0D54DA).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.black87,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 5. Performance Section & Chart (إحصائيات الأداء) - Overflow Fixed!
  // ==========================================
  Widget _buildPerformanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Tabs (أسبوعي - شهري)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _chartTab('أسبوعي', true),
                    _chartTab('شهري', false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart Area (رسم بياني مخصص)
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(painter: ChartLinePainter()),
          ),
          const SizedBox(height: 15),
          // Days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dayText('السبت', false),
              _dayText('الأحد', false),
              _dayText('الاثنين', false),
              _dayText('اليوم', true), // أزرق
              _dayText('الأربعاء', false),
              _dayText('الخميس', false),
              _dayText('الجمعة', false),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(),
          ),

          // ==========================================
          // الحل لمشكلة تجاوز الشاشة (Right Overflow Fixed)
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // استخدمت Flexible للنصوص الطويلة حتى تنضغط بدون إظهار خطأ
              Flexible(
                flex: 3,
                child: const Text(
                  'إجمالي الأسبوع: 2,450 ج.م',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                flex: 2,
                child: const Text(
                  'مقارنة بالأسبوع الماضي',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '12%',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 2),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.green,
                      size: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartTab(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        // TODO: Change chart filter
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0D54DA) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _dayText(String day, bool isToday) {
    return Text(
      day,
      style: TextStyle(
        color: isToday ? const Color(0xFF0D54DA) : Colors.grey.shade400,
        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
    );
  }

  // ==========================================
  // 6. Map Section (الطلبات النشطة في منطقتك)
  // ==========================================
  Widget _buildMapSection() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Full Screen Map
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade300,
          image: const DecorationImage(
            // صورة مؤقتة لخريطة، يمكنك استبدالها بصورة من أصول التطبيق (assets)
            image: NetworkImage('https://i.stack.imgur.com/HILmr.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Floating Location Tag
            Positioned(
              bottom: 15,
              right: 15, // يمين بسبب RTL
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.my_location, color: Color(0xFF0D54DA), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'القاهرة، المعادي',
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
    );
  }

  // ==========================================
  // 7. Bottom Navigation Bar (شريط التنقل)
  // ==========================================
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'الرئيسية',
            ),
            _navItem(
              index: 1,
              icon: Icons.assignment_outlined,
              activeIcon: Icons.assignment,
              label: 'الطلبات',
            ),
            _navItem(
              index: 2,
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'المحادثات',
            ),
            _navItem(
              index: 3,
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today,
              label: 'المواعيد',
            ),
            _navItem(
              index: 4,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainTechnicianScreen()),
        );
        print('تم الضغط على $label');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF739BFE)
              : Colors.transparent, // لون أزرق فاتح للحالة النشطة
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? const Color(0xFF002266)
                  : const Color(0xFF4A4A4A),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF002266)
                    : const Color(0xFF4A4A4A),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Section Titles
  Widget _buildSectionTitle(String title, {bool isInline = false}) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: const Color(0xFF0D54DA)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isInline ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// رسم الخط البياني (Custom Chart Painter)
// لمحاكاة الصورة المرفقة بلمسة احترافية
// ==========================================
class ChartLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D54DA)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.7,
      size.width * 0.25,
      size.height * 0.5,
    ); // Sat-Sun
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.1,
    ); // Mon-Today (Peak)
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.4,
      size.width * 0.75,
      size.height * 0.4,
    ); // Wed-Thu
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.4,
      size.width,
      size.height * 0.7,
    ); // Fri

    // التدرج اللوني تحت الخط
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D54DA).withValues(alpha: 0.2),
          const Color(0xFF0D54DA).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint); // رسم الظل
    canvas.drawPath(path, paint); // رسم الخط الأساسي

    // رسم النقطة الزرقاء والبيضاء عند "اليوم" (أعلى قمة)
    final dotPaint = Paint()
      ..color = const Color(0xFF0D54DA)
      ..style = PaintingStyle.fill;
    final whiteDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // موضع النقطة بناءً على القمة في المنحنى
    Offset peakPosition = Offset(size.width * 0.5, size.height * 0.1);
    canvas.drawCircle(peakPosition, 7, whiteDotPaint); // إطار أبيض
    canvas.drawCircle(peakPosition, 4, dotPaint); // نقطة زرقاء
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
