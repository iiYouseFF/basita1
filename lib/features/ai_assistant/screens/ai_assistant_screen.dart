import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:basita1/features/technician/screens/technicians_screen.dart';

enum MessageType { welcomeCard, userText, botText, loading }

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
  // الألوان الأساسية لتطبيق بسيطة
  static const Color brandBlue = Color(0xFF0053AC);
  static const Color botOrange = Color(0xFFFF7A00);
  static const Color bgLightGrey = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF10B981);

  // رابط Replit الخاص بك
  static const String apiUrl =
      "https://home-appliance-helper--basseeyta.replit.app/task-completion";

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<String> _quickSuggestions = [
    "الغسالة بتسرب مية من تحت وقت التشغيل",
    "الثلاجة مش بتبرد خالص",
    "السخان مش بيسخن مياة",
    "احجز لي سباك اليوم",
  ];

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    messages = [ChatMessage(type: MessageType.welcomeCard)];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- دالة استخراج النص الذكية (لمنع الفقاعات الفارغة) ---
  String _extractTextFromResponse(dynamic data) {
    if (data == null) return "";

    if (data is String) return data;

    if (data is List) {
      if (data.isNotEmpty) {
        return _extractTextFromResponse(data.first);
      }
      return "";
    }

    if (data is Map) {
      final possibleKeys = [
        'reply',
        'response',
        'answer',
        'text',
        'output',
        'message',
        'content',
        'result',
        'data',
      ];

      for (var key in possibleKeys) {
        if (data.containsKey(key) &&
            data[key] != null &&
            data[key].toString().trim().isNotEmpty) {
          return data[key].toString().trim();
        }
      }

      for (var value in data.values) {
        if (value is String && value.trim().length > 5) {
          return value.trim();
        }
      }

      return data.toString();
    }

    return data.toString();
  }

  // --- دالة الإرسال مع ترويسات المتصفح وإيقاظ السيرفر التلقائي ---
  Future<void> _sendMessage(String text, {int retryCount = 0}) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || (_isLoading && retryCount == 0)) return;

    if (retryCount == 0) {
      setState(() {
        _isLoading = true;
        messages.add(
          ChatMessage(type: MessageType.userText, text: trimmedText),
        );
        messages.add(ChatMessage(type: MessageType.loading));
        _messageController.clear();
      });
      _scrollToBottom();
    } else {
      _removeLoadingBubble();
      setState(() {
        messages.add(ChatMessage(type: MessageType.loading));
      });
      _scrollToBottom();
    }

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json, text/plain, */*',
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
            },
            body: jsonEncode({
              'prompt': trimmedText,
              'query': trimmedText,
              'message': trimmedText,
              'input': trimmedText,
              'check_database_history': true,
              'source': 'app_mirrored_client',
            }),
          )
          .timeout(const Duration(seconds: 45));

      final decodedBody = utf8.decode(response.bodyBytes);

      // إذا استجاب Replit بصفحة HTML (وضع السبات)، نعيد المحاولة تلقائياً (حتى 4 مرات)
      if ((decodedBody.trim().startsWith('<') ||
              decodedBody.toLowerCase().contains('<!doctype html')) &&
          retryCount < 4) {
        await Future.delayed(Duration(seconds: 4 + retryCount));
        return _sendMessage(text, retryCount: retryCount + 1);
      }

      _removeLoadingBubble();
      String botResponse = "";

      if (decodedBody.trim().startsWith('<') ||
          decodedBody.toLowerCase().contains('<!doctype html')) {
        botResponse =
            "عذراً، الخادم يستغرق وقتاً طويلاً للاستيقاظ. يرجى المحاولة مرة أخرى بعد قليل.";
      } else if (response.statusCode == 200) {
        try {
          final dynamic decodedJson = jsonDecode(decodedBody);
          botResponse = _extractTextFromResponse(decodedJson);
        } catch (e) {
          botResponse = decodedBody.trim();
        }
      } else {
        botResponse =
            "عذراً، حدث خطأ في الاتصال بالخادم (الكود: ${response.statusCode}). يرجى المحاولة مرة أخرى.";
      }

      if (botResponse.trim().isEmpty) {
        botResponse =
            "لم أتمكن من صياغة الرد في الوقت الحالي، هل يمكنك توضيح المشكلة أكثر؟";
      }

      setState(() {
        messages.add(
          ChatMessage(type: MessageType.botText, text: botResponse.trim()),
        );
      });
    } on SocketException {
      _removeLoadingBubble();
      setState(() {
        messages.add(
          ChatMessage(
            type: MessageType.botText,
            text:
                "لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة مرة أخرى.",
          ),
        );
      });
    } catch (e) {
      if (retryCount < 3) {
        await Future.delayed(const Duration(seconds: 4));
        return _sendMessage(text, retryCount: retryCount + 1);
      }
      _removeLoadingBubble();
      setState(() {
        messages.add(
          ChatMessage(
            type: MessageType.botText,
            text:
                "عذراً، استغرق الخادم وقتاً طويلاً للرد. يرجى إعادة المحاولة.",
          ),
        );
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _removeLoadingBubble() {
    setState(() {
      messages.removeWhere((msg) => msg.type == MessageType.loading);
    });
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عذراً، لا يمكن فتح هذا الرابط.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLightGrey,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (context, index) =>
                    _buildMessageItem(messages[index]),
              ),
            ),
            _buildQuickQueryBar(),
            _buildBottomInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: successGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "عم بسيط - مساعد الصيانة الذكي",
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: textDark, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: textDark, size: 22),
          onPressed: () {
            setState(() {
              messages = [ChatMessage(type: MessageType.welcomeCard)];
            });
          },
          tooltip: "محادثة جديدة",
        ),
      ],
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    switch (message.type) {
      case MessageType.welcomeCard:
        return _buildWelcomeCard();
      case MessageType.userText:
        return _buildUserBubble(message.text ?? "");
      case MessageType.botText:
        return _buildBotBubble(message.text ?? "");
      case MessageType.loading:
        return _buildLoadingBubble();
    }
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: botOrange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: botOrange,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "أهلاً بك مع عم بسيط!",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "مساعدك الذكي لصيانة الأجهزة المنزلية",
                      style: TextStyle(
                        fontSize: 13,
                        color: textMuted,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          const Text(
            "اكتب مشكلتك ليتم فحصها عبر قاعدة بيانات الصيانة وتوجيهك لأفضل حل أو فني مناسب. النظام الآن متصل بالذكاء الاصطناعي مباشرة.",
            style: TextStyle(
              fontSize: 13,
              color: textDark,
              height: 1.5,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQueryBar() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(color: bgLightGrey),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _quickSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _quickSuggestions[index];
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ActionChip(
              backgroundColor: Colors.white,
              elevation: 0.5,
              pressElevation: 0,
              side: BorderSide(color: Colors.grey.shade300),
              label: Text(
                suggestion,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
              ),
              onPressed: () => _sendMessage(suggestion),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: brandBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
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
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: brandBlue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: brandBlue,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: botOrange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: botOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "عم بسيط",
                        style: TextStyle(
                          color: botOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.verified_rounded,
                        color: successGreen,
                        size: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MarkdownBody(
                    data: text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        color: textDark,
                        fontSize: 14,
                        height: 1.6,
                        fontFamily: 'Cairo',
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Cairo',
                      ),
                      a: const TextStyle(
                        color: brandBlue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      listBullet: const TextStyle(
                        color: botOrange,
                        fontSize: 16,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: bgLightGrey,
                        border: const Border(
                          right: BorderSide(color: botOrange, width: 4),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      blockquotePadding: const EdgeInsets.all(12),
                    ),
                    onTapLink: (text, href, title) {
                      if (href == null) return;
                      if (href == '#' ||
                          href.toLowerCase().contains('technician') ||
                          href.toLowerCase().contains('book')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TechniciansScreen(),
                          ),
                        );
                      } else {
                        _launchURL(href);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: botOrange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: botOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: botOrange,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "جاري استجابة الخادم...",
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: IconButton(
              icon: const Icon(
                Icons.mic_none_rounded,
                color: brandBlue,
                size: 26,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ميزة التحدث الصوتي ستتوفر قريباً!'),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: bgLightGrey,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isLoading,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                      decoration: const InputDecoration(
                        hintText: "اسأل عم بسيط عن أي عطل...",
                        hintStyle: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          fontFamily: 'Cairo',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: textMuted,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ميزة إرفاق الصور ستتوفر قريباً!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => _sendMessage(_messageController.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey.shade400 : brandBlue,
                  shape: BoxShape.circle,
                  boxShadow: _isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: brandBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
