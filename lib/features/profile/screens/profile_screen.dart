import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:basita1/features/profile/screens/personal_data_screen.dart';
import 'package:basita1/core/session/user_session.dart';
import 'package:basita1/features/community/screens/community_screen.dart';
import 'package:basita1/features/auth/screens/account_type_screen.dart';
import 'package:basita1/features/auth/screens/account_verification_screen.dart';
import 'package:basita1/features/payment/screens/payment_cards_screen.dart';
import 'package:basita1/features/feedback/screens/coming_soon_screen.dart';
import 'package:basita1/features/payment/screens/bills_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const Color brandBlue = Color(0xFF0053AC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bgLightGrey = Color(0xFFF8FAFC);

  static const Color accountIconColor = Color(0xFF0053AC);
  static const Color homeServiceIconColor = Color(0xFF0F8A5F);
  static const Color communityIconColor = Color(0xFF475569);

  // الاستماع المباشر لمجموعة 'verified' المستقلة للتحقق من حالة التوثيق
  Stream<QuerySnapshot> get _verifiedQueryStream {
    String? fbUid = FirebaseAuth.instance.currentUser?.uid;
    String phone = UserSession.instance.phone.trim();

    Query query = FirebaseFirestore.instance.collection('verified');
    if (fbUid != null && fbUid.isNotEmpty) {
      query = query.where('userId', isEqualTo: fbUid);
    } else if (phone.isNotEmpty) {
      query = query.where('phone', isEqualTo: phone);
    } else {
      query = query.where('userId', isEqualTo: 'none');
    }
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLightGrey,
        appBar: _buildCustomAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeaderCard(),
              const SizedBox(height: 24),
              _buildSectionHeader("إدارة الحساب"),
              _buildSectionCard([
                _buildListTile(
                  icon: Icons.person_outline,
                  iconColor: accountIconColor,
                  title: "البيانات الشخصية",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalDataScreen(),
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.payment_outlined,
                  iconColor: accountIconColor,
                  title: "طرق الدفع",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentCardsScreen(),
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.verified_outlined,
                  iconColor: accountIconColor,
                  title: "توثيق الحساب",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountVerificationScreen(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionHeader("خدمات المنزل"),
              _buildSectionCard([
                _buildListTile(
                  icon: Icons.receipt_long_outlined,
                  iconColor: homeServiceIconColor,
                  title: "الفواتير والمدفوعات",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InvoicesListScreen(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionHeader("المجتمع"),
              _buildSectionCard([
                _buildListTile(
                  icon: Icons.hub_outlined,
                  iconColor: communityIconColor,
                  title: "مجتمعاتي",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunityScreenPerfect(),
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.chat_bubble_outline,
                  iconColor: communityIconColor,
                  title: "منشوراتي",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComingSoonScreen(),
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.quiz_outlined,
                  iconColor: communityIconColor,
                  title: "أسئلتي الفنية",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComingSoonScreen(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionCard([
                _buildListTile(
                  icon: Icons.help_outline,
                  iconColor: communityIconColor,
                  title: "مركز الدعم والمساعدة",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComingSoonScreen(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildLogoutButton(),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "إصدار التطبيق 2.4.0",
                  style: GoogleFonts.cairo(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
      centerTitle: true,
    );
  }

  Widget _buildProfileHeaderCard() {
    return StreamBuilder<QuerySnapshot>(
      // الاستماع لمجموعة 'verified' للتحقق من حالة الموافقة (approved)
      stream: _verifiedQueryStream,
      builder: (context, snapshot) {
        bool isVerified = false;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          var data = snapshot.data!.docs.first.data() as Map<String, dynamic>?;
          if (data != null && data['verificationStatus'] == 'approved') {
            isVerified = true;
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                UserSession.instance.name.isNotEmpty
                                    ? UserSession.instance.name
                                    : "محمد أحمد",
                                style: GoogleFonts.cairo(
                                  color: textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // شارة التوثيق (Verified Badge) وتعمل الآن بلحظية
                            if (isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: brandBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      color: brandBlue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "موثق",
                                      style: GoogleFonts.cairo(
                                        color: brandBlue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Icon(
                                Icons.verified_outlined,
                                color: Colors.grey,
                                size: 18,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "عضو منذ 2023",
                          style: GoogleFonts.cairo(
                            color: textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PersonalDataScreen(), // حط اسم صفحتك هنا
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.edit_note_outlined,
                                color: brandBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "تعديل الملف الشخصي",
                                style: GoogleFonts.cairo(
                                  color: brandBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              (UserSession.instance.profileImagePath != null &&
                                  UserSession
                                      .instance
                                      .profileImagePath!
                                      .isNotEmpty)
                              ? (UserSession.instance.profileImagePath!
                                        .startsWith('http')
                                    ? NetworkImage(
                                            UserSession
                                                .instance
                                                .profileImagePath!,
                                          )
                                          as ImageProvider
                                    : FileImage(
                                            File(
                                              UserSession
                                                  .instance
                                                  .profileImagePath!,
                                            ),
                                          )
                                          as ImageProvider)
                              : const AssetImage(
                                  'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
                                ),
                        ),
                      ),
                      // Positioned(
                      //   bottom: -4,
                      //   right: -4,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 6,
                      //       vertical: 2,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: activeGreen,
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Text(
                      //           "4.9",
                      //           style: GoogleFonts.cairo(
                      //             color: Colors.white,
                      //             fontSize: 10,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //         const SizedBox(width: 2),
                      //         const Icon(
                      //           Icons.star,
                      //           color: Colors.white,
                      //           size: 10,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: textDark,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index < children.length - 1) {
            return Column(
              children: [
                children[index],
                const Divider(
                  height: 1,
                  color: Color(0xFFF1F5F9),
                  indent: 16,
                  endIndent: 16,
                ),
              ],
            );
          }
          return children[index];
        }),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  color: textDark,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFCBD5E1),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          UserSession.instance.clearSession();
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AccountTypeScreen()),
            (route) => false,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: Color(0xFFE11D48), size: 20),
              const SizedBox(width: 8),
              Text(
                "تسجيل الخروج",
                style: GoogleFonts.cairo(
                  color: const Color(0xFFE11D48),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: GoogleFonts.cairo(color: const Color(0xFF0053AC)),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Color(0xFF0053AC)),
          elevation: 1,
        ),
        body: Center(
          child: Text(
            "صفحة $title\n(قيد التطوير)",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 20, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
