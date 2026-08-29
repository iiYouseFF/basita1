import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// استدعاء ملف الـ Session الخاص بك
import 'package:basita1/core/session/user_session.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  static const Color brandBlue = Color(0xFF0053AC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bgLightGrey = Color(0xFFF8FAFC);

  bool _isSubmitting = false;

  // متغيرات الصور
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();

  // دالة اختيار الصورة
  Future<void> _pickImage(bool isFront) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // لتقليل حجم الصورة
      );

      if (pickedFile != null) {
        setState(() {
          if (isFront) {
            _frontImage = File(pickedFile.path);
          } else {
            _backImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint("خطأ في اختيار الصورة: $e");
    }
  }

  // دالة رفع الصورة إلى Supabase
  Future<String?> _uploadImageToSupabase(
    File imageFile,
    String docId,
    String side,
  ) async {
    try {
      final fileName =
          '${docId}_${side}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$docId/$fileName'; // حفظها في مجلد باسم المعرف

      await Supabase.instance.client.storage
          .from('account_verification')
          .upload(path, imageFile);

      return path;
    } catch (e) {
      debugPrint("خطأ في رفع الصورة لسوبابيز: $e");
      return null;
    }
  }

  // دالة الإرسال وحفظ البيانات في مجموعة 'verified' المستقلة
  Future<void> _submitForReview() async {
    final session = UserSession.instance;
    String? fbUid = FirebaseAuth.instance.currentUser?.uid;
    String phone = session.phone.trim();

    // التحقق من أن المستخدم مسجل سواء بفايربيز أو بالجلسة المحلية
    if (fbUid == null && phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى تسجيل الدخول أولاً', style: GoogleFonts.cairo()),
        ),
      );
      return;
    }

    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى رفع صورتي البطاقة الأمامية والخلفية',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // تحديد معرف فريد ومستقر للمستند (UID أو رقم الهاتف)
      String docId = fbUid ?? phone;

      if (fbUid == null) {
        var query = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phone)
            .get();
        if (query.docs.isNotEmpty) {
          docId = query.docs.first.id;
        }
      }

      // 1. رفع الصور لـ Supabase أولاً
      String? frontImagePath = await _uploadImageToSupabase(
        _frontImage!,
        docId,
        'front',
      );
      String? backImagePath = await _uploadImageToSupabase(
        _backImage!,
        docId,
        'back',
      );

      if (frontImagePath == null || backImagePath == null) {
        throw Exception("فشل في رفع الصور");
      }

      // 2. إنشاء مستند منظم بالكامل داخل مجموعة 'verified' مع ضبط الحالة إلى 'pending'
      await FirebaseFirestore.instance.collection('verified').doc(docId).set({
        'userId': docId,
        'verificationStatus': 'pending',
        'name': session.name.isNotEmpty ? session.name : 'بدون اسم',
        'phone': session.phone.isNotEmpty ? session.phone : 'بدون رقم',
        'email': session.email,
        'city': session.city,
        'governorate': session.governorate,
        'frontIdPath': frontImagePath,
        'backIdPath': backImagePath,
        'submittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. تحديث سريع لحالة المستخدم في مجموعة users
      await FirebaseFirestore.instance.collection('users').doc(docId).set({
        'verificationStatus': 'pending',
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("خطأ في الإرسال: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء الإرسال، حاول مجدداً.',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // استخدام Query Stream ذكي للبحث عن بيانات التوثيق فورياً ولحظياً
  Stream<QuerySnapshot> get _verifiedQueryStream {
    String? fbUid = FirebaseAuth.instance.currentUser?.uid;
    String phone = UserSession.instance.phone.trim();

    Query query = FirebaseFirestore.instance.collection('verified');
    if (fbUid != null && fbUid.isNotEmpty) {
      query = query.where('userId', isEqualTo: fbUid);
    } else if (phone.isNotEmpty) {
      query = query.where('phone', isEqualTo: phone);
    } else {
      query = query.where('userId', isEqualTo: 'none');
    }
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    String? fbUid = FirebaseAuth.instance.currentUser?.uid;
    String phone = UserSession.instance.phone.trim();
    bool isLoggedIn = fbUid != null || phone.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLightGrey,
        appBar: AppBar(
          backgroundColor: bgLightGrey,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "توثيق الحساب",
            style: GoogleFonts.cairo(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: brandBlue),
              onPressed: () => Navigator.pop(context),
            ),
          ],
          leading: const SizedBox(),
        ),
        body: !isLoggedIn
            ? _buildUnauthenticatedUI()
            : StreamBuilder<QuerySnapshot>(
                stream: _verifiedQueryStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: brandBlue),
                    );
                  }

                  String status = 'none';

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final data =
                        snapshot.data!.docs.first.data()
                            as Map<String, dynamic>?;
                    if (data != null &&
                        data.containsKey('verificationStatus')) {
                      status = data['verificationStatus'];
                    }
                  }

                  // توجيه الواجهة بناءً على الحالة الواردة من الفايربيز
                  switch (status) {
                    case 'approved':
                      return _buildApprovedUI();
                    case 'pending':
                      return _buildPendingUI();
                    case 'rejected':
                      return _buildUploadUI(isRejected: true);
                    default:
                      return _buildUploadUI(isRejected: false);
                  }
                },
              ),
      ),
    );
  }

  // ==========================================
  // 1. واجهة رفع البيانات
  // ==========================================
  Widget _buildUploadUI({required bool isRejected}) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: brandBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: brandBlue,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "وثّق حسابك",
                  style: GoogleFonts.cairo(
                    color: textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "ساعدنا في التأكد من هويتك للحفاظ على أمان حسابك\nوزيادة ثقة العملاء بك.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (isRejected) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "تم رفض طلبك السابق، يرجى التأكد من وضوح صور الهوية وإعادة الرفع.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.black87,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "تم التحقق",
                              style: GoogleFonts.cairo(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "رقم الهاتف",
                            style: GoogleFonts.cairo(
                              color: textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            UserSession.instance.phone.isNotEmpty
                                ? UserSession.instance.phone
                                : "+20 100 123 4567",
                            style: GoogleFonts.cairo(
                              color: textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: bgLightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone_iphone, color: textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "بطاقة الهوية",
                                  style: GoogleFonts.cairo(
                                    color: textDark,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "ارفع صورة بطاقة الرقم القومي من الأمام والخلف للتأكد من بياناتك.",
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.cairo(
                                    color: textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: brandBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: brandBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDashedUploadBox(
                              "صورة البطاقة\nالوجه الأمامي",
                              _frontImage,
                              () => _pickImage(true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDashedUploadBox(
                              "صورة البطاقة\nالوجه الخلفي",
                              _backImage,
                              () => _pickImage(false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(
          buttonText: "إرسال للمراجعة",
          buttonIcon: Icons.send_outlined,
          isLoading: _isSubmitting,
          onTap: _submitForReview,
        ),
      ],
    );
  }

  // ==========================================
  // 2. واجهة المراجعة (Pending)
  // ==========================================
  Widget _buildPendingUI() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_empty,
                    color: Colors.orange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "طلبك قيد المراجعة",
                  style: GoogleFonts.cairo(
                    color: textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "شكراً لك. فريقنا يقوم الآن بمراجعة بياناتك، سنقوم بإعلامك فور الانتهاء.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: textMuted,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(
          buttonText: "العودة للرئيسية",
          buttonIcon: null,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ==========================================
  // 3. واجهة التوثيق بنجاح (Approved)
  // ==========================================
  Widget _buildApprovedUI() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.green,
                    size: 45,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "الحساب موثق",
                  style: GoogleFonts.cairo(
                    color: textDark,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "حسابك بالفعل موثق ومدرج ضمن قائمة التوثيق الخاصة بنا",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(color: textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(
          buttonText: "العودة للرئيسية",
          buttonIcon: null,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ==========================================
  // واجهة غير مسجل الدخول
  // ==========================================
  Widget _buildUnauthenticatedUI() {
    return Center(
      child: Text(
        "يجب تسجيل الدخول لاستخدام هذه الميزة.",
        style: GoogleFonts.cairo(fontSize: 16),
      ),
    );
  }

  // ==========================================
  // ودجت الفوتر
  // ==========================================
  Widget _buildFooter({
    required String buttonText,
    IconData? buttonIcon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (buttonIcon != null) ...[
                          Icon(buttonIcon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          buttonText,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "بياناتك آمنة وتستخدم فقط للتحقق من هويتك.",
                style: GoogleFonts.cairo(color: textMuted, fontSize: 11),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.lock_outline, color: textMuted, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ودجت مربع الرفع
  // ==========================================
  Widget _buildDashedUploadBox(String text, File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedRectPainter(
          color: Colors.grey.shade400,
          strokeWidth: 1.5,
          gap: 5.0,
        ),
        child: Container(
          height: 110,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: textMuted,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ==========================================
// رسام لرسم الحدود المقطعة (Dashed Border)
// ==========================================
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();
    var rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    path.addRRect(rrect);

    Path dashPath = Path();
    double dashWidth = 6.0;
    double dashSpace = gap;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
