import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// تأكد من مسار ملف UserDataSession الخاص بك
import 'package:basita1/core/session/user_data_session.dart';

class TechnicianDashboardS extends StatefulWidget {
  const TechnicianDashboardS({super.key});

  @override
  State<TechnicianDashboardS> createState() => _TechnicianDashboardSState();
}

class _TechnicianDashboardSState extends State<TechnicianDashboardS> {
  // ألوان تطبيق بسيطة الأساسية
  static const Color primaryBlue = Color(0xFF0053AC);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textGrey = Color(0xFF8C8C8C);
  static const Color barLightBlue = Color(0xFFB9D0EA);

  // دالة لحساب مستوى الفني ديناميكياً بناءً على عدد الطلبات
  Map<String, dynamic> _calculateLevel(int completedOrders) {
    if (completedOrders <= 20) {
      return {
        'currentLevel': 'مبتدئ',
        'nextLevel': 'فني برونزي',
        'color': Colors.blue.shade300,
        'progress': completedOrders / 20.0,
        'remaining': 20 - completedOrders,
      };
    } else if (completedOrders <= 50) {
      return {
        'currentLevel': 'فني برونزي',
        'nextLevel': 'فني فضي',
        'color': const Color(0xFFCD7F32), // لون برونزي
        'progress': (completedOrders - 20) / (50 - 20),
        'remaining': 50 - completedOrders,
      };
    } else if (completedOrders <= 100) {
      return {
        'currentLevel': 'فني فضي',
        'nextLevel': 'فني ذهبي',
        'color': const Color(0xFF9E9E9E), // لون فضي
        'progress': (completedOrders - 50) / (100 - 50),
        'remaining': 100 - completedOrders,
      };
    } else if (completedOrders <= 200) {
      return {
        'currentLevel': 'فني ذهبي',
        'nextLevel': 'المستوى الماسي',
        'color': const Color(0xFFC5A059), // لون ذهبي
        'progress': (completedOrders - 100) / (200 - 100),
        'remaining': 200 - completedOrders,
      };
    } else if (completedOrders <= 400) {
      return {
        'currentLevel': 'فني ماسي',
        'nextLevel': 'فني محترف',
        'color': const Color(0xFF00BFFF), // لون أزرق ماسي
        'progress': (completedOrders - 200) / (400 - 200),
        'remaining': 400 - completedOrders,
      };
    } else {
      return {
        'currentLevel': 'فني محترف',
        'nextLevel': 'القمة',
        'color': const Color(0xFF8A2BE2), // لون بنفسجي للمحترفين
        'progress': 1.0,
        'remaining': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // الاعتماد الكلي على الاكونت المفتوح حالياً من الجلسة
    String currentPhone = UserDataSession.phone;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        // قراءة حية من Firestore بناءً على رقم التليفون
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('technicians')
              .doc(currentPhone)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'جاري تحميل بيانات الحساب...',
                  style: GoogleFonts.cairo(color: textGrey, fontSize: 16),
                ),
              );
            }

            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            // --- جلب البيانات الديناميكية ---

            // الاسم والصورة (الأولوية للـ Firebase ثم للـ Session)
            String fullName = data['fullName'] ?? UserDataSession.fullName;
            if (fullName.isEmpty) fullName = 'يا بطل';

            String firstName = fullName.trim().split(' ').isNotEmpty
                ? fullName.trim().split(' ')[0]
                : 'يا بطل';

            String profileImageUrl =
                data['profileImagePath'] ?? UserDataSession.profileImagePath;

            // أرقام الأداء (تم التعديل لتتطابق مع الداتا بيز وتجنب أخطاء الكسور)
            int earnings = ((data['totalEarnings'] ?? 0) as num).toInt();
            int completedOrders = ((data['todayOrdersCount'] ?? 0) as num)
                .toInt();
            double rating = ((data['rating'] ?? 0.0) as num).toDouble();
            int responseTime = ((data['responseTime'] ?? 0) as num).toInt();
            int activeTasks = ((data['activeTasks'] ?? 0) as num).toInt();

            // معدلات الأداء (لو لسه جديد بتبدأ بـ 100% قبول ورضا و 0% إلغاء)
            double customerSatisfaction =
                ((data['customerSatisfaction'] ?? 1.0) as num).toDouble();
            double acceptanceRate = ((data['acceptanceRate'] ?? 1.0) as num)
                .toDouble();
            double cancellationRate = ((data['cancellationRate'] ?? 0.0) as num)
                .toDouble();

            // --- حساب المستوى ديناميكياً ---
            Map<String, dynamic> levelData = _calculateLevel(completedOrders);

            return CustomScrollView(
              slivers: [
                // AppBar
                SliverAppBar(
                  backgroundColor: bgLight,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  pinned: true,
                  title: Text(
                    'بسيطة | الفني',
                    style: GoogleFonts.cairo(
                      color: primaryBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new, // سهم الرجوع
                      color: primaryBlue,
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // تفعيل زر الرجوع
                    },
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryBlue, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                // المحتوى
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildDynamicWelcomeCard(firstName, levelData),
                      const SizedBox(height: 16),
                      _buildStatsGrid(
                        earnings: earnings,
                        completedOrders: completedOrders,
                        rating: rating,
                        responseTime: responseTime,
                        data: data,
                      ),
                      const SizedBox(height: 16),
                      _buildChartCard(data),
                      const SizedBox(height: 16),
                      _buildPerformanceIndicators(
                        customerSatisfaction,
                        acceptanceRate,
                        cancellationRate,
                      ),
                      const SizedBox(height: 16),
                      _buildActiveTasksCard(activeTasks),
                      const SizedBox(height: 16),
                      _buildAchievementsGallery(
                        data['achievements'] as List<dynamic>? ?? [],
                      ),
                      const SizedBox(height: 30),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 1. بطاقة الترحيب الديناميكية بالكامل
  Widget _buildDynamicWelcomeCard(
    String firstName,
    Map<String, dynamic> levelData,
  ) {
    String currentLevel = levelData['currentLevel'];
    String nextLevel = levelData['nextLevel'];
    Color levelColor = levelData['color'];
    double progress = levelData['progress'];
    int remaining = levelData['remaining'];
    int percentInt = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 85,
                height: 85,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.workspace_premium,
                  color: levelColor,
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'مرحباً بك، $firstName!',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: textGrey,
                fontWeight: FontWeight.w600,
              ),
              children: [
                const TextSpan(text: 'أنت حالياً في مستوى '),
                TextSpan(
                  text: currentLevel,
                  style: GoogleFonts.cairo(
                    color: levelColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: remaining > 0
                      ? '.\n حقق $remaining مهام إضافية للوصول لـ $nextLevel.'
                      : '.\n لقد وصلت لأعلى مستوى متاح!',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentInt% من التقدم',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                nextLevel,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. شبكة الإحصائيات الديناميكية
  Widget _buildStatsGrid({
    required int earnings,
    required int completedOrders,
    required double rating,
    required int responseTime,
    required Map<String, dynamic> data,
  }) {
    String formattedEarnings = earnings.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    String ordersIndicator = data['ordersGrowth'] != null
        ? '+${data['ordersGrowth']}'
        : '0';
    String earningsIndicator = data['earningsGrowth'] != null
        ? '+${data['earningsGrowth']}%'
        : '0%';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'الطلبات المكتملة',
                value: completedOrders.toString(),
                unit: '',
                icon: Icons.checklist_rtl,
                indicatorText: ordersIndicator,
                indicatorColor: primaryBlue,
                borderColor: primaryBlue,
                isLeftBorder: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'إجمالي الأرباح',
                value: formattedEarnings,
                unit: 'ج.م',
                icon: Icons.account_balance_wallet_outlined,
                indicatorText: earningsIndicator,
                indicatorColor: primaryBlue,
                borderColor: primaryBlue,
                isLeftBorder: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'وقت الاستجابة',
                value: responseTime.toString(),
                unit: 'دقيقة',
                icon: Icons.bolt,
                indicatorText: responseTime == 0
                    ? '--'
                    : (responseTime <= 20 ? 'سريع' : 'متوسط'),
                indicatorColor: primaryBlue,
                borderColor: Colors.grey.shade300,
                isLeftBorder: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'متوسط التقييم',
                value: rating.toString(),
                unit: '/ 5',
                icon: Icons.star,
                iconColor: const Color(0xFFC5A059),
                indicatorText: rating == 0.0
                    ? 'جديد'
                    : (rating >= 4.5 ? 'ممتاز' : 'جيد'),
                indicatorColor: const Color(0xFFC5A059),
                borderColor: const Color(0xFFC5A059),
                isLeftBorder: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    Color iconColor = primaryBlue,
    required String indicatorText,
    required Color indicatorColor,
    required Color borderColor,
    required bool isLeftBorder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          right: isLeftBorder
              ? BorderSide.none
              : BorderSide(color: borderColor, width: 4),
          left: isLeftBorder
              ? BorderSide(color: borderColor, width: 4)
              : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                indicatorText,
                style: GoogleFonts.cairo(
                  color: indicatorColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Icon(icon, color: iconColor.withValues(alpha: 0.8), size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              if (unit.isNotEmpty) const SizedBox(width: 4),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. الرسم البياني الديناميكي
  Widget _buildChartCard(Map<String, dynamic> data) {
    List<double> weekData = [0, 0, 0, 0, 0, 0, 0];
    if (data.containsKey('weeklyChartData') &&
        data['weeklyChartData'] != null) {
      weekData = List<double>.from(
        data['weeklyChartData'].map((x) => (x as num).toDouble()),
      );
    }

    double maxVal = weekData.reduce((curr, next) => curr > next ? curr : next);
    double scale = maxVal > 0 ? 120 / maxVal : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اتجاه الأرباح الأسبوعي',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Text(
                      'آخر 7 أيام',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: textGrey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildResponsiveBarItem('السبت', weekData[0] * scale, false),
                _buildResponsiveBarItem('الأحد', weekData[1] * scale, false),
                _buildResponsiveBarItem('الاثنين', weekData[2] * scale, false),
                _buildResponsiveBarItem('الثلاثاء', weekData[3] * scale, false),
                _buildResponsiveBarItem(
                  'الأربعاء',
                  weekData[4] * scale,
                  weekData[4] == maxVal && maxVal > 0,
                ),
                _buildResponsiveBarItem('الخميس', weekData[5] * scale, false),
                _buildResponsiveBarItem('الجمعة', weekData[6] * scale, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveBarItem(
    String day,
    double height,
    bool isHighlighted,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: height > 0 ? height : 5,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isHighlighted ? primaryBlue : barLightBlue,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: textGrey,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }

  // 4. مؤشرات الأداء الديناميكية
  Widget _buildPerformanceIndicators(
    double satisfaction,
    double acceptance,
    double cancellation,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مؤشرات الأداء',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressRow(
            'رضا العملاء',
            satisfaction,
            '${(satisfaction * 100).toInt()}%',
            primaryBlue,
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            'معدل القبول',
            acceptance,
            '${(acceptance * 100).toInt()}%',
            primaryBlue,
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            'معدل الإلغاء',
            cancellation,
            '${(cancellation * 100).toInt()}%',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(
    String label,
    double value,
    String percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              percentage,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // 5. المهام النشطة
  Widget _buildActiveTasksCard(int activeTasks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_ind_outlined,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                'المهام النشطة حالياً',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            activeTasks.toString(),
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 6. معرض الإنجازات الديناميكي
  Widget _buildAchievementsGallery(List<dynamic> achievements) {
    if (achievements.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'معرض الإنجازات',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100, width: 2),
            ),
            child: Center(
              child: Text(
                'لا توجد إنجازات حالياً. أتمم المزيد من الطلبات لفتح الإنجازات!',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'معرض الإنجازات',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              Text(
                'مشاهدة الكل',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...achievements.map((achievement) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildAchievementItem(
              title: achievement['title'] ?? 'إنجاز جديد',
              subtitle: achievement['subtitle'] ?? '',
              icon: Icons.emoji_events,
              iconColor: const Color(0xFFC5A059),
              bgColor: const Color(0xFFC5A059).withValues(alpha: 0.15),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAchievementItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
