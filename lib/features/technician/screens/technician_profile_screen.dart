import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TechnicianProfileScreen extends StatelessWidget {
  const TechnicianProfileScreen({super.key});

  // ==========================================
  // الألوان المستخدمة في التصميم لسهولة التعديل
  // ==========================================
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color lightBlueHeader = const Color(0xFFD3E3FD);
  final Color bgColor = const Color(0xFFF4F7FB);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);
  final Color starGold = const Color(0xFFFABB05);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضبط الاتجاه من اليمين لليسار
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward, color: primaryBlue, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share_outlined, color: primaryBlue, size: 26),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 40,
            top: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildAboutCard(),
              const SizedBox(height: 20),
              _buildGallerySection(),
              const SizedBox(height: 20),
              _buildReviewsCard(),
            ],
          ),
        ),
        // ==========================================
        // زر "احجز الآن" الثابت في أسفل الشاشة
        // ==========================================
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: قم بإزالة التعليق واستبدل BookingScreen بصفحة الحجز الخاصة بك
                  /*
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookingScreen()),
                  );
                  */
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "احجز الآن",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. كارت الملف الشخصي (العلوي)
  // ==========================================
  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // الهيدر الأزرق الفاتح مع الصورة
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: lightBlueHeader,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
              Positioned(
                bottom: -45,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(
                          'assets/Image (33).png',
                        ), // مسار صورتك
                      ),
                    ),
                    // علامة التوثيق
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFB58D2D), // لون ذهبي غامق
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 55), // مساحة بعد الصورة المرفوعة
          // الاسم والتقييم
          Text(
            "ابراهيم حسن",
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "(128 تقييم)",
                style: GoogleFonts.cairo(color: textGrey, fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                "4.9",
                style: GoogleFonts.cairo(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.star, color: starGold, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          // شريطة التخصص (سباكة)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "سباكة",
                  style: GoogleFonts.cairo(
                    color: textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.plumbing,
                  size: 16,
                  color: textGrey,
                ), // يمكنك استخدام أيقونة مفتاح أو أداة
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            color: Colors.grey.shade200,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 16),
          // إحصائيات الفني
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("15د", "سرعة الاستجابة"),
                _buildVerticalDivider(),
                _buildStatItem("+12", "سنوات خبرة"),
                _buildVerticalDivider(),
                _buildStatItem("248", "مهمة منجزة"),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ==========================================
  // 2. كارت "عن الفني"
  // ==========================================
  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                "عن الفني",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "متخصص في كافة أعمال السباكة المنزلية بخبرة تزيد عن 15 عاماً. ألتزم بتقديم أعلى مستويات الجودة والدقة في العمل، مع ضمان السرعة في التنفيذ والالتزام بالمواعيد. هدفي هو تقديم حلول عملية ومستدامة تلبي احتياجات العملاء بأفضل الأسعار.",
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: textGrey,
              height: 1.6, // تباعد الأسطر لسهولة القراءة
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. قسم "معرض الأعمال"
  // ==========================================
  Widget _buildGallerySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "معرض الأعمال",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "عرض الكل",
                style: GoogleFonts.cairo(
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140, // ارتفاع الصور
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _buildGalleryImage(
                'assets/Overlay+Shadow (5).png',
              ), // استبدلها بمسار صورتك
              const SizedBox(width: 12),
              _buildGalleryImage('assets/Overlay+Shadow (5).png'),
              // تقدر تزود صور هنا
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4. كارت "التقييمات"
  // ==========================================
  Widget _buildReviewsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.reviews_outlined, color: primaryBlue, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "التقييمات",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: starGold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "4.9",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildReviewItem(
            name: "محمد علي",
            time: "منذ يومين",
            rating: 5,
            review:
                "شغل ممتاز ودقيق جداً. أنصح بالتعامل معه بشدة، التزام بالمواعيد وأمانة في العمل.",
            avatarLetter: "م",
            avatarColor: const Color(0xFFD3E3FD),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),
          _buildReviewItem(
            name: "سارة أحمد",
            time: "منذ أسبوع",
            rating: 4,
            review:
                "سريع في الاستجابة وحل المشكلة بمهارة عالية. السعر كان معقولاً جداً مقابل الجودة.",
            avatarLetter: "س",
            avatarColor: const Color(0xFFE0E7FF),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                "عرض جميع التقييمات",
                style: GoogleFonts.cairo(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // دوال مساعدة (Helper Widgets)
  // ==========================================

  // بناء إحصائية واحدة (مثلاً: 248 مهمة منجزة)
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: textGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // الخط الفاصل بين الإحصائيات
  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }

  // بناء صورة للمعرض
  Widget _buildGalleryImage(String assetPath) {
    return Container(
      width: 220, // عرض الصورة في المعرض
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.cover, // عشان الصورة تملا المساحة بشكل متناسق
        ),
      ),
    );
  }

  // بناء تعليق مستخدم
  Widget _buildReviewItem({
    required String name,
    required String time,
    required int rating,
    required String review,
    required String avatarLetter,
    required Color avatarColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: avatarColor,
                  radius: 20,
                  child: Text(
                    avatarLetter,
                    style: GoogleFonts.cairo(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.cairo(color: textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: starGold,
                  size: 16,
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          review,
          style: GoogleFonts.cairo(color: textDark, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}
