import 'package:flutter/material.dart';

class ModernDesignPage extends StatefulWidget {
  const ModernDesignPage({super.key});

  @override
  State<ModernDesignPage> createState() => _ModernDesignPageState();
}

class _ModernDesignPageState extends State<ModernDesignPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // الهيدر المتداخل والمحمي بالكامل من مشاكل القص
              SliverToBoxAdapter(child: _buildOverlappingHeader(context)),

              // تبويبات التنقل (Tabs)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF0056D2),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF0056D2),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                      tabs: const [
                        Tab(text: "معرض الأعمال"),
                        Tab(text: "عن الشركة"),
                        Tab(text: "الفروع"),
                        Tab(text: "التقييمات"),
                      ],
                    ),
                  ),
                ),
              ),

              // محتوى التبويب النشط وقائمة الباقات
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // قسم المشاريع المنفذة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "المشاريع المنفذة",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "عرض الكل",
                              style: TextStyle(
                                color: Color(0xFF0056D2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // عنوان باقات التشطيب
                      const Text(
                        "باقات التشطيب",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // قائمة كروت الباقات بتصميمها الجديد والمطابق تماماً
                      _buildPackageCard(
                        title: "الباقة الاقتصادية",
                        description:
                            "تشطيب عملي بجودة عالية وميزانية مدروسة للمساحات السكنية.",
                        price: "4,500",
                        icon: Icons.architecture_outlined,
                        isFeatured: false,
                      ),
                      const SizedBox(height: 16),
                      _buildPackageCard(
                        title: "الباقة الفاخرة",
                        description:
                            "تصاميم حصرية مع استخدام أجود أنواع الرخام والأخشاب المستوردة.",
                        price: "8,500",
                        icon: Icons.diamond_outlined,
                        isFeatured:
                            true, // تفعيل شريط "الأكثر طلباً" والزر المملوء
                      ),
                      const SizedBox(height: 16),
                      _buildPackageCard(
                        title: "الباقة التجارية",
                        description:
                            "حلول متكاملة للمكاتب والشركات والمحلات التجارية الكبرى.",
                        price: "6,200",
                        icon: Icons.business_outlined,
                        isFeatured: false,
                      ),

                      const SizedBox(
                        height: 110,
                      ), // مساحة أمان إضافية لعدم التداخل مع شريط الاتصال بالأسفل
                    ],
                  ),
                ),
              ),
            ],
          ),

          // شريط الاتصال الثابت في الأسفل (Sticky Footer)
          _buildStickyFooter(),
        ],
      ),
    );
  }

  // دالة بناء الهيدر المتداخل والمحمي تماماً من القص والتداخل
  Widget _buildOverlappingHeader(BuildContext context) {
    const double imageHeight = 260.0;
    const double cardHeight = 190.0;
    const double overlapOffset = 90.0; // مقدار التداخل بين الكارت والصورة

    return SizedBox(
      height:
          imageHeight +
          cardHeight -
          overlapOffset, // تحديد مساحة كافية ومحجوزة بدقة
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. الصورة الخلفية للأثاث
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imageHeight,
            child: Image.asset('assets/Hero Section.png', fit: BoxFit.cover),
          ),

          // 2. أزرار التحكم الطافية في الأعلى (رجوع، مشاركة، إعجاب)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر الرجوع للخلف
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // العودة للصفحة السابقة مباشرة
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                // أزرار المشاركة والإعجاب
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. كارت تفاصيل الشركة الطافي والمتداخل (تنسيق Stack يمنع حدوث أي قص)
          Positioned(
            top: imageHeight - overlapOffset,
            left: 16,
            right: 16,
            height: cardHeight,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // النصوص والتقييم
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "مودرن ديزاين",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "تصميم المعماري تشطيبات",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text(
                                  "منذ 2010",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "4.9 (120 تقييم)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // اللوجو الدائري/المربع مع علامة التوثيق الصفراء
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset(
                                  'assets/Background+Border+Shadow.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          // شارة التوثيق الذهبية/البيضاء
                          Positioned(
                            bottom: -2,
                            left: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFC107),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // زر طلب المقايسة داخل الكارت
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        "اطلب مقايسة",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // كارد الباقة (Reusable Widget)
  Widget _buildPackageCard({
    required String title,
    required String description,
    required String price,
    required IconData icon,
    required bool isFeatured,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFeatured
                  ? const Color(0xFF0056D2)
                  : Colors.grey.shade200,
              width: isFeatured ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isFeatured
                          ? const Color(0xFFE8F1FF)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: const Color(0xFF0056D2), size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0056D2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "ج.م / متر",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // الأزرار المخصصة لكل باقة (ممتلئ أو شفاف حسب الحالة)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: isFeatured
                    ? ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056D2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "تفاصيل الباقة",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0056D2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "تفاصيل الباقة",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0056D2),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),

        // شارة "الأكثر طلباً" للباقة المميزة
        if (isFeatured)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFF0056D2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
              child: const Text(
                'الأكثر طلباً',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // شريط الاتصال والتواصل الثابت بالأسفل
  Widget _buildStickyFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
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
        child: Row(
          children: [
            // زر الاتصال الهاتفي الدائري
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0056D2), width: 1.5),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.phone_outlined,
                  color: Color(0xFF0056D2),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // زر تواصل الآن الأزرق العريض
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    "تواصل الآن",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
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
