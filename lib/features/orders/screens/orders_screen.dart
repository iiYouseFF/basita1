import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:basita1/features/home/screens/home1.dart';
import 'package:basita1/features/ai_assistant/screens/ai1_screen.dart';
import 'package:basita1/features/orders/screens/sale_screen.dart';
import 'package:basita1/features/profile/screens/profile2.dart';
import 'package:basita1/features/orders/screens/complete_task_page.dart';
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/core/services/order_accept_service.dart';
import 'package:basita1/features/booking/screens/appointments_screen.dart';

// ==========================================
// الصفحة الرئيسية للطلبات (RequestsPage)
// ==========================================
class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['الطلبات', 'قيد التنفيذ', 'مكتملة', 'ملغاة'];
  String _searchQuery = '';

  final List<RequestModel> _localRequestsList = [
    RequestModel(
      id: 'req_1',
      name: 'سارة المنصوري',
      time: 'منذ ١٥ دقيقة',
      distance: '2.5 كم',
      rating: '4.9',
      serviceType: 'سباكة - صيانة حنفيات',
      serviceIcon: Icons.plumbing,
      location: 'المعادي، شارع ٩، عمارة ٤٢، الطابق الثالث',
      description:
          'يوجد تسريب في حنفية المطبخ الرئيسية، المياه تتدفق بغزارة تحت الحوض. نحتاج فني للمعاينة والإصلاح فوراً.',
      price: '٣٥٠ ج.م',
      imagePath: 'assets/Background+Shadow (6).png',
      taskImages: ['assets/Background+Shadow (6).png'],
      clientPhone: '+20 1098765432',
      status: 'pending',
    ),
    RequestModel(
      id: 'req_2',
      name: 'أحمد كمال',
      time: 'منذ ٤٠ دقيقة',
      distance: '1.2 كم',
      rating: '4.7',
      serviceType: 'كهرباء - صيانة لوحة مفاتيح',
      serviceIcon: Icons.electrical_services,
      location: 'التجمع الخامس، حي الياسمين ٤',
      description:
          'انقطاع متكرر في التيار الكهربائي عن غرف النوم، أظن أن هناك مشكلة في أحد القواطع الأوتوماتيكية.',
      price: '٥٠٠ ج.م',
      imagePath: 'assets/Background+Shadow (8).png',
      taskImages: ['assets/Background+Shadow (8).png'],
      clientPhone: '+20 1122334455',
      status: 'pending',
    ),
    RequestModel(
      id: 'req_3',
      name: 'ليلى يوسف',
      time: 'منذ ساعة',
      distance: '3.8 كم',
      rating: '5.0',
      serviceType: 'تكييف - شحن فريون',
      serviceIcon: Icons.ac_unit,
      location: 'مدينة نصر، حي الواحة، عمارة ١٠',
      description:
          'التكييف يعمل ولكن لا يبرد الغرفة نهائياً. الفلتر نظيف، أظن أنه يحتاج لشحن فريون أو فحص للتسريب.',
      price: '٨٥٠ ج.م',
      imagePath: 'assets/Background+Shadow (7).png',
      taskImages: ['assets/Background+Shadow (7).png'],
      clientPhone: '+20 1234567890',
      status: 'pending',
    ),
  ];

  void _addNewRequestFromUser() {
    setState(() {
      _localRequestsList.insert(
        0,
        RequestModel(
          id: 'req_${DateTime.now().millisecondsSinceEpoch}',
          name: 'عمر الشناوي',
          time: 'الآن',
          distance: '1.5 كم',
          rating: '4.8',
          serviceType: 'نجارة - تصليح أبواب',
          serviceIcon: Icons.carpenter,
          location: 'الإسكندرية، المنتزه',
          description:
              'الباب الرئيسي لا يغلق بشكل صحيح ويحتاج إلى ضبط المفصلات وتغيير الكالون في أسرع وقت.',
          price: '٢٥٠ ج.م',
          imagePath:
              'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
          taskImages: [],
          clientPhone: '+20 1555667788',
          status: 'pending',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildTabs(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('requests')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<RequestModel> combinedList = List.from(
                      _localRequestsList,
                    );

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final remoteRequests = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        List<String> uploadedImages = [];
                        if (data['images'] != null) {
                          uploadedImages = List<String>.from(data['images']);
                        } else if (data['taskImages'] != null) {
                          uploadedImages = List<String>.from(
                            data['taskImages'],
                          );
                        }

                        String mainImage =
                            data['image'] ??
                            (uploadedImages.isNotEmpty
                                ? uploadedImages.first
                                : 'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg');

                        String locationStr = 'الإسكندرية';
                        if (data['location'] != null) {
                          locationStr = data['location'];
                        } else if (data['region'] != null &&
                            data['governorate'] != null) {
                          locationStr =
                              '${data['governorate']}، ${data['region']}';
                        } else if (data['region'] != null) {
                          locationStr = data['region'];
                        }

                        String priceStr = 'غير محدد';
                        if (data['price'] != null &&
                            data['price'].toString().isNotEmpty) {
                          priceStr = data['price'].toString();
                        } else if (data['budget'] != null &&
                            data['budget'].toString().isNotEmpty) {
                          priceStr = '${data['budget']} ج.م';
                        }

                        return RequestModel(
                          id: doc.id,
                          name:
                              data['name'] ??
                              data['userName'] ??
                              data['customerName'] ??
                              'مستخدم جديد',
                          time: data['scheduledDate'] ?? data['time'] ?? 'الآن',
                          distance: data['distance'] ?? '1.0 كم',
                          rating: data['rating']?.toString() ?? '4.9',
                          serviceType: data['title'] ?? 'خدمة صيانة',
                          serviceIcon: Icons.handyman,
                          location: locationStr,
                          description:
                              data['description'] ?? 'لا يوجد وصف متاح',
                          price: priceStr,
                          imagePath: mainImage,
                          taskImages: uploadedImages,
                          clientPhone:
                              data['phone'] ??
                              data['userPhone'] ??
                              '+20 1000000000',
                          isNetworkImage: mainImage.startsWith('http'),
                          status: data['status'] ?? 'pending',
                        );
                      }).toList();

                      combinedList.insertAll(0, remoteRequests);
                    }

                    String currentStatus = 'pending';
                    if (_selectedTabIndex == 1) currentStatus = 'in_progress';
                    if (_selectedTabIndex == 2) currentStatus = 'completed';
                    if (_selectedTabIndex == 3) currentStatus = 'cancelled';

                    final filteredList = combinedList.where((req) {
                      bool matchesStatus = req.status == currentStatus;
                      bool matchesSearch =
                          req.name.contains(_searchQuery) ||
                          req.serviceType.contains(_searchQuery) ||
                          req.description.contains(_searchQuery);
                      return matchesStatus && matchesSearch;
                    }).toList();

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد طلبات في هذا القسم حالياً',
                              style: GoogleFonts.cairo(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final request = filteredList[index];
                        return _buildRequestCard(request);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNewRequestFromUser,
          backgroundColor: const Color(0xFF005CEE),
          label: Text(
            'محاكاة طلب جديد',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: (UserDataSession.profileImagePath.isNotEmpty)
                    ? (UserDataSession.profileImagePath.startsWith('http')
                          ? NetworkImage(UserDataSession.profileImagePath)
                                as ImageProvider
                          : AssetImage(UserDataSession.profileImagePath))
                    : const AssetImage(
                        'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
                      ),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 12),
              Text(
                UserDataSession.fullName.isNotEmpty
                    ? UserDataSession.fullName
                    : (FirebaseAuth.instance.currentUser?.displayName ??
                          'بسيطة | الفني'),
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF005CEE),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              size: 28,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'البحث عن طلب أو خدمة...',
                  hintStyle: GoogleFonts.cairo(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Color(0xFF4A5568)),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF93C5FD)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _tabs[index],
                  style: GoogleFonts.cairo(
                    color: isSelected
                        ? const Color(0xFF0056D2)
                        : Colors.grey.shade700,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: request.isNetworkImage
                    ? NetworkImage(request.imagePath) as ImageProvider
                    : AssetImage(request.imagePath),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          request.rating,
                          style: GoogleFonts.cairo(color: Colors.grey.shade700),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  ${request.distance}',
                          style: GoogleFonts.cairo(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.time,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                request.serviceIcon,
                color: const Color(0xFF005CEE),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                request.serviceType,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.location,
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: const Color(0xFF4A5568),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الميزانية المتوقعة',
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
              Text(
                request.price,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF005CEE),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005CEE),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    try {
                      await OrderAcceptService.acceptRequest(
                        requestId: request.id,
                        clientPhone: request.clientPhone,
                        serviceType: request.serviceType,
                        serviceName: request.name,
                        clientAddress: request.location,
                        requestPrice: request.price,
                      );
                    } catch (e) {
                      debugPrint("Error accepting request: $e");
                    }
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskDetailsPage(request: request),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'قبول',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE5E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      _localRequestsList.removeWhere((r) => r.id == request.id);
                    });
                  },
                  child: Text(
                    'رفض',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailsScreen(request: request),
                      ),
                    );
                  },
                  child: Text(
                    'عرض التفاصيل',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF4A5568),
                      fontWeight: FontWeight.bold,
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            "الرئيسية",
            Icons.home_filled,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainTechnicianScreen(),
                ),
              );
            },
          ),
          _buildNavItem(
            "الطلبات",
            Icons.assignment_outlined,
            isActive: true,
            onTap: () {},
          ),
          _buildNavItem(
            "المحادثات",
            Icons.chat_bubble_outline,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SmartAssistantScreen(),
                ),
              );
            },
          ),
          _buildNavItem(
            "المواعيد",
            Icons.calendar_today_outlined,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentsScreen(),
                ),
              );
            },
          ),
          _buildNavItem(
            "حسابي",
            Icons.person_outline,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String label,
    IconData icon, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 8,
          vertical: 8,
        ),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFF82A9FF).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF00308F)
                  : const Color(0xFF4A5568),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF00308F)
                    : const Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// صفحة عرض التفاصيل وتقديم العروض (OrderDetailsScreen)
// =========================================================================
class OrderDetailsScreen extends StatefulWidget {
  final RequestModel request;

  const OrderDetailsScreen({super.key, required this.request});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  static const Color primaryBlue = Color(0xFF0056D2);
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color aiBgColor = Color(0xFFEFF6FF);

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _warrantyController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _durationController.dispose();
    _arrivalController.dispose();
    _warrantyController.dispose();
    _messageController.dispose();
    super.dispose();
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
            icon: const Icon(Icons.share_outlined, color: textDark),
            onPressed: () {},
          ),
          title: const Text(
            "تفاصيل الطلب",
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: primaryBlue),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerInfo(context),
              const SizedBox(height: 24),
              const Text(
                "وصف المشكلة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.request.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildProblemImages(context),
              const SizedBox(height: 24),
              _buildDetailsGrid(context),
              const SizedBox(height: 24),
              _buildAICard(context),
              const SizedBox(height: 24),
              _buildOffersStatsCard(context),
              const SizedBox(height: 24),
              _buildMapSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: _buildStickyBottomBar(context),
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.request.rating,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    " ${widget.request.name} ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "12 طلب مكتمل • عضو منذ يناير 2023",
                style: TextStyle(fontSize: 12, color: textGrey),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: widget.request.isNetworkImage
                    ? NetworkImage(widget.request.imagePath) as ImageProvider
                    : AssetImage(widget.request.imagePath),
                onBackgroundImageError: (_, __) {},
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: primaryBlue,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProblemImages(BuildContext context) {
    if (widget.request.taskImages.isEmpty) {
      return Container(
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            'لا توجد صور مرفقة للمشكلة',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.request.taskImages.length,
        itemBuilder: (context, index) {
          final img = widget.request.taskImages[index];
          final bool isNet = img.startsWith('http');
          return Container(
            width: 100,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              image: DecorationImage(
                image: isNet
                    ? NetworkImage(img) as ImageProvider
                    : AssetImage(img),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridCard(
                context,
                "الخدمة المطلوبة",
                widget.request.serviceType,
                widget.request.serviceIcon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGridCard(
                context,
                "الموعد المطلوب",
                widget.request.time,
                Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGridCard(
                context,
                "الميزانية المتوقعة",
                widget.request.price,
                Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGridCard(
                context,
                "السعر المقترح",
                widget.request.price,
                Icons.insert_chart_outlined,
                isBlueText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    bool isBlueText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: textGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isBlueText ? primaryBlue : textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAICard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: aiBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.auto_awesome, color: primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                "توصية الذكاء الاصطناعي",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "بناءً على وصف المشكلة والصور، يُتوقع أن تستغرق عملية الإصلاح حوالي ساعة.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: textDark, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text(
                "إنشاء عرض بالذكاء الاصطناعي",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersStatsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          const Text(
            "إحصائيات العروض المقدمة",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textGrey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatBar(
                "الأعلى",
                "400",
                100,
                Colors.grey.shade200,
                textDark,
              ),
              _buildStatBar(
                "المتوسط",
                "310",
                70,
                const Color(0xFF93C5FD),
                primaryBlue,
                isBold: true,
              ),
              _buildStatBar("الأقل", "250", 40, Colors.grey.shade200, textDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(
    String label,
    String value,
    double height,
    Color bgColor,
    Color textColor, {
    bool isBold = false,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: textGrey)),
      ],
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/Image+Background.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey.shade300),
                ),
                Container(color: Colors.black.withOpacity(0.3)),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.request.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text("فتح في الخرائط"),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: primaryBlue),
                const SizedBox(width: 4),
                const Text(
                  "20 دقيقة",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: textDark,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.request.distance,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await OrderAcceptService.acceptRequest(
                      requestId: widget.request.id,
                      clientPhone: widget.request.clientPhone,
                      serviceType: widget.request.serviceType,
                      serviceName: widget.request.name,
                      clientAddress: widget.request.location,
                      requestPrice: widget.request.price,
                    );
                  } catch (e) {
                    debugPrint("Error accepting request: $e");
                  }
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaskDetailsPage(request: widget.request),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E7FF),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "قبول (${widget.request.price})",
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _showOfferBottomSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "تقديم عرض",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfferBottomSheet(BuildContext context) {
    bool provideMaterials = false;
    bool priceIncludesMaterials = true;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "تقديم عرض سعر",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: bgLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildLabel("قيمة العرض (ج.م)"),
                      _buildTextField(
                        hint: "مثال: 320",
                        keyboardType: TextInputType.number,
                        controller: _priceController,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("مدة العمل"),
                                _buildTextField(
                                  hint: "ساعة واحدة",
                                  controller: _durationController,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("وقت الوصول"),
                                _buildTextField(
                                  hint: "خلال 30 دقيقة",
                                  controller: _arrivalController,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("الضمان (أيام)"),
                      _buildTextField(
                        hint: "مثال: 30 يوم",
                        keyboardType: TextInputType.number,
                        controller: _warrantyController,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("رسالة للعميل (اختياري)"),
                      _buildTextField(
                        hint: "أهلاً بك، سأقوم بإحضار الأدوات اللازمة...",
                        maxLines: 3,
                        controller: _messageController,
                      ),
                      const SizedBox(height: 24),
                      _buildCheckboxOption(
                        "أستطيع توفير الخامات اللازمة",
                        provideMaterials,
                        () {
                          setModalState(() {
                            provideMaterials = !provideMaterials;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildCheckboxOption(
                        "السعر يشمل تكلفة الخامات",
                        priceIncludesMaterials,
                        () {
                          setModalState(() {
                            priceIncludesMaterials = !priceIncludesMaterials;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (_priceController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('برجاء إدخال قيمة العرض'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setModalState(() {
                                    isSubmitting = true;
                                  });

                                  try {
                                    final uid = UserDataSession.phone.isNotEmpty
                                        ? UserDataSession.phone
                                        : (FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.uid ??
                                              'unknown_uid');
                                    final techName =
                                        UserDataSession.fullName.isNotEmpty
                                        ? UserDataSession.fullName
                                        : (FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.displayName ??
                                              'بسيطة | الفني');

                                    await FirebaseFirestore.instance
                                        .collection('offers')
                                        .add({
                                          'requestId': widget.request.id,
                                          'technicianId': uid,
                                          'technicianName': techName,
                                          'price': _priceController.text,
                                          'duration': _durationController.text,
                                          'arrivalTime':
                                              _arrivalController.text,
                                          'warranty': _warrantyController.text,
                                          'message': _messageController.text,
                                          'provideMaterials': provideMaterials,
                                          'priceIncludesMaterials':
                                              priceIncludesMaterials,
                                          'rating': 4.9,
                                          'reviewsCount': 15,
                                          'experienceYears': 4,
                                          'isVerified': true,
                                          'imagePath':
                                              'assets/Container (8).png',
                                          'status': 'pending',
                                          'createdAt':
                                              FieldValue.serverTimestamp(),
                                        });

                                    await FirebaseFirestore.instance
                                        .collection('requests')
                                        .doc(widget.request.id)
                                        .set({
                                          'hasOffers': true,
                                          'status': 'offer_submitted',
                                          'clientAccepted': false,
                                          'lastOfferTime':
                                              FieldValue.serverTimestamp(),
                                        }, SetOptions(merge: true));

                                    setModalState(() {
                                      isSubmitting = false;
                                    });
                                    if (context.mounted) Navigator.pop(context);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'تم إرسال العرض بنجاح إلى العميل!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }

                                    _priceController.clear();
                                    _durationController.clear();
                                    _arrivalController.clear();
                                    _warrantyController.clear();
                                    _messageController.clear();
                                  } catch (e) {
                                    setModalState(() {
                                      isSubmitting = false;
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'حدث خطأ أثناء الإرسال: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "إرسال العرض",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textGrey, fontSize: 14),
        filled: true,
        fillColor: bgLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(
    String title,
    bool isChecked,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: textDark)),
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: isChecked ? primaryBlue : textGrey,
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// صفحة بدء تنفيذ الطلب الفعلي (TaskDetailsPage)
// =======================================================================
class TaskDetailsPage extends StatefulWidget {
  final RequestModel request;

  const TaskDetailsPage({super.key, required this.request});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  bool _isLoadingWorkStart = false;
  bool _isPickingImage = false; // متغير للحماية ضد already_active

  Future<void> _startWork() async {
    setState(() {
      _isLoadingWorkStart = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.request.id)
          .update({'workStarted': true, 'status': 'in_progress'});

      setState(() {
        _isLoadingWorkStart = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم بدء العمل بنجاح! تم إشعار العميل وتحديث الحالة.',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingWorkStart = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء بدء العمل: $e',
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
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .doc(widget.request.id)
              .snapshots(),
          builder: (context, snapshot) {
            bool isWorkStarted = false;
            bool isClientAccepted = false;

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data != null) {
                isWorkStarted = data['workStarted'] ?? false;
                isClientAccepted =
                    (data['clientAccepted'] == true) ||
                    (data['status'] == 'client_accepted') ||
                    (data['status'] == 'in_progress') ||
                    (data['status'] == 'accepted_by_client');
              }
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildMapSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildClientInfoCard(isClientAccepted),
                        const SizedBox(height: 24),
                        if (!isClientAccepted && !isWorkStarted)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'زر بدء العمل معطل حالياً بانتظار موافقة وقبول العميل من تطبيق المستخدم.',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.amber.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isWorkStarted
                                  ? Colors.green
                                  : (isClientAccepted
                                        ? const Color(0xFF005CEE)
                                        : Colors.grey.shade400),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: (isWorkStarted || !isClientAccepted)
                                ? null
                                : _startWork,
                            icon: _isLoadingWorkStart
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    isWorkStarted
                                        ? Icons.check_circle
                                        : (isClientAccepted
                                              ? Icons.play_arrow
                                              : Icons.lock_outline),
                                    color: Colors.white,
                                    size: 28,
                                  ),
                            label: Text(
                              isWorkStarted
                                  ? 'العمل جاري الآن'
                                  : (isClientAccepted
                                        ? 'بدء العمل'
                                        : 'في انتظار قبول العميل'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'خطوات المهمة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTaskStepsGrid(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CompleteTaskPage(request: widget.request),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF4A5568),
                            ),
                            label: const Text(
                              'إنهاء المهمة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A5568),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2), size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        UserDataSession.fullName.isNotEmpty
            ? UserDataSession.fullName
            : (FirebaseAuth.instance.currentUser?.displayName ??
                  'بسيطة | الفني'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF005CEE),
        ),
      ),
      actions: [
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            size: 28,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMapSection() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/a.png'),
              fit: BoxFit.cover,
            ),
            color: Color(0xFFE2E8F0),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          transform: Matrix4.translationValues(0, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF005CEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_outlined,
                  color: Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'المسافة المتبقية',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
                  ),
                  Text(
                    widget.request.distance,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005CEE),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfoCard(bool isClientAccepted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: widget.request.isNetworkImage
                    ? NetworkImage(widget.request.imagePath) as ImageProvider
                    : AssetImage(widget.request.imagePath),
                onBackgroundImageError: (_, __) {},
                backgroundColor: const Color(0xFF82A9FF).withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.request.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.request.serviceType,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A5568),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isClientAccepted
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isClientAccepted ? 'تم قبول العميل' : 'في انتظار القبول',
                  style: TextStyle(
                    color: isClientAccepted
                        ? const Color(0xFF15803D)
                        : const Color(0xFFD97706),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF005CEE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF005CEE),
                    size: 20,
                  ),
                  label: const Text(
                    'دردشة',
                    style: TextStyle(
                      color: Color(0xFF005CEE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF005CEE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF005CEE),
                    size: 20,
                  ),
                  label: const Text(
                    'اتصال',
                    style: TextStyle(
                      color: Color(0xFF005CEE),
                      fontWeight: FontWeight.bold,
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

  Widget _buildTaskStepsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildStepCard(
          icon: Icons.camera_alt_outlined,
          title: 'رفع صور قبل العمل',
          onTap: () {
            // حماية اختيار الصور من التكرار السريع لتجنب خطأ already_active
            if (_isPickingImage) return;
            setState(() {
              _isPickingImage = true;
            });
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _isPickingImage = false;
                });
              }
            });
          },
        ),
        _buildStepCard(
          icon: Icons.camera_alt_outlined,
          title: 'رفع صور بعد العمل',
          onTap: () {
            if (_isPickingImage) return;
            setState(() {
              _isPickingImage = true;
            });
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _isPickingImage = false;
                });
              }
            });
          },
        ),
        _buildStepCard(
          icon: Icons.receipt_long_outlined,
          title: 'إصدار فاتورة',
          onTap: () {},
        ),
        _buildStepCard(
          icon: Icons.payments_outlined,
          title: 'طلب الدفع',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF005CEE), size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              "الرئيسية",
              Icons.home_outlined,
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainTechnicianScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              "الطلبات",
              Icons.assignment,
              isActive: true,
              onTap: () {},
            ),
            _buildNavItem(
              "المحادثات",
              Icons.chat_bubble_outline,
              isActive: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SmartAssistantScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              "المواعيد",
              Icons.calendar_today_outlined,
              isActive: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentsScreen(),
                  ),
                );
              },
            ),
            _buildNavItem(
              "حسابي",
              Icons.person_outline,
              isActive: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    String label,
    IconData icon, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFF93C5FD),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF00308F)
                  : const Color(0xFF4B5563),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF00308F)
                    : const Color(0xFF4B5563),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
