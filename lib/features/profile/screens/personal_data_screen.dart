import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// removed: cloud_firestore - see docs/backend-prd.html
// removed: firebase_auth
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
// removed: supabase_flutter

import 'package:basita1/core/session/user_session.dart';
import 'package:basita1/features/feedback/screens/coming_soon_screen.dart';
import 'package:basita1/features/auth/screens/account_type_screen.dart';
import 'package:basita1/core/network/mock_backend.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<PersonalDataScreen> {
  late TextEditingController emailController;
  late TextEditingController cityController;

  final Color primaryBlue = const Color(0xFF0056D2);
  final Color bgLight = const Color(0xFFF8F9FE);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);
  final ImagePicker _picker = ImagePicker();

  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: UserSession.instance.email);
    cityController = TextEditingController(text: UserSession.instance.city);
  }

  @override
  void dispose() {
    emailController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpdateImage() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        setState(() => _isPickingImage = false);
        return;
      }

      File imageFile = File(pickedFile.path);
      String userPhone = UserSession.instance.phone.trim();
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final supabase = MockSupabase;
      await supabase.storage
          .from('user_profiles')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final String downloadUrl = supabase.storage
          .from('user_profiles')
          .getPublicUrl(fileName);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedUserId = prefs.getString('userId');
      String? currentUid = MockAuth.currentUser?.uid ?? savedUserId;

      if (currentUid != null && currentUid.isNotEmpty) {
        var docRef = MockFirestore.collection('users').doc(currentUid);
        var docSnap = await docRef.get();
        if (docSnap.exists) {
          await docRef.update({'profileImagePath': downloadUrl});
        } else if (userPhone.isNotEmpty) {
          var querySnapshot = await MockFirestore.collection(
            'users',
          ).where('phone', isEqualTo: userPhone).get();

          if (querySnapshot.docs.isNotEmpty) {
            await MockFirestore.collection('users')
                .doc(querySnapshot.docs.first.id)
                .update({'profileImagePath': downloadUrl});
          }
        }
      } else if (userPhone.isNotEmpty) {
        var querySnapshot = await MockFirestore.collection(
          'users',
        ).where('phone', isEqualTo: userPhone).get();

        if (querySnapshot.docs.isNotEmpty) {
          await MockFirestore.collection('users')
              .doc(querySnapshot.docs.first.id)
              .update({'profileImagePath': downloadUrl});
        }
      }

      setState(() {
        UserSession.instance.profileImagePath = downloadUrl;
      });

      try {
        await prefs.setString('userImage', downloadUrl);
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "تم رفع وتحديث الصورة الشخصية أونلاين بنجاح",
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "حدث خطأ أثناء رفع الصورة: $e",
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    String userPhone = UserSession.instance.phone.trim();
    String updatedEmail = emailController.text.trim();
    String updatedCity = cityController.text.trim();

    if (updatedEmail.isNotEmpty) {
      // التعبير النمطي (Regex) للتحقق من أن الإيميل باللغة الإنجليزية وبصيغة صحيحة (يمنع الحروف العربية والمسافات)
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(updatedEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "بريد إلكتروني غير صالح (تأكد من كتابته باللغة الإنجليزية وبدون مسافات)",
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return; // إيقاف تنفيذ الحفظ إذا كان الإيميل غير صالح
      }
    }

    UserSession.instance.email = updatedEmail;
    UserSession.instance.city = updatedCity;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedUserId = prefs.getString('userId');
      String? currentUid = MockAuth.currentUser?.uid ?? savedUserId;

      if (currentUid != null && currentUid.isNotEmpty) {
        var docRef = MockFirestore.collection('users').doc(currentUid);
        var docSnap = await docRef.get();
        if (docSnap.exists) {
          await docRef.update({'email': updatedEmail, 'city': updatedCity});
        } else if (userPhone.isNotEmpty) {
          var querySnapshot = await MockFirestore.collection(
            'users',
          ).where('phone', isEqualTo: userPhone).get();

          if (querySnapshot.docs.isNotEmpty) {
            await MockFirestore.collection('users')
                .doc(querySnapshot.docs.first.id)
                .update({'email': updatedEmail, 'city': updatedCity});
          }
        }
      } else if (userPhone.isNotEmpty) {
        var querySnapshot = await MockFirestore.collection(
          'users',
        ).where('phone', isEqualTo: userPhone).get();

        if (querySnapshot.docs.isNotEmpty) {
          await MockFirestore.collection('users')
              .doc(querySnapshot.docs.first.id)
              .update({'email': updatedEmail, 'city': updatedCity});
        }
      }

      await prefs.setString('userEmail', updatedEmail);
      await prefs.setString('userCity', updatedCity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم حفظ البيانات بنجاح", style: GoogleFonts.cairo()),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "حدث خطأ أثناء حفظ البيانات: $e",
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildSaveButton(),
              const SizedBox(height: 28),
              _buildAccountActionsSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgLight,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "البيانات الشخصية",
        style: GoogleFonts.cairo(
          color: primaryBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: primaryBlue, size: 26),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: textDark, size: 24),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ComingSoonScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    ImageProvider profileImageProvider;
    final String? imagePath = UserSession.instance.profileImagePath;

    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        profileImageProvider = NetworkImage(imagePath);
      } else {
        profileImageProvider = FileImage(File(imagePath));
      }
    } else {
      profileImageProvider = const AssetImage(
        'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _isPickingImage ? null : _pickAndUpdateImage,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageProvider,
                  child: _isPickingImage
                      ? const CircularProgressIndicator(color: Colors.white)
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          UserSession.instance.name.isNotEmpty
              ? UserSession.instance.name
              : "مستخدم جديد",
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        children: [
          _buildStaticRow("الاسم الكامل", UserSession.instance.name),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildStaticRow("رقم الهاتف", UserSession.instance.phone),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildEditableRow(
            "البريد الإلكتروني",
            emailController,
            "example@email.com",
            keyboardType: TextInputType.emailAddress,
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildEditableRow(
            "المدينة",
            cityController,
            "أدخل المدينة / العنوان",
          ),
        ],
      ),
    );
  }

  Widget _buildStaticRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.cairo(color: textGrey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? "غير محدد" : value,
            style: GoogleFonts.cairo(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(color: textGrey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: GoogleFonts.cairo(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.cairo(
                    color: textGrey.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.edit_outlined,
          color: textGrey.withValues(alpha: 0.7),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
        label: Text(
          "حفظ",
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: _saveUserData,
      ),
    );
  }

  Widget _buildAccountActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "إجراءات الحساب",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE11D48),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountTypeScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Color(0xFFE11D48),
                ),
                Row(
                  children: [
                    Text(
                      "تسجيل الخروج",
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFE11D48),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFE11D48),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
