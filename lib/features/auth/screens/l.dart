import 'dart:io';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import 'package:basita1/core/session/user_session.dart';

import 'login_screen.dart';
import 'package:basita1/features/home/screens/home_screen.dart';
import 'package:basita1/features/success/screens/success_screen.dart';

class BaseetaSignUpApp extends StatefulWidget {
  const BaseetaSignUpApp({super.key});

  @override
  State<BaseetaSignUpApp> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<BaseetaSignUpApp> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _govController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  final String _selectedPlaceType = "شقة";
  final List<String> _placeTypes = ["شقة", "فيلا", "مكتب", "محل", "أخرى"];

  bool _isTermsAccepted = false;
  bool _isLoadingLocation = false;
  bool _isSavingData = false;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final Color primaryBlue = const Color(0xFF005CEE);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);
  final Color borderGrey = const Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.phoneNumber != null) {
      _phoneController.text = currentUser.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _govController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة: $e')),
        );
      }
    }
  }

  Future<void> _fillLocationFromGPS() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('برجاء تفعيل خدمة تحديد الموقع (GPS)'),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفض إذن الوصول للموقع')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'إذن الموقع مرفوض دائماً، برجاء تفعيله من إعدادات الجهاز',
              ),
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String fetchedGov = place.administrativeArea ?? "";
        String fetchedCity = place.locality?.isNotEmpty == true
            ? place.locality!
            : (place.subAdministrativeArea ?? "");
        String fetchedRegion = place.subLocality?.isNotEmpty == true
            ? place.subLocality!
            : (place.street ?? "");

        setState(() {
          if (fetchedGov.isNotEmpty) {
            _govController.text = fetchedGov;
          }
          if (fetchedCity.isNotEmpty) {
            _cityController.text = fetchedCity;
          }
          if (fetchedRegion.isNotEmpty) {
            _regionController.text = fetchedRegion;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديد عنوانك الحالي بنجاح!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء جلب الموقع: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  String _generateFamilyId() {
    final random = Random();
    int randomNumber = 1000 + random.nextInt(9000);
    return "BSITA-$randomNumber";
  }

  Future<void> _onCreateAccountPressed() async {
    if (_formKey.currentState!.validate()) {
      if (!_isTermsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب الموافقة على الشروط والأحكام أولاً'),
          ),
        );
        return;
      }

      setState(() => _isSavingData = true);

      try {
        String enteredPhone = _phoneController.text.trim();

        if (enteredPhone.startsWith('1') && enteredPhone.length == 10) {
          enteredPhone = '0$enteredPhone';
        }

        final existingUser = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: enteredPhone)
            .get();

        if (existingUser.docs.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'هذا الرقم مسجل بالفعل! برجاء الانتقال لصفحة تسجيل الدخول.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isSavingData = false);
          return;
        }

        final currentUser = FirebaseAuth.instance.currentUser;
        final usersCollection = FirebaseFirestore.instance.collection('users');
        DocumentReference userDocRef;

        if (currentUser != null) {
          userDocRef = usersCollection.doc(currentUser.uid);
        } else {
          userDocRef = usersCollection.doc();
        }

        String finalUid = userDocRef.id;
        // String generatedFamilyId = _generateFamilyId(); // التعديل هنا: تم إيقاف توليد كود العائلة

        String? profileImageUrl;
        if (_profileImage != null) {
          try {
            final fileExtension = p.extension(_profileImage!.path);
            final fileName =
                '${DateTime.now().millisecondsSinceEpoch}_$finalUid$fileExtension';

            final supabase = Supabase.instance.client;

            await supabase.storage
                .from('user_profiles')
                .upload(
                  fileName,
                  _profileImage!,
                  fileOptions: const FileOptions(
                    cacheControl: '3600',
                    upsert: false,
                  ),
                );

            profileImageUrl = supabase.storage
                .from('user_profiles')
                .getPublicUrl(fileName);
          } catch (e) {
            throw Exception('فشل رفع الصورة الشخصية: $e');
          }
        }

        Map<String, dynamic> userData = {
          'uid': finalUid,
          'familyId':
              '', // التعديل هنا: تم تعيين قيمة فارغة ليتم توجيه المستخدم لشاشة إنشاء/انضمام لعائلة
          'name': _nameController.text.trim(),
          'phone': enteredPhone,
          'email': _emailController.text.trim(),
          'governorate': _govController.text.trim(),
          'city': _cityController.text.trim(),
          'region': _regionController.text.trim(),
          'placeType': _selectedPlaceType,
          'profileImagePath': profileImageUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'verificationData': {},
        };

        await userDocRef.set(userData);

        UserSession.instance.saveUserData(
          name: userData['name'],
          phone: userData['phone'],
          email: userData['email'],
          governorate: userData['governorate'],
          city: userData['city'],
          region: userData['region'],
          placeType: userData['placeType'],
          profileImagePath: userData['profileImagePath'],
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userType', 'user');
        await prefs.setString('userId', userData['uid'] ?? '');
        await prefs.setString('userName', userData['name'] ?? '');
        await prefs.setString('userPhone', userData['phone'] ?? '');
        await prefs.setString('userEmail', userData['email'] ?? '');
        await prefs.setString('userGov', userData['governorate'] ?? '');
        await prefs.setString('userCity', userData['city'] ?? '');
        await prefs.setString('userRegion', userData['region'] ?? '');
        await prefs.setString('userPlaceType', userData['placeType'] ?? '');
        if (userData['profileImagePath'] != null) {
          await prefs.setString('userImage', userData['profileImagePath']);
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSavingData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "بسيطة",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "إنشاء حساب",
                    style: TextStyle(
                      color: textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "أنشئ حسابك وابدأ في طلب أفضل الفنيين بكل سهولة.",
                    style: TextStyle(color: textGrey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: borderGrey, width: 2),
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _profileImage == null
                                ? Icon(
                                    Icons.person_outline,
                                    size: 40,
                                    color: borderGrey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickImage,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _profileImage == null
                                    ? Icons.camera_alt_outlined
                                    : Icons.edit,
                                size: 18,
                                color: primaryBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _profileImage == null
                                    ? "إضافة صورة (اختياري)"
                                    : "تغيير الصورة",
                                style: TextStyle(
                                  color: primaryBlue,
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
                  const SizedBox(height: 30),

                  _buildLabel("الاسم بالكامل", isRequired: true),
                  _buildTextField(
                    controller: _nameController,
                    hint: "ادخل اسمك الحقيقي",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "الاسم مطلوب";
                      }
                      if (value.trim().split(RegExp(r'\s+')).length < 2) {
                        return "يجب إدخال الاسم ثنائياً على الأقل";
                      }
                      if (!RegExp(
                        r'^[\u0600-\u06FFa-zA-Z\s]+$',
                      ).hasMatch(value)) {
                        return "الاسم يجب أن يحتوي على حروف فقط (بدون أرقام أو رموز)";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("رقم الهاتف", isRequired: true),
                  _buildPhoneField(),
                  const SizedBox(height: 16),

                  _buildLabel("البريد الإلكتروني (اختياري)"),
                  _buildTextField(
                    controller: _emailController,
                    hint: "example@gmail.com",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(value.trim())) {
                          return "بريد إلكتروني غير صالح (يجب أن يكون باللغة الإنجليزية)";
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 4, height: 20, color: primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            "تفاصيل العنوان",
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _isLoadingLocation ? null : _fillLocationFromGPS,
                        child: Row(
                          children: [
                            if (_isLoadingLocation)
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryBlue,
                                ),
                              )
                            else
                              Icon(
                                Icons.my_location,
                                size: 18,
                                color: primaryBlue,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              _isLoadingLocation
                                  ? "جاري التحديد..."
                                  : "تحديد موقعي الحقيقي",
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("المحافظة", isRequired: true),
                  _buildTextField(
                    controller: _govController,
                    hint: "ادخل المحافظة",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "المحافظة مطلوبة";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("المدينة", isRequired: true),
                            _buildTextField(
                              controller: _cityController,
                              hint: "ادخل المدينة",
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "مطلوب";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("المنطقة", isRequired: true),
                            _buildTextField(
                              controller: _regionController,
                              hint: "ادخل المنطقة",
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "مطلوب";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isTermsAccepted,
                          onChanged: (val) =>
                              setState(() => _isTermsAccepted = val!),
                          activeColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.notoSansArabic(
                              color: textDark,
                              fontSize: 13,
                            ),
                            children: [
                              const TextSpan(text: "أوافق على "),
                              TextSpan(
                                text: "الشروط والأحكام",
                                style: TextStyle(
                                  color: primaryBlue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                              const TextSpan(text: " و "),
                              TextSpan(
                                text: "سياسة الخصوصية.",
                                style: TextStyle(
                                  color: primaryBlue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSavingData ? null : _onCreateAccountPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: _isSavingData
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "إنشاء الحساب",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "لديك حساب بالفعل؟ ",
                        style: TextStyle(color: textGrey, fontSize: 14),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        ),
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.notoSansArabic(
              color: textDark,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            children: [
              TextSpan(text: text),
              if (isRequired)
                const TextSpan(
                  text: "*",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textGrey.withValues(alpha: 0.5)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "رقم الهاتف مطلوب";
        if (!RegExp(r'^(01|1)[0-9]{9}$').hasMatch(value.trim()) &&
            !value.contains('+')) {
          return "رقم الهاتف غير صحيح، يجب أن يبدأ بـ 01 أو 1";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: "01XXXXXXXXX",
        hintStyle: TextStyle(color: textGrey.withValues(alpha: 0.5)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            border: Border(left: BorderSide(color: borderGrey)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "+20",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
