import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:math';

// استبدل هذه الـ Imports بمسارات ملفاتك الحقيقية
import 'package:basita1/features/home/screens/home_screen.dart';
import 'package:basita1/features/chat/screens/chat_screen.dart';
import 'package:basita1/features/profile/screens/profile_screen.dart';
import 'package:basita1/features/booking/screens/request_service_screen.dart';
import 'package:basita1/core/session/user_session.dart';

// دالة مساعدة ذكية لجلب مرجع وثيقة المستخدم الحقيقية في فايربيز (تمنع ضياع الـ Session والرجوع للتسجيل)
Future<DocumentReference<Map<String, dynamic>>?> _getRealUserDocRef() async {
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) return doc.reference;
  }

  String phone = UserSession.instance.phone.trim();
  if (phone.isEmpty) {
    if (uid != null) {
      return FirebaseFirestore.instance.collection('users').doc(uid);
    }
    return null;
  }

  final query = await FirebaseFirestore.instance
      .collection('users')
      .where('phone', isEqualTo: phone)
      .get();

  if (query.docs.isNotEmpty) {
    return query.docs.first.reference;
  }

  String fallbackUid = uid ?? "user_${phone.replaceAll(RegExp(r'[^0-9]'), '')}";
  return FirebaseFirestore.instance.collection('users').doc(fallbackUid);
}

// =========================================================================
// 1. Family Gate Screen (شاشة التوجيه الذكية بالـ Stream للاحتفاظ بالحالة)
// =========================================================================
class FamilyGateScreen extends StatelessWidget {
  const FamilyGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentReference<Map<String, dynamic>>?>(
      future: _getRealUserDocRef(),
      builder: (context, userDocSnapshot) {
        if (userDocSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAFC),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0066CC)),
            ),
          );
        }

        if (!userDocSnapshot.hasData || userDocSnapshot.data == null) {
          return const FamilyJoiningScreen();
        }

        // استخدام StreamBuilder المباشر على وثيقة المستخدم لضمان عدم ضياع الحالة أبداً
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userDocSnapshot.data!.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFFF9FAFC),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF0066CC)),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              Map<String, dynamic>? userData = snapshot.data!.data();
              String? familyId = userData?['familyId'];

              if (familyId != null && familyId.isNotEmpty) {
                return FamilyDashboardScreen(familyCode: familyId);
              }
            }

            return const FamilyJoiningScreen();
          },
        );
      },
    );
  }
}

// =========================================================================
// 2. Family Joining & Creation Screen (شاشة الانضمام والإنشاء والدعوات)
// =========================================================================
class FamilyJoiningScreen extends StatefulWidget {
  const FamilyJoiningScreen({super.key});

  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color lightBlueBg = Color(0xFFEBF3FF);

  @override
  State<FamilyJoiningScreen> createState() => _FamilyJoiningScreenState();
}

class _FamilyJoiningScreenState extends State<FamilyJoiningScreen> {
  final TextEditingController _joinCodeController = TextEditingController();
  bool isLoading = false;

  String get currentUserName => UserSession.instance.name.isNotEmpty
      ? UserSession.instance.name
      : (FirebaseAuth.instance.currentUser?.displayName ?? "مستخدم");

  String get currentUserPhone => UserSession.instance.phone.trim();

  // دالة الانضمام لعائلة موجودة بالكود أو بقبول الدعوة
  Future<void> _joinFamily(String code) async {
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى إدخال كود العائلة")));
      return;
    }

    setState(() => isLoading = true);
    try {
      DocumentSnapshot familyDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(code)
          .get();

      if (familyDoc.exists) {
        final userRef = await _getRealUserDocRef();
        if (userRef == null) throw "تعذر تحديد بيانات المستخدم";
        String currentUserId = userRef.id;

        // إضافة المستخدم كعضو في العائلة
        await FirebaseFirestore.instance
            .collection('families')
            .doc(code)
            .collection('members')
            .doc(currentUserId)
            .set({
              'name': currentUserName,
              'role': 'عضو',
              'isOnline': true,
              'joinedAt': FieldValue.serverTimestamp(),
              'imageUrl': UserSession.instance.profileImagePath ?? '',
            }, SetOptions(merge: true));

        // ربط العائلة بملف المستخدم
        await userRef.set({
          'familyId': code,
          'name': currentUserName,
          'phone': UserSession.instance.phone,
        }, SetOptions(merge: true));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FamilyDashboardScreen(familyCode: code),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("هذا الكود غير صحيح، تأكد من الكود وحاول مجدداً"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    }
    if (mounted) setState(() => isLoading = false);
  }

  // نافذة تفاعلية (BottomSheet) لإنشاء العائلة وإدخال الاسم وتوليد الكود
  void _showCreateFamilyBottomSheet(BuildContext context) {
    String defaultName = currentUserName.isNotEmpty
        ? "عائلة ${currentUserName.split(' ').first}"
        : "عائلة بسيطة";
    final TextEditingController familyNameController = TextEditingController(
      text: defaultName,
    );
    final String generatedCode = "BSITA-${Random().nextInt(9000) + 1000}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 20),
                  Text(
                    "إنشاء عائلة جديدة",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "حدد اسم عائلتك وشارك الكود أو ابعت دعوات لأفراد أسرتك",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "اسم العائلة",
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: familyNameController,
                    style: GoogleFonts.cairo(fontSize: 15),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: FamilyJoiningScreen.primaryBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: FamilyJoiningScreen.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FamilyJoiningScreen.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.vpn_key_outlined,
                              color: FamilyJoiningScreen.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              generatedCode,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: FamilyJoiningScreen.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: FamilyJoiningScreen.primaryBlue,
                            size: 20,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: generatedCode),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تم نسخ كود العائلة بنجاح!"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _executeCreateFamily(
                          familyNameController.text.trim(),
                          generatedCode,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FamilyJoiningScreen.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "إنشاء والانتقال للداشبورد",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // تنفيذ إنشاء العائلة وحفظها في فايربيز
  Future<void> _executeCreateFamily(
    String familyName,
    String familyCode,
  ) async {
    setState(() => isLoading = true);
    try {
      final userRef = await _getRealUserDocRef();
      if (userRef == null) throw "تعذر تحديد بيانات المستخدم";
      String currentUserId = userRef.id;

      final batch = FirebaseFirestore.instance.batch();

      final familyRef = FirebaseFirestore.instance
          .collection('families')
          .doc(familyCode);

      // حفظ البيانات الأساسية والقائد
      batch.set(familyRef, {
        'familyName': familyName.isNotEmpty
            ? familyName
            : "عائلة $currentUserName",
        'adminId': currentUserId, // القائد
        'createdAt': FieldValue.serverTimestamp(),
        'monthlySpend': 0,
        'activeRequests': 0,
        'familyPoints': 100,
        'totalServices': 0,
      });

      final memberRef = familyRef.collection('members').doc(currentUserId);
      batch.set(memberRef, {
        'name': currentUserName,
        'role': 'مسؤول العائلة',
        'isOnline': true,
        'joinedAt': FieldValue.serverTimestamp(),
        'imageUrl': UserSession.instance.profileImagePath ?? '',
      });

      batch.set(userRef, {
        'familyId': familyCode,
        'name': currentUserName,
        'phone': UserSession.instance.phone,
      }, SetOptions(merge: true));

      await batch.commit();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FamilyDashboardScreen(familyCode: familyCode),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء الإنشاء: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ويدجت عرض الدعوات المُرسلة للمستخدم برقم الموبايل
  Widget _buildInvitationsSection() {
    if (currentUserPhone.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('family_invitations')
          .where('toPhone', isEqualTo: currentUserPhone)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink(); // لا توجد دعوات
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 12),
              child: Text(
                "دعوات الانضمام (${snapshot.data!.docs.length})",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            ...snapshot.data!.docs.map((doc) {
              var inviteData = doc.data() as Map<String, dynamic>;
              String inviteId = doc.id;
              String familyName = inviteData['familyName'] ?? 'عائلة';
              String inviterName = inviteData['inviterName'] ?? 'شخص ما';
              String familyCode = inviteData['familyCode'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6), // لون مميز لكارت الدعوة
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFC107).withOpacity(0.5),
                  ),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE082),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_rounded,
                            color: Color(0xFFF57F17),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "دعوة جديدة من $inviterName",
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "للانضمام إلى: $familyName",
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // تحديث حالة الدعوة
                              await FirebaseFirestore.instance
                                  .collection('family_invitations')
                                  .doc(inviteId)
                                  .update({'status': 'accepted'});
                              // الانضمام للعائلة
                              _joinFamily(familyCode);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27AE60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "قبول",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              // رفض ومسح الدعوة
                              await FirebaseFirestore.instance
                                  .collection('family_invitations')
                                  .doc(inviteId)
                                  .delete();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE74C3C)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "رفض",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE74C3C),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: _buildCustomAppBar(),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: FamilyJoiningScreen.primaryBlue,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Column(
                  children: [
                    _buildPageHeader(),
                    const SizedBox(height: 24),

                    // كارت الانضمام إلى عائلة بكود
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          Text(
                            "كود العائلة",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _joinCodeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: "مثال: BSITA-0000",
                              hintStyle: GoogleFonts.cairo(
                                color: Colors.grey.shade400,
                              ),
                              suffixIcon: const Icon(
                                Icons.vpn_key_outlined,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: FamilyJoiningScreen.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _joinFamily(
                                _joinCodeController.text.trim().toUpperCase(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    FamilyJoiningScreen.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "انضمام >",
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // كارت إنشاء العائلة
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F8F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.qr_code_2_rounded,
                                  color: Color(0xFF27AE60),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "كود عائلتك الخاص",
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "أنشئ عائلتك واحصل على كود خاص لمشاركة أفراد أسرتك",
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showCreateFamilyBottomSheet(context),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: FamilyJoiningScreen.primaryBlue,
                              ),
                              label: Text(
                                "إنشاء عائلة جديدة",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: FamilyJoiningScreen.primaryBlue,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: FamilyJoiningScreen.primaryBlue,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // قسم الدعوات (بيظهر بس لو في دعوات)
                    _buildInvitationsSection(),

                    // الفوتر الإرشادي
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: FamilyJoiningScreen.primaryBlue.withOpacity(
                          0.05,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "بمجرد الانضمام، سيتمكن أفراد العائلة من رؤية الطلبات المشتركة، رصيد المحفظة العائلية، وتنسيق المواعيد بسهولة.",
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: _buildCustomBottomNavBar(context, 3),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    String? userProfileImage = UserSession.instance.profileImagePath;
    ImageProvider avatarProvider;
    if (userProfileImage != null && userProfileImage.isNotEmpty) {
      if (userProfileImage.startsWith('http')) {
        avatarProvider = NetworkImage(userProfileImage);
      } else {
        avatarProvider = FileImage(File(userProfileImage));
      }
    } else {
      avatarProvider = const AssetImage(
        'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "بسيطة",
        style: GoogleFonts.cairo(
          color: FamilyJoiningScreen.primaryBlue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: avatarProvider,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: FamilyJoiningScreen.lightBlueBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.group_add_rounded,
            size: 45,
            color: FamilyJoiningScreen.primaryBlue,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "الانضمام إلى عائلة",
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "أدخل الكود أو اقبل الدعوات لتتمكن من مشاركة الخدمات",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// 3. Family Dashboard Screen (لوحة تحكم العائلة الديناميكية مع صلاحيات القائد)
// =========================================================================
class FamilyDashboardScreen extends StatefulWidget {
  final String familyCode;

  const FamilyDashboardScreen({super.key, required this.familyCode});

  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color backgroundColor = Color(0xFFF9FAFC);

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userRef = await _getRealUserDocRef();
    if (userRef != null && mounted) {
      setState(() {
        currentUserId = userRef.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: FamilyDashboardScreen.backgroundColor,
        body: SafeArea(
          child: currentUserId == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('families')
                      .doc(widget.familyCode)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      // لو العائلة اتمسحت، رجعه لشاشة الانضمام
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FamilyGateScreen(),
                          ),
                        );
                      });
                      return const SizedBox();
                    }

                    var familyData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    bool isAdmin = familyData['adminId'] == currentUserId;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          _buildMainBlueCard(familyData, context),
                          const SizedBox(height: 20),
                          _buildQuickActions(context, familyData, isAdmin),
                          const SizedBox(height: 25),
                          _buildMembersHeader(),
                          const SizedBox(height: 12),
                          _buildMembersList(
                            isAdmin,
                            familyData['adminId'] ?? '',
                          ),
                          const SizedBox(height: 20),
                          _buildFooterCards(familyData),
                        ],
                      ),
                    );
                  },
                ),
        ),
        bottomNavigationBar: _buildCustomBottomNavBar(context, 3),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "العائلة",
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: FamilyDashboardScreen.primaryBlue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "كل أفراد أسرتك وخدماتهم في مكان واحد",
              style: GoogleFonts.cairo(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 26,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMainBlueCard(
    Map<String, dynamic> familyData,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FamilyDashboardScreen.primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: FamilyDashboardScreen.primaryBlue.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    familyData['familyName'] ?? "عائلتي",
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('families')
                        .doc(widget.familyCode)
                        .collection('members')
                        .snapshots(),
                    builder: (context, memberSnapshot) {
                      int count = memberSnapshot.hasData
                          ? memberSnapshot.data!.docs.length
                          : 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_alt_outlined,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$count أفراد",
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showShareCodeDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.qr_code_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatBox(
                "الإنفاق الشهري",
                "${familyData['monthlySpend'] ?? 0} ج.م",
              ),
              const SizedBox(width: 12),
              _buildStatBox(
                "الطلبات النشطة",
                "${familyData['activeRequests'] ?? 0} خدمات",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    Map<String, dynamic> familyData,
    bool isAdmin,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          Icons.person_add_alt_1_rounded,
          "دعوة فرد",
          const Color(0xFFEBF3FF),
          FamilyDashboardScreen.primaryBlue,
          onTap: () => _showInviteByPhoneDialog(context, familyData),
        ),
        _buildActionButton(
          Icons.share_outlined,
          "مشاركة الكود",
          const Color(0xFFE8F8F0),
          const Color(0xFF27AE60),
          onTap: () => _showShareCodeDialog(context),
        ),
        _buildActionButton(
          Icons.logout,
          "مغادرة",
          const Color(0xFFFEECEB),
          const Color(0xFFE74C3C),
          onTap: () => _leaveFamily(context),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor, {
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "أفراد العائلة",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(bool isAdmin, String adminId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('families')
          .doc(widget.familyCode)
          .collection('members')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Text("لا يوجد أفراد بعد");

        return Column(
          children: snapshot.data!.docs.map((doc) {
            var member = doc.data() as Map<String, dynamic>;
            String memberId = doc.id;
            bool isMemberAdmin = memberId == adminId;

            return _buildMemberItem(
              memberId: memberId,
              name: member['name'] ?? 'مستخدم',
              role: isMemberAdmin ? 'القائد' : (member['role'] ?? 'عضو'),
              status: member['isOnline'] == true ? "متصل الآن" : "غير متصل",
              isOnline: member['isOnline'] ?? false,
              imageUrl: member['imageUrl'] ?? '',
              isAdminViewer: isAdmin,
              isTargetAdmin: isMemberAdmin,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMemberItem({
    required String memberId,
    required String name,
    required String role,
    required String status,
    required bool isOnline,
    required String imageUrl,
    required bool isAdminViewer,
    required bool isTargetAdmin,
  }) {
    ImageProvider avatar;
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      avatar = NetworkImage(imageUrl);
    } else if (imageUrl.isNotEmpty) {
      avatar = FileImage(File(imageUrl));
    } else {
      avatar = const AssetImage(
        'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // لو اللي فاتح هو القائد والمستخدم المعروض مش القائد، نظهرله زرار الطرد
          if (isAdminViewer && !isTargetAdmin)
            IconButton(
              icon: const Icon(
                Icons.person_remove_rounded,
                color: Color(0xFFE74C3C),
                size: 22,
              ),
              onPressed: () => _removeMember(memberId, name),
              tooltip: "طرد من العائلة",
            )
          else
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 12,
                color: FamilyDashboardScreen.primaryBlue,
              ),
            ),

          const SizedBox(width: 10),
          Text(
            status,
            style: GoogleFonts.cairo(
              color: isOnline ? const Color(0xFF27AE60) : Colors.grey,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  if (isTargetAdmin)
                    const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFFFC107),
                      size: 16,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: avatar,
                backgroundColor: Colors.grey.shade200,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFBDBDBD),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterCards(Map<String, dynamic> familyData) {
    return Row(
      children: [
        _buildSimpleCard(
          Icons.verified_rounded,
          "نقاط العائلة",
          "${familyData['familyPoints'] ?? 0} نقطة",
          const Color(0xFF27AE60),
        ),
        const SizedBox(width: 12),
        _buildSimpleCard(
          Icons.history_rounded,
          "السجل المشترك",
          "${familyData['totalServices'] ?? 0} خدمة",
          FamilyDashboardScreen.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildSimpleCard(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== الوظائف (Functions) ===================== //

  // نافذة دعوة فرد برقم التليفون
  void _showInviteByPhoneDialog(
    BuildContext context,
    Map<String, dynamic> familyData,
  ) {
    final TextEditingController phoneController = TextEditingController();
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "إضافة فرد للعائلة",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "أدخل رقم هاتف الشخص المراد إضافته لإرسال دعوة له",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "رقم الموبايل (مثال: 010...)",
                          prefixIcon: const Icon(Icons.phone_android_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: FamilyDashboardScreen.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSending
                              ? null
                              : () async {
                                  String phone = phoneController.text.trim();
                                  if (phone.isEmpty) return;

                                  setStateModal(() => isSending = true);
                                  try {
                                    String currentUserName =
                                        UserSession.instance.name.isNotEmpty
                                        ? UserSession.instance.name
                                        : (FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.displayName ??
                                              "القائد");

                                    await FirebaseFirestore.instance
                                        .collection('family_invitations')
                                        .add({
                                          'toPhone': phone,
                                          'familyCode': widget.familyCode,
                                          'familyName':
                                              familyData['familyName'] ??
                                              'عائلتي',
                                          'inviterName': currentUserName,
                                          'status': 'pending',
                                          'createdAt':
                                              FieldValue.serverTimestamp(),
                                        });

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "تم إرسال الدعوة إلى $phone بنجاح!",
                                          ),
                                          backgroundColor: const Color(
                                            0xFF27AE60,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("حدث خطأ: $e")),
                                      );
                                    }
                                  } finally {
                                    setStateModal(() => isSending = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FamilyDashboardScreen.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "إرسال الدعوة",
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
              ),
            );
          },
        );
      },
    );
  }

  // نافذة مشاركة الكود ونسخه
  void _showShareCodeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "شارك هذا الكود مع عائلتك",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 40,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: FamilyDashboardScreen.primaryBlue,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: FamilyDashboardScreen.primaryBlue.withOpacity(0.05),
                ),
                child: Text(
                  widget.familyCode,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: FamilyDashboardScreen.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  label: Text(
                    "نسخ الكود",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FamilyDashboardScreen.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: widget.familyCode),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم النسخ بنجاح!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // طرد عضو (خاصة بالقائد فقط)
  Future<void> _removeMember(String memberId, String memberName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            "طرد الفرد",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "هل أنت متأكد أنك تريد إزالة $memberName من العائلة؟",
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "إلغاء",
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "طرد",
                style: GoogleFonts.cairo(
                  color: const Color(0xFFE74C3C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      final batch = FirebaseFirestore.instance.batch();

      // إزالة من Users
      final targetUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(memberId);
      batch.update(targetUserRef, {'familyId': FieldValue.delete()});

      // إزالة من Members
      final memberRef = FirebaseFirestore.instance
          .collection('families')
          .doc(widget.familyCode)
          .collection('members')
          .doc(memberId);
      batch.delete(memberRef);

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تمت إزالة $memberName من العائلة")),
        );
      }
    }
  }

  // مغادرة العائلة (لو آخر فرد، العائلة تتمسح)
  Future<void> _leaveFamily(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            "مغادرة العائلة",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "هل أنت متأكد أنك تريد مغادرة العائلة؟",
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "إلغاء",
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "مغادرة",
                style: GoogleFonts.cairo(
                  color: const Color(0xFFE74C3C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirm != true || currentUserId == null) return;

    // جلب عدد الأعضاء الحاليين قبل المغادرة
    var membersQuery = await FirebaseFirestore.instance
        .collection('families')
        .doc(widget.familyCode)
        .collection('members')
        .get();

    int currentMembersCount = membersQuery.docs.length;

    final batch = FirebaseFirestore.instance.batch();

    // مسح المستخدم الحالي من الـ users
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId);
    batch.update(userRef, {'familyId': FieldValue.delete()});

    // مسحه من members العائلة
    final memberRef = FirebaseFirestore.instance
        .collection('families')
        .doc(widget.familyCode)
        .collection('members')
        .doc(currentUserId);
    batch.delete(memberRef);

    // لو ده كان آخر فرد، امسح العائلة كلها
    if (currentMembersCount <= 1) {
      final familyRef = FirebaseFirestore.instance
          .collection('families')
          .doc(widget.familyCode);
      batch.delete(familyRef);
    }

    await batch.commit();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FamilyGateScreen()),
      );
    }
  }
}

// شريط التنقل السفلي الموحد
Widget _buildCustomBottomNavBar(BuildContext context, int currentIndex) {
  const Color primaryBlue = Color(0xFF0066CC);

  final List<Map<String, dynamic>> items = [
    {'icon': Icons.home_filled, 'label': "الرئيسية"},
    {'icon': Icons.local_offer_outlined, 'label': "طلباتي"},
    {'icon': Icons.chat_bubble_outline_rounded, 'label': "المحادثات"},
    {'icon': Icons.people_outline_rounded, 'label': "العائلة"},
    {'icon': Icons.person_outline_rounded, 'label': "الحساب"},
  ];

  return Container(
    height: 85,
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
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(items.length, (index) {
        final isSelected = currentIndex == index;
        final item = items[index];

        return Expanded(
          child: InkWell(
            onTap: () {
              if (isSelected) return;
              switch (index) {
                case 0:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SimpleHomeScreen(), // تأكد من الاسم بمشروعك
                    ),
                  );
                  break;
                case 1:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestServiceScreen(),
                    ),
                  );
                  break;
                case 2:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatMainPage(),
                    ),
                  );
                  break;
                case 3:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FamilyGateScreen(),
                    ),
                  );
                  break;
                case 4:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfileScreen(),
                    ),
                  );
                  break;
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item['icon'], color: primaryBlue, size: 26),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: GoogleFonts.cairo(
                            color: primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item['icon'], color: Colors.grey.shade500, size: 26),
                      const SizedBox(height: 4),
                      Text(
                        item['label'],
                        style: GoogleFonts.cairo(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }),
    ),
  );
}
