import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/repositories/appointment_repository.dart';
import 'package:basita1/core/models/appointment.dart';
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/features/home/screens/home1.dart';
import 'package:basita1/features/profile/screens/profile2.dart';
import 'package:basita1/features/orders/screens/orders_screen.dart';
import 'package:basita1/features/chat/screens/chat_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedTab = 0;
  final int _currentIndex = 3;
  final Color primaryBlue = const Color(0xFF0D52CB);
  final Color lightBlueBg = const Color(0xFFEFF5FF);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF6B7280);
  final Color bgLight = const Color(0xFFF9FAFB);
  final Color warningRedText = const Color(0xFFDC2626);
  final Color warningRedBg = const Color(0xFFFEF2F2);

  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  final String _currentUserId = UserDataSession.phone;
  List<Appointment> _allAppointments = [];
  bool _isLoading = true;
  StreamSubscription<List<Appointment>>? _appointmentsSub;

  @override
  void initState() {
    super.initState();
    _subscribeToAppointments();
  }

  @override
  void dispose() {
    _appointmentsSub?.cancel();
    super.dispose();
  }

  void _subscribeToAppointments() {
    setState(() => _isLoading = true);
    _appointmentsSub?.cancel();
    _appointmentsSub = _appointmentRepo
        .watchUserAppointments(_currentUserId)
        .listen((appointments) {
      if (!mounted) return;
      setState(() {
        _allAppointments = appointments;
        _isLoading = false;
      });
    }, onError: (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  List<Appointment> get _filteredAppointments {
    final now = DateTime.now();
    switch (_selectedTab) {
      case 0: // Today
        return _allAppointments.where((a) {
          if (a.appointmentDate == null) return false;
          return a.appointmentDate!.year == now.year &&
              a.appointmentDate!.month == now.month &&
              a.appointmentDate!.day == now.day;
        }).toList();
      case 1: // Tomorrow
        final tomorrow = now.add(const Duration(days: 1));
        return _allAppointments.where((a) {
          if (a.appointmentDate == null) return false;
          return a.appointmentDate!.year == tomorrow.year &&
              a.appointmentDate!.month == tomorrow.month &&
              a.appointmentDate!.day == tomorrow.day;
        }).toList();
      case 2: // This week
        final endOfWeek = now.add(const Duration(days: 7));
        return _allAppointments.where((a) {
          if (a.appointmentDate == null) return false;
          return a.appointmentDate!.isAfter(now) &&
              a.appointmentDate!.isBefore(endOfWeek);
        }).toList();
      default:
        return _allAppointments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTabs(),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _buildSectionTitle('مواعيدك', Icons.stars, true),
                  const SizedBox(height: 16),
                  if (_filteredAppointments.isEmpty)
                    _buildEmptyState()
                  else
                    ...List.generate(
                      _filteredAppointments.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAppointmentCard(
                          _filteredAppointments[index],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'لا توجد مواعيد في هذا اليوم',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيظهر هنا المواعيد عند إنشائها',
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'مواعيدي',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'اعرف مواعيدك ووجهاتك بسهولة',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          _buildTabItem(title: 'اليوم', index: 0),
          _buildTabItem(title: 'غدًا', index: 1),
          _buildTabItem(title: 'هذا الأسبوع', index: 2),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? primaryBlue : textGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData? icon, bool isPrimary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: primaryBlue, size: 22),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isCompleted = appointment.status == 'completed';
    final hasClientLocation =
        appointment.clientLatitude != null &&
        appointment.clientLatitude != 0 &&
        appointment.clientLongitude != null &&
        appointment.clientLongitude != 0;
    final hasTechLocation =
        appointment.technicianLatitude != null &&
        appointment.technicianLatitude != 0 &&
        appointment.technicianLongitude != null &&
        appointment.technicianLongitude != 0;
    final dateStr = appointment.appointmentDate != null
        ? '${appointment.appointmentDate!.day}/${appointment.appointmentDate!.month}/${appointment.appointmentDate!.year}'
        : 'غير محدد';
    final timeStr = appointment.appointmentTime ?? 'غير محدد';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lightBlueBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appointment.serviceType,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'العميل: ${appointment.serviceName ?? "غير معروف"}',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(appointment.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildIconText(Icons.access_time, '$dateStr - $timeStr'),
              const SizedBox(width: 16),
              if (appointment.price != null && appointment.price! > 0)
                _buildIconText(
                  Icons.attach_money,
                  '${appointment.price!.toStringAsFixed(0)} ج.م',
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (appointment.clientAddress != null &&
              appointment.clientAddress!.isNotEmpty)
            Row(
              children: [
                _buildIconText(
                  Icons.location_on_outlined,
                  appointment.clientAddress!,
                ),
              ],
            ),
          const SizedBox(height: 16),
          if (isCompleted && hasTechLocation) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_pin_circle, color: const Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'موقعك (الفني): ${appointment.technicianLatitude!.toStringAsFixed(4)}, ${appointment.technicianLongitude!.toStringAsFixed(4)}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (isCompleted && hasClientLocation) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                children: [
                  Icon(Icons.home_outlined, color: primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'موقع العميل: ${appointment.clientLatitude!.toStringAsFixed(4)}, ${appointment.clientLongitude!.toStringAsFixed(4)}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else if (hasClientLocation) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.map_outlined, color: primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الإحداثيات: ${appointment.clientLatitude!.toStringAsFixed(4)}, ${appointment.clientLongitude!.toStringAsFixed(4)}',
                      style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasClientLocation
                      ? () {
                          _openDirections(
                            appointment.clientLatitude!,
                            appointment.clientLongitude!,
                          );
                        }
                      : null,
                  icon: const Icon(
                    Icons.navigation_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    'ابدأ الطريق',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showAppointmentDetails(appointment);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: textGrey,
                  ),
                  child: Text(
                    'التفاصيل',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textDark,
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

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'scheduled':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        label = 'مجدول';
        break;
      case 'confirmed':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        label = 'مؤكد';
        break;
      case 'in_progress':
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFD97706);
        label = 'قيد التنفيذ';
        break;
      case 'completed':
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF16A34A);
        label = 'مكتمل';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        label = 'ملغي';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = textGrey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: textGrey, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: textGrey,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _openDirections(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    try {
      await Supabase.instance.client.functions.invoke(
        'open_url',
        body: {'url': url},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'إحداثيات الموقع: $latitude, $longitude',
              style: GoogleFonts.cairo(),
            ),
            action: SnackBarAction(
              label: 'نسخ',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
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
                    'تفاصيل الموعد',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    'نوع الخدمة',
                    appointment.serviceType,
                    Icons.build,
                  ),
                  _buildDetailItem(
                    'الحالة',
                    appointment.status,
                    Icons.info_outline,
                  ),
                  if (appointment.appointmentDate != null)
                    _buildDetailItem(
                      'التاريخ',
                      '${appointment.appointmentDate!.day}/${appointment.appointmentDate!.month}/${appointment.appointmentDate!.year}',
                      Icons.calendar_today,
                    ),
                  if (appointment.appointmentTime != null)
                    _buildDetailItem(
                      'الوقت',
                      appointment.appointmentTime!,
                      Icons.access_time,
                    ),
                  if (appointment.clientAddress != null)
                    _buildDetailItem(
                      'العنوان',
                      appointment.clientAddress!,
                      Icons.location_on,
                    ),
                  if (appointment.price != null && appointment.price! > 0)
                    _buildDetailItem(
                      'السعر',
                      '${appointment.price!.toStringAsFixed(0)} ج.م',
                      Icons.attach_money,
                    ),
                  if (appointment.clientLatitude != 0)
                    _buildDetailItem(
                      'إحداثيات العميل',
                      '${appointment.clientLatitude!.toStringAsFixed(4)}, ${appointment.clientLongitude!.toStringAsFixed(4)}',
                      Icons.map,
                    ),
                  if (appointment.notes != null &&
                      appointment.notes!.isNotEmpty)
                    _buildDetailItem('ملاحظات', appointment.notes!, Icons.note),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(fontSize: 12, color: textGrey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomNavItem(0, Icons.home_outlined, Icons.home, 'الرئيسية', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainTechnicianScreen(),
                ),
              );
            }),
            _bottomNavItem(
              1,
              Icons.assignment_outlined,
              Icons.assignment,
              'الطلبات',
              () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestsPage()),
                );
              },
            ),
            _bottomNavItem(
              2,
              Icons.chat_bubble_outline,
              Icons.chat_bubble,
              'المحادثات',
              () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatMainPage()),
                );
              },
            ),
            _bottomNavItem(
              3,
              Icons.calendar_today_outlined,
              Icons.calendar_today,
              'المواعيد',
              () {},
            ),
            _bottomNavItem(4, Icons.person_outline, Icons.person, 'حسابي', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    VoidCallback onTap,
  ) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF5FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryBlue : const Color(0xFF4B5563),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected ? primaryBlue : const Color(0xFF4B5563),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
