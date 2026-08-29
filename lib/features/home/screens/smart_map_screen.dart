import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:basita1/core/services/order_accept_service.dart';

/// طلب وارد يتم جلب البيانات منه مباشرة من Firestore.
class _MapOrder {
  final String id;
  final String name;
  final String serviceType;
  final String price;
  final String location;
  final String description;
  final String clientPhone;

  const _MapOrder({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.price,
    required this.location,
    required this.description,
    required this.clientPhone,
  });
}

// ==========================================
// صفحة: الطلبات الجديدة + الخريطة (SmartMap)
// ==========================================
class SmartMapScreen extends StatefulWidget {
  const SmartMapScreen({super.key});

  @override
  State<SmartMapScreen> createState() => _TechnicianMapScreenState();
}

class _TechnicianMapScreenState extends State<SmartMapScreen> {
  final Color primaryBlue = const Color(0xFF1E75EB);
  final Color bgLight = const Color(0xFFF8FAFC);

  bool _isOnline = true;
  GoogleMapController? _mapController;
  String? _acceptingRequestId;

  // إحداثيات الطلبات (id -> LatLng) بعد تحويل العنوان إلى إحداثيات
  final Map<String, LatLng> _orderCoordinates = {};
  final Set<String> _geocodingIds = {};

  static const LatLng _cairoCenter = LatLng(30.0444, 31.2357);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // تحويل عنوان الطلب إلى إحداثيات لوضع Marker على الخريطة
  // ------------------------------------------------------------
  Future<void> _geocodeOrder(_MapOrder order) async {
    if (_orderCoordinates.containsKey(order.id) ||
        _geocodingIds.contains(order.id)) {
      return;
    }
    _geocodingIds.add(order.id);
    try {
      final locations = await locationFromAddress(order.location);
      if (locations.isNotEmpty && mounted) {
        setState(() {
          _orderCoordinates[order.id] = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
        });
      }
    } catch (e) {
      debugPrint('Geocoding failed for ${order.id}: $e');
    } finally {
      _geocodingIds.remove(order.id);
    }
  }

  void _moveCameraTo(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 14));
  }

  // ------------------------------------------------------------
  // قبول الطلب (نفس منطق صفحة الطلبات عبر OrderAcceptService)
  // ------------------------------------------------------------
  Future<void> _acceptOrder(_MapOrder order) async {
    setState(() => _acceptingRequestId = order.id);
    try {
      await OrderAcceptService.acceptRequest(
        requestId: order.id,
        clientPhone: order.clientPhone,
        serviceType: order.serviceType,
        serviceName: order.name,
        clientAddress: order.location,
        requestPrice: order.price,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم قبول الطلب بنجاح'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error accepting request: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء قبول الطلب، حاول مرة أخرى'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _acceptingRequestId = null);
    }
  }

  // ------------------------------------------------------------
  // عرض سعر آخر (Bottom Sheet)
  // ------------------------------------------------------------
  void _showOfferPriceSheet(_MapOrder order) {
    final priceController = TextEditingController();
    final messageController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
                            'تقديم عرض سعر آخر',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: bgLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'الطلب: ${order.serviceType}',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'قيمة العرض (ج.م)',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'مثال: 320',
                          filled: true,
                          fillColor: bgLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'رسالة للعميل (اختياري)',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: messageController,
                        maxLines: 2,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'أهلاً بك، سأقوم بإحضار الأدوات اللازمة...',
                          filled: true,
                          fillColor: bgLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (priceController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('برجاء إدخال قيمة العرض'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await OrderAcceptService.acceptRequest(
                                      requestId: order.id,
                                      clientPhone: order.clientPhone,
                                      serviceType: order.serviceType,
                                      serviceName: order.name,
                                      clientAddress: order.location,
                                      requestPrice: order.price,
                                      offerPrice: priceController.text.trim(),
                                      message: messageController.text.trim(),
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(sheetContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'تم إرسال العرض بنجاح إلى العميل!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    debugPrint('Error submitting offer: $e');
                                    setModalState(() => isSubmitting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'حدث خطأ أثناء إرسال العرض',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'إرسال العرض',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
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

  // ------------------------------------------------------------
  // بناء الواجهة
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 8),
              _buildSmartSuggestionBanner(),
              const SizedBox(height: 12),
              _buildMapSection(),
              const SizedBox(height: 8),
              Expanded(child: _buildOrdersStream()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  _isOnline ? 'متصل' : 'غير متصل',
                  style: GoogleFonts.cairo(
                    color: _isOnline ? primaryBlue : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isOnline,
                  onChanged: (val) => setState(() => _isOnline = val),
                  activeThumbColor: Colors.white,
                  activeTrackColor: primaryBlue,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade400,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSuggestionBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'اقتراح ذكي: توجه نحو المعادي، الطلب مرتفع هناك حالياً',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // قسم الخريطة (Google Map + Markers للعملاء)
  // ------------------------------------------------------------
  Widget _buildMapSection() {
    final markers = _orderCoordinates.entries.map((entry) {
      final order = entry.value;
      return Marker(
        markerId: MarkerId(entry.key),
        position: order,
        infoWindow: InfoWindow(
          title: _ordersById[entry.key]?.serviceType ?? 'طلب جديد',
          snippet: _ordersById[entry.key]?.location ?? '',
          onTap: () => _moveCameraTo(order),
        ),
        onTap: () => _moveCameraTo(order),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }).toSet();

    return SizedBox(
      height: 290,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                target: _cairoCenter,
                zoom: 12,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: _buildMapActionButton(
                Icons.my_location,
                color: Colors.white,
                iconColor: primaryBlue,
                onTap: () {
                  if (_orderCoordinates.isNotEmpty) {
                    _moveCameraTo(_orderCoordinates.values.first);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapActionButton(
    IconData icon, {
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          height: 45,
          width: 45,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }

  // خريطة معرفات الطلبات للأمانة العابرة للـ Marker infoWindow
  final Map<String, _MapOrder> _ordersById = {};

  // ------------------------------------------------------------
  // قائمة الطلبات المتاحة (حالة pending) مباشرة من Firestore
  // ------------------------------------------------------------
  Widget _buildOrdersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            text: 'حدث خطأ في تحميل الطلبات',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          String locationStr = 'الإسكندرية';
          if (data['location'] != null) {
            locationStr = data['location'].toString();
          } else if (data['region'] != null && data['governorate'] != null) {
            locationStr = '${data['governorate']}، ${data['region']}';
          } else if (data['region'] != null) {
            locationStr = data['region'].toString();
          }

          String priceStr = 'غير محدد';
          if (data['price'] != null && data['price'].toString().isNotEmpty) {
            priceStr = data['price'].toString();
          } else if (data['budget'] != null &&
              data['budget'].toString().isNotEmpty) {
            priceStr = '${data['budget']} ج.م';
          }

          return _MapOrder(
            id: doc.id,
            name:
                (data['name'] ??
                        data['userName'] ??
                        data['customerName'] ??
                        'مستخدم جديد')
                    .toString(),
            serviceType: (data['title'] ?? 'خدمة صيانة').toString(),
            price: priceStr,
            location: locationStr,
            description: (data['description'] ?? 'لا يوجد وصف متاح').toString(),
            clientPhone:
                (data['phone'] ?? data['userPhone'] ?? '+20 1000000000')
                    .toString(),
          );
        }).toList();

        // تحديث مصادر الإحداثيات وجلب الإحداثيات للطلبات الجديدة
        _ordersById
          ..clear()
          ..addEntries(orders.map((o) => MapEntry(o.id, o)));
        for (final order in orders) {
          _geocodeOrder(order);
        }

        if (orders.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox_outlined,
            text: 'لا توجد طلبات جديدة حالياً',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(orders[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            text,
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

  Widget _buildOrderCard(_MapOrder order) {
    final isAccepting = _acceptingRequestId == order.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryBlue.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF1E75EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.name,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.serviceType,
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                order.price,
                style: GoogleFonts.cairo(
                  color: primaryBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.location,
                  style: GoogleFonts.cairo(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isAccepting ? null : () => _acceptOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isAccepting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'قبول الطلب',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => _showOfferPriceSheet(order),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'عرض سعر آخر',
                    style: TextStyle(
                      color: Color(0xFF1E75EB),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      fontSize: 14,
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
}
