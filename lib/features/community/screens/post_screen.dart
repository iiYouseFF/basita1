import 'package:flutter/material.dart';
import 'dart:ui';

// =========================================================
// شاشة إنشاء منشور (Create Post Screen)
// =========================================================
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  // المتحكمات في النصوص
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _tagSearchController = TextEditingController();

  // حالة زر النشر
  bool _isPublishEnabled = false;

  // قائمة الوسوم المتاحة والمحددة
  final List<String> _availableTags = ['#سباكة', '#نصيحة', '#كهرباء'];
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    // مراقبة التغييرات لتفعيل/تعطيل زر النشر
    _titleController.addListener(_checkPublishState);
    _bodyController.addListener(_checkPublishState);
  }

  void _checkPublishState() {
    setState(() {
      _isPublishEnabled =
          _titleController.text.trim().isNotEmpty ||
          _bodyController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagSearchController.dispose();
    super.dispose();
  }

  void _publishPost() {
    if (!_isPublishEnabled) return;

    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    // إظهار رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نشر المنشور بنجاح!', textAlign: TextAlign.right),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );

    // العودة للشاشة السابقة بعد النشر (اختياري، يمكنك تفعيله)
    // Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم كامل للغة العربية
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 1. الهيدر العُلوي (Top Navigation Bar)
              _buildHeader(),

              // 2. المحتوى القابل للتمرير
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات المستخدم
                      _buildUserInfo(),
                      const SizedBox(height: 24),

                      // حقل عنوان المنشور
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                        decoration: const InputDecoration(
                          hintText: "عنوان المنشور",
                          hintStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCBD5E1),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // حقل كتابة المحتوى
                      TextField(
                        controller: _bodyController,
                        maxLines: null,
                        minLines: 3,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A5568),
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: "اكتب منشورك أو سؤالك هنا...",
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFA0AEC0),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // مربعات رفع الوسائط (فيديو وصورة)
                      Row(
                        children: [
                          Expanded(
                            child: _buildMediaPlaceholder(
                              Icons.videocam_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMediaPlaceholder(Icons.image_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // قسم الوسوم (Tags)
                      _buildTagsSection(),

                      // مساحة إضافية لتجنب تغطية الشريط السفلي للمحتوى
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. الشريط السفلي اللاصق (Sticky Bottom Toolbar)
        bottomNavigationBar: _buildStickyToolbar(),
      ),
    );
  }

  // ==================== 1. الهيدر العلوي ====================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // أيقونة الإغلاق
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF4A5568), size: 28),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // عنوان الصفحة
          const Text(
            "إنشاء منشور",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),

          // زر النشر
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isPublishEnabled
                  ? const Color(0xFF72A0D4) // لون مفعل
                  : const Color(0xFF72A0D4).withValues(alpha: 0.5), // لون معطل
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _publishPost,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    "نشر",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== معلومات المستخدم ====================
  Widget _buildUserInfo() {
    return Row(
      children: [
        // الصورة الشخصية
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade50,
          backgroundImage: const AssetImage(
            'assets/WhatsApp Image 2026-07-14 at 00.13.52.jpeg',
          ), // صورة توضيحية
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "شمس الدين",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.public, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  "عام للمجتمع",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ==================== مربعات الوسائط (الحدود المنقطة) ====================
  Widget _buildMediaPlaceholder(IconData icon) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: const Color(0xFFCBD5E1),
        strokeWidth: 2,
        dashWidth: 6,
        dashSpace: 4,
        borderRadius: 16,
      ),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(icon, size: 32, color: const Color(0xFF94A3B8)),
        ),
      ),
    );
  }

  // ==================== قسم الوسوم (Tags) ====================
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        const Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              color: Color(0xFF005CEE),
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              "إضافة وسم",
              style: TextStyle(
                color: Color(0xFF005CEE),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // قائمة الوسوم المتاحة
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF005CEE)
                      : const Color(0xFFE4EFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isSelected ? Icons.check : Icons.add,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF4A5568),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // حقل البحث عن وسوم
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _tagSearchController,
            decoration: const InputDecoration(
              hintText: "ابحث عن وسم...",
              hintStyle: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFFA0AEC0),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== الشريط السفلي اللاصق ====================
  Widget _buildStickyToolbar() {
    return Container(
      margin: const EdgeInsets.all(16), // هوامش لجعله عائماً
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // توسيط العناصر
        children: [
          _buildToolbarIcon(Icons.image_outlined),
          const SizedBox(width: 16),
          _buildToolbarIcon(Icons.videocam_outlined),
          const SizedBox(width: 16),
          _buildToolbarIcon(Icons.poll_outlined),
          const SizedBox(width: 16),
          _buildToolbarIcon(Icons.attach_file),

          // فاصل عمودي
          Container(
            height: 24,
            width: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFFE2E8F0),
          ),

          // إعدادات الردود
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF4A5568),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "إعدادات",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4A5568),
                        height: 1,
                      ),
                    ),
                    Text(
                      "الردود",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4A5568),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // أيقونات الشريط السفلي
  Widget _buildToolbarIcon(IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Icon(icon, color: const Color(0xFF4A5568), size: 26),
    );
  }
}

// =========================================================
// Custom Painter لرسم الحدود المنقطة (Dashed Border)
// =========================================================
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.borderRadius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
