import 'package:flutter/material.dart';
import 'package:basita1/features/orders/screens/task_details_page.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  // الألوان الأساسية
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color aiBgColor = Color(0xFFEFF6FF);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        // ==========================================
        // 1. شريط التنقل العلوي (AppBar)
        // ==========================================
        appBar: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.share_outlined, color: textDark),
            onPressed: () {
              // 💡 كود الانتقال أو إجراء المشاركة
              /*
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ShareScreen()));
              */
            },
          ),
          title: const Text(
            "تفاصيل الطلب",
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: primaryBlue),
              onPressed: () {
                // 💡 الرجوع للصفحة السابقة
                Navigator.pop(context);
              },
            ),
          ],
        ),

        // ==========================================
        // 2. محتوى الصفحة (Body)
        // ==========================================
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // كارت معلومات العميل
              _buildCustomerInfo(context),
              const SizedBox(height: 24),

              // وصف المشكلة والصور
              const Text(
                "وصف المشكلة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "هناك تسريب مياه من صنبور المطبخ، المياه تتدفق بشكل مستمر ولا يمكن إغلاق المحبس الرئيسي للوحدة.",
                style: TextStyle(fontSize: 14, color: textGrey, height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildProblemImages(context),
              const SizedBox(height: 24),

              // كروت تفاصيل الخدمة (الموعد، الخدمة، السعر...)
              _buildDetailsGrid(context),
              const SizedBox(height: 24),

              // كارت توصية الذكاء الاصطناعي
              _buildAICard(context),
              const SizedBox(height: 24),

              // إحصائيات العروض
              _buildOffersStatsCard(context),
              const SizedBox(height: 24),

              // الخريطة والموقع
              _buildMapSection(context),
              const SizedBox(height: 32), // مساحة إضافية قبل الشريط السفلي
            ],
          ),
        ),

        // ==========================================
        // 3. الشريط السفلي اللاصق (Bottom Sticky Action Bar)
        // ==========================================
        bottomNavigationBar: _buildStickyBottomBar(context),
      ),
    );
  }

  // ---------------------------------------------------------
  // دوال بناء العناصر (Widgets)
  // ---------------------------------------------------------

  Widget _buildCustomerInfo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 💡 كود الانتقال لصفحة بروفايل العميل
        /*
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerProfileScreen()));
        */
      },
      child: Row(
        children: [
          // زر المحادثة
          Container(
            decoration: const BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                // 💡 كود الانتقال لصفحة الشات مع هذا العميل
                /*
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatWithCustomerScreen()));
                */
              },
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.star, color: Colors.orange, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "4.8",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    " سارة المنصوري ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "12 طلب مكتمل • عضو منذ يناير 2023",
                style: TextStyle(fontSize: 12, color: textGrey),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // صورة العميل
          Stack(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/Background+Shadow (6).png'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: primaryBlue,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProblemImages(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildImageTile(
            context,
            'assets/AB6AXuBW40HZcr1R5jf0SBGBwRnzfznr9w4Bqe3N-m7i3MmmlxOuH-gNDiL4ppnJjJdtt8HLYoxdhPRBNn5i3wLxoegcVBgMpWK1-FUBDvmXfndd21I_jnhlzAp4M-1sxuhdsWAgL05IZx-TSluxiaH9H3UxpZYKnu3_a90M2eujBvRANMtN7acddKuZRLuYyzh1xraof4dXxr9En.png',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildImageTile(
            context,
            'assets/AB6AXuDtuVGpF74KBWPuqUjI2SIJut52_xgujlmATNTwvT0y8jOAhTJ7b6DGQPiNusd0bbBFivCHfcQoLfsaBK9o1hkXkAn7uiwdZZCudZ-iSjEQDO1EE7aJh72YaDwd8QgJ2UzimqqqvZ2BWuVB7WDzClcO7XHbm3qB-RXLt--tHs7Rmf5OlbFdhB7_ZJoIHkF142PzmrcmcesXU.png',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildImageTile(
            context,
            'assets/AB6AXuCIDiZ4cDWhjFv5ofOf4Fm6utd1FRhNGT93QrCGFtZMAd5hEOIwpj3KC0n-lu8E50CwIupy5HTBB3NRXrnjptKzGpKHk7nBfQ_ERjHiBXYeD9zvongVh7F1QGuJhdOr76nUnCpPcB4o8et3qdGXoE-W3TX5S9J5yqhOa87GM-F_fRltBD9upu0RHhtIP8HkY6B4BVW_Nkzco.png',
          ),
        ),
      ],
    );
  }

  Widget _buildImageTile(BuildContext context, String imagePath) {
    return GestureDetector(
      onTap: () {
        // 💡 كود الانتقال لصفحة عرض الصورة مكبرة
        /*
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FullScreenImage()));
        */
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 80,
          color: Colors.grey.shade300,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.image, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridCard(
                context,
                "الخدمة المطلوبة",
                "سباكة",
                Icons.plumbing,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGridCard(
                context,
                "الموعد المطلوب",
                "اليوم - 4:00 م",
                Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGridCard(
                context,
                "الميزانية المتوقعة",
                "300 ج.م",
                Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGridCard(
                context,
                "السعر المقترح",
                "250 - 350 ج.م",
                Icons.insert_chart_outlined,
                isBlueText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    bool isBlueText = false,
  }) {
    return GestureDetector(
      onTap: () {
        // 💡 كود الانتقال لصفحة تفاصيل البطاقة إن وجدت
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: textGrey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isBlueText ? primaryBlue : textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAICard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: aiBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.auto_awesome, color: primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                "توصية الذكاء الاصطناعي",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "بناءً على وصف المشكلة والصور، يُتوقع أن تستغرق عملية الإصلاح حوالي ساعة، ويُنصح بعرض سعر بين 280 و320 جنيه.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: textDark, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 💡 كود الانتقال لصفحة إنشاء العرض بالذكاء الاصطناعي
                /*
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AIOfferScreen()));
                */
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text(
                "إنشاء عرض بالذكاء الاصطناعي",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersStatsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          const Text(
            "إحصائيات العروض المقدمة",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textGrey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatBar(
                "الأعلى",
                "400",
                100,
                Colors.grey.shade200,
                textDark,
              ),
              _buildStatBar(
                "المتوسط",
                "310",
                70,
                const Color(0xFF93C5FD),
                primaryBlue,
                isBold: true,
              ),
              _buildStatBar("الأقل", "250", 40, Colors.grey.shade200, textDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(
    String label,
    String value,
    double height,
    Color bgColor,
    Color textColor, {
    bool isBold = false,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: textGrey)),
      ],
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/Image+Background.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey.shade300),
                ),
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ), // تعتيم الخريطة قليلاً
                const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "المعادي، القاهرة",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // 💡 كود فتح تطبيق الخرائط
              },
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text("فتح في الخرائط"),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Row(
              children: const [
                Icon(Icons.access_time, size: 16, color: primaryBlue),
                SizedBox(width: 4),
                Text(
                  "20 دقيقة",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.location_on_outlined, size: 16, color: textDark),
                SizedBox(width: 4),
                Text(
                  "3.5 كم",
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // بناء الشريط السفلي اللاصق
  // =========================================================
  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // زر الرفض X
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {
                  // 💡 كود رفض الطلب أو الرجوع
                  /*
                  Navigator.pop(context); // أو الانتقال لصفحة أسباب الرفض
                  */
                },
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
            const SizedBox(width: 8),

            // زر قبول مبدئي
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // 💡 كود الموافقة بالسعر المبدئي

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskDetailsPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E7FF), // أزرق فاتح جداً
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "قبول (300 ج.م)",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // زر تقديم عرض (يفتح الـ Bottom Sheet)
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // 🔥 فتح المودال عند الضغط
                  _showOfferBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "تقديم عرض",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // دالة ظهور النافذة المنبثقة (Modal Bottom Sheet)
  // =========================================================
  void _showOfferBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // مهم عشان المودال يكبر مع الكيبورد
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                context,
              ).viewInsets.bottom, // رفع النافذة عند فتح لوحة المفاتيح
              left: 24,
              right: 24,
              top: 16,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // شريط السحب العلوي (Drag Handle)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الهيدر (العنوان + زر X للإغلاق)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "تقديم عرض سعر",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // 🔥 إغلاق النافذة والعودة للصفحة
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(backgroundColor: bgLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // الحقول (Forms)
                  _buildLabel("قيمة العرض (ج.م)"),
                  _buildTextField(
                    hint: "مثال: 320",
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("مدة العمل"),
                            _buildTextField(hint: "ساعة واحدة"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("وقت الوصول"),
                            _buildTextField(hint: "خلال 30 دقيقة"),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildLabel("الضمان (أيام)"),
                  _buildTextField(
                    hint: "مثال: 30 يوم",
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),
                  _buildLabel("رسالة للعميل (اختياري)"),
                  _buildTextField(
                    hint: "أهلاً بك، سأقوم بإحضار الأدوات اللازمة...",
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // الخيارات (Checkboxes)
                  _buildCheckboxOption("أستطيع توفير الخامات اللازمة", false),
                  const SizedBox(height: 12),
                  _buildCheckboxOption(
                    "السعر يشمل تكلفة الخامات",
                    true,
                  ), // محدد افتراضياً في الصورة

                  const SizedBox(height: 24),

                  // زر الإرسال
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 💡 كود حفظ البيانات وإرسال العرض للعميل
                        /*
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
                        */
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "إرسال العرض",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // مسافة سفلية للأمان
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // دوال مساعدة لنموذج الـ Bottom Sheet
  // ---------------------------------------------------------

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textGrey, fontSize: 14),
        filled: true,
        fillColor: bgLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(String title, bool isChecked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: textDark)),
          Icon(
            isChecked ? Icons.check_box : Icons.check_box_outline_blank,
            color: isChecked ? primaryBlue : textGrey,
          ),
        ],
      ),
    );
  }
}
