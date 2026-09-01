import 'package:flutter/material.dart';
import 'package:basita1/features/technician/screens/technicians_screen.dart';
import 'package:basita1/features/ai_assistant/screens/uncle_baseet_chat_screen.dart';

// تعريف أنواع الرسائل لتسهيل بناء الواجهة
enum MessageType {
  welcomeCard,
  suggestions,
  userText,
  botText,
  actionCard,
  recentCommands,
}

// نموذج بيانات الرسالة
class ChatMessage {
  final MessageType type;
  final String? text;

  ChatMessage({required this.type, this.text});
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  // الألوان الأساسية المستوحاة من التصميم
  static const Color brandBlue = Color(0xFF0053AC); // الأزرق الرئيسي
  static const Color bgLightGrey = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // خريطة (Map) تحتوي على الردود المخصصة لكل مقترح سريع
  final Map<String, String> _quickRepliesMap = {
    "احجز لي سباك اليوم":
        "فهمت ذلك. سأبحث لك عن أفضل السباكين المتاحين الآن لخدمتك اليوم.",
    "اطلب كهربائي بأعلى تقييم":
        "جاري البحث عن كهربائيين حاصلين على تقييم 5 نجوم لضمان أفضل خدمة لك.",
    "افتح صفحة العائلة":
        "حسناً، جاري تحضير صفحة العائلة لتتمكن من إدارتها ومتابعة أفراد أسرتك.",
    "اعرض شركات التشطيب":
        "بالتأكيد، سأعرض لك الآن قائمة بأفضل شركات التشطيب المعتمدة لدينا.",
    "اشترك في التأمين":
        "خطوة ممتازة! سأقوم بفتح باقات التأمين المتاحة لتختار ما يناسب احتياجاتك.",
    "اعرض آخر طلباتي":
        "جاري استرجاع سجل طلباتك السابقة لتتمكن من مراجعتها ومتابعتها.",
  };

  // قائمة الرسائل المبدئية التي تظهر عند فتح الصفحة (مطابقة للصورة)
  List<ChatMessage> messages = [
    ChatMessage(type: MessageType.welcomeCard),
    ChatMessage(type: MessageType.suggestions),
    ChatMessage(
      type: MessageType.userText,
      text: "عندي تسريب مياه في مطبخ الشقة اللي في سموحة، محتاج سباك ضروري.",
    ),
    ChatMessage(
      type: MessageType.botText,
      text:
          "فهمت ذلك. سأبحث لك عن أفضل السباكين المتاحين الآن في منطقة سموحة للتعامل مع تسريب المياه.",
    ),
    ChatMessage(type: MessageType.actionCard),
    ChatMessage(type: MessageType.recentCommands),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // دالة إرسال الرسالة من المستخدم
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(type: MessageType.userText, text: text));
      _messageController.clear();
    });

    _scrollToBottom();
    _simulateBotResponse(text);
  }

  // دالة محاكاة رد البوت الذكي
  void _simulateBotResponse(String userText) {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        // تحديد الرد بناءً على إذا كان النص موجوداً في المقترحات أم لا
        String botReply =
            _quickRepliesMap[userText] ??
            "سأقوم بتنفيذ طلبك: '$userText' فوراً. هل تحتاج لشيء آخر؟";

        // إضافة رد البوت
        messages.add(ChatMessage(type: MessageType.botText, text: botReply));

        // إظهار كارت الحجز فقط إذا كان الطلب متعلقاً بسباك كمثال تفاعلي
        if (userText == "احجز لي سباك اليوم") {
          messages.add(ChatMessage(type: MessageType.actionCard));
        }
      });
      _scrollToBottom();
    });
  }

  // دالة النزول لأسفل الشات تلقائياً عند إضافة رسالة
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // الواجهة باللغة العربية
      child: Scaffold(
        backgroundColor: bgLightGrey,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // منطقة الشات
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(messages[index]);
                },
              ),
            ),
            // حقل إدخال النص السفلي
            _buildBottomInputArea(),
          ],
        ),
      ),
    );
  }

  // ==================== 1. الـ AppBar ====================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgLightGrey,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "المساعد الذكي",
        style: TextStyle(
          color: brandBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2), size: 28),
        onPressed: () {
          Navigator.pop(context); // العودة للصفحة السابقة مباشرة
        },
      ),
    );
  }

  // ==================== 2. موجه رسائل الشات ====================
  Widget _buildMessageItem(ChatMessage message) {
    switch (message.type) {
      case MessageType.welcomeCard:
        return _buildWelcomeCard();
      case MessageType.suggestions:
        return _buildSuggestionsSection();
      case MessageType.userText:
        return _buildUserBubble(message.text ?? "");
      case MessageType.botText:
        return _buildBotBubble(message.text ?? "");
      case MessageType.actionCard:
        return _buildActionCard();
      case MessageType.recentCommands:
        return _buildRecentCommands();
    }
  }

  // ==================== 3. كارت الترحيب ====================
  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: brandBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: brandBlue,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "مرحبًا أنا مساعد بسيطة الذكي",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "يمكنني تنفيذ أي مهمة داخل التطبيق بمجرد أن تخبرني بما تريد. اطلب أي شيء وسأنفذه لك فوراً.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textMuted,
              height: 1.5,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UncleBaseetChatScreen()),
                );
              },
              icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
              label: const Text(
                'تحدث مع عمو بسيط (متصل بـ n8n)',
                style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 4. المقترحات السريعة ====================
  Widget _buildSuggestionsSection() {
    // جلب النصوص من الخريطة المحددة مسبقاً
    List<String> suggestions = _quickRepliesMap.keys.toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0, bottom: 12.0),
            child: Text(
              "مقترحات سريعة",
              style: TextStyle(
                color: textMuted,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 10.0,
            children: suggestions.map((text) {
              return GestureDetector(
                onTap: () =>
                    _sendMessage(text), // إرسال الاقتراح كرسالة عند الضغط
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==================== 5. رسالة المستخدم ====================
  Widget _buildUserBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft, // في الـ RTL سيظهر على اليسار
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: brandBlue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4), // الطرف المدبب
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  // ==================== 6. رسالة البوت النصية ====================
  Widget _buildBotBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة البوت
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: brandBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: brandBlue,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          // فقاعة نص البوت
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4), // الطرف المدبب
                ),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 14,
                  height: 1.5,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 7. كارت الحجز التفاعلي ====================
  Widget _buildActionCard() {
    return Padding(
      padding: const EdgeInsets.only(right: 32, bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brandBlue.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: brandBlue.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // العنوان
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.build_circle_rounded,
                    color: brandBlue,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "طلب سباك - سموحة",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: brandBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "متاح الآن",
                      style: TextStyle(
                        color: brandBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            // الإحصائيات
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn("عدد الفنيين", "12", null),
                  Container(height: 30, width: 1, color: Colors.grey.shade200),
                  _buildStatColumn("أفضل سعر", "120", "ج.م"),
                  Container(height: 30, width: 1, color: Colors.grey.shade200),
                  _buildStatColumn("أفضل تقييم", "4.9", "⭐"),
                ],
              ),
            ),
            // الأزرار
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: أكشن الحجز
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "احجز الآن",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: أكشن عرض الفنيين
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TechniciansScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: textDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "عرض الفنيين",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, String? suffix) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textMuted,
            fontSize: 11,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 4),
              if (suffix == "⭐")
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16)
              else
                Text(
                  suffix,
                  style: const TextStyle(
                    color: brandBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }

  // ==================== 8. الأوامر الأخيرة ====================
  Widget _buildRecentCommands() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 30, color: Color(0xFFE2E8F0)),
          const Padding(
            padding: EdgeInsets.only(right: 8.0, bottom: 12.0),
            child: Text(
              "الأوامر الأخيرة",
              style: TextStyle(
                color: textDark,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          _buildRecentTile("حجز كهربائي في التجمع", "أمس"),
          _buildRecentTile("استعراض شركات التشطيب الحديثة", "منذ يومين"),
        ],
      ),
    );
  }

  Widget _buildRecentTile(String title, String time) {
    return GestureDetector(
      onTap: () => _sendMessage(title), // إعادة إرسال الأمر عند الضغط عليه
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, color: textMuted, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                color: textMuted,
                fontSize: 11,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 9. حقل الإدخال السفلي (الكيبورد) ====================
  Widget _buildBottomInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(color: bgLightGrey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // أيقونة المايك
            IconButton(
              icon: const Icon(Icons.mic_none_rounded, color: brandBlue),
              onPressed: () {}, // إضافة الأوامر الصوتية هنا
            ),
            // حقل النص
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                decoration: const InputDecoration(
                  hintText: "اكتب أو تحدث بما تحتاج...",
                  hintStyle: TextStyle(
                    color: textMuted,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            // أيقونة الكاميرا
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: textMuted),
              onPressed: () {}, // رفع الصور
            ),
            // زر الإرسال الأزرق
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: brandBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
