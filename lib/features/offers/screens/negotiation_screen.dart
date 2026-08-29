import 'package:flutter/material.dart';

class NegotiationScreen extends StatefulWidget {
  const NegotiationScreen({super.key});

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  // تعريف الألوان الأساسية المتطابقة مع التصميم
  static const Color brandBlue = Color(0xFF0075FF);
  static const Color accentGreen = Color(
    0xFF4BF37B,
  ); // الأخضر الفوسفوري للأزرار
  static const Color badgeGreen = Color(0xFF2ECC71); // أخضر حالة الطلب النشط
  static const Color rejectRedBg = Color(0xFFFCE4E4); // خلفية زر الرفض
  static const Color rejectRedText = Color(0xFFD32F2F); // نص زر الرفض
  static const Color bgLightGrey = Color(
    0xFFF6F8FB,
  ); // لون خلفية الصفحة الأساسي
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  // متغير حالة العرض: 'pending', 'accepted', 'rejected'
  String offerStatus = "pending";

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // يدعم الواجهة العربية بالكامل
      child: Scaffold(
        backgroundColor: bgLightGrey,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // منطقة التفاوض القابلة للتمرير
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 1. كارت تفاصيل الطلب النشط
                    _buildActiveJobCard(),
                    const SizedBox(height: 16),

                    // 2. فقاعة دردشة العميل (خالد)
                    _buildChatBubble(
                      message:
                          "أهلاً بك يافندم، عرضي هو 400 جنيه للتركيب، هل هذا مناسب؟",
                      time: "10:30 ص",
                      isMe: false,
                    ),

                    // 3. فقاعة دردشة الفني (أحمد)
                    _buildChatBubble(
                      message:
                          "أهلاً يا ريس السعر العادل للخدمة مع الضمان هو 600 جنيه.",
                      time: "10:32 ص",
                      isMe: true,
                    ),

                    const SizedBox(height: 12),

                    // 4. حالة انتظار رد العميل
                    if (offerStatus == "pending") _buildWaitingStatusChip(),

                    const SizedBox(height: 16),

                    // 5. كارت عرض السعر الجديد من العميل (القرارات التفاعلية)
                    _buildProposalCard(),
                  ],
                ),
              ),
            ),

            // 6. لوحة التحكم الثابتة بالأسفل (The Action Center)
            _buildActionCenter(),
          ],
        ),
      ),
    );
  }

  // ==================== 1. شريط العنوان العلوي (AppBar) ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // سهم الرجوع المخصص (يعمل الآن بنجاح)
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // العودة للخلف
            },
            child: const Icon(Icons.arrow_back, color: textDark, size: 26),
          ),
          const SizedBox(width: 12),
          // الصورة الشخصية للفني مع الإطار الأزرق
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: brandBlue, width: 2),
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/Container (8).png'),
            ),
          ),
          const SizedBox(width: 12),
          // تفاصيل الفني
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "أحمد محمد",
                  style: TextStyle(
                    color: brandBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "فني صيانة معتمد",
                  style: TextStyle(color: textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: brandBlue, size: 26),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("جاري الاتصال بالفني أحمد محمد...")),
            );
          },
        ),
      ],
    );
  }

  // ==================== 2. كارت تفاصيل الطلب النشط ====================
  Widget _buildActiveJobCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FA), // خلفية زرقاء فاتحة
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "رقم الطلب: #5829",
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
              // شارة الطلب النشط
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "طلب نشط",
                  style: TextStyle(
                    color: badgeGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "تركيب مكيف سبليت 1.5 حصان",
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.location_on_outlined, size: 16, color: textMuted),
              SizedBox(width: 4),
              Text(
                "التجمع الخامس، القاهرة",
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== 3. فقاعات الدردشة ====================
  Widget _buildChatBubble({
    required String message,
    required String time,
    required bool isMe,
  }) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isMe ? brandBlue : const Color(0xFFE8ECF4),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : textDark,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            time,
            style: const TextStyle(color: textMuted, fontSize: 10),
          ),
        ),
      ],
    );
  }

  // ==================== 4. شارة جاري الانتظار ====================
  Widget _buildWaitingStatusChip() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "جاري انتظار رد العميل...",
          style: TextStyle(
            color: textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ==================== 5. كارت عرض سعر جديد (القرارات) ====================
  Widget _buildProposalCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E4F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "عرض سعر جديد من العميل",
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: brandBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: brandBlue,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "لقد قام العميل بتحديث عرضه النهائي لإتمام العملية الآن.",
                style: TextStyle(color: textMuted, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "السعر المقترح",
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offerStatus == "accepted"
                          ? "تم قبول 500 ج.م"
                          : offerStatus == "rejected"
                          ? "تم رفض 500 ج.م"
                          : "500 ج.م",
                      style: const TextStyle(
                        color: brandBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // الأزرار التفاعلية (قبول / رفض)
              if (offerStatus == "pending")
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            offerStatus = "accepted";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          "قبول",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            offerStatus = "rejected";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rejectRedBg,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: rejectRedText,
                          size: 20,
                        ),
                        label: const Text(
                          "رفض",
                          style: TextStyle(
                            color: rejectRedText,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Center(
                  child: Text(
                    offerStatus == "accepted"
                        ? "🎉 تم قبول العرض بنجاح!"
                        : "❌ تم رفض العرض بنجاح.",
                    style: TextStyle(
                      color: offerStatus == "accepted"
                          ? badgeGreen
                          : rejectRedText,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6.0, right: 8.0),
          child: Text(
            "منذ دقيقتين",
            style: TextStyle(color: textMuted, fontSize: 11),
          ),
        ),
      ],
    );
  }

  // ==================== 6. لوحة التحكم السفلية (Action Center) ====================
  Widget _buildActionCenter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // زر إرفاق الصور
                Container(
                  height: 52,
                  width: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FA),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.image_outlined, color: textDark),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "جاري فتح الاستوديو لإرفاق صور المعاينة...",
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // زر عرض السعر الجديد
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: accentGreen,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: accentGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          // إعادة تعيين الحالة للتجربة
                          offerStatus = "pending";
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تم تقديم عرض السعر بنجاح للعميل!"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF0D5E24),
                        size: 22,
                      ),
                      label: const Text(
                        "عرض سعر جديد",
                        style: TextStyle(
                          color: Color(0xFF0D5E24),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // السطر السفلي: رقاقات الخيارات السريعة
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickPriceChip("525 ج.م"),
                  _buildQuickPriceChip("550 ج.م"),
                  _buildQuickPriceChip("575 ج.م"),
                  _buildQuickPriceChip("تم السعر", isCustom: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 7. أزرار الأسعار السريعة ====================
  Widget _buildQuickPriceChip(String text, {bool isCustom = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ActionChip(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("تم اختيار: $text")));
        },
        backgroundColor: const Color(0xFFEEF2FA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD6E4F0), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        label: Text(
          text,
          style: TextStyle(
            color: isCustom ? brandBlue : textDark,
            fontSize: 13,
            fontWeight: isCustom ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
