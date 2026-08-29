import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:geolocator/geolocator.dart'; // 👈 استيراد مكتبة الموقع
import 'package:geocoding/geocoding.dart'; // 👈 استيراد مكتبة تحويل الإحداثيات لعنوان

import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/features/auth/screens/login_screen1.dart';
import 'package:basita1/features/auth/screens/id_verification_screen1.dart';

class TechnicianOnboardingScreen extends StatefulWidget {
  const TechnicianOnboardingScreen({super.key});

  @override
  State<TechnicianOnboardingScreen> createState() =>
      _TechnicianOnboardingScreenState();
}

class _TechnicianOnboardingScreenState
    extends State<TechnicianOnboardingScreen> {
  static const Color brandBlue = Color(0xFF1E75EB);
  static const Color brandDarkBlue = Color(0xFF0053AC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bgGrey = Color(0xFFF8FAFC);
  static const Color fieldBg = Color(0xFFF8FAFC);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // 👈 استبدال متغيرات الاختيارات بـ Controllers للموقع
  final TextEditingController _govController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  String? _selectedExperience;
  String? _selectedSpecialty;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isLoadingLocation = false; // 👈 متغير حالة تحميل الموقع

  final List<String> _experienceList = [
    'سنة واحدة',
    'سنتان',
    '3 - 5 سنوات',
    'أكثر من 5 سنوات',
  ];
  final List<String> _specialtyList = [
    'سباكة',
    'كهرباء',
    'تكييف وتبريد',
    'نقاشة',
    'نجارة',
    'صيانة أجهزة منزلية',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _govController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  // 👈 دالة جلب الموقع من الـ GPS
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
              content: Text(
                'برجاء تفعيل خدمة تحديد الموقع (GPS)',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
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
              const SnackBar(
                content: Text(
                  'تم رفض إذن الوصول للموقع',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
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
                style: TextStyle(fontFamily: 'Cairo'),
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
        String fetchedArea = place.locality?.isNotEmpty == true
            ? place.locality!
            : (place.subAdministrativeArea ?? "");

        setState(() {
          if (fetchedGov.isNotEmpty) {
            _govController.text = fetchedGov;
          }
          if (fetchedArea.isNotEmpty) {
            _areaController.text = fetchedArea;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم تحديد عنوانك الحالي بنجاح!',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء جلب الموقع: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _saveDataAndProceed({required bool isSaveOnly}) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String enteredPhone = _phoneController.text.trim().replaceAll(
          RegExp(r'\s+'),
          '',
        );

        // 👈 توحيد صيغة الرقم ليكون دائماً 01XXXXXXXXX (11 رقم) لتنظيم الداتابيز
        String standardizedPhone = enteredPhone;
        if (standardizedPhone.startsWith('+2')) {
          standardizedPhone = standardizedPhone.substring(2);
        }
        if (standardizedPhone.startsWith('002')) {
          standardizedPhone = standardizedPhone.substring(3);
        }
        if (standardizedPhone.startsWith('201')) {
          standardizedPhone = standardizedPhone.substring(1);
        }
        // لو المستخدم كتب الرقم بيبدأ بـ 1 على طول زي 12225...
        if (standardizedPhone.startsWith('1')) {
          standardizedPhone = '0$standardizedPhone';
        }

        String cleanPhone = standardizedPhone.startsWith('0')
            ? standardizedPhone.substring(1)
            : standardizedPhone;

        // للبحث عن الرقم إذا كان مسجلاً بصيغ مختلفة قديماً
        List<String> possibleFormats = [
          standardizedPhone,
          cleanPhone,
          '+20$cleanPhone',
          '20$cleanPhone',
          '0020$cleanPhone',
        ];

        var query1 = await FirebaseFirestore.instance
            .collection('technicians')
            .where('phoneNumber', whereIn: possibleFormats)
            .get();

        var query2 = await FirebaseFirestore.instance
            .collection('technicians')
            .where('phone', whereIn: possibleFormats)
            .get();

        var docByPhone = await FirebaseFirestore.instance
            .collection('technicians')
            .doc(standardizedPhone) // نبحث بالرقم الموحد
            .get();

        var docByPhoneWithCode = await FirebaseFirestore.instance
            .collection('technicians')
            .doc('+20$cleanPhone')
            .get();

        if (query1.docs.isNotEmpty ||
            query2.docs.isNotEmpty ||
            docByPhone.exists ||
            docByPhoneWithCode.exists) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "هذا الرقم مسجل بالفعل! يرجى تسجيل الدخول بدلاً من إنشاء حساب جديد.",
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        String profileImageUrl = '';
        if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
          try {
            final file = File(_profileImagePath!);
            final fileExtension = p.extension(_profileImagePath!);
            // حفظ الصورة باسم يعتمد على الرقم الموحد
            final fileName =
                '${DateTime.now().millisecondsSinceEpoch}_tech_$standardizedPhone$fileExtension';

            final supabase = Supabase.instance.client;

            await supabase.storage
                .from('user_profiles')
                .upload(
                  fileName,
                  file,
                  fileOptions: const FileOptions(
                    cacheControl: '3600',
                    upsert: false,
                  ),
                );

            profileImageUrl = supabase.storage
                .from('user_profiles')
                .getPublicUrl(fileName);
          } catch (e) {
            throw Exception('فشل رفع صورة الفني إلى Supabase: $e');
          }
        }

        // 👈 تحديث حفظ البيانات لأخذ القيم من الحقول النصية الجديدة والرقم الموحد
        UserDataSession.saveUserData(
          name: _nameController.text.trim(),
          phoneNumber: standardizedPhone, // نستخدم الرقم الموحد هنا
          exp: _selectedExperience ?? '',
          spec: _selectedSpecialty ?? '',
          gov: _govController.text.trim(),
          ar: _areaController.text.trim(),
          imagePath: profileImageUrl,
        );

        await UserDataSession.uploadDataToFirebase();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userType', 'technician');
        await prefs.setString('techName', _nameController.text.trim());
        await prefs.setString(
          'techPhone',
          standardizedPhone,
        ); // وحفظناه محلياً موحد
        await prefs.setString('techExp', _selectedExperience ?? '');
        await prefs.setString('techSpec', _selectedSpecialty ?? '');
        await prefs.setString('techGov', _govController.text.trim());
        await prefs.setString('techArea', _areaController.text.trim());
        if (profileImageUrl.isNotEmpty) {
          await prefs.setString('techImage', profileImageUrl);
        }

        if (isSaveOnly) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "تم حفظ البيانات ورفعها بنجاح!",
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: brandDarkBlue,
              ),
            );
          }
        } else {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const IdentityVerificationStepOne1(),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "حدث خطأ أثناء الرفع: $e",
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgGrey,
        appBar: _buildAppBar(context),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: brandBlue))
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressHeader(),
                        const SizedBox(height: 20),
                        const Text(
                          "أدخل بياناتك الأساسية للبدء في استقبال الطلبات.",
                          style: TextStyle(
                            color: textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildProfileImageCard(),
                        const SizedBox(height: 20),
                        _buildMainFormCard(),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen1(),
                                ),
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: "لديك حساب بالفعل؟ ",
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Cairo',
                                ),
                                children: [
                                  TextSpan(
                                    text: "تسجيل الدخول",
                                    style: TextStyle(
                                      color: brandBlue,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: _isLoading ? null : _buildBottomActions(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgGrey,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: textDark, size: 24),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.maybePop(context);
            },
          ),
          const Text(
            "بسيطة",
            style: TextStyle(
              color: brandDarkBlue,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "الخطوة 1 من 3",
              style: TextStyle(
                color: textDark,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              "25% اكتمل",
              style: TextStyle(
                color: textMuted,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.25,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(brandBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F5F9),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
              image: _profileImagePath != null && _profileImagePath!.isNotEmpty
                  ? DecorationImage(
                      image: FileImage(File(_profileImagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _profileImagePath == null || _profileImagePath!.isEmpty
                ? const Icon(
                    Icons.person_outline_rounded,
                    size: 48,
                    color: textMuted,
                  )
                : null,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              _pickImage();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: brandBlue, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            icon: const Icon(
              Icons.add_a_photo_outlined,
              color: brandBlue,
              size: 18,
            ),
            label: Text(
              _profileImagePath == null ? "إضافة صورة شخصية" : "تغيير الصورة",
              style: const TextStyle(
                color: brandBlue,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("الاسم بالكامل"),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            decoration: _buildInputDecoration("ادخل اسمك"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال الاسم';
              }
              if (value.trim().split(RegExp(r'\s+')).length < 2) {
                return 'يرجى إدخال الاسم ثنائي على الأقل';
              }
              // التأكد من عدم وجود رموز أو أرقام، ويسمح بالحروف العربية والإنجليزية والمسافات فقط
              if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$').hasMatch(value)) {
                return 'الاسم يجب أن يحتوي على حروف فقط (بدون أرقام أو رموز)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFieldLabel("رقم الهاتف"),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            decoration: _buildInputDecoration("رقم هاتفك").copyWith(
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: textMuted,
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال رقم الهاتف';
              }
              // 👈 السماح بصيغة الرقم سواء بدأ بـ 01 أو 1 (للي بيكتبوا 12 على طول)
              if (!RegExp(r'^(01|1)[0125][0-9]{8}$').hasMatch(value.trim())) {
                return 'يرجى إدخال رقم هاتف مصري صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFieldLabel("عدد سنوات الخبرة"),
          DropdownButtonFormField<String>(
            initialValue: _selectedExperience,
            hint: const Text(
              "اختر سنوات الخبرة",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: textMuted,
              ),
            ),
            items: _experienceList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontFamily: 'Cairo')),
                  ),
                )
                .toList(),
            onChanged: (val) {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => _selectedExperience = val);
            },
            decoration: _buildInputDecoration(""),
            validator: (val) => val == null ? 'يرجى اختيار عدد السنوات' : null,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel("التخصص الأساسي"),
          DropdownButtonFormField<String>(
            initialValue: _selectedSpecialty,
            hint: const Text(
              "اختر التخصص",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: textMuted,
              ),
            ),
            items: _specialtyList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontFamily: 'Cairo')),
                  ),
                )
                .toList(),
            onChanged: (val) {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => _selectedSpecialty = val);
            },
            decoration: _buildInputDecoration(""),
            validator: (val) => val == null ? 'يرجى اختيار التخصص' : null,
          ),
          const SizedBox(height: 24),

          // 👈 إضافة قسم العنوان وزر تحديد الموقع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 20, color: brandBlue),
                  const SizedBox(width: 8),
                  const Text(
                    "تفاصيل العنوان",
                    style: TextStyle(
                      color: brandBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (!_isLoadingLocation) {
                    _fillLocationFromGPS();
                  }
                },
                child: Row(
                  children: [
                    if (_isLoadingLocation)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: brandBlue,
                        ),
                      )
                    else
                      const Icon(Icons.my_location, size: 18, color: brandBlue),
                    const SizedBox(width: 4),
                    Text(
                      _isLoadingLocation
                          ? "جاري التحديد..."
                          : "تحديد موقعي الحقيقي",
                      style: const TextStyle(
                        color: brandBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 👈 تحويل المحافظة لـ TextField
          _buildFieldLabel("المحافظة"),
          TextFormField(
            controller: _govController,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            decoration: _buildInputDecoration("ادخل المحافظة"),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'يرجى إدخال المحافظة';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 👈 تحويل المنطقة لـ TextField
          _buildFieldLabel("المنطقة"),
          TextFormField(
            controller: _areaController,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            decoration: _buildInputDecoration("ادخل المنطقة"),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'يرجى إدخال المنطقة';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          color: textDark,
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: textMuted,
        fontSize: 13,
        fontFamily: 'Cairo',
      ),
      filled: true,
      fillColor: fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandBlue, width: 1.5),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _saveDataAndProceed(isSaveOnly: true);
                },
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.save_outlined, color: textMuted, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "حفظ والمتابعة\nلاحقاً",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _saveDataAndProceed(isSaveOnly: false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "التالي",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
