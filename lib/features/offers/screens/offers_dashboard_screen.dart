import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:basita1/features/home/screens/home_screen.dart';
import 'package:basita1/features/chat/screens/chat_screen.dart';
import 'package:basita1/features/profile/screens/profile_screen.dart';
import 'package:basita1/features/family/screens/family_join_screen.dart';

// ==========================================
// 1. نموذج بيانات العرض (OfferModel)
// ==========================================
class OfferModel {
  final String offerId;
  final String requestId;
  final String technicianId;
  final String name;
  final double rating;
  final int reviewsCount;
  final String price;
  final int experienceYears;
  final String arrivalTime;
  final String imagePath;
  final bool isVerified;
  final bool hasGreenArrivalTag;
  final String status; // حالة العرض: 'pending', 'accepted', 'rejected'

  const OfferModel({
    required this.offerId,
    required this.requestId,
    required this.technicianId,
    required this.name,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.experienceYears,
    required this.arrivalTime,
    required this.imagePath,
    this.isVerified = false,
    this.hasGreenArrivalTag = false,
    this.status = 'pending',
  });

  factory OfferModel.fromMap(Map<String, dynamic> map, String docId) {
    // جلب صورة الفني ديناميكياً من قاعدة البيانات أو من بيانات الجلسة (UserDataSession / Supabase) لضمان عدم وجود قيم وهمية
    String resolvedImage =
        map['imagePath'] ??
        map['profileImage'] ??
        map['technicianImage'] ??
        (UserDataSession.profileImagePath.isNotEmpty
            ? UserDataSession.profileImagePath
            : "assets/Container (8).png");

    return OfferModel(
      offerId: docId,
      requestId: map['requestId'] ?? '',
      technicianId: map['technicianId'] ?? UserDataSession.uid ?? '',
      name:
          map['technicianName'] ??
          map['name'] ??
          (UserDataSession.fullName.isNotEmpty
              ? UserDataSession.fullName
              : "فني محترف"),
      rating: (map['rating'] ?? 5.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      price: map['price']?.toString() ?? map['offerPrice']?.toString() ?? "0",
      experienceYears: map['experienceYears'] ?? 3,
      arrivalTime: map['arrivalTime'] ?? "يصل خلال 30 دقيقة",
      imagePath: resolvedImage,
      isVerified: map['isVerified'] ?? true,
      hasGreenArrivalTag: map['hasGreenArrivalTag'] ?? false,
      status: map['status'] ?? 'pending',
    );
  }
}

// ==========================================
// 2. شاشة العروض المتاحة (AvailableOffersScreen)
// ==========================================
class AvailableOffersScreen extends StatefulWidget {
  final String requestId;

  const AvailableOffersScreen({super.key, required this.requestId});

  @override
  State<AvailableOffersScreen> createState() => _AvailableOffersScreenState();
}

class _AvailableOffersScreenState extends State<AvailableOffersScreen> {
  static const Color brandBlue = Color(0xFF0053AC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bgLightGrey = Color(0xFFF8FAFC);
  static const Color borderColor = Color(0xFFF1F5F9);
  static const Color tagBgBlue = Color(0xFFE3EFFC);
  static const Color tagBgGreen = Color(0xFF22C55E);

  // دالة قبول العرض الحقيقي وتحديث Firebase
  Future<void> _acceptOffer(BuildContext context, OfferModel offer) async {
    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offer.offerId)
          .update({'status': 'accepted'});

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
            'status': 'in_progress', // متوافق مع تعديل حالة الفني
            'acceptedTechnicianName': offer.name,
            'acceptedPrice': offer.price,
            'acceptedOfferId': offer.offerId,
            'clientAccepted': true,
          });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم قبول عرض الفني ${offer.name} بنجاح!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء قبول العرض: $e',
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
        backgroundColor: bgLightGrey,
        appBar: _buildTopAppBar(context),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .doc(widget.requestId)
              .snapshots(),
          builder: (context, requestSnapshot) {
            String requestTitle = "تركيب وتصليح مكيف";
            if (requestSnapshot.hasData && requestSnapshot.data!.exists) {
              var reqData =
                  requestSnapshot.data!.data() as Map<String, dynamic>;
              requestTitle =
                  reqData['title'] ??
                  reqData['serviceName'] ??
                  reqData['serviceType'] ??
                  "صيانة منزلية";
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('offers')
                  .where('requestId', isEqualTo: widget.requestId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: brandBlue),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "في انتظار عروض الفنيين...",
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade600,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                List<OfferModel> offers = snapshot.data!.docs.map((doc) {
                  return OfferModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                OfferModel? acceptedOffer;
                try {
                  acceptedOffer = offers.firstWhere(
                    (o) => o.status == 'accepted',
                  );
                } catch (e) {
                  acceptedOffer = null;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(
                      acceptedOffer != null ? 1 : offers.length,
                      requestTitle,
                      acceptedOffer != null,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          return _buildTechnicianCard(
                            context,
                            offers[index],
                            requestTitle,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        bottomNavigationBar: _buildCustomBottomNavBar(context),
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgLightGrey,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "بسيطة",
              style: GoogleFonts.cairo(
                color: brandBlue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: brandBlue,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(int count, String requestTitle, bool hasAccepted) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasAccepted ? "الفني المقبول للطلب" : "العروض المتاحة",
                style: GoogleFonts.cairo(
                  color: textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: hasAccepted
                      ? Colors.green.shade100
                      : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasAccepted ? "تم القبول" : "$count عروض جديدة",
                  style: GoogleFonts.cairo(
                    color: hasAccepted ? Colors.green.shade800 : brandBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'طلب: "$requestTitle"',
            style: GoogleFonts.cairo(color: textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(
    BuildContext context,
    OfferModel offer,
    String requestTitle,
  ) {
    bool isAccepted = offer.status == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccepted ? Colors.green.shade400 : borderColor,
          width: isAccepted ? 2 : 1.5,
        ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: offer.imagePath.startsWith('http')
                        ? Image.network(
                            offer.imagePath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackAvatar(),
                          )
                        : Image.asset(
                            offer.imagePath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackAvatar(),
                          ),
                  ),
                  if (offer.isVerified)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
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
                      offer.name,
                      style: GoogleFonts.cairo(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "${offer.rating}",
                          style: GoogleFonts.cairo(
                            color: textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${offer.reviewsCount} تقييم)",
                          style: GoogleFonts.cairo(
                            color: textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                "${offer.price} ج.م",
                style: GoogleFonts.cairo(
                  color: brandBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      size: 14,
                      color: textDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "خبرة ${offer.experienceYears} سنوات",
                      style: GoogleFonts.cairo(
                        color: textDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: offer.hasGreenArrivalTag
                      ? tagBgGreen.withOpacity(0.15)
                      : tagBgBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 14,
                      color: offer.hasGreenArrivalTag ? tagBgGreen : brandBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      offer.arrivalTime,
                      style: GoogleFonts.cairo(
                        color: offer.hasGreenArrivalTag
                            ? tagBgGreen
                            : brandBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 1. زر محادثة ديناميكي
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DynamicChatScreen(
                            offer: offer,
                            requestId: widget.requestId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2E8F0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: textDark,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "مراسلة",
                          style: GoogleFonts.cairo(
                            color: textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. زر تفاوض
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DynamicNegotiationScreen(
                            offer: offer,
                            requestId: widget.requestId,
                            requestTitle: requestTitle,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: brandBlue, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.handshake_outlined,
                          color: brandBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "تفاوض",
                          style: GoogleFonts.cairo(
                            color: brandBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 3. زر قبول العرض
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => _acceptOffer(context, offer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAccepted ? Colors.green : brandBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isAccepted
                              ? Icons.check_circle
                              : Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAccepted ? "تم القبول" : "قبول",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildFallbackAvatar() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade200,
      child: const Icon(Icons.person, color: textMuted),
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStandardNavItem(
                label: "الرئيسية",
                icon: Icons.home_filled,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleHomeScreen(),
                    ),
                  );
                },
              ),
              _buildCapsuleNavItem(
                label: "طلباتي",
                icon: Icons.local_offer_outlined,
                onTap: () {},
              ),
              _buildStandardNavItem(
                label: "المحادثات",
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatMainPage(),
                    ),
                  );
                },
              ),
              _buildStandardNavItem(
                label: "العائلة",
                icon: Icons.family_restroom_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FamilyGateScreen(),
                    ),
                  );
                },
              ),
              _buildStandardNavItem(
                label: "الحساب",
                icon: Icons.person_outline_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapsuleNavItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF9BC1EC),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF004FB6), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: const Color(0xFF004FB6),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardNavItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF475569), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: const Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 3. دوال عامة للنوافذ المنبثقة (الحظر والإبلاغ)
// =========================================================================
void _showBlockDialog(BuildContext context, String technicianName) {
  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "تأكيد حظر $technicianName",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "تم حظر $technicianName",
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    child: Text(
                      "تأكيد",
                      style: GoogleFonts.cairo(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "إلغاء",
                      style: GoogleFonts.cairo(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showReportDialog(BuildContext context, String technicianName) {
  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "تأكيد الابلاغ عن $technicianName",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "تم الإبلاغ عن $technicianName",
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    child: Text(
                      "تأكيد",
                      style: GoogleFonts.cairo(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "إلغاء",
                      style: GoogleFonts.cairo(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// =========================================================================
// 4. شاشة التفاوض الديناميكية بالكامل (DynamicNegotiationScreen)
// =========================================================================
class DynamicNegotiationScreen extends StatefulWidget {
  final OfferModel offer;
  final String requestId;
  final String requestTitle;

  const DynamicNegotiationScreen({
    super.key,
    required this.offer,
    required this.requestId,
    this.requestTitle = "صيانة وتركيب",
  });

  @override
  State<DynamicNegotiationScreen> createState() =>
      _DynamicNegotiationScreenState();
}

class _DynamicNegotiationScreenState extends State<DynamicNegotiationScreen> {
  static const Color brandBlue = Color(0xFF0075FF);
  static const Color accentGreen = Color(0xFF4BF37B);
  static const Color badgeGreen = Color(0xFF2ECC71);
  static const Color rejectRedBg = Color(0xFFFCE4E4);
  static const Color rejectRedText = Color(0xFFD32F2F);
  static const Color bgLightGrey = Color(0xFFF6F8FB);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  late String currentPrice;
  late String offerStatus;
  final TextEditingController _customPriceController = TextEditingController();

  List<Map<String, dynamic>> chatMessages = [];

  @override
  void initState() {
    super.initState();
    currentPrice = widget.offer.price;
    offerStatus = widget.offer.status;

    String clientName = UserDataSession.fullName.isNotEmpty
        ? UserDataSession.fullName
        : 'عميلنا العزيز';

    chatMessages = [
      {
        "message":
            "أهلاً بك، عرضي المبدئي للخدمة هو ${widget.offer.price} جنيه، تشمل المعاينة والضمان.",
        "time": "الآن",
        "isMe": false,
      },
      {
        "message":
            "أهلاً بك يا ${widget.offer.name}، أنا $clientName وأود التفاوض حول السعر للحصول على أفضل اتفاق مناسب الطرفين.",
        "time": "الآن",
        "isMe": true,
      },
    ];
  }

  @override
  void dispose() {
    _customPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleAcceptProposal() async {
    setState(() {
      offerStatus = "accepted";
    });

    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(widget.offer.offerId)
          .update({'status': 'accepted', 'finalPrice': currentPrice});

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
            'status': 'in_progress',
            'acceptedTechnicianName': widget.offer.name,
            'acceptedPrice': currentPrice,
            'acceptedOfferId': widget.offer.offerId,
            'clientAccepted': true,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "🎉 تم قبول العرض بسعر $currentPrice ج.م بنجاح!",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: badgeGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "حدث خطأ أثناء حفظ القبول: $e",
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRejectProposal() async {
    setState(() {
      offerStatus = "rejected";
    });

    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(widget.offer.offerId)
          .update({'status': 'rejected'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ تم رفض العرض.",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: rejectRedText,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error rejecting offer: $e");
    }
  }

  void _submitNewPrice(String newPrice) {
    setState(() {
      currentPrice = newPrice;
      offerStatus = "pending";
      chatMessages.add({
        "message": "تم تقديم اقتراح سعر جديد: $newPrice ج.م",
        "time": "الآن",
        "isMe": true,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "تم إرسال المقترح الجديد ($newPrice ج.م) للفني!",
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: brandBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLightGrey,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildActiveJobCard(),
                    const SizedBox(height: 16),
                    ...chatMessages.map(
                      (msg) => _buildChatBubble(
                        message: msg["message"],
                        time: msg["time"],
                        isMe: msg["isMe"],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (offerStatus == "pending") _buildWaitingStatusChip(),
                    const SizedBox(height: 16),
                    _buildProposalCard(),
                  ],
                ),
              ),
            ),
            _buildActionCenter(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_forward, color: textDark, size: 26),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: brandBlue, width: 2),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: widget.offer.imagePath.startsWith('http')
                  ? NetworkImage(widget.offer.imagePath) as ImageProvider
                  : AssetImage(widget.offer.imagePath),
              onBackgroundImageError: (_, __) {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.offer.name,
                  style: GoogleFonts.cairo(
                    color: brandBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "فني صيانة معتمد",
                  style: GoogleFonts.cairo(color: textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: brandBlue, size: 26),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "جاري الاتصال بالفني ${widget.offer.name}...",
                  style: GoogleFonts.cairo(),
                ),
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: textDark),
          onSelected: (value) {
            if (value == 'block') {
              _showBlockDialog(context, widget.offer.name);
            } else if (value == 'report') {
              _showReportDialog(context, widget.offer.name);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'block',
              child: Text(
                'حظر',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Text(
                'إبلاغ',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveJobCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "رقم الطلب: #${widget.requestId.substring(0, widget.requestId.length > 6 ? 6 : widget.requestId.length)}",
                style: GoogleFonts.cairo(color: textMuted, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "طلب نشط",
                  style: GoogleFonts.cairo(
                    color: badgeGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.requestTitle,
            style: GoogleFonts.cairo(
              color: textDark,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                "الإسكندرية، مصر",
                style: GoogleFonts.cairo(color: textMuted, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({
    required String message,
    required String time,
    required bool isMe,
  }) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              color: isMe ? brandBlue : const Color(0xFFE8ECF4),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Text(
              message,
              style: GoogleFonts.cairo(
                color: isMe ? Colors.white : textDark,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            time,
            style: GoogleFonts.cairo(color: textMuted, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingStatusChip() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "جاري انتظار الرد وإتمام الاتفاق...",
          style: GoogleFonts.cairo(
            color: textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProposalCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E4F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "العرض الحالي المتاح",
                    style: GoogleFonts.cairo(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: brandBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: brandBlue,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "$currentPrice ج.م",
                style: GoogleFonts.cairo(
                  color: brandBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "هذا السعر يشمل رسوم المعاينة والتوصيل.",
                style: GoogleFonts.cairo(color: textMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              if (offerStatus == "pending")
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleAcceptProposal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: badgeGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "قبول العرض",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleRejectProposal,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: rejectRedText,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "رفض العرض",
                          style: GoogleFonts.cairo(
                            color: rejectRedText,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else if (offerStatus == "accepted")
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: badgeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeGreen),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: badgeGreen),
                      const SizedBox(width: 8),
                      Text(
                        "تم قبول العرض والاتفاق نهائياً",
                        style: GoogleFonts.cairo(
                          color: badgeGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              else if (offerStatus == "rejected")
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: rejectRedBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: rejectRedText),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cancel, color: rejectRedText),
                      const SizedBox(width: 8),
                      Text(
                        "لقد قمت برفض هذا العرض",
                        style: GoogleFonts.cairo(
                          color: rejectRedText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCenter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _customPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "اكتب سعرك المقترح (مثال: 500)",
                        hintStyle: GoogleFonts.cairo(
                          color: textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (_customPriceController.text.trim().isNotEmpty) {
                      _submitNewPrice(_customPriceController.text.trim());
                      _customPriceController.clear();
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: accentGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickPriceChip("525 ج.م"),
                  _buildQuickPriceChip("550 ج.م"),
                  _buildQuickPriceChip("575 ج.م"),
                  _buildQuickPriceChip("تم السعر"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPriceChip(String label) {
    return GestureDetector(
      onTap: () {
        if (label != "تم السعر") {
          _submitNewPrice(label.replaceAll(" ج.م", ""));
        } else {
          _handleAcceptProposal();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 5. شاشة المحادثة الديناميكية المخصصة لكل فني (DynamicChatScreen)
// =========================================================================
class DynamicChatScreen extends StatefulWidget {
  final OfferModel offer;
  final String requestId;

  const DynamicChatScreen({
    super.key,
    required this.offer,
    required this.requestId,
  });

  @override
  State<DynamicChatScreen> createState() => _DynamicChatScreenState();
}

class _DynamicChatScreenState extends State<DynamicChatScreen> {
  static const Color brandBlue = Color(0xFF0075FF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bgLightGrey = Color(0xFFF6F8FB);
  static const Color accentGreen = Color(0xFF4BF37B);

  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> chatMessages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatMessages = [
      {
        "message": "مرحباً، لقد استلمت طلبك وأنا مستعد لتنفيذه.",
        "time": "منذ قليل",
        "isMe": false,
      },
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        chatMessages.add({
          "message": _messageController.text.trim(),
          "time": "الآن",
          "isMe": true,
        });
      });
      _messageController.clear();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLightGrey,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = chatMessages[index];
                  return _buildChatBubble(
                    message: msg["message"],
                    time: msg["time"],
                    isMe: msg["isMe"],
                  );
                },
              ),
            ),
            _buildActionCenter(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_forward, color: textDark, size: 26),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: brandBlue, width: 2),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: widget.offer.imagePath.startsWith('http')
                  ? NetworkImage(widget.offer.imagePath) as ImageProvider
                  : AssetImage(widget.offer.imagePath),
              onBackgroundImageError: (_, __) {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.offer.name,
                  style: GoogleFonts.cairo(
                    color: brandBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "فني صيانة معتمد",
                  style: GoogleFonts.cairo(color: textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: brandBlue, size: 26),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "جاري الاتصال بالفني ${widget.offer.name}...",
                  style: GoogleFonts.cairo(),
                ),
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: textDark),
          onSelected: (value) {
            if (value == 'block') {
              _showBlockDialog(context, widget.offer.name);
            } else if (value == 'report') {
              _showReportDialog(context, widget.offer.name);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'block',
              child: Text(
                'حظر',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Text(
                'إبلاغ',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatBubble({
    required String message,
    required String time,
    required bool isMe,
  }) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              color: isMe ? brandBlue : const Color(0xFFE8ECF4),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Text(
              message,
              style: GoogleFonts.cairo(
                color: isMe ? Colors.white : textDark,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            time,
            style: GoogleFonts.cairo(color: textMuted, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCenter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
        child: Row(
          children: [
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: accentGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: " اكتب هنا ...",
                    hintStyle: GoogleFonts.cairo(
                      color: textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 6. جلسة بيانات المستخدم (UserDataSession)
// =========================================================================
class UserDataSession {
  static String uid = "user_123";
  static String fullName = "شمس الدين ناجي سعد صيام حسن";
  static String profileImagePath =
      ""; // مسار أو رابط صورة البروفايل الحالية للمستخدم
}