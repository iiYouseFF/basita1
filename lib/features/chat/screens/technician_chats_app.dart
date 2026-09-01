import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:basita1/core/repositories/chat_repository.dart';
import 'package:basita1/core/models/chat_room.dart' as model;
import 'package:basita1/core/models/chat_message.dart' as msg;
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/core/network/socket_service.dart';
import 'package:basita1/features/orders/screens/sale_screen.dart';
import 'package:basita1/features/home/screens/home1.dart';
import 'package:basita1/features/orders/screens/orders_screen.dart';
import 'package:basita1/features/profile/screens/profile2.dart';

class TechnicianChatsApp extends StatelessWidget {
  const TechnicianChatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'محادثات الفني - بسيطة',
      theme: ThemeData(
        primaryColor: const Color(0xFF005CEE),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
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
  final SocketService _socketService = SocketService.instance;
  final String _currentUserId = UserDataSession.phone;

  int _selectedIndex = 2;
  List<model.ChatRoom> _allRooms = [];
  List<model.ChatRoom> _filteredRooms = [];
  bool _isLoading = true;
  bool _isSocketConnected = false;
  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
    _initSocket();
  }

  Future<void> _initSocket() async {
    await _socketService.connectChat();
    _connSub = _socketService.connectionStream.listen((c) {
      if (mounted) setState(() => _isSocketConnected = c);
    });
    _isSocketConnected = _socketService.isChatConnected;
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadChatRooms() async {
    try {
      final rooms = await _chatRepo.getUserChatRooms(_currentUserId);
      setState(() {
        _allRooms = rooms;
        _filteredRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterChats,
                decoration: InputDecoration(
                  hintText: "ابحث في المحادثات",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filterChats('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "لا توجد محادثات بعد",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "ستظهر المحادثات عند وجود طلبات نشطة",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<List<model.ChatRoom>>(
                    stream: _chatRepo.watchUserChatRooms(_currentUserId),
                    builder: (context, snapshot) {
                      final rooms = snapshot.data ?? _filteredRooms;
                      return ListView.separated(
                        itemCount: rooms.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey.shade200,
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Text(
            "المحادثات",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _isSocketConnected ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _isSocketConnected ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isSocketConnected ? "متصل" : "غير متصل",
                  style: TextStyle(
                    fontSize: 10,
                    color: _isSocketConnected ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ],
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
            final otherName = room.serviceType ?? 'محادثة';

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
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
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
                                  otherName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (lastMsg?.createdAt != null)
                                Text(
                                  _formatTime(lastMsg!.createdAt!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: unreadCount > 0
                                        ? primaryBlue
                                        : Colors.grey.shade500,
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  lastMsg?.message ?? "لا توجد رسائل",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: unreadCount > 0
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
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

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String amPm = hour >= 12 ? 'م' : 'ص';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    String minuteStr = minute < 10 ? '0$minute' : minute.toString();
    return '$hour:$minuteStr $amPm';
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
  final SocketService _socketService = SocketService.instance;
  bool isTyping = false;
  bool _isSocketConnected = false;
  StreamSubscription<bool>? _connectionSub;

  @override
  void initState() {
    super.initState();
    _chatRepo.markAsRead(widget.room.id, widget.currentUserId);
    _initRealtime();
  }

  Future<void> _initRealtime() async {
    await _socketService.connectChat();
    _socketService.joinRoom(widget.room.id);
    _connectionSub = _socketService.connectionStream.listen((c) {
      if (mounted) setState(() => _isSocketConnected = c);
    });
    _isSocketConnected = _socketService.isChatConnected;
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _socketService.leaveRoom(widget.room.id);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text;
    _messageController.clear();

    try {
      await _chatRepo.sendMessage(
        roomId: widget.room.id,
        senderId: widget.currentUserId,
        senderType: 'technician',
        message: text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الرسالة: $e'), backgroundColor: Colors.red),
        );
      }
    }

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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.serviceType ?? 'محادثة',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isSocketConnected ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isSocketConnected ? "متصل الآن" : "جاري الاتصال...",
                      style: TextStyle(
                        color: _isSocketConnected ? Colors.green : Colors.orange,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<msg.ChatMessage>>(
              stream: _chatRepo.watchMessages(widget.room.id),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "ابدأ المحادثة مع العميل",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgItem = messages[index];
                    return _buildMessageBubble(msgItem);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(msg.ChatMessage message) {
    bool isMe = message.senderId == widget.currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.createdAt != null
                      ? _formatTime(message.createdAt!)
                      : '',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.check,
                    size: 13,
                    color: message.isRead
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String amPm = hour >= 12 ? 'م' : 'ص';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    String minuteStr = minute < 10 ? '0$minute' : minute.toString();
    return '$hour:$minuteStr $amPm';
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: primaryBlue,
                size: 26,
              ),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "اكتب رسالة للعميل...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
