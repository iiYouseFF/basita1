import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:basita1/features/payment/screens/instapay_screen.dart';
import 'package:basita1/core/repositories/chat_repository.dart';
import 'package:basita1/core/repositories/appointment_repository.dart';
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/features/home/screens/home1.dart';

// ==========================================
// نموذج بيانات الطلب الديناميكي الشامل
// ==========================================
class RequestModel {
  final String id;
  final String name;
  final String time;
  final String distance;
  final String rating;
  final String serviceType;
  final IconData serviceIcon;
  final String location;
  final String description;
  final String price;
  final String imagePath;
  final List<String> taskImages;
  final List<String> taskSteps;
  final String clientPhone;
  final bool isNetworkImage;
  final String status;

  RequestModel({
    required this.id,
    required this.name,
    required this.time,
    required this.distance,
    required this.rating,
    required this.serviceType,
    required this.serviceIcon,
    required this.location,
    required this.description,
    required this.price,
    required this.imagePath,
    this.taskImages = const [],
    this.taskSteps = const [
      'معاينة موقع العطل بدقة',
      'فحص التوصيلات والأجزاء التالفة',
      'إصلاح أو استبدال القطع المتضررة',
      'اختبار النظام والتأكد من كفاءة العمل',
    ],
    this.clientPhone = '+20 1012345678',
    this.isNetworkImage = false,
    this.status = 'pending',
  });
}

// ==========================================
// نماذج بيانات ملخص المهمة والفاتورة
// ==========================================
class MaterialItemModel {
  String name;
  double quantity;
  double unitPrice;

  MaterialItemModel({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class BasseytaItemModel {
  String name;
  double price;
  String imagePath;
  bool isChecked;

  BasseytaItemModel({
    required this.name,
    required this.price,
    required this.imagePath,
    this.isChecked = false,
  });
}

// ==========================================
// صفحة إتمام المهمة (CompleteTaskPage)
// ==========================================
class CompleteTaskPage extends StatefulWidget {
  final RequestModel request;

  const CompleteTaskPage({super.key, required this.request});

  @override
  State<CompleteTaskPage> createState() => _CompleteTaskPageState();
}

class _CompleteTaskPageState extends State<CompleteTaskPage> {
  final Color primaryBlue = const Color(0xFF0A58CA);
  final Color cardBackground = const Color(0xFFF3F4F6);
  final Color textColor = const Color(0xFF1D1D1D);
  final Color subtitleColor = const Color(0xFF6C757D);

  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _isUploading = false;
  bool _isPickingImage = false;
  final TextEditingController _notesController = TextEditingController();

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'عفواً، الحد الأقصى هو 5 صور فقط',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveDraft() async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.request.id)
          .update({
            'draftNotes': _notesController.text,
            'draftSavedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم حفظ المسودة بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving draft: $e");
    }
  }

  Future<void> _finishTaskAndNavigate() async {
    setState(() {
      _isUploading = true;
    });

    List<String> uploadedImageUrls = [];

    try {
      final supabase = Supabase.instance.client;

      for (File img in _selectedImages) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${img.path.split('/').last}';

        await supabase.storage.from('task_images').upload(fileName, img);

        final imageUrl = supabase.storage
            .from('task_images')
            .getPublicUrl(fileName);
        uploadedImageUrls.add(imageUrl);
      }

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.request.id)
          .update({
            'afterTaskImages': uploadedImageUrls,
            'technicianNotes': _notesController.text,
            'status': 'task_finished_pending_invoice',
          });

      // إتمام الموعد في قاعدة المواعيد (Supabase) وعرض موقع الفني والعميل
      await _completeAppointmentWithLocations();

      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskSummaryScreen(request: widget.request),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء رفع البيانات: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// تحديد موقع الفني (وموقع العميل إن أمكن) ثم إتمام الموعد.
  Future<void> _completeAppointmentWithLocations() async {
    try {
      final appointmentRepo = AppointmentRepository();
      final appointment = await appointmentRepo.getAppointmentByRequestId(
        widget.request.id,
      );
      if (appointment == null) {
        debugPrint("لا يوجد موعد مرتبط بالطلب لتحديثه");
        return;
      }

      double techLat = appointment.technicianLatitude ?? 0;
      double techLng = appointment.technicianLongitude ?? 0;
      double clientLat = appointment.clientLatitude ?? 0;
      double clientLng = appointment.clientLongitude ?? 0;

      if (techLat == 0 && techLng == 0) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            techLat = position.latitude;
            techLng = position.longitude;
          }
        }
      }

      if (clientLat == 0 &&
          clientLng == 0 &&
          appointment.clientAddress != null) {
        try {
          final results = await locationFromAddress(appointment.clientAddress!);
          if (results.isNotEmpty) {
            clientLat = results.first.latitude;
            clientLng = results.first.longitude;
          }
        } catch (e) {
          debugPrint("فشل تحديد موقع العميل من العنوان: $e");
        }
      }

      await appointmentRepo.completeAppointmentAndSetLocations(
        requestId: widget.request.id,
        technicianLatitude: techLat,
        technicianLongitude: techLng,
        clientLatitude: clientLat,
        clientLongitude: clientLng,
      );
    } catch (e) {
      debugPrint("Error completing appointment: $e");
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FA),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "إتمام المهمة",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_forward, color: primaryBlue),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                InkWell(
                  onTap: _saveDraft,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      border: Border.all(
                        color: const Color(0xFFCED4DA),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.save_outlined,
                      color: Color(0xFF6C757D),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _finishTaskAndNavigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "إنهاء المهمة وإرسال التقرير",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.send_outlined,
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
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                "الخطوة النهائية",
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "يرجى توثيق انتهاء العمل وإضافة الملاحظات الأخيرة.",
                style: GoogleFonts.cairo(fontSize: 15, color: subtitleColor),
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: primaryBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "صور العمل بعد التنفيذ",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "بحد أقصى 5 صور",
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 60) / 2,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          border: Border.all(
                            color: const Color(0xFFADB5BD),
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: primaryBlue,
                              size: 35,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "رفع صورة",
                              style: GoogleFonts.cairo(
                                color: subtitleColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...List.generate(_selectedImages.length, (index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImages[index],
                              width:
                                  (MediaQuery.of(context).size.width - 60) / 2,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: InkWell(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              Row(
                children: [
                  Icon(Icons.edit_note, color: primaryBlue, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    "الملاحظات الختامية",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                style: GoogleFonts.cairo(),
                decoration: InputDecoration(
                  hintText:
                      "اكتب أي ملاحظات فنية للعميل أو تقرير للإدارة عن حالة العمل...",
                  hintStyle: GoogleFonts.cairo(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  counterText: "اختياري",
                  counterStyle: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: subtitleColor,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: primaryBlue, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "الملخص التلقائي للعميل",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "سيتم إرسال المستندات التالية للعميل فور الاعتماد:",
                  style: GoogleFonts.cairo(fontSize: 14, color: textColor),
                ),
              ),
              const SizedBox(height: 15),
              _buildSummaryCard(
                title: "الفاتورة الضريبية",
                subtitle: "إلكترونية معتمدة",
                icon: Icons.receipt_long,
                iconBgColor: const Color(0xFFD3E3F8),
                iconColor: primaryBlue,
              ),
              _buildSummaryCard(
                title: "شهادة الضمان",
                subtitle: "صلاحية لمدة عام",
                icon: Icons.verified_outlined,
                iconBgColor: const Color(0xFFFCECD5),
                iconColor: const Color(0xFFD97706),
              ),
              _buildSummaryCard(
                title: "إيصال الدفع",
                subtitle: "تأكيد الاستلام النقدي",
                icon: Icons.payments_outlined,
                iconBgColor: const Color(0xFFD3E3F8),
                iconColor: primaryBlue,
              ),
              _buildSummaryCard(
                title: "ملخص الخدمة",
                subtitle: "تقرير العمل الفني",
                icon: Icons.description_outlined,
                iconBgColor: const Color(0xFFE9ECEF),
                iconColor: const Color(0xFF495057),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => debugPrint("تفاصيل: $title"),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: primaryBlue, size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// صفحة ملخص المهمة (TaskSummaryScreen)
// ==========================================
class TaskSummaryScreen extends StatefulWidget {
  final RequestModel request;

  const TaskSummaryScreen({super.key, required this.request});

  @override
  State<TaskSummaryScreen> createState() => _TaskSummaryScreenState();
}

class _TaskSummaryScreenState extends State<TaskSummaryScreen> {
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF111827);
  static const Color cardBorder = Color(0xFFE5E7EB);

  late double laborCost;

  final List<MaterialItemModel> materials = [
    MaterialItemModel(name: "شحن فريون R22", quantity: 1.5, unitPrice: 120.0),
  ];

  final List<BasseytaItemModel> basseytaItems = [
    BasseytaItemModel(
      name: "خرطوم صرف 3 متر",
      price: 85.0,
      imagePath: 'assets/hose.png',
      isChecked: true,
    ),
    BasseytaItemModel(
      name: "مجموعة مسامير تثبيت",
      price: 25.0,
      imagePath: 'assets/screws.png',
      isChecked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    laborCost =
        double.tryParse(
          widget.request.price.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;
  }

  double _calculateTotalInvoice() {
    double total = laborCost;
    for (var item in materials) {
      total += item.total;
    }
    for (var item in basseytaItems) {
      if (item.isChecked) {
        total += item.price;
      }
    }
    return total;
  }

  void _showAddMaterialDialog() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: "1");
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "إضافة خامة جديدة",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.cairo(),
                    decoration: InputDecoration(
                      labelText: "اسم الخامة / الصنف",
                      labelStyle: GoogleFonts.cairo(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.cairo(),
                    decoration: InputDecoration(
                      labelText: "الكمية",
                      labelStyle: GoogleFonts.cairo(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.cairo(),
                    decoration: InputDecoration(
                      labelText: "سعر الوحدة (ج.م)",
                      labelStyle: GoogleFonts.cairo(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "إلغاء",
                  style: GoogleFonts.cairo(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                onPressed: () {
                  final name = nameController.text.trim();
                  final qty = double.tryParse(qtyController.text) ?? 1.0;
                  final price = double.tryParse(priceController.text) ?? 0.0;

                  if (name.isNotEmpty && price > 0) {
                    setState(() {
                      materials.add(
                        MaterialItemModel(
                          name: name,
                          quantity: qty,
                          unitPrice: price,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "إضافة",
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToInvoice() {
    final double totalAmount = _calculateTotalInvoice();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinalInvoiceScreen(
          request: widget.request,
          totalAmount: totalAmount,
          laborCost: laborCost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "ملخص المهمة والتكاليف",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlue),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "تكلفة الخدمة (مصنعية / عمالة)",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "العمالة والخدمة المباشرة",
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                    Text(
                      "$laborCost ج.م",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "الخامات والمواد الإضافية",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddMaterialDialog,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text(
                      "إضافة خامة",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (materials.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Center(
                    child: Text(
                      "لم يتم إضافة خامات خارجية بعد",
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...materials.asMap().entries.map((entry) {
                  int idx = entry.key;
                  MaterialItemModel m = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cardBorder),
                    ),
                    child: ListTile(
                      title: Text(
                        m.name,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "الكمية: ${m.quantity} × ${m.unitPrice} ج.م",
                        style: GoogleFonts.cairo(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${m.total} ج.م",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                materials.removeAt(idx);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              Text(
                "قطع غيار وتجهيزات من بسيطة",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              ...basseytaItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isChecked ? primaryBlue : cardBorder,
                      width: item.isChecked ? 1.5 : 1.0,
                    ),
                  ),
                  child: CheckboxListTile(
                    activeColor: primaryBlue,
                    title: Text(
                      item.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${item.price} ج.م",
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    value: item.isChecked,
                    onChanged: (val) {
                      setState(() {
                        item.isChecked = val ?? false;
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "الإجمالي المبدئي",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${_calculateTotalInvoice()} ج.م",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _navigateToInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "متابعة لإنشاء الفاتورة",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// صفحة الفاتورة النهائية (FinalInvoiceScreen)
// ==========================================
class FinalInvoiceScreen extends StatefulWidget {
  final RequestModel request;
  final double totalAmount;
  final double laborCost;

  const FinalInvoiceScreen({
    super.key,
    required this.request,
    required this.totalAmount,
    required this.laborCost,
  });

  @override
  State<FinalInvoiceScreen> createState() => _FinalInvoiceScreenState();
}

class _FinalInvoiceScreenState extends State<FinalInvoiceScreen> {
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color lightBlueBg = Color(0xFFEFF6FF);
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color redIcon = Color(0xFFDC2626);
  static const Color lightRedBg = Color(0xFFFEE2E2);

  int _selectedPaymentMethodIndex = 0;
  bool _isConfirming = false;

  late final String invoiceNumber;
  late final String invoiceDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    invoiceNumber = "#BS-${now.millisecondsSinceEpoch.toString().substring(6)}";
    invoiceDate = "${now.day}/${now.month}/${now.year}";
  }

  double get finalTotal {
    double calculated =
        widget.totalAmount + 150 + 200 + (widget.totalAmount * 0.14) - 400;
    return calculated < 0 ? 0 : calculated;
  }

  Future<void> _confirmInvoice() async {
    setState(() {
      _isConfirming = true;
    });

    try {
      final paymentMethods = [
        "نقداً",
        "بطاقة ائتمان",
        "محفظة",
        "إنستا باي",
        "فودافون كاش",
        "Apple Pay",
      ];
      String selectedPayment = paymentMethods[_selectedPaymentMethodIndex];

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.request.id)
          .update({
            'status': 'awaiting_payment',
            'finalTotal': finalTotal,
            'finalPrice': finalTotal,
            'laborCost': widget.laborCost,
            'materialsCost': widget.totalAmount - widget.laborCost,
            'paymentMethod': selectedPayment,
            'invoiceNumber': invoiceNumber,
            'invoiceIssuedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إصدار الفاتورة وتفعيل خيار الدفع للعميل بنجاح!',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TechnicianInvoiceIssuedScreen(
              request: widget.request,
              finalTotal: finalTotal,
              paymentMethod: selectedPayment,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء حفظ الفاتورة: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlue),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "الفاتورة النهائية",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "الرسوم الإضافية",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAdditionalFeeCard(
                "رسوم الانتقالات",
                "150 ج.م",
                Icons.local_shipping,
                primaryBlue,
                lightBlueBg,
              ),
              const SizedBox(height: 12),
              _buildAdditionalFeeCard(
                "خدمة طارئة",
                "200 ج.م",
                Icons.flash_on,
                redIcon,
                lightRedBg,
              ),
              const SizedBox(height: 28),
              Text(
                "تفاصيل الحساب",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildAccountDetailsCard(),
              const SizedBox(height: 28),
              Text(
                "وسيلة الدفع المتوقعة",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodsGrid(),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomConfirmButton(context),
      ),
    );
  }

  Widget _buildAdditionalFeeCard(
    String title,
    String price,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "رقم الفاتورة",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: textGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invoiceNumber,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "التاريخ",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: textGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invoiceDate,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomPaint(
            painter: DashedLinePainter(),
            child: const SizedBox(width: double.infinity, height: 1),
          ),
          const SizedBox(height: 20),
          _buildInvoiceRow("تكلفة العمالة", "${widget.laborCost} ج.م"),
          const SizedBox(height: 12),
          _buildInvoiceRow(
            "تكلفة الخامات والمواد",
            "${widget.totalAmount - widget.laborCost} ج.م",
          ),
          const SizedBox(height: 12),
          _buildInvoiceRow("الرسوم الإضافية", "350 ج.م"),
          const SizedBox(height: 12),
          _buildInvoiceRow("الخصم (برومو كود)", "- 400 ج.م", isDiscount: true),
          const SizedBox(height: 12),
          _buildInvoiceRow(
            "الضريبة (14%)",
            "${(widget.totalAmount * 0.14).toStringAsFixed(2)} ج.م",
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: lightBlueBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "الإجمالي الكلي",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      finalTotal.toStringAsFixed(2),
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "ج.م",
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
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

  Widget _buildInvoiceRow(
    String title,
    String value, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: isDiscount ? primaryBlue : textGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isDiscount ? primaryBlue : textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsGrid() {
    final List<Map<String, dynamic>> paymentMethods = [
      {"title": "نقداً", "icon": Icons.payments_outlined},
      {"title": "بطاقة ائتمان", "icon": Icons.credit_card},
      {"title": "محفظة", "icon": Icons.account_balance_wallet_outlined},
      {"title": "إنستا باي", "icon": Icons.account_balance},
      {"title": "فودافون كاش", "icon": Icons.phone_android},
      {"title": "Apple Pay", "icon": Icons.grid_view_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        return _buildPaymentMethodItem(
          index,
          paymentMethods[index]["title"],
          paymentMethods[index]["icon"],
        );
      },
    );
  }

  Widget _buildPaymentMethodItem(int index, String title, IconData icon) {
    bool isSelected = _selectedPaymentMethodIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethodIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? lightBlueBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primaryBlue : textGrey, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                color: isSelected ? primaryBlue : textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isConfirming ? null : _confirmInvoice,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: _isConfirming
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "تأكيد وإصدار الفاتورة",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// =====================================================================
// صفحة تأكيد إرسال الفاتورة للفني (Technician Invoice Issued Screen)
// =====================================================================
class TechnicianInvoiceIssuedScreen extends StatefulWidget {
  final RequestModel request; // افتراض أن لديك موديل بهذا الاسم
  final double finalTotal;
  final String paymentMethod;

  const TechnicianInvoiceIssuedScreen({
    super.key,
    required this.request,
    required this.finalTotal,
    required this.paymentMethod,
  });

  @override
  State<TechnicianInvoiceIssuedScreen> createState() =>
      _TechnicianInvoiceIssuedScreenState();
}

class _TechnicianInvoiceIssuedScreenState
    extends State<TechnicianInvoiceIssuedScreen> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0056D2);
    const Color textDark = Color(0xFF111827);
    const Color textGrey = Color(0xFF6B7280);
    const Color bgGrey = Color(0xFFF8F9FA);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgGrey,
        appBar: AppBar(
          backgroundColor: bgGrey,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "بسيطة",
            style: GoogleFonts.cairo(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: primaryBlue),
            onPressed: () {
              // TODO: إضافة وظيفة القائمة
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. قسم التأكيد العلوي (Header)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "تم إنهاء الخدمة بنجاح",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "شكرًا لاستخدامك بسيطة، نحب نعرف رأيك في\nالخدمة.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. كارت تقييم العميل
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "قيّم تجربتك مع العميل",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "كيف كانت تجربتك؟",
                        style: GoogleFonts.cairo(fontSize: 13, color: textGrey),
                      ),
                      const SizedBox(height: 16),
                      // النجوم
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = index + 1;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Icon(
                                index < _rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: const Color(
                                  0xFFD4AF37,
                                ), // لون ذهبي للنجوم
                                size: 36,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      // حقل النص الملاحظات
                      TextField(
                        controller: _feedbackController,
                        maxLines: 3,
                        style: GoogleFonts.cairo(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "اكتب ملاحظاتك عن الخدمة...",
                          hintStyle: GoogleFonts.cairo(
                            color: const Color(0xFFA1A1AA),
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE4E4E7),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryBlue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. كارت إتمام الدفع
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "إتمام الدفع",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          color: Color(0xFFF3F4F6),
                          thickness: 1.5,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "المبلغ المطلوب",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: textGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "${widget.finalTotal.toStringAsFixed(0)} ج.م",
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // صندوق معلومات إنستا باي
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: primaryBlue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "يمكنك تحويل قيمة الخدمة بسهولة وأمان عبر InstaPay.",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: textDark,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // زر إنستا باي
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InstaPayScreen(
                                  amount: widget.finalTotal,
                                  requestId: widget.request.id,
                                  technicianId: UserDataSession.phone,
                                  technicianName: widget.request.name,
                                  serviceName: widget.request.serviceType,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            "تحويل المبلغ عبر InstaPay",
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          "بعد إتمام التحويل، اضغط على تأكيد الدفع.",
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: textGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // زر الدفع لمحفظة (تم التعديل للانتقال المباشر للصفحة الرئيسية دون إظهار نافذة قيم تجربتك)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MainTechnicianScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: primaryBlue,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "الدفع لمحفظة",
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// كلاس CustomPainter لرسم الخط الفاصل المتقطع (Dashed Line)
// =====================================================================
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 4, startX = 0;
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.5;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
