import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:basita1/core/repositories/chat_repository.dart';
import 'package:basita1/core/models/chat_room.dart' as model;
import 'package:basita1/core/models/chat_message.dart' as msg;
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/features/orders/screens/sale_screen.dart';
import 'package:basita1/features/home/screens/home1.dart';
import 'package:basita1/features/orders/screens/orders_screen.dart';
import 'package:basita1/features/profile/screens/profile2.dart';

// دالة تنسيق الوقت لتظهر بشكل احترافي (ص/م)
String formatTime(DateTime time) {
  int hour = time.hour;
  int minute = time.minute;
  String amPm = hour >= 12 ? 'م' : 'ص';
  hour = hour % 12;
  hour = hour == 0 ? 12 : hour;
  String minuteStr = minute < 10 ? '0$minute' : minute.toString();
  return '$hour:$minuteStr $amPm';
}

class TechnicianChatsApp extends StatelessWidget {
  const TechnicianChatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'محادثات الفني - بسيطة',
      theme: ThemeData(
        primaryColor: const Color(0xFF005CEE),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: child!,
        );
      },
      home: const TechnicianChatsMainScreen(),
    );
  }
}

// ==========================================
// 1. شاشة المحادثات الرئيسية للفني (الواجهة الخارجية)
// ==========================================
class TechnicianChatsMainScreen extends StatefulWidget {
  const TechnicianChatsMainScreen({super.key});

  @override
  State<TechnicianChatsMainScreen> createState() =>
      _TechnicianChatsMainScreenState();
}

class _TechnicianChatsMainScreenState extends State<TechnicianChatsMainScreen> {
  final Color primaryBlue = const Color(0xFF005CEE);
  final TextEditingController _searchController = TextEditingController();
  final ChatRepository _chatRepo = ChatRepository();

  // استدعاء رقم الفني من الجلسة
  final String _currentUserId = UserDataSession.phone;

  int _selectedIndex = 2;
  List<model.ChatRoom> _allRooms = [];
  List<model.ChatRoom> _filteredRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  void _loadChatRooms() async {
    try {
      final rooms = await _chatRepo.getUserChatRooms(_currentUserId);
      if (mounted) {
        setState(() {
          _allRooms = rooms;
          _filteredRooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterChats(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredRooms = _allRooms;
      } else {
        _filteredRooms = _allRooms.where((room) {
          final serviceMatch =
              room.serviceType?.toLowerCase().contains(query.toLowerCase()) ??
              false;
          return serviceMatch;
        }).toList();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainTechnicianScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RequestsPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BasiytaApp()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AccountScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          "المحادثات",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث بتصميم مدمج
          Container(
            color: primaryBlue,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterChats,
                decoration: const InputDecoration(
                  hintText: "البحث في المحادثات...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : _filteredRooms.isEmpty
                ? _buildEmptyState()
                : StreamBuilder<List<model.ChatRoom>>(
                    stream: _chatRepo.watchUserChatRooms(_currentUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          _allRooms.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(color: primaryBlue),
                        );
                      }
                      final rooms = snapshot.data ?? _filteredRooms;

                      if (rooms.isEmpty) return _buildEmptyState();

                      return ListView.separated(
                        itemCount: rooms.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: Color(0xFFF0F0F0),
                          height: 1,
                          indent: 80,
                        ),
                        itemBuilder: (context, index) {
                          return _buildChatTile(rooms[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "لا توجد محادثات",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ستظهر رسائل العملاء هنا عند وجود طلبات نشطة",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(model.ChatRoom room) {
    return FutureBuilder<List<msg.ChatMessage>>(
      future: _chatRepo.getMessages(room.id, limit: 1),
      builder: (context, msgSnapshot) {
        final messages = msgSnapshot.data ?? [];
        final lastMsg = messages.isNotEmpty ? messages.first : null;

        return FutureBuilder<int>(
          future: _chatRepo.getUnreadCount(room.id, _currentUserId),
          builder: (context, unreadSnapshot) {
            final unreadCount = unreadSnapshot.data ?? 0;
            // اسم العميل أو نوع الخدمة
            final clientName = room.serviceType ?? 'عميل بسيطة';

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TechnicianChatDetailScreen(
                      room: room,
                      currentUserId: _currentUserId,
                    ),
                  ),
                ).then((_) => _loadChatRooms());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: const AssetImage(
                            'assets/avatar_placeholder.png', // صورة افتراضية
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  clientName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (lastMsg?.createdAt != null)
                                Text(
                                  formatTime(lastMsg!.createdAt!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: unreadCount > 0
                                        ? const Color(0xFF25D366)
                                        : Colors.grey.shade500,
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (lastMsg != null &&
                                  lastMsg.senderId == _currentUserId)
                                Icon(
                                  lastMsg.isRead ? Icons.done_all : Icons.check,
                                  size: 16,
                                  color: lastMsg.isRead
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              if (lastMsg != null &&
                                  lastMsg.senderId == _currentUserId)
                                const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  lastMsg?.message ?? "لا توجد رسائل بعد...",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF25D366),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
          },
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorColor: primaryBlue.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            );
          }
          return TextStyle(color: Colors.grey.shade600, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryBlue, size: 26);
          }
          return IconThemeData(color: Colors.grey.shade600, size: 26);
        }),
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'الطلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'المحادثات',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'المحفظة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. شاشة المحادثة المباشرة (ستايل الواتساب للفني)
// ==========================================
class TechnicianChatDetailScreen extends StatefulWidget {
  final model.ChatRoom room;
  final String currentUserId;

  const TechnicianChatDetailScreen({
    super.key,
    required this.room,
    required this.currentUserId,
  });

  @override
  State<TechnicianChatDetailScreen> createState() =>
      _TechnicianChatDetailScreenState();
}

class _TechnicianChatDetailScreenState
    extends State<TechnicianChatDetailScreen> {
  final Color primaryBlue = const Color(0xFF005CEE);
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatRepository _chatRepo = ChatRepository();
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    // جعل الرسائل مقروءة فور فتح الشات
    _chatRepo.markAsRead(widget.room.id, widget.currentUserId);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text;
    _messageController.clear();
    setState(() {
      isTyping = false;
    });

    _chatRepo.sendMessage(
      roomId: widget.room.id,
      senderId: widget.currentUserId,
      senderType: 'technician', // إرسال كـ فني
      message: text,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // لون خلفية الواتساب
      appBar: AppBar(
        backgroundColor: primaryBlue,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.serviceType ?? 'العميل',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "متصل الآن",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/chat_bg.png"), // خلفية المحادثة (الواتس)
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<msg.ChatMessage>>(
                stream: _chatRepo.watchMessages(widget.room.id),
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEDB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "الرسائل والمكالمات محمية بالتشفير بين الطرفين.",
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildWhatsAppBubble(messages[index]);
                    },
                  );
                },
              ),
            ),
            _buildWhatsAppInputArea(),
          ],
        ),
      ),
    );
  }

  // تصميم رسالة الواتساب
  Widget _buildWhatsAppBubble(msg.ChatMessage message) {
    bool isMe = message.senderId == widget.currentUserId;

    // الأخضر الفاتح للرسائل المرسلة من الفني، والأبيض لرسائل العميل
    Color bubbleColor = isMe ? const Color(0xFFDCF8C6) : Colors.white;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4, top: 4),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 8,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isMe ? 12 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 12),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  message.message,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ),
              Positioned(
                bottom: 4,
                left: isMe ? 8 : 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.createdAt != null
                          ? formatTime(message.createdAt!)
                          : '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.check,
                        size: 15,
                        color: message.isRead
                            ? Colors.blue
                            : Colors.grey.shade600,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // تصميم مربع الكتابة زي الواتساب
  Widget _buildWhatsAppInputArea() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 12.0,
        top: 8.0,
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: 5,
                        minLines: 1,
                        onChanged: (val) {
                          setState(() {
                            isTyping = val.trim().isNotEmpty;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "المراسلة",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.grey),
                      onPressed: () {}, // إضافة مرفقات أو صور للعميل
                    ),
                    if (!isTyping)
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.grey),
                        onPressed: () {}, // الكاميرا
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // زرار الإرسال أو المايك
            GestureDetector(
              onTap: isTyping ? _sendMessage : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue, // لون بسيطة الأزرق
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  isTyping ? Icons.send : Icons.mic,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
