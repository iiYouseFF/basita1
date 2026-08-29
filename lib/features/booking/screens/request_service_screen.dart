import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/session/user_session.dart';
import 'package:basita1/core/repositories/chat_repository.dart';
import 'package:basita1/features/offers/screens/offers_dashboard_screen.dart';

class RequestServiceScreen extends StatefulWidget {
  const RequestServiceScreen({super.key});

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  static const Color brandBlue = Color(0xFF0053AC);
  static const Color bgLightGrey = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: brandBlue,
              onPrimary: Colors.white,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عنوان المشكلة على الأقل')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      String uid = currentUser?.uid ?? "unknown_uid";

      String userName = UserSession.instance.name;
      String userPhone = UserSession.instance.phone;
      String userRegion = UserSession.instance.region;
      String userGovernorate = UserSession.instance.governorate;

      if (userName.isEmpty || userPhone.isEmpty) {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          if (userDoc.exists) {
            var data = userDoc.data() as Map<String, dynamic>?;
            if (data != null) {
              userName = userName.isEmpty
                  ? (data['name'] ??
                        data['fullName'] ??
                        data['userName'] ??
                        currentUser?.displayName ??
                        "شمس")
                  : userName;
              userPhone = userPhone.isEmpty
                  ? (data['phone'] ?? data['phoneNumber'] ?? "")
                  : userPhone;
              userRegion = userRegion.isEmpty
                  ? (data['region'] ?? "")
                  : userRegion;
              userGovernorate = userGovernorate.isEmpty
                  ? (data['governorate'] ?? "")
                  : userGovernorate;
            }
          }
        } catch (e) {
          print("Error fetching user from Firestore: $e");
        }
      }

      if (userName.isEmpty) {
        userName = currentUser?.displayName ?? "شمس";
      }

      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final supabase = Supabase.instance.client;
        for (int i = 0; i < _selectedImages.length; i++) {
          try {
            String fileName =
                '$uid/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

            await supabase.storage
                .from('request')
                .upload(
                  fileName,
                  _selectedImages[i],
                  fileOptions: const FileOptions(
                    cacheControl: '3600',
                    upsert: false,
                  ),
                );

            String downloadUrl = supabase.storage
                .from('request')
                .getPublicUrl(fileName);

            imageUrls.add(downloadUrl);
          } catch (e) {
            print("Error uploading image $i to Supabase: $e");
          }
        }
      }

      Map<String, dynamic> requestData = {
        'userId': uid,
        'userName': userName,
        'name': userName,
        'customerName': userName,
        'userPhone': userPhone,
        'phone': userPhone,
        'userRegion': userRegion,
        'region': userRegion,
        'userGovernorate': userGovernorate,
        'governorate': userGovernorate,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'budget': _budgetController.text.trim(),
        'price': _budgetController.text.trim().isNotEmpty
            ? '${_budgetController.text.trim()} ج.م'
            : 'غير محدد',
        'scheduledDate': _dateController.text.trim().isNotEmpty
            ? _dateController.text.trim()
            : 'الآن',
        'status': 'pending',
        'images': imageUrls,
        'taskImages': imageUrls,
        'image': imageUrls.isNotEmpty ? imageUrls.first : null,
        'createdAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('requests')
          .add(requestData);
      String requestId = docRef.id;

      // إنشاء جلسة محادثة مبدئية للطلب فوراً،
      // سيتم ربط الفني بها عند قبوله للطلب دون إنشاء غرفة مكررة.
      try {
        await ChatRepository().getOrCreateRoom(
          clientId: userPhone,
          technicianId: '',
          requestId: requestId,
          serviceType: _titleController.text.trim(),
        );
      } catch (e) {
        print("Error creating chat room: $e");
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AvailableOffersScreen(requestId: requestId),
        ),
      );
    } catch (e) {
      print("Error in _submitRequest: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLightGrey,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "اطلب خدمة جديدة",
                style: GoogleFonts.cairo(
                  color: textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "أخبرنا بما تحتاجه وسنوفر لك أفضل المحترفين.",
                style: GoogleFonts.cairo(color: textMuted, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildSectionLabel("عنوان المشكلة"),
              _buildTextField(
                controller: _titleController,
                hintText: "مثلاً: صيانة تكييف، تسريب مياه...",
                prefixIcon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 20),
              _buildSectionLabel("وصف المشكلة بالتفصيل"),
              _buildTextField(
                controller: _descriptionController,
                hintText:
                    "اشرح لنا المشكلة التي تواجهها لمساعدة الفني في تقييم العمل بدقة...",
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              _buildSectionLabel("الصور والفيديو"),
              _buildMediaUploadSection(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionLabel("تحديد الموقع"),
                  Row(
                    children: [
                      const Icon(Icons.my_location, color: brandBlue, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "موقعي الحالي",
                        style: GoogleFonts.cairo(
                          color: brandBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildLocationSection(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel("الموعد"),
                        _buildTextField(
                          controller: _dateController,
                          hintText: "اختر الموعد",
                          prefixIcon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: _selectDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel("الميزانية (اختياري)"),
                        _buildTextField(
                          controller: _budgetController,
                          hintText: "جنيه",
                          prefixIcon: Icons.account_balance_wallet_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomSubmitButton(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgLightGrey,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: brandBlue, size: 26),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "بسيطة",
        style: GoogleFonts.cairo(
          color: brandBlue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: brandBlue,
            size: 26,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: textDark,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hintText,
    IconData? prefixIcon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: GoogleFonts.cairo(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(color: textMuted, fontSize: 13),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: textMuted, size: 20)
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: brandBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaUploadSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: brandBlue.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    color: brandBlue,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "أضف صور",
                    style: GoogleFonts.cairo(
                      color: brandBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (_selectedImages.isEmpty)
            Container(
              width: 150,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/Background (2).png'),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            ..._selectedImages.map((image) {
              return Container(
                margin: const EdgeInsets.only(left: 12),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  image: DecorationImage(
                    image: FileImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImages.remove(image);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/Border (1).png',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSubmitButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: brandBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.send_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "نشر الطلب",
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
    );
  }
}
