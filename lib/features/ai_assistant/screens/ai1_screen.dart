import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:basita1/features/orders/screens/sale_screen.dart';
import 'package:basita1/features/home/screens/home1.dart';
import 'package:basita1/features/orders/screens/orders_screen.dart';
import 'package:basita1/features/profile/screens/profile2.dart';

class SmartAssistantScreen extends StatelessWidget {
  const SmartAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'المساعد الذكي - بسيطة',
      theme: ThemeData(
        primaryColor: const Color(0xFF005CEE),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // لون خلفية مريح
        fontFamily: 'Cairo', // خط كايرو للتطابق مع التصميم
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: ui.TextDirection.rtl, // دعم كامل للغة العربية
          child: child!,
        );
      },
      home: const SmartAssistantScreenWidget(),
    );
  }
}

// نموذج رسالة الشات
class ChatMessage {
  final String text;
  final bool isBot;
  final String time;

  ChatMessage({required this.text, required this.isBot, required this.time});
}

class SmartAssistantScreenWidget extends StatefulWidget {
  const SmartAssistantScreenWidget({super.key});

  @override
  State<SmartAssistantScreenWidget> createState() =>
      _SmartAssistantScreenWidgetState();
}

class _SmartAssistantScreenWidgetState
    extends State<SmartAssistantScreenWidget> {
  final Color primaryBlue = const Color(0xFF005CEE);
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];
  bool isTyping = false;
  int _selectedIndex = 2; // "المحادثات" هي المحددة افتراضياً

  // الردود الوهمية للذكاء الاصطناعي
  final List<String> aiReplies = [
    "بالتأكيد! يمكنني مساعدتك في ذلك. هل يمكنك تزويدي بمزيد من التفاصيل؟",
    "جاري تحليل البيانات... سأقوم بتجهيز الرد فوراً.",
    "فهمت طلبك. سأقوم بإعداد عرض السعر الآن، كم تبلغ تكلفة المواد؟",
    "ممتاز، قمت بحفظ هذه المعلومات لك. هل تحتاج لشيء آخر؟",
    "هذا سؤال رائع. بناءً على تقييمات العملاء، أدائك ممتاز هذا الشهر!",
  ];
  int replyIndex = 0;

  @override
  void initState() {
    super.initState();
    // الرسالة الترحيبية الأولى
    messages.add(
      ChatMessage(
        text:
            "كيف يمكنني مساعدتك اليوم؟ يمكنني مساعدتك في تسعير الطلبات، كتابة العروض، أو تحليل أرباحك.",
        isBot: true,
        time: _getCurrentTime(),
      ),
    );
  }

  String _getCurrentTime() {
    return DateFormat('hh:mm a')
        .format(DateTime.now())
        .replaceAll('AM', 'صباحاً')
        .replaceAll('PM', 'مساءً');
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.insert(
        0,
        ChatMessage(text: text, isBot: false, time: _getCurrentTime()),
      );
      _messageController.clear();
      isTyping = true;
    });

    _scrollToBottom();

    // محاكاة تأخير الرد للذكاء الاصطناعي
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isTyping = false;
          messages.insert(
            0,
            ChatMessage(
              text: aiReplies[replyIndex % aiReplies.length],
              isBot: true,
              time: _getCurrentTime(),
            ),
          );
          replyIndex++;
        });
        _scrollToBottom();
      }
    });
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

  // ==========================================
  // دالة التعامل مع الضغط على الـ Bottom Nav
  // ==========================================
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // --------------------------------------------------------------
    // كود الـ Navigator للانتقال للصفحات الأخرى
    // قم بإزالة (/* و */) واستبدل أسماء الكلاسات بأسماء صفحاتك الحقيقية
    // --------------------------------------------------------------

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
    } else if (index == 2) {
      // نحن بالفعل في صفحة المحادثات
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // يبدأ من الأسفل للأعلى
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length + 1, // +1 للهيدر العلوي
              itemBuilder: (context, index) {
                // إذا كنا في نهاية القائمة، نعرض الهيدر والخيارات
                if (index == messages.length) {
                  return _buildAIHeaderAndSuggestions();
                }

                // عرض الرسائل (نطرح 1 بسبب الهيدر)
                final msg = messages[messages.length - 1 - index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (isTyping) _buildTypingIndicator(),
          _buildMessageInputArea(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ==========================================
  // 1. شريط الـ AppBar
  // ==========================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      title: Row(
        children: [
          // لو عندك صورة حقيقية حطها في assets واستخدم AssetImage
          const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage(
              "assets/user-profile-icon-profile-avatar-symbol-man-avatar-icon-free-vector.jpg",
            ),
            backgroundColor: Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(
            "بسيطة | الفني",
            style: TextStyle(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.black87,
            size: 26,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // ==========================================
  // 2. هيدر المساعد الذكي والخيارات المقترحة
  // ==========================================
  Widget _buildAIHeaderAndSuggestions() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // أيقونة الذكاء الاصطناعي
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: primaryBlue.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 35),
        ),
        const SizedBox(height: 16),
        const Text(
          "المساعد الذكي للفني",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "مدعوم بالذكاء الاصطناعي لتحسين كفاءة عملك وزيادة\nأرباحك",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 30),

        // عرض الخيارات المقترحة فقط إذا كانت المحادثة فارغة (بها الرسالة الترحيبية فقط)
        if (messages.length == 1)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip("توليد عرض سعر احترافي"),
              _buildSuggestionChip("تحليل تقييمات العملاء"),
              _buildSuggestionChip("توقع أرباح الشهر القادم"),
              _buildSuggestionChip("كتابة فاتورة"),
            ],
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  // تصميم الأزرار المقترحة
  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () => _sendMessage(text), // يرسل النص عند الضغط عليه
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: primaryBlue),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. تصميم فقاعة الرسالة (البوت والمستخدم)
  // ==========================================
  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: message.isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (message.isBot) ...[
            // أيقونة البوت بجوار الرسالة
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isBot ? Colors.white : primaryBlue,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomRight: Radius.circular(message.isBot ? 16 : 0),
                  bottomLeft: Radius.circular(message.isBot ? 0 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: message.isBot
                    ? Border.all(color: Colors.grey.shade200)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isBot ? Colors.black87 : Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.time,
                    style: TextStyle(
                      color: message.isBot
                          ? Colors.grey.shade500
                          : Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. منطقة كتابة الرسالة السفلية
  // ==========================================
  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "اكتب سؤالك هنا...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    // إضافة أيقونة الكاميرا والمايك كما في التصميم
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mic_none_outlined,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // زر الإرسال التفاعلي
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 5. الـ Bottom Navigation Bar (بالترتيب المطلوب)
  // ==========================================
  Widget _buildBottomNavigationBar() {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        // 1. تحديد شكل خلفية الزر النشط لتكون مثل الصورة (مربع بحواف دائرية)
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorColor: primaryBlue.withValues(
          alpha: 0.25, // تم زيادة الشفافية قليلاً ليطابق درجة لون الصورة
        ),
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
        // 2. لكي يكون "المحادثات" هو المحدد، يجب أن تكون هذه القيمة 2 في صفحة المحادثات
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.black,
        surfaceTintColor:
            Colors.transparent, // لمنع تغيير لون الخلفية الأبيض عند التمرير
        // في الـ TextDirection.rtl، العنصر رقم 0 يكون في أقصى اليمين
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.assignment_outlined,
            ), // تم تعديلها لتطابق الورقة في الصورة
            selectedIcon: Icon(Icons.assignment),
            label: 'الطلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline), // أيقونة المحادثات
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'المحادثات',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ), // تم تعديلها لتطابق المحفظة
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

  // مؤشر الكتابة (Typing Indicator)
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              "المساعد يكتب الآن...",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
