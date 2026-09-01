import 'package:flutter/material.dart';
// removed: cloud_firestore - see docs/backend-prd.html
// removed: firebase_auth
import 'package:google_fonts/google_fonts.dart';

// استدعاء صفحات التنقل السفلية وبيانات الجلسة
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/core/network/mock_backend.dart';

class BasiytaApp extends StatelessWidget {
  const BasiytaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: WalletScreen(),
    );
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool isDailyStats = true; // للتبديل بين إحصائيات يومي / شهري

  final Color primaryBlue = const Color(0xFF0056D2);
  final Color textDark = const Color(0xFF1D1D1D);
  final Color textGrey = const Color(0xFF6C757D);
  final Color bgLight = const Color(0xFFF8F9FA);

  /// جلب معرّف الفني ديناميكياً بنفس الطريقة المستخدمة في الشاشة الرئيسية
  String get _technicianDocId {
    final user = MockAuth.currentUser;
    String rawPhone = user?.phoneNumber ?? '';

    // إذا كان رقم الهاتف فارغاً في dynamic، نجرب جلب القيمة من Session
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
  Widget build(BuildContext context) {
    final String currentTechId = _technicianDocId;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      // قراءة الداتا مباشرة من Transactions لضمان الديناميكية
      body: StreamBuilder<dynamic>(
        stream: currentTechId.isNotEmpty
            ? MockFirestore.collection(
                'transactions',
              ).where('technicianId', isEqualTo: currentTechId).snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          double walletBalance = 0.0;
          double totalEarnings = 0.0;
          double todayEarnings = 0.0;

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            DateTime now = DateTime.now();
            String todayStr =
                "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

            for (var doc in snapshot.data!.docs) {
              final data = doc.data();
              double amount = ((data['amount'] ?? 0.0) as num).toDouble();
              bool isPositive = data['isPositive'] ?? true;
              String type = data['type'] ?? '';

              // معالجة التاريخ (تحويل Timestamp إلى String لو dateStr مش موجود)
              String txDateStr = data['dateStr'] ?? '';
              if (txDateStr.isEmpty && data['createdAt'] != null) {
                DateTime dt = (data['createdAt'] as Timestamp).toDate();
                txDateStr =
                    "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
              }

              // حساب الرصيد الإجمالي بناءً على حالة العملية
              if (isPositive) {
                walletBalance += amount;
              } else {
                walletBalance -= amount;
              }

              // حساب الأرباح (الإجمالي واليومي)
              if (type == 'income' || isPositive) {
                totalEarnings += amount;
                if (txDateStr == todayStr) {
                  todayEarnings += amount;
                }
              }
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 20),
                _buildBalanceCard(walletBalance),
                const SizedBox(height: 24),
                _buildWithdrawalOptions(),
                const SizedBox(height: 24),
                _buildStatisticsSection(todayEarnings, totalEarnings),
                const SizedBox(height: 24),
                _buildRecentTransactions(currentTechId),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 1. الهيدر العلوي (AppBar)
  // ==========================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgLight,
      elevation: 0,
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
      title: Text(
        'بسيطة | الفني',
        style: GoogleFonts.cairo(
          color: primaryBlue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      titleSpacing: 0, // لتقليل المسافة بين السهم والكلمة
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryBlue, width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEFF5FF),
                // يمكنك تفعيل السطر التالي ووضع مسار صورتك الحقيقية
                // backgroundImage: AssetImage('assets/images/profile.png'),
                child: Icon(Icons.person, size: 20, color: Color(0xFF0056D2)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. عناوين الصفحة
  // ==========================================
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المحفظة والأرباح',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'تتبع مستحقاتك المالية وإدارة عمليات السحب لحظياً',
          style: GoogleFonts.cairo(fontSize: 13, color: textGrey),
        ),
      ],
    );
  }

  // ==========================================
  // 3. بطاقة الرصيد المتاح (Balance Card)
  // ==========================================
  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white70,
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            'الرصيد المتاح للسحب',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                balance.toInt().toString(),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ج.م',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showWithdrawBottomSheet(context, balance);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'سحب الرصيد',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // تفاصيل اضافية
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'التفاصيل المالية',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
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

  // ==========================================
  // 4. خيارات السحب (Withdrawal Options)
  // ==========================================
  Widget _buildWithdrawalOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طرق السحب المتاحة',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _withdrawalOptionCard(
              icon: Icons.account_balance,
              title: 'حساب بنكي',
              onTap: () {},
            ),
            _withdrawalOptionCard(
              icon: Icons.phone_android,
              title: 'فودافون كاش',
              onTap: () {},
            ),
            _withdrawalOptionCard(
              icon: Icons.flash_on,
              title: 'إنستا باي',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _withdrawalOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDEE2E6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEFF5FF),
                child: Icon(icon, color: primaryBlue, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 5. إحصائيات الأرباح (Statistics Section)
  // ==========================================
  Widget _buildStatisticsSection(double todayEarnings, double totalEarnings) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'إحصائيات الأرباح',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isDailyStats = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDailyStats ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'يومي',
                        style: GoogleFonts.cairo(
                          color: isDailyStats ? primaryBlue : textGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isDailyStats = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: !isDailyStats
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'إجمالي',
                        style: GoogleFonts.cairo(
                          color: !isDailyStats ? primaryBlue : textGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'أرباح اليوم',
                '${todayEarnings.toInt()} ج.م',
                primaryBlue,
                0.7,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'إجمالي الأرباح',
                '${totalEarnings.toInt()} ج.م',
                const Color(0xFFA67C00),
                0.9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String amount,
    Color barColor,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDEE2E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.cairo(color: textGrey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. آخر العمليات (Recent Transactions - Dynamic)
  // ==========================================
  Widget _buildRecentTransactions(String currentTechId) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آخر العمليات',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'عرض الكل',
                style: GoogleFonts.cairo(
                  color: primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        StreamBuilder<dynamic>(
          stream: currentTechId.isNotEmpty
              ? MockFirestore.collection('transactions')
                    .where('technicianId', isEqualTo: currentTechId)
                    .orderBy('createdAt', descending: true)
                    .limit(10)
                    .snapshots()
              : const Stream.empty(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDEE2E6)),
                ),
                child: Text(
                  'لا توجد عمليات مالية مسجلة حتى الآن',
                  style: GoogleFonts.cairo(color: textGrey, fontSize: 14),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDEE2E6)),
              ),
              child: ListView.separated(
                itemCount: docs.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final serviceName = data['serviceName'] ?? 'عملية صيانة';
                  final amount = ((data['amount'] ?? 0.0) as num).toDouble();
                  final isPositive = data['isPositive'] ?? true;
                  final paymentMethod = data['paymentMethod'] ?? 'إلكتروني';

                  Timestamp? t = data['createdAt'] as Timestamp?;
                  String dateFormatted = 'وقت حديث';
                  if (t != null) {
                    DateTime dt = t.toDate();
                    dateFormatted =
                        "${dt.year}/${dt.month}/${dt.day} - ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF5FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.build_outlined,
                        color: primaryBlue,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      serviceName,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    subtitle: Text(
                      '$dateFormatted ($paymentMethod)',
                      style: GoogleFonts.cairo(fontSize: 11, color: textGrey),
                    ),
                    trailing: Text(
                      '${isPositive ? '+' : '-'}${amount.toInt()} ج.م',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? primaryBlue : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _showWithdrawBottomSheet(BuildContext context, double balance) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سحب الأرباح',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'الرصيد المتاح حالياً للسحب هو: ${balance.toInt()} ج.م',
              style: GoogleFonts.cairo(fontSize: 14, color: textGrey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إرسال طلب السحب بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'تأكيد طلب السحب',
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
    );
  }
}
