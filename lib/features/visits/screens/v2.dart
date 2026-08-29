import 'package:flutter/material.dart';

class BasseytaApp12 extends StatelessWidget {
  const BasseytaApp12({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            _buildTechnicianProfile(),
            const SizedBox(height: 16),
            _buildServiceDetails(),
            const SizedBox(height: 16),
            _buildFinancialSummary(),
            const SizedBox(height: 16),
            _buildVisitTracking(),
            const SizedBox(height: 16),
            _buildWarrantySection(),
            const SizedBox(height: 16),
            _buildInvoiceSection(),
            const SizedBox(height: 16),
            _buildPrivateNotesSection(),
            const SizedBox(height: 16),
            _buildInteractionStatsSection(),
            const SizedBox(height: 24),
            _buildReportIssueButton(), // تم إضافة الزر المفقود هنا
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 1. شريط التنقل العلوي (AppBar)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9F9),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2), size: 28),
        onPressed: () {
          Navigator.pop(context); // العودة للصفحة السابقة مباشرة
        },
      ),
      title: const Text(
        "الملف الشخصي",
        style: TextStyle(
          color: Color(0xFF0056D2),
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.share_outlined,
            color: Color(0xFF0056D2),
            size: 24,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: Color(0xFF0056D2),
            size: 26,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // 2. كارت بيانات الفني والأزرار (تم التعديل بالكامل لمطابقة الصورة)
  Widget _buildTechnicianProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // رأس الكارت (الصورة، الاسم، التقييم، رقم الطلب)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الفني والتقييم (تم نقلها لليمين لمطابقة التصميم)
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/Image (33).png', // تأكد من مسار الصورة
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "4.8",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.star, size: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // معلومات الفني
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            "م. ابراهيم حسن",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EFFF), // أزرق فاتح جداً
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "طلب #SH-8821",
                            style: TextStyle(
                              color: Color(0xFF0056D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "فني نجارة معتمد ",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // مستطيل الإحصائيات (الخبرة وإجمالي الخدمات)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: const [
                      Text(
                        "الخبرة",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "15 سنوات",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: Column(
                    children: const [
                      Text(
                        "إجمالي الخدمات",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "875 خدمة",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // أزرار الإجراءات الجديدة (تحديث، رسائل، اتصال، تقييم)
          Row(
            children: [
              Expanded(child: _buildActionBtn(Icons.sync, isFilled: true)),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionBtn(Icons.mail_outline, isFilled: false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionBtn(Icons.phone_outlined, isFilled: false),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildActionBtn(Icons.star, isFilled: false)),
            ],
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء الأزرار الأربعة
  Widget _buildActionBtn(IconData icon, {required bool isFilled}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isFilled ? const Color(0xFF0056D2) : Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: const Color(0xFF0056D2), width: 1.5),
          ),
        ),
        child: Icon(
          icon,
          color: isFilled ? Colors.white : const Color(0xFF0056D2),
          size: 24,
        ),
      ),
    );
  }

  // 3. تفاصيل الخدمة
  Widget _buildServiceDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0056D2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "تفاصيل الخدمة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "وصف المشكلة",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text(
            "ترهل ملحوظ في مفصلات باب خزانة المطبخ، مما يؤدي إلى صعوبة في الإغلاق واحتكاك الباب بالإطار، مع وجود تشققات بسيطة في الخشب نتيجة الرطوبة",
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),

          // الحل المنفذ
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF0056D2).withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "الحل المنفذ",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0056D2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "تم استبدال المفصلات التالفة بأخرى جديدة عالية التحمل، وإعادة ضبط محاذاة باب الخزانة لضمان سهولة الفتح والإغلاق، مع معالجة التشققات باستخدام معجون خشب مقاوم للرطوبة وإعادة تشطيب السطح لحمايته من التلف مستقبلاً",
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // صور قبل وبعد
          Row(
            children: [
              Expanded(
                child: _buildBeforeAfterImage(
                  'قبل الإصلاح',
                  'assets/image (32).png',
                  isBefore: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBeforeAfterImage(
                  'بعد الإصلاح',
                  'assets/image (34).png',
                  isBefore: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterImage(
    String label,
    String url, {
    required bool isBefore,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            url,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isBefore ? Colors.black54 : const Color(0xFF0056D2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 4. الملخص المالي والوقت
  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "الملخص المالي والوقت",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  "وقت التنفيذ",
                  "1.5 ساعة",
                  isHighlighted: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBox("تكلفة العمالة", "350 ج.م")),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  "الإجمالي",
                  "770 ج.م",
                  isHighlighted: true,
                  highlightColor: const Color(0xFFD6E4FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBox("تكلفة المواد", "420 ج.م")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String title,
    String value, {
    bool isHighlighted = false,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? (highlightColor ?? const Color(0xFFF0F5FF))
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isHighlighted
                  ? const Color(0xFF0056D2)
                  : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF0056D2) : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 5. تتبع الزيارة
  Widget _buildVisitTracking() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "تتبع الزيارة",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTimelineStep(
            "09:15 ص",
            "تم قبول الطلب",
            "تم تعيين م. أحمد للمهمة",
            isCompleted: true,
          ),
          _buildTimelineStep(
            "10:05 ص",
            "وصول الفني",
            "تم البدء في المعاينة والإصلاح",
            isCompleted: true,
          ),
          _buildTimelineStep(
            "11:40 ص",
            "اكتمال المهمة",
            "تم الدفع وإغلاق البلاغ",
            isCompleted: true,
          ),
          _buildTimelineStep(
            "12:00 م",
            "تم التقييم",
            "شكراً لمشاركتنا تجربتكم",
            isCompleted: true,
            isLast: true,
            color: const Color(0xFFFFC107),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String time,
    String title,
    String desc, {
    bool isLast = false,
    bool isCompleted = false,
    Color color = const Color(0xFF0056D2),
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 55,
            child: Text(
              time,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: color, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. قسم الضمان
  Widget _buildWarrantySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_user_outlined, color: Color(0xFF0056D2)),
              SizedBox(width: 8),
              Text(
                "الضمان",
                style: TextStyle(
                  color: Color(0xFF0056D2),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow("الحالة", "ساري", hasGreenDot: true),
          const SizedBox(height: 12),
          _buildInfoRow("المدة", "6 أشهر"),
          const SizedBox(height: 12),
          _buildInfoRow("تاريخ الانتهاء", "15 سبتمبر 2024"),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF0056D2)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "فتح مطالبة ضمان",
                style: TextStyle(
                  color: Color(0xFF0056D2),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 7. الفاتورة الإلكترونية
  Widget _buildInvoiceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.receipt_long_outlined, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                "الفاتورة الإلكترونية",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "فاتورة رقم #INV-9901 جاهزة للتحميل.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.black87,
                    size: 18,
                  ),
                  label: const Text(
                    "مشاركة",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.download_outlined,
                    color: Colors.black87,
                    size: 18,
                  ),
                  label: const Text(
                    "PDF",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 8. ملاحظاتي الخاصة
  Widget _buildPrivateNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // أصفر خفيف جداً
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.speaker_notes_outlined, color: Color(0xFF967B00)),
              SizedBox(width: 8),
              Text(
                "ملاحظاتي الخاصة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF967B00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '"مواعيده ممتازة جداً وملتزم بنظافة المكان بعد الانتهاء من العمل. ينصح به بشدة في الأعمال المعقدة."',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 16, color: Color(0xFF0056D2)),
              label: const Text(
                "تعديل الملاحظات",
                style: TextStyle(
                  color: Color(0xFF0056D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 9. إحصائيات التعامل
  Widget _buildInteractionStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "إحصائيات التعامل",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow("مرات الزيارة", "3 زيارات"),
          const SizedBox(height: 12),
          _buildInfoRow("إجمالي المدفوع", "2,450 ج.م"),
          const SizedBox(height: 12),
          _buildInfoRow("آخر زيارة", "منذ شهر"),
        ],
      ),
    );
  }

  // مكون مساعد لصفوف النصوص (تم إصلاح الجزء الناقص فيه)
  Widget _buildInfoRow(String title, String value, {bool hasGreenDot = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (hasGreenDot)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "ساري",
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
      ],
    );
  }

  // زر الإبلاغ عن مشكلة
  Widget _buildReportIssueButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.info_outline, color: Colors.red),
        label: const Text(
          "إبلاغ عن مشكلة في هذه الزيارة",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.red.shade300, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
