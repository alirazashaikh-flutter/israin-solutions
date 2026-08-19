import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/theme_provider.dart';
import '../../services/chatbot_service.dart';
import '../../services/api_service.dart';
import '../../services/language_service.dart';

class ChatWithAIScreen extends StatefulWidget {
  const ChatWithAIScreen({super.key});

  @override
  State<ChatWithAIScreen> createState() => _ChatWithAIScreenState();
}

class _ChatWithAIScreenState extends State<ChatWithAIScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _inquiryId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'bot',
      'text': LanguageService.t('ai_chat_welcome'),
      'time': _formatTime(DateTime.now()),
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());
  }

  Future<void> _initChat() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final response = await ApiService.get('/inquiries/chat');
      _inquiryId = response['_id'];
    } catch (e) {
      debugPrint('Failed to init AI chat: $e');
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
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

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.add({
        'sender': 'customer',
        'text': text.trim(),
        'time': _formatTime(DateTime.now()),
      });
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    if (_inquiryId == null) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': LanguageService.t('setup_thanks'),
          'time': _formatTime(DateTime.now()),
        });
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final response = await ChatbotService.sendMessage(
        inquiryId: _inquiryId!,
        message: text.trim(),
      );
      if (!mounted) return;
      setState(() {
        if (response['escalated'] == true && response['response'] == null) {
          _messages.add({
            'sender': 'bot',
            'text': LanguageService.t('team_notified'),
            'time': _formatTime(DateTime.now()),
          });
        } else {
          _messages.add({
            'sender': 'bot',
            'text': response['response'] ?? 'No response',
            'time': _formatTime(DateTime.now()),
          });
        }
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': LanguageService.t('something_wrong'),
          'time': _formatTime(DateTime.now()),
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),
              _buildQuickActions(),
              const SizedBox(height: 12),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Image.asset('assets/logo.png', height: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.t('chat_with_ai_title'),
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                ),
                Text(
                  LanguageService.t('powered_by'),
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(LanguageService.t('team_notified_short')), backgroundColor: AppColors.primary),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurfaceVariant,
              side: BorderSide(color: AppColors.outlineVariant),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.support_agent, size: 16),
                const SizedBox(width: 4),
                Text(LanguageService.t('talk_to_human'), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primary)),
            ),
            const SizedBox(width: 10),
            Text(LanguageService.t('thinking'), style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isBot = message['sender'] == 'bot';
    final isRight = !isBot;

    return Align(
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRight ? null : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: isRight ? null : Border.all(color: AppColors.outlineVariant),
                gradient: isRight ? AppColors.primaryGradient : null,
              ),
              child: Text(
                message['text'],
                style: GoogleFonts.inter(fontSize: 14, color: isRight ? Colors.white : AppColors.onSurface, height: 1.5),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(message['time'], style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildQuickChip(Icons.attach_money, LanguageService.t('pricing_info')),
          _buildQuickChip(Icons.schedule, LanguageService.t('timelines')),
          _buildQuickChip(Icons.code, LanguageService.t('our_services')),
          _buildQuickChip(Icons.support_agent, LanguageService.t('talk_to_team')),
        ],
      ),
    );
  }

  Widget _buildQuickChip(IconData icon, String label) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(color: AppColors.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _sendMessage(label),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: TextField(
                  controller: _messageController,
                  style: GoogleFonts.inter(fontSize: 14),
                  enabled: !_isLoading,
                  onSubmitted: (value) => _sendMessage(value),
                  decoration: InputDecoration(
                    hintText: LanguageService.t('type_message'),
                    hintStyle: GoogleFonts.inter(color: AppColors.outline),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isLoading ? null : () => _sendMessage(_messageController.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : AppColors.primaryGradient,
                  color: _isLoading ? AppColors.outline.withValues(alpha: 0.3) : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.send, color: _isLoading ? AppColors.outline : Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
