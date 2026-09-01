import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // تأكد من إضافة المكتبة في pubspec.yaml

// =========================================================================
// 1. نموذج البيانات (Model) لتوحيد شكل البيانات الثابتة والقادمة من فايربيس
// =========================================================================
class VisitModel {
  final String requestId;
  final String name;
  final String jobTitle;
  final String date;
  final String time;
  final String duration;
  final String price;
  final String location;
  final String rating;
  final bool isVerified;
  final String imageUrl; // صورة الفني
  final String description; // وصف المشكلة من العميل
  final String solution; // الحل المنفذ
  final String laborCost;
  final String materialsCost;
  final String experience;
  final List<String> afterTaskImages; // صور العمل بعد التنفيذ من فايربيس
  final String technicianNotes; // ملاحظات الفني الختامية

  // حقول إضافية لدعم التصميم الجديد (مع قيم افتراضية حتى لا يتأثر الكود القديم)
  final String totalServices;
  final int clientRating;
  final String paymentMethod;
  final String warrantyDuration;
  final String warrantyEndDate;

  VisitModel({
    required this.requestId,
    required this.name,
    required this.jobTitle,
    required this.date,
    required this.time,
    required this.duration,
    required this.price,
    required this.location,
    required this.rating,
    required this.isVerified,
    required this.imageUrl,
    required this.description,
    required this.solution,
    required this.laborCost,
    required this.materialsCost,
    required this.experience,
    this.afterTaskImages = const [],
    this.technicianNotes = "",
    this.totalServices = "1,240 خدمة",
    this.clientRating = 5,
    this.paymentMethod = "نقدي",
    this.warrantyDuration = "6 أشهر",
    this.warrantyEndDate = "15 سبتمبر 2024",
  });
}

// =========================================================================
// 2. الواجهة الرئيسية: سجل الزيارات (Dynamic Visits App)
// =========================================================================
class BasseytaVisitsApp extends StatefulWidget {
  const BasseytaVisitsApp({super.key});

  @override
  State<BasseytaVisitsApp> createState() => _VisitsHistoryPageState();
}

class _VisitsHistoryPageState extends State<BasseytaVisitsApp> {
  int selectedFilterIndex = 0;
  final List<String> filters = ["كل الزيارات", "اليوم", "هذا الأسبوع"];

  List<VisitModel> allVisits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // دالة لجلب البيانات ودمجها مع البيانات الثابتة
  Future<void> _loadData() async {
    // 1. البيانات الثابتة
    List<VisitModel> staticVisits = [
      VisitModel(
        requestId: "SH-8821",
        name: "أحمد المحمدي",
        jobTitle: "فني كهرباء",
        date: "12 أكتوبر 2023",
        time: "10:30 صباحاً",
        duration: "ساعة ونصف",
        price: "450 ج.م",
        paymentMethod: "نقدي",
        location: "شارع النزهة، التجمع الخامس، القاهرة",
        rating: "4.9",
        isVerified: true,
        imageUrl: '',
        description:
            "انقطاع متكرر في التيار الكهربائي في منطقة المطبخ عند تشغيل أكثر من جهاز، مع وجود رائحة احتراق بسيطة بالقرب من لوحة المفاتيح الرئيسية.",
        solution:
            "تم استبدال مفتاح الأمان (Circuit Breaker) بآخر أصلي سعة 32 أمبير، وإعادة توزيع الأحمال على خطوط منفصلة لتجنب زيادة الحمل مستقبلاً.",
        laborCost: "350 ج.م",
        materialsCost: "420 ج.م",
        experience: "8 سنوات",
        totalServices: "1,240 خدمة",
        afterTaskImages: [],
        technicianNotes:
            "مواظبة ممتازة جداً وملتزم بنظافة المكان بعد الانتهاء من العمل. ينصح به بشدة في الأعمال المعقدة.",
      ),
      VisitModel(
        requestId: "MM-9932",
        name: "محمود الشافعي",
        jobTitle: "فني سباكة",
        date: "5 أكتوبر 2023",
        time: "02:00 مساءً",
        duration: "45 دقيقة",
        price: "320 ج.م",
        paymentMethod: "فيزا",
        location: "مدينتي، منطقة B3، مبنى 14",
        rating: "4.8",
        isVerified: true,
        imageUrl: '',
        description: "تسريب مياه أسفل حوض الحمام.",
        solution: "تم تغيير الوصلات المرنة وتثبيت مانع تسرب جديد.",
        laborCost: "200 ج.م",
        materialsCost: "120 ج.م",
        experience: "5 سنوات",
        totalServices: "850 خدمة",
        afterTaskImages: [],
        technicianNotes: "العميل متعاون وتم إنهاء العمل في الوقت المحدد.",
      ),
    ];

    List<VisitModel> firebaseVisits = [];

    try {
      // 2. جلب البيانات ديناميكياً من Firebase
      QuerySnapshot transactionsSnap = await FirebaseFirestore.instance
          .collection('transactions')
          .get();

      for (var doc in transactionsSnap.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String techId = data['technicianId'] ?? '';
        String reqId = data['requestId'] ?? '';
        String amount = data['amount']?.toString() ?? '0';
        String dateStr = data['dateStr'] ?? 'تاريخ غير محدد';
        String serviceName = data['serviceName'] ?? 'خدمة عامة';

        String techName = "فني غير محدد";
        String experience = "غير محدد";
        String location = "موقع غير محدد";
        String description = "لا يوجد وصف";
        String techNotes = "لم يتم ترك ملاحظات إضافية.";
        List<String> taskImages = [];

        // جلب بيانات الفني
        if (techId.isNotEmpty) {
          DocumentSnapshot techDoc = await FirebaseFirestore.instance
              .collection('technicians')
              .doc(techId)
              .get();
          if (techDoc.exists) {
            var techData = techDoc.data() as Map<String, dynamic>;
            techName = techData['fullName'] ?? techName;
            experience = techData['experience'] ?? experience;
          }
        }

        // جلب بيانات الطلب (مهم جداً لجلب الصور والملاحظات)
        if (reqId.isNotEmpty) {
          DocumentSnapshot reqDoc = await FirebaseFirestore.instance
              .collection('requests')
              .doc(reqId)
              .get();
          if (reqDoc.exists) {
            var reqData = reqDoc.data() as Map<String, dynamic>;
            location = reqData['governorate'] ?? location;
            description = reqData['description'] ?? description;
            techNotes = reqData['technicianNotes'] ?? techNotes;

            // سحب الصور المرفوعة من صفحة CompleteTaskPage
            if (reqData['afterTaskImages'] != null) {
              taskImages = List<String>.from(reqData['afterTaskImages']);
            }
          }
        }

        // معالجة آمنة لـ reqId لمنع حدوث RangeError
        String formattedReqId = reqId.isNotEmpty
            ? (reqId.length >= 5
                  ? reqId.substring(0, 5).toUpperCase()
                  : reqId.toUpperCase())
            : "0000";

        firebaseVisits.add(
          VisitModel(
            requestId: formattedReqId,
            name: techName,
            jobTitle: serviceName,
            date: dateStr,
            time: "تم التنفيذ",
            duration: "غير محدد",
            price: "$amount ج.م",
            location: location,
            rating: "4.5",
            isVerified: true,
            imageUrl: '',
            description: description,
            solution: "تم إنجاز الخدمة بنجاح بناءً على تقرير الفني.",
            laborCost: "$amount ج.م",
            materialsCost: "0 ج.م",
            experience: experience,
            afterTaskImages: taskImages,
            technicianNotes: techNotes,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }

    setState(() {
      allVisits = [...firebaseVisits, ...staticVisits];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0056D2)),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "سجل الزيارات",
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "جميع الفنيين الذين زاروا منزلك في مكان واحد",
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildFilterChips(),
                      const SizedBox(height: 24),
                      allVisits.isEmpty
                          ? Center(
                              child: Text(
                                "لا توجد زيارات سابقة.",
                                style: GoogleFonts.cairo(color: Colors.grey),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: allVisits.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                return _buildVisitCard(allVisits[index]);
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          hintText: "ابحث باسم الفني أو نوع الخدمة...",
          hintStyle: GoogleFonts.cairo(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(filters.length, (index) {
          bool isSelected = selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: ChoiceChip(
              label: Text(
                filters[index],
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                setState(() => selectedFilterIndex = index);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF0056D2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVisitCard(VisitModel visit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 65,
                      height: 65,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 35,
                      ),
                    ),
                  ),
                  if (visit.isVerified)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.name,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bolt, size: 18, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Text(
                          visit.jobTitle,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4EDDA).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "اكتملت",
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF155724),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        visit.rating,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetailItem(Icons.calendar_today_outlined, visit.date),
                    _buildDetailItem(Icons.access_time_outlined, visit.time),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildDetailItem(Icons.timer_outlined, visit.duration),
                    _buildDetailItem(
                      Icons.payments_outlined,
                      "${visit.price} (${visit.paymentMethod})",
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.location_on_outlined,
                      visit.location,
                      isFullWidth: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "تقييمك له",
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: List.generate(5, (index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0),
                          child: Icon(
                            Icons.star_border,
                            color: Color(0xFF0056D2),
                            size: 24,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DynamicVisitDetailsApp(visit: visit),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF0056D2),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "عرض التفاصيل",
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF0056D2),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "إعادة الحجز",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String text, {
    bool isFullWidth = false,
  }) {
    Widget content = Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Expanded(child: content);
  }
}

// =========================================================================
// 3. الواجهة الفرعية: التفاصيل الشخصية للزيارة والفني (Dynamic Details)
// =========================================================================
class DynamicVisitDetailsApp extends StatelessWidget {
  final VisitModel visit;

  const DynamicVisitDetailsApp({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              _buildTechnicianProfile(),
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 20),
              _buildServiceDetails(),
              const SizedBox(height: 20),
              _buildFinancialSummary(),
              const SizedBox(height: 20),
              _buildVisitTracking(),
              const SizedBox(height: 20),
              _buildWarrantySection(),
              const SizedBox(height: 20),
              _buildInvoiceSection(),
              const SizedBox(height: 20),
              _buildPrivateNotesSection(),
              const SizedBox(height: 20),
              _buildStatisticsSection(),
              const SizedBox(height: 20),
              _buildReportButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF6F8FA),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF0056D2),
          size: 22,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "تفاصيل الزيارة",
        style: GoogleFonts.cairo(
          color: const Color(0xFF0056D2),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Color(0xFF0056D2)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Color(0xFF0056D2)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTechnicianProfile() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            visit.rating,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            visit.name,
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "طلب #${visit.requestId}",
                            style: GoogleFonts.cairo(
                              color: const Color(0xFF0056D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${visit.jobTitle} • خبير تشطيبات",
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "الخبرة",
                        style: GoogleFonts.cairo(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        visit.experience,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "إجمالي الخدمات",
                        style: GoogleFonts.cairo(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        visit.totalServices,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleAction(Icons.star_border),
        _buildCircleAction(Icons.phone_outlined),
        _buildCircleAction(Icons.email_outlined),
        _buildCircleAction(Icons.sync),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0056D2), width: 1.5),
        color: Colors.white,
      ),
      child: Icon(icon, color: const Color(0xFF0056D2), size: 28),
    );
  }

  Widget _buildServiceDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                decoration: BoxDecoration(
                  color: const Color(0xFF0056D2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                "تفاصيل الخدمة",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "وصف المشكلة",
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            visit.description,
            style: GoogleFonts.cairo(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الحل المنفذ",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF0056D2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  visit.solution,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          visit.afterTaskImages.isNotEmpty
              ? SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: visit.afterTaskImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            visit.afterTaskImages[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildErrorImagePlaceholder(),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildFallbackImage(
                        'assets/image_334268.png',
                        'قبل الإصلاح',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFallbackImage(
                        'assets/image_33426b.png',
                        'بعد الإصلاح',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage(String assetPath, String label) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image, color: Colors.grey, size: 40),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0056D2).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorImagePlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "الملخص المالي والوقت",
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  "وقت التنفيذ",
                  visit.duration,
                  isHighlighted: true,
                  highlightTextColor: const Color(0xFF0056D2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildStatBox("تكلفة العمالة", visit.laborCost)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  "الإجمالي",
                  visit.price,
                  isHighlighted: true,
                  highlightColor: const Color(0xFFD3E3FF),
                  highlightTextColor: const Color(0xFF0056D2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatBox("تكلفة المواد", visit.materialsCost),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String title,
    String value, {
    bool isHighlighted = false,
    Color? highlightColor,
    Color? highlightTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isHighlighted
            ? (highlightColor ?? const Color(0xFFF0F5FF))
            : const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              color: isHighlighted
                  ? (highlightTextColor ?? const Color(0xFF0056D2))
                  : Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: isHighlighted
                  ? (highlightTextColor ?? const Color(0xFF0056D2))
                  : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitTracking() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "تتبع الزيارة",
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTimelineStep(
            "تم قبول الطلب",
            "تم التوزيع لـ أحمد المحمدي",
            "10:15 ص",
            true,
            isFirst: true,
          ),
          _buildTimelineStep(
            "وصول الفني",
            "تم البدء في المعاينة والإصلاح",
            "10:30 ص",
            true,
          ),
          _buildTimelineStep(
            "اكتمال المهمة",
            "تم الدفع وإغلاق البلاغ",
            "11:40 ص",
            true,
          ),
          _buildTimelineStep(
            "تم التقييم",
            "شكراً لثقتكم! تم تقييمكم",
            "12:00 م",
            true,
            isLast: true,
            icon: Icons.star,
            iconColor: const Color(0xFFFFD700),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    String subtitle,
    String time,
    bool isCompleted, {
    bool isFirst = false,
    bool isLast = false,
    IconData? icon,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            time,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 25,
                color: isCompleted
                    ? const Color(0xFF0056D2)
                    : Colors.grey.shade300,
              ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? (icon != null ? Colors.white : const Color(0xFF0056D2))
                    : Colors.white,
                border: Border.all(
                  color: isCompleted
                      ? (iconColor ?? const Color(0xFF0056D2))
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: icon != null
                  ? Icon(icon, size: 14, color: iconColor)
                  : (isCompleted
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 25,
                color: isCompleted
                    ? const Color(0xFF0056D2)
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: isFirst ? 0 : (isLast ? 0 : 8),
              bottom: isLast ? 0 : 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarrantySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: Color(0xFF0056D2),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                "الضمان",
                style: GoogleFonts.cairo(
                  color: const Color(0xFF0056D2),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الحالة",
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "ساري",
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF00C853),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "المدة",
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              Text(
                visit.warrantyDuration,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "تاريخ الانتهاء",
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              Text(
                visit.warrantyEndDate,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0056D2), width: 1.5),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "فتح مطالبة ضمان",
                style: GoogleFonts.cairo(
                  color: const Color(0xFF0056D2),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                "الفاتورة الإلكترونية",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "فاتورة رقم #INV-9901 جاهزة للتحميل.",
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: Colors.black87,
                    ),
                    label: Text(
                      "مشاركة",
                      style: GoogleFonts.cairo(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.download_rounded,
                      size: 18,
                      color: Colors.black87,
                    ),
                    label: Text(
                      "PDF",
                      style: GoogleFonts.cairo(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateNotesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.speaker_notes_outlined,
                color: Color(0xFFB8860B),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                "ملاحظاتي الخاصة",
                style: GoogleFonts.cairo(
                  color: const Color(0xFFB8860B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              visit.technicianNotes.isNotEmpty
                  ? '"${visit.technicianNotes}"'
                  : '"لم تقم بكتابة ملاحظات إضافية لهذه الزيارة."',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 16, color: Color(0xFF0056D2)),
              label: Text(
                "تعديل الملاحظات",
                style: GoogleFonts.cairo(
                  color: const Color(0xFF0056D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "إحصائيات التعامل",
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "مرات الزيارة",
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              Text(
                "3 زيارات",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "إجمالي المدفوع",
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              Text(
                "2,450 ج.م",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "آخر زيارة",
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              Text(
                "منذ شهر",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.info_outline,
          color: Color(0xFFD32F2F),
          size: 20,
        ),
        label: Text(
          "إبلاغ عن مشكلة في هذه الزيارة",
          style: GoogleFonts.cairo(
            color: const Color(0xFFD32F2F),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFFFCDD2),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          backgroundColor: const Color(0xFFFFF5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
