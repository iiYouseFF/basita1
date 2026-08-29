import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👈 استيراد مكتبة Supabase
import 'package:basita1/core/session/user_session.dart'; // استدعاء ملف الـ UserSession الموحد في تطبيقك

// ==========================================
// 1. Data Models (نموذج بيانات المنشور)
// ==========================================
class ElectricityPostModel {
  final String? id;
  final String authorName;
  final String authorRole;
  final String time;
  final String? title;
  final String content;
  final String? imagePath;
  final int likes;
  final int comments;
  final bool isQuestion;
  final List<String> likedBy;

  ElectricityPostModel({
    this.id,
    required this.authorName,
    required this.authorRole,
    required this.time,
    this.title,
    required this.content,
    this.imagePath,
    required this.likes,
    required this.comments,
    this.isQuestion = false,
    required this.likedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'authorName': authorName,
      'authorRole': authorRole,
      'time': time,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'likes': likes,
      'comments': comments,
      'isQuestion': isQuestion,
      'likedBy': likedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory ElectricityPostModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return ElectricityPostModel(
      id: documentId,
      authorName: map['authorName'] ?? 'مستخدم',
      authorRole: map['authorRole'] ?? 'عضو بالمجتمع',
      time: map['time'] ?? 'الآن',
      title: map['title'],
      content: map['content'] ?? '',
      imagePath: map['imagePath'],
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      isQuestion: map['isQuestion'] ?? false,
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }
}

// ==========================================
// 2. Main Community Screen (صفحة مجتمع النجارة)
// ==========================================
class CarpentryCommunityScreen extends StatefulWidget {
  const CarpentryCommunityScreen({super.key});

  @override
  State<CarpentryCommunityScreen> createState() =>
      _CarpentryCommunityScreenState();
}

class _CarpentryCommunityScreenState extends State<CarpentryCommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color brandBlue = const Color(0xFF0053AC);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  String getFirstName() {
    String rawName = UserSession.instance.name.trim();
    if (rawName.isEmpty) return 'يا فندم';
    return rawName.split(' ').first;
  }

  // --- دالة مساعدة لعرض صورة البروفيسور بأمان ---
  ImageProvider _getProfileImage(String? path) {
    if (path != null && path.isNotEmpty) {
      if (path.startsWith('http')) {
        return NetworkImage(path);
      } else {
        return FileImage(File(path));
      }
    }
    return const AssetImage(
      'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
    );
  }

  // --- دالة تأكيد وحذف المنشور ---
  void _confirmDeletePost(BuildContext context, String? postId) {
    if (postId == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'حذف المنشور',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف هذا المنشور؟ لا يمكن التراجع عن هذه الخطوة.',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await FirebaseFirestore.instance
                      .collection('post_Carpentry')
                      .doc(postId)
                      .delete();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم حذف المنشور بنجاح',
                          style: GoogleFonts.cairo(),
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
                          'حدث خطأ أثناء الحذف: $e',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- دالة عرض نافذة التعليقات ---
  void _showCommentsSheet(BuildContext context, String postId) {
    final TextEditingController _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "التعليقات",
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('post_Carpentry')
                          .doc(postId)
                          .collection('comments')
                          .orderBy('createdAt', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "لا توجد تعليقات بعد. كن أول من يعلق!",
                              style: GoogleFonts.cairo(color: Colors.grey),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var comment = snapshot.data!.docs[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                              ),
                              title: Text(
                                comment['authorName'] ?? 'مستخدم',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                comment['text'] ?? '',
                                style: GoogleFonts.cairo(fontSize: 13),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      left: 16,
                      right: 16,
                      top: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: GoogleFonts.cairo(),
                            decoration: InputDecoration(
                              hintText: "اكتب تعليقاً...",
                              hintStyle: GoogleFonts.cairo(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: brandBlue,
                          child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              if (_commentController.text.trim().isNotEmpty) {
                                FirebaseFirestore.instance
                                    .collection('post_Carpentry')
                                    .doc(postId)
                                    .collection('comments')
                                    .add({
                                      'text': _commentController.text.trim(),
                                      'authorName':
                                          UserSession.instance.name.isNotEmpty
                                          ? UserSession.instance.name
                                          : 'مستخدم',
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });
                                FirebaseFirestore.instance
                                    .collection('post_Carpentry')
                                    .doc(postId)
                                    .update({
                                      'comments': FieldValue.increment(1),
                                    });
                                _commentController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0056D2),
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "مجتمع النجارة",
            style: GoogleFonts.cairo(
              color: const Color(0xFF0053AC),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildCommunityHeader()),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: brandBlue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: brandBlue,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: "المنشورات"),
                      Tab(text: "الأسئلة"),
                      Tab(text: "الأكثر تداولا"),
                      Tab(text: "الفنيون"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsList(),
              _buildQuestionsList(),
              Center(child: Text("الأكثر تداولا", style: GoogleFonts.cairo())),
              Center(child: Text("الفنيون", style: GoogleFonts.cairo())),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_tabController.index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateElectricityQuestionScreen(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateElectricityPostScreen(),
                ),
              );
            }
          },
          backgroundColor: brandBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    String? userProfileImage = UserSession.instance.profileImagePath;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateElectricityPostScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _getProfileImage(userProfileImage),
                ),
                const SizedBox(width: 12),
                Text(
                  "بم تفكر يا ${getFirstName()}؟",
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('post_Carpentry')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "لا توجد منشورات حتى الآن",
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                );
              }

              final posts = snapshot.data!.docs
                  .map(
                    (doc) => ElectricityPostModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .where((post) => !post.isQuestion)
                  .toList();

              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    "لا توجد منشورات حتى الآن",
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return _buildPostCard(posts[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    String? userProfileImage = UserSession.instance.profileImagePath;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateElectricityQuestionScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _getProfileImage(userProfileImage),
                ),
                const SizedBox(width: 12),
                Text(
                  "عندك سؤال يا ${getFirstName()}؟",
                  style: GoogleFonts.cairo(
                    color: Colors.blue.shade800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('post_Carpentry')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "لا توجد أسئلة حتى الآن",
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                );
              }

              final questions = snapshot.data!.docs
                  .map(
                    (doc) => ElectricityPostModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .where((post) => post.isQuestion)
                  .toList();

              if (questions.isEmpty) {
                return Center(
                  child: Text(
                    "لا توجد أسئلة حتى الآن",
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return _buildPostCard(questions[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[300],
              child: Image.asset(
                'assets/image (52).png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            Positioned(
              bottom: -25,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: brandBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.carpenter,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              left: 20,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "انضم للمجتمع",
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 35),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "مجتمع النجارة",
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            "أكبر تجمع للنجارين والمهتمين بأعمال النجارة والأثاث في مصر. نتبادل الخبرات والحلول الفنية وأفكار التصميم والتنفيذ.",
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPostCard(ElectricityPostModel post) {
    bool isMyPost = post.authorName.trim() == UserSession.instance.name.trim();
    String currentUserName = UserSession.instance.name.trim();
    bool isLiked = post.likedBy.contains(currentUserName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: post.isQuestion
            ? Colors.blue.shade50.withOpacity(0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!post.isQuestion) const SizedBox(width: 4),
                        if (!post.isQuestion)
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                      ],
                    ),
                    Text(
                      "${post.authorRole} • ${post.time}",
                      style: GoogleFonts.cairo(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDeletePost(context, post.id);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    if (isMyPost)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'حذف المنشور',
                              style: GoogleFonts.cairo(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuItem<String>(
                      value: 'report',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('إبلاغ', style: GoogleFonts.cairo()),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          if (post.title != null && post.title!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              post.title!,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            post.content,
            style: GoogleFonts.cairo(fontSize: 14, height: 1.5),
          ),
          // 👇 عرض صورة المنشور بأمان (سواء رابط سحابي أو ملف محلي)
          if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: post.imagePath!.startsWith('http')
                  ? Image.network(
                      post.imagePath!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _errorImagePlaceholder(),
                    )
                  : Image.file(
                      File(post.imagePath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _errorImagePlaceholder(),
                    ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (post.id != null && currentUserName.isNotEmpty) {
                    final postRef = FirebaseFirestore.instance
                        .collection('post_Carpentry')
                        .doc(post.id);
                    if (isLiked) {
                      postRef.update({
                        'likes': FieldValue.increment(-1),
                        'likedBy': FieldValue.arrayRemove([currentUserName]),
                      });
                    } else {
                      postRef.update({
                        'likes': FieldValue.increment(1),
                        'likedBy': FieldValue.arrayUnion([currentUserName]),
                      });
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: isLiked ? brandBlue : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${post.likes}",
                        style: GoogleFonts.cairo(
                          color: isLiked ? brandBlue : Colors.grey,
                          fontWeight: isLiked
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () {
                  if (post.id != null) {
                    _showCommentsSheet(context, post.id!);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${post.comments}",
                        style: GoogleFonts.cairo(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorImagePlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

// ==========================================
// 3. Create Post Screen (إنشاء منشورات النجارة مع رفع الصورة لـ Supabase)
// ==========================================
class CreateElectricityPostScreen extends StatefulWidget {
  const CreateElectricityPostScreen({super.key});

  @override
  State<CreateElectricityPostScreen> createState() =>
      _CreateElectricityPostScreenState();
}

class _CreateElectricityPostScreenState
    extends State<CreateElectricityPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final Color brandBlue = const Color(0xFF62A1DF);
  bool _isLoading = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String displayName = "";
  String displayRole = "";
  String? displayImage;

  @override
  void initState() {
    super.initState();
    _fetchUserDataFromSession();
  }

  void _fetchUserDataFromSession() {
    final userSession = UserSession.instance;
    setState(() {
      String rawName = userSession.name.trim();
      displayName = rawName.isNotEmpty ? rawName : "مستخدم جديد";
      displayRole = userSession.placeType.trim().isNotEmpty
          ? userSession.placeType
          : "عام للمجتمع";
      displayImage = userSession.profileImagePath;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // 👇 رفع الصورة إلى Supabase Storage ثم الحفظ في فايربيز
  Future<void> _publishPost() async {
    if (_contentController.text.trim().isEmpty &&
        _titleController.text.trim().isEmpty &&
        _selectedImage == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      // 1. رفع الصورة إلى Supabase Storage إذا تم اختيار صورة
      if (_selectedImage != null) {
        final fileName =
            'carpentry_post_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await Supabase.instance.client.storage
            .from('community_images')
            .upload(
              fileName,
              _selectedImage!,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );

        // 2. الحصول على رابط الصورة المباشر من Supabase
        imageUrl = Supabase.instance.client.storage
            .from('community_images')
            .getPublicUrl(fileName);
      }

      // 3. إنشاء كائن المنشور بالرابط السحابي
      ElectricityPostModel newPost = ElectricityPostModel(
        authorName: displayName,
        authorRole: displayRole,
        time: "الآن",
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imagePath: imageUrl,
        likes: 0,
        comments: 0,
        isQuestion: false,
        likedBy: [],
      );

      // 4. الحفظ في فايربيز (مجموعة النجارة)
      await FirebaseFirestore.instance
          .collection('post_Carpentry')
          .add(newPost.toMap());

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "حدث خطأ أثناء النشر: $e",
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider _getCreateProfileImage(String? path) {
      if (path != null && path.isNotEmpty) {
        if (path.startsWith('http')) {
          return NetworkImage(path);
        } else {
          return FileImage(File(path));
        }
      }
      return const AssetImage(
        'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1E293B), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "إنشاء منشور",
            style: GoogleFonts.cairo(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: SizedBox(
                width: 70,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _publishPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "نشر",
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
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _getCreateProfileImage(displayImage),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.language,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  displayRole.isNotEmpty
                                      ? displayRole
                                      : "عام للمجتمع",
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        hintText: "عنوان المنشور",
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFCBD5E1),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        hintText: "اكتب منشورك هنا...",
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 16,
                          color: const Color(0xFFCBD5E1),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedImage == null)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.videocam_outlined,
                                  size: 40,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF475569),
                    ),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.videocam_outlined,
                      color: Color(0xFF475569),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.poll_outlined,
                      color: Color(0xFF475569),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: Color(0xFF475569),
                    ),
                    onPressed: () {},
                  ),
                  const VerticalDivider(width: 20, thickness: 1),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        "إعدادات الردود",
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF475569),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF475569),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. Create Question Screen (إنشاء أسئلة النجارة)
// ==========================================
class CreateElectricityQuestionScreen extends StatefulWidget {
  const CreateElectricityQuestionScreen({super.key});

  @override
  State<CreateElectricityQuestionScreen> createState() =>
      _CreateElectricityQuestionScreenState();
}

class _CreateElectricityQuestionScreenState
    extends State<CreateElectricityQuestionScreen> {
  final TextEditingController _contentController = TextEditingController();
  final Color brandBlue = const Color(0xFF62A1DF);
  bool _isLoading = false;

  String displayName = "";
  String displayRole = "";
  String? displayImage;

  @override
  void initState() {
    super.initState();
    _fetchUserDataFromSession();
  }

  void _fetchUserDataFromSession() {
    final userSession = UserSession.instance;
    setState(() {
      String rawName = userSession.name.trim();
      displayName = rawName.isNotEmpty ? rawName : "مستخدم جديد";
      displayRole = userSession.placeType.trim().isNotEmpty
          ? userSession.placeType
          : "عام للمجتمع";
      displayImage = userSession.profileImagePath;
    });
  }

  Future<void> _publishQuestion() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      ElectricityPostModel newQuestion = ElectricityPostModel(
        authorName: displayName,
        authorRole: displayRole,
        time: "الآن",
        content: _contentController.text.trim(),
        imagePath: null,
        likes: 0,
        comments: 0,
        isQuestion: true,
        likedBy: [],
      );

      await FirebaseFirestore.instance
          .collection('post_Carpentry')
          .add(newQuestion.toMap());

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "حدث خطأ أثناء طرح السؤال: $e",
              style: GoogleFonts.cairo(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider _getQuestionProfileImage(String? path) {
      if (path != null && path.isNotEmpty) {
        if (path.startsWith('http')) {
          return NetworkImage(path);
        } else {
          return FileImage(File(path));
        }
      }
      return const AssetImage(
        'assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg',
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1E293B), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "اكتب سؤال",
            style: GoogleFonts.cairo(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: SizedBox(
                width: 70,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _publishQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "نشر",
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _getQuestionProfileImage(displayImage),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.language,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            displayRole.isNotEmpty
                                ? displayRole
                                : "عام للمجتمع",
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _contentController,
                maxLines: null,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: "اكتب سؤالك هنا...",
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 18,
                    color: const Color(0xFFCBD5E1),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
