import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:basita1/core/session/user_session.dart';
import 'package:basita1/features/orders/screens/visit_details_page.dart';
import 'package:basita1/features/booking/screens/request_service_screen.dart';

class BasseytaVisitsApp extends StatefulWidget {
  const BasseytaVisitsApp({super.key});

  @override
  State<BasseytaVisitsApp> createState() => _VisitsHistoryPageState();
}

class _VisitsHistoryPageState extends State<BasseytaVisitsApp> {
  int selectedFilterIndex = 0;
  final List<String> filters = ["كل الزيارات", "اليوم", "هذا الأسبوع"];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _completedRequests = [];

  static const List<String> _arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  void initState() {
    super.initState();
    _loadCompletedRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletedRequests() async {
    final String phone = UserSession.instance.phone.trim();
    if (phone.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('userPhone', isEqualTo: phone)
          .orderBy('createdAt', descending: true)
          .get();

      if (!mounted) return;

      setState(() {
        _completedRequests = snapshot.docs
            .map((doc) => {'id': doc.id, ...(doc.data() as Map<String, dynamic>)})
            .where((req) {
              final status = (req['status'] ?? '').toString();
              return status == 'completed' ||
                  status == 'pending_cash' ||
                  status == 'paid' ||
                  (req['isPaid'] == true);
            })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      // نقوم بتحميل قائمة فارغة عند حدوث أي خطأ في الاتصال
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحميل الزيارات: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  DateTime? _requestDate(Map<String, dynamic> req) {
    final dynamic rawPaidAt = req['paidAt'];
    final dynamic rawCreatedAt = req['createdAt'];
    final dynamic dateValue = rawPaidAt ?? rawCreatedAt;
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }
    if (dateValue is DateTime) {
      return dateValue;
    }
    return null;
  }

  bool _dateMatchesFilter(DateTime? date) {
    if (date == null) return selectedFilterIndex == 0;
    final DateTime now = DateTime.now();
    switch (selectedFilterIndex) {
      case 1:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case 2:
        final DateTime weekStart = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        return !date.isBefore(weekStart);
      default:
        return true;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_arabicMonths[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    int hour = date.hour;
    final String period = hour >= 12 ? 'مساءً' : 'صباحاً';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    final String minutes = date.minute.toString().padLeft(2, '0');
    return '$hour:$minutes $period';
  }

  String _serviceName(Map<String, dynamic> req) {
    return (req['title'] ?? req['serviceType'] ?? 'صيانة منزلية').toString();
  }

  String _technicianName(Map<String, dynamic> req) {
    final String name = (req['acceptedTechnicianName'] ??
            req['technicianName'] ??
            '')
        .toString();
    return name.isNotEmpty ? name : (req['name'] ?? req['customerName'] ?? '').toString();
  }

  String _priceText(Map<String, dynamic> req) {
    final dynamic priceValue = req['paidAmount'] ?? req['acceptedPrice'];
    if (priceValue == null) return 'غير محدد';
    return '$priceValue ج.م';
  }

  String _locationText(Map<String, dynamic> req) {
    final List<String> parts = [
      (req['region'] ?? req['userRegion'] ?? '').toString(),
      (req['governorate'] ?? req['userGovernorate'] ?? '').toString(),
    ];
    final List<String> nonEmpty = parts.where((p) => p.isNotEmpty).toList();
    return nonEmpty.isNotEmpty ? nonEmpty.join('، ') : 'غير محدد';
  }

  IconData _serviceIcon(String serviceName) {
    if (serviceName.contains('كهرباء') || serviceName.contains('مكيف')) {
      return Icons.bolt;
    }
    if (serviceName.contains('سباك') || serviceName.contains('حمام')) {
      return Icons.plumbing;
    }
    if (serviceName.contains('نجار')) {
      return Icons.chair;
    }
    if (serviceName.contains('دهان') || serviceName.contains('نقاش')) {
      return Icons.format_paint;
    }
    return Icons.build;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // واجهة من اليمين لليسار
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "سجل الزيارات",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "جميع الفنيين الذين زاروا منزلك في مكان واحد",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSearchBar(),
              const SizedBox(height: 20),

              _buildFilterChips(),
              const SizedBox(height: 24),

              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0056D2)),
      );
    }

    final String query = _searchQuery.trim().toLowerCase();
    final List<Map<String, dynamic>> filtered = _completedRequests
        .where((req) => _dateMatchesFilter(_requestDate(req)))
        .where((req) {
          if (query.isEmpty) return true;
          final String name = _technicianName(req).toLowerCase();
          final String service = _serviceName(req).toLowerCase();
          return name.contains(query) || service.contains(query);
        })
        .toList();

    if (filtered.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "لا توجد زيارات مكتملة بعد",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "عندما يكمل الفني زيارتك ستظهر هنا",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildVisitCard(filtered[index]),
    );
  }

  // الهيدر العلوي (AppBar)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9F9),
      elevation: 0,
      centerTitle: true,
      leadingWidth: 70,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2), size: 28),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        "بسيطة",
        style: TextStyle(
          color: Color(0xFF0056D2),
          fontSize: 26,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.black87,
            size: 28,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // شريط البحث
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "ابحث باسم الفني أو نوع الخدمة...",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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

  // أزرار الفلترة
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(filters.length, (index) {
          bool isSelected = selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilterIndex = index;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF0056D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
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

  // كارت زيارة الفني
  Widget _buildVisitCard(Map<String, dynamic> req) {
    final String requestId = (req['id'] ?? '').toString();
    final String name = _technicianName(req);
    final String serviceName = _serviceName(req);
    final DateTime? visitDate = _requestDate(req);
    final String date = visitDate != null ? _formatDate(visitDate) : 'غير محدد';
    final String time =
        visitDate != null ? _formatTime(visitDate) : 'غير محدد';
    final int ratingValue = (req['clientRating'] as int?) ?? 0;
    final String image = (req['image'] ?? '').toString();
    final bool isNetworkImage = image.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isNetworkImage
                        ? Image.network(
                            image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/Container (22).png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/Container (22).png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _serviceIcon(serviceName),
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            serviceName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F8ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "اكتملت",
                      style: TextStyle(
                        color: Color(0xFF00B050),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        ratingValue > 0 ? ratingValue.toString() : '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // صندوق التفاصيل الرمادي
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetailItem(Icons.calendar_today_outlined, date),
                    _buildDetailItem(Icons.access_time_outlined, time),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.payments_outlined,
                      _priceText(req),
                    ),
                    _buildDetailItem(
                      Icons.person_outline,
                      'فني مختص',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.location_on_outlined,
                      _locationText(req),
                      isFullWidth: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // قسم تقييمك له (النجوم المفرغة كما في الصورة)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "تقييمك له",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showRatingDialog(requestId, ratingValue),
                      child: Row(
                        children: List.generate(
                          5,
                          (index) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(
                              index < ratingValue
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFF0056D2),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // الأزرار السفلية
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BasseytaApp(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0056D2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "عرض التفاصيل",
                      style: TextStyle(
                        color: Color(0xFF0056D2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RequestServiceScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "إعادة الحجز",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  // دالة مساعدة لعناصر التفاصيل
  Widget _buildDetailItem(
    IconData icon,
    String text, {
    bool isFullWidth = false,
  }) {
    Widget content = Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Expanded(child: content);
  }

  Future<void> _showRatingDialog(String requestId, int currentRating) async {
    int selectedRating = currentRating;
    final int? result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text(
                  "تقييمك له",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "كيف تقيم تجربتك مع الفني؟",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => IconButton(
                          icon: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFFFC107),
                            size: 36,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = index + 1;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, null);
                    },
                    child: const Text("إلغاء"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, selectedRating);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056D2),
                    ),
                    child: const Text("حفظ التقييم"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null || result <= 0 || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
            'clientRating': result,
            'clientRatedAt': FieldValue.serverTimestamp(),
          });

      await _reloadRequest(requestId, result);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ تقييمك بنجاح'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ التقييم: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _reloadRequest(String requestId, int rating) async {
    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .get();
      if (!mounted || !doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;
      final int index = _completedRequests.indexWhere(
        (r) => r['id'] == requestId,
      );
      setState(() {
        _completedRequests[index]['clientRating'] = rating;
        _completedRequests[index] = {
          'id': requestId,
          ...data,
        };
      });
    } catch (e) {
      // تجاهل أخطاء إعادة التحميل
    }
  }
}