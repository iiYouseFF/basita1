import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:basita1/core/services/uncle_baseet_chat_service.dart';
import 'package:basita1/core/session/auth_session.dart';

/// Customer Flow: Chatting with "Uncle Baseet" AI Assistant
///
/// Connects to n8n: POST https://basseeyta-api.duckdns.org/webhook/chat
///
/// Features:
/// - Session management: persistent sessionId via SharedPreferences
/// - Rich text: flutter_markdown MarkdownBody for headers/bullets/links
/// - Loading: animated typing indicator (dots)
/// - Error handling: try-catch → SnackBar human-readable
class UncleBaseetChatScreen extends StatefulWidget {
  const UncleBaseetChatScreen({super.key});

  @override
  State<UncleBaseetChatScreen> createState() => _UncleBaseetChatScreenState();
}

class _UncleBaseetChatScreenState extends State<UncleBaseetChatScreen> with TickerProviderStateMixin {
  // Design tokens
  static const Color brandBlue = Color(0xFF0056D2);
  static const Color brandBlueDark = Color(0xFF0053AC);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color botBubbleBg = Colors.white;
  static const Color userBubbleBg = Color(0xFF0056D2);

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final UncleBaseetChatService _chatService = UncleBaseetChatService();

  final List<_ChatMessage> _messages = [];
  String? _sessionId;
  bool _isTyping = false;
  bool _isInitializing = true;

  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      // Prefer user-bound session if logged in, else persistent random
      final fallback = await _chatService.getOrCreateSessionId();
      final userId = AuthSession.instance.userId ?? AuthSession.instance.phone;
      final sid = UncleBaseetChatService.sessionIdForUser(userId, fallback);
      // Persist the resolved id for n8n memory continuity
      if (sid != fallback) {
        // Keep fallback stored too, but we use user-bound id for requests
        // No need to overwrite prefs — just use in-memory
      }
      if (!mounted) return;
      setState(() {
        _sessionId = sid;
        _isInitializing = false;
      });
      // Welcome message from Uncle Baseet
      _addBotWelcome();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sessionId = _chatService.generateSessionId();
        _isInitializing = false;
      });
      _addBotWelcome();
    }
  }

  void _addBotWelcome() {
    setState(() {
      _messages.add(
        _ChatMessage(
          role: _Role.bot,
          text:
              'أهلاً بيك يا فندم 👋 أنا **عمو بسيط**، مساعدك الذكي في بسيطة!\n\n'
              'أقدر أساعدك في:\n'
              '- تشخيص أعطال الأجهزة\n'
              '- تقدير التكاليف\n'
              '- ترشيح أفضل الفنيين\n'
              '- فيديوهات صيانة من يوتيوب\n\n'
              'اسألني أي حاجة و هرد عليك فوراً!',
        ),
      );
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _dotsController.dispose();
    _chatService.close();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isTyping) return;
    if (_sessionId == null) {
      _showSnackBar('جاري تجهيز الجلسة... حاول مرة أخرى', isError: true);
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(role: _Role.user, text: text));
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final output = await _chatService.sendMessage(
        sessionId: _sessionId!,
        chatInput: text,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(role: _Role.bot, text: output));
        _isTyping = false;
      });
      _scrollToBottom();
    } on UncleBaseetChatException catch (e) {
      if (!mounted) return;
      setState(() => _isTyping = false);
      // Remove typing state and show error as bot bubble + snackbar
      _showSnackBar(e.userMessage, isError: true);
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _Role.bot,
            text: '⚠️ ${e.userMessage}\n\nحاول مرة أخرى أو تأكد من الاتصال بالإنترنت.',
            isError: true,
          ),
        );
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isTyping = false);
      _showSnackBar('حدث خطأ غير متوقع. حاول مرة أخرى.', isError: true);
    }
  }

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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleNewChat() async {
    final newId = await _chatService.resetSession();
    setState(() {
      _sessionId = newId;
      _messages.clear();
      _isTyping = false;
    });
    _addBotWelcome();
    _showSnackBar('تم بدء محادثة جديدة');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            if (_isInitializing)
              const LinearProgressIndicator(color: brandBlue, backgroundColor: Color(0xFFE2E8F0), minHeight: 2),
            Expanded(
              child: _messages.isEmpty && !_isInitializing
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        final msg = _messages[index];
                        return msg.role == _Role.user ? _buildUserBubble(msg.text) : _buildBotBubble(msg);
                      },
                    ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: brandBlue, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: brandBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded, color: brandBlue, size: 20),
          ),
          const SizedBox(width: 8),
          Text('عمو بسيط', style: GoogleFonts.cairo(color: brandBlueDark, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'محادثة جديدة',
          icon: const Icon(Icons.refresh_rounded, color: textMuted),
          onPressed: _handleNewChat,
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: borderLight),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: brandBlue.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: brandBlue, size: 40),
            ),
            const SizedBox(height: 16),
            Text('ابدأ المحادثة مع عمو بسيط', style: GoogleFonts.cairo(color: textDark, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'اسأل عن أي عطل أو تكلفة أو اطلب فني — هرد عليك فوراً مع فيديوهات وتقديرات.',
              style: GoogleFonts.cairo(color: textMuted, fontSize: 12, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft, // RTL: appears on left (visual mirror handles it)
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: userBubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(text, style: GoogleFonts.cairo(color: Colors.white, fontSize: 14, height: 1.5)),
      ),
    );
  }

  Widget _buildBotBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: brandBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded, color: brandBlue, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 32),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isError ? const Color(0xFFFEF2F2) : botBubbleBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(color: msg.isError ? const Color(0xFFFECACA) : borderLight),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: MarkdownBody(
                data: msg.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.cairo(color: msg.isError ? const Color(0xFF991B1B) : textDark, fontSize: 14, height: 1.6),
                  h1: GoogleFonts.cairo(color: textDark, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
                  h2: GoogleFonts.cairo(color: textDark, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                  h3: GoogleFonts.cairo(color: textDark, fontSize: 15, fontWeight: FontWeight.bold, height: 1.4),
                  strong: GoogleFonts.cairo(color: textDark, fontSize: 14, fontWeight: FontWeight.bold),
                  em: GoogleFonts.cairo(color: textDark, fontSize: 14, fontStyle: FontStyle.italic),
                  listBullet: GoogleFonts.cairo(color: brandBlue, fontSize: 14, fontWeight: FontWeight.bold),
                  blockquote: GoogleFonts.cairo(color: textMuted, fontSize: 13, fontStyle: FontStyle.italic),
                  blockquoteDecoration: BoxDecoration(
                    color: bgLight,
                    border: const Border(left: BorderSide(color: brandBlue, width: 3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  code: GoogleFonts.cairo(color: const Color(0xFF1E293B), fontSize: 12, backgroundColor: const Color(0xFFF1F5F9)),
                  codeblockDecoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  a: GoogleFonts.cairo(color: brandBlue, fontSize: 14, decoration: TextDecoration.underline, decorationColor: brandBlue),
                ),
                onTapLink: (text, href, title) async {
                  if (href == null) return;
                  final uri = Uri.tryParse(href);
                  if (uri == null) return;
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (!mounted) return;
                    _showSnackBar('تعذر فتح الرابط', isError: true);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: brandBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded, color: brandBlue, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(left: 32),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: botBubbleBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
              border: Border.all(color: borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('عمو بسيط يكتب', style: GoogleFonts.cairo(color: textMuted, fontSize: 12, fontStyle: FontStyle.italic)),
                const SizedBox(width: 12),
                AnimatedBuilder(
                  animation: _dotsController,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (i) {
                        final t = (_dotsController.value + i * 0.33) % 1.0;
                        final scale = (t < 0.5) ? (0.5 + t) : (1.5 - t);
                        final opacity = (0.4 + 0.6 * scale).clamp(0.0, 1.0);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: brandBlue.withValues(alpha: opacity),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderLight)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(30), border: Border.all(color: borderLight)),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  enabled: !_isInitializing,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  style: GoogleFonts.cairo(color: textDark, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _isTyping ? 'انتظر رد عمو بسيط...' : 'اكتب رسالتك لعمو بسيط...',
                    hintStyle: GoogleFonts.cairo(color: textMuted, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _isTyping || _inputController.text.trim().isEmpty ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _inputController.text.trim().isEmpty || _isTyping ? borderLight : brandBlue,
                    shape: BoxShape.circle,
                  ),
                  child: _isTyping
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: textMuted),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: _inputController.text.trim().isEmpty ? textMuted : Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Role { user, bot }

class _ChatMessage {
  _ChatMessage({required this.role, required this.text, this.isError = false});
  final _Role role;
  final String text;
  final bool isError;
}
