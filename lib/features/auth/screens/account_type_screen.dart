import 'package:flutter/material.dart';
import 'package:basita1/features/auth/screens/login_screen.dart';
import 'package:basita1/features/auth/screens/l.dart';
import 'package:basita1/features/auth/screens/technician_onboarding_screen.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

// تعريف نوع الحساب لسهولة تتبع الاختيار
enum AccountType { none, customer, technician }

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  // المتغير الذي يحفظ اختيار المستخدم الحالي
  AccountType _selectedType = AccountType.none;

  // الألوان المعتمدة للتصميم
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorderColor = Color(0xFFE5E7EB);
  static const Color iconBgColor = Color(0xFFEEF2F6);
  static const Color disabledButtonColor = Color(0xFFDCDFE6);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // ==========================================
                // 1. الهيدر واللوجو الجديد (حرف B)
                // ==========================================
                Image.asset(
                  'assets/Gemini_Generated_Image_rlqvx4rlqvx4rlqv (1).png', // تأكد من إضافة الصورة في مجلد الـ assets وتفعيلها في pubspec.yaml
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  "بسيطة",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 2, 48, 113),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "محترفين في خدمتك",
                  style: TextStyle(
                    fontSize: 16,
                    color: textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                // ==========================================
                // 2. عنوان قسم الاختيار
                // ==========================================
                const Text(
                  "اختر نوع حسابك",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "ابدأ رحلتك معنا باختيار الصفة المناسبة لك",
                  style: TextStyle(fontSize: 14, color: textGrey),
                ),
                const SizedBox(height: 32),

                // ==========================================
                // 3. كروت اختيار نوع الحساب
                // ==========================================

                // كارت (أنا عميل)
                _buildSelectionCard(
                  type: AccountType.customer,
                  title: "أنا عميل",
                  description:
                      "أبحث عن فنيين محترفين لإنجاز مهامي المنزلية بجودة عالية.",
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                // كارت (أنا فني)
                _buildSelectionCard(
                  type: AccountType.technician,
                  title: "أنا فني",
                  description:
                      "أرغب في عرض مهاراتي والوصول لعملاء جدد وزيادة دخلي.",
                  icon: Icons.build_outlined,
                ),

                const Spacer(),

                // ==========================================
                // 4. الفوتر (زر استمرار التفاعلي)
                // ==========================================
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedType == AccountType.none
                        ? null // الزر يكون معطلاً وغير قابل للضغط حتى يتم الاختيار
                        : () {
                            // عند الضغط على استمرار، يتم التحقق من الاختيار والانتقال فوراً
                            if (_selectedType == AccountType.customer) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BaseetaSignUpApp(),
                                ),
                              );
                            } else if (_selectedType ==
                                AccountType.technician) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TechnicianOnboardingScreen(),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == AccountType.none
                          ? disabledButtonColor
                          : primaryBlue,
                      disabledBackgroundColor: disabledButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "استمرار",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _selectedType == AccountType.none
                            ? Colors.grey.shade500
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // نص تسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "لديك حساب بالفعل؟ ",
                      style: TextStyle(color: textGrey, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                        // هنا يمكنك وضع كود الانتقال لصفحة تسجيل الدخول عند الحاجة
                      },
                      child: const Text(
                        "تسجيل الدخول",
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // دالة بناء كارت الاختيار
  // ==========================================
  Widget _buildSelectionCard({
    required AccountType type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    bool isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type; // تحديث النوع المختار وتنشيط زر استمرار
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryBlue : cardBorderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // أيقونة الراديو الخارجية
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryBlue : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // النصوص (العنوان والوصف)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // مربع الأيقونة اليساري الفاتح
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: textDark, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// صفحات مؤقتة (Placeholders) للانتقال إليها عند الضغط على زر استمرار
// قم باستبدالها لاحقاً بملفات صفحاتك الحقيقية
// =========================================================================

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("حساب العميل"),
          backgroundColor: const Color(0xFF0056D2),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "مرحباً بك في لوحة تحكم العميل الخاصة بـ بسيطة 👋",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class TechnicianScreen extends StatelessWidget {
  const TechnicianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("حساب الفني"),
          backgroundColor: const Color(0xFF0056D2),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "مرحباً بك في لوحة تحكم الفني الخاصة بـ بسيطة 🛠️",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
