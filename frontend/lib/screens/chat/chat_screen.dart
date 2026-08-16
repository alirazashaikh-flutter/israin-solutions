import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../config/colors.dart';
import '../../config/api.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

import '../../services/message_service.dart';
import '../../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _inquiryId;
  bool _initialized = false;
  IO.Socket? _socket;
  bool _otherTyping = false;
  String _otherName = '';
  Timer? _typingTimer;
  Map<String, dynamic>? _customerInfo;
  final Set<String> _onlineUserIds = {};
  bool _isSearchActive = false;
  String _searchQuery = '';

  bool get _isAdmin => context.read<AuthProvider>().isAdmin;

  @override
  void initState() {
    super.initState();
    if (!_isAdmin) {
      _messages.add({
        'sender': 'admin',
        'text': "Hello! Welcome to Israin Solutions. How can we help you today?",
        'time': _formatTime(DateTime.now()),
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());
  }

  void _connectSocket() {
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.onConnect((_) {
      debugPrint('Socket connected');
      if (_inquiryId != null) {
        _socket!.emit('join_inquiry', _inquiryId);
      }
    });

    _socket!.on('receive_message', (data) {
      if (!mounted) return;
      final senderId = data['sender_id'];
      final senderMap = senderId is Map ? senderId : null;
      final msgSenderId = senderMap?['_id'] ?? senderId?.toString() ?? '';
      final currentUserId = context.read<AuthProvider>().user?.id;

      if (msgSenderId == currentUserId) return;

      final senderRole = senderMap?['role'];
      final senderType = senderRole == 'admin' ? 'admin' : 'customer';

      setState(() {
        _messages.add({
          'sender': senderType,
          'text': data['text'] ?? '',
          'time': _formatTime(DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now()),
          'read': false,
          'id': data['_id'] ?? '',
          'attachments': data['attachments'] ?? [],
        });
      });
      _scrollToBottom();
      _markAsRead();
    });

    _socket!.on('messages_read', (data) {
      if (!mounted) return;
      final readerId = data['reader_id'];
      final currentUserId = context.read<AuthProvider>().user?.id;
      if (readerId != currentUserId) {
        setState(() {
          for (var msg in _messages) {
            if (msg['sender'] == (_isAdmin ? 'admin' : 'customer')) {
              msg['read'] = true;
            }
          }
        });
      }
    });

    _socket!.on('user_typing', (data) {
      if (!mounted) return;
      setState(() {
        _otherTyping = true;
        _otherName = data['user_name'] ?? '';
      });
    });

    _socket!.on('user_stop_typing', (data) {
      if (!mounted) return;
      setState(() => _otherTyping = false);
    });

    _socket!.on('online_users', (data) {
      if (!mounted) return;
      final users = data is List ? data : [];
      setState(() {
        _onlineUserIds.clear();
        for (final u in users) {
          final id = u is Map ? (u['_id'] ?? u['id'] ?? '').toString() : u.toString();
          if (id.isNotEmpty) _onlineUserIds.add(id);
        }
      });
    });

    _socket!.onDisconnect((_) => debugPrint('Socket disconnected'));

    _socket!.connect();
  }

  Future<void> _initChat() async {
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _inquiryId = args;
      _connectSocket();
      await _loadMessages();
      if (_isAdmin) await _loadCustomerInfo();
      return;
    }

    if (_isAdmin) return;

    try {
      final response = await ApiService.get('/inquiries/chat');
      _inquiryId = response['_id'];
      _connectSocket();
      await _loadMessages();
    } catch (e) {
      debugPrint('Failed to create inquiry for chat: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (_inquiryId == null) return;
    try {
      final messages = await MessageService.getMessages(_inquiryId!);
      if (!mounted) return;
      setState(() {
        _messages.clear();
        for (final msg in messages) {
          final senderId = msg['sender_id'];
          final senderRole = senderId is Map ? senderId['role'] : null;
          final isMe = senderRole == 'admin';
          _messages.add({
            'sender': isMe ? 'admin' : 'customer',
            'text': msg['text'] ?? '',
            'time': _formatTime(DateTime.tryParse(msg['createdAt'] ?? '') ?? DateTime.now()),
            'read': msg['read'] ?? false,
            'id': msg['_id'] ?? '',
            'attachments': msg['attachments'] ?? [],
          });
        }
      });
      _scrollToBottom();
      _markAsRead();
    } catch (e) {
      debugPrint('Failed to load messages: $e');
    }
  }

  Future<void> _loadCustomerInfo() async {
    if (_inquiryId == null) return;
    try {
      final inquiry = await ApiService.get('/inquiries/$_inquiryId');
      final customerId = inquiry['customer_id'];
      if (customerId is Map && mounted) {
        setState(() => _customerInfo = Map<String, dynamic>.from(customerId));
      }
    } catch (e) {
      debugPrint('Failed to load customer info: $e');
    }
  }

  void _markAsRead() {
    if (_inquiryId == null || _socket == null) return;
    final currentUserId = context.read<AuthProvider>().user?.id;
    _socket!.emit('mark_read', {
      'inquiry_id': _inquiryId,
      'reader_id': currentUserId,
    });
  }

  void _onTyping() {
    if (_inquiryId == null || _socket == null) return;
    final userName = context.read<AuthProvider>().user?.name ?? '';
    _socket!.emit('typing', {
      'inquiry_id': _inquiryId,
      'user_name': userName,
    });
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _socket!.emit('stop_typing', {'inquiry_id': _inquiryId});
    });
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

    final sender = _isAdmin ? 'admin' : 'customer';

    setState(() {
      _messages.add({
        'sender': sender,
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
          'text': "Setting things up. Please try again in a moment.",
          'time': _formatTime(DateTime.now()),
        });
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final user = context.read<AuthProvider>().user;
      _socket!.emit('send_message', {
        'inquiry_id': _inquiryId,
        'text': text.trim(),
        'sender_id': user?.id,
      });
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'error',
          'text': 'Failed to send. Please try again.',
          'time': _formatTime(DateTime.now()),
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _socket?.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final isAdmin = context.read<AuthProvider>().isAdmin;
          Navigator.pushReplacementNamed(context, isAdmin ? '/admin' : '/my-inquiries');
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_isAdmin && _customerInfo != null) _buildCustomerInfoBar(),
            if (_isSearchActive) _buildSearchBar(),
            Expanded(
              child: _filteredMessages.isEmpty && _isAdmin
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.outline),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty ? 'No messages match your search' : 'Start the conversation',
                            style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _filteredMessages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredMessages.length) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessageBubble(_filteredMessages[index]);
                      },
                    ),
            ),
            if (_otherTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text('$_otherName is typing', style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline, fontStyle: FontStyle.italic)),
                    const SizedBox(width: 6),
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            _buildMessageInput(),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildHeader() {
    final userName = context.read<AuthProvider>().user?.name ?? (_isAdmin ? 'Admin' : 'Customer');
    final otherUserId = _customerInfo?['_id']?.toString() ?? '';
    final isOtherOnline = otherUserId.isNotEmpty && _onlineUserIds.contains(otherUserId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          if (_isAdmin) ...[
            Image.asset('assets/logo.png', height: 36,),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isAdmin ? 'Customer Chat' : 'AI Assistant',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                    ),
                    if (_isAdmin) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOtherOnline ? const Color(0xFF00FF88) : AppColors.outline,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _isAdmin ? userName : 'Powered by Israin Intelligence',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (_isAdmin)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchActive = !_isSearchActive;
                  if (!_isSearchActive) {
                    _searchQuery = '';
                    _searchController.clear();
                  }
                });
              },
              icon: Icon(_isSearchActive ? Icons.close : Icons.search, size: 22, color: AppColors.onSurfaceVariant),
              tooltip: 'Search messages',
            ),
          if (!_isAdmin) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Our team will be notified. They\'ll respond shortly!'), backgroundColor: AppColors.primary),
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
                  const Icon(Icons.headset_mic_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('Talk to\nHuman', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInfoBar() {
    final name = _customerInfo?['name'] ?? '';
    final email = _customerInfo?['email'] ?? '';
    final phone = _customerInfo?['phone'] ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          if (name.isNotEmpty)
            Text(name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
          if (email.isNotEmpty) ...[
            const SizedBox(width: 10),
            Icon(Icons.email_outlined, size: 12, color: AppColors.outline),
            const SizedBox(width: 4),
            Text(email, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(width: 10),
            Icon(Icons.phone_outlined, size: 12, color: AppColors.outline),
            const SizedBox(width: 4),
            Text(phone, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: GoogleFonts.inter(fontSize: 14),
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle: GoogleFonts.inter(color: AppColors.outline),
          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.outline),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: Icon(Icons.clear, size: 18, color: AppColors.outline),
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredMessages {
    if (_searchQuery.isEmpty) return _messages;
    final query = _searchQuery.toLowerCase();
    return _messages.where((m) {
      final text = (m['text'] ?? '').toString().toLowerCase();
      return text.contains(query);
    }).toList();
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
            Text('Thinking...', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isBot = message['sender'] == 'bot';
    final senderIsAdmin = message['sender'] == 'admin';
    final isRight = _isAdmin ? senderIsAdmin : (!senderIsAdmin && !isBot);
    final escalated = message['escalated'] == true;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message['attachments'] != null && (message['attachments'] as List).isNotEmpty)
                    ...((message['attachments'] as List).map<Widget>((att) {
                      final attMap = att is Map ? att : {};
                      final url = attMap['url'] ?? '';
                      final name = attMap['originalName'] ?? attMap['filename'] ?? 'File';
                      final mimetype = attMap['mimetype'] ?? '';
                      if (mimetype.startsWith('image/')) {
                        final imageUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}$url';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _FullScreenImage(imageUrl: imageUrl),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                                  child: Row(children: [Icon(Icons.broken_image, color: AppColors.outline), const SizedBox(width: 8), Text(name, style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline))]),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: isRight ? Colors.white.withValues(alpha: 0.15) : AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.insert_drive_file, color: isRight ? Colors.white70 : AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Flexible(child: Text(name, style: GoogleFonts.inter(fontSize: 12, color: isRight ? Colors.white : AppColors.onSurface), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      );
                    })),
                  if (message['text'] != null && (message['text'] as String).isNotEmpty)
                    Text(
                      message['text'],
                      style: GoogleFonts.inter(fontSize: 14, color: isRight ? Colors.white : AppColors.onSurface, height: 1.5),
                    ),
                ],
              ),
            ),
            if (escalated) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8A317).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.support_agent, size: 14, color: Color(0xFFE8A317)),
                    const SizedBox(width: 4),
                    Text('Escalated to human agent', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFE8A317))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message['time'], style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                  if (isRight) ...[
                    const SizedBox(width: 4),
                    Icon(
                      (message['read'] == true) ? Icons.done_all : Icons.done,
                      size: 14,
                      color: (message['read'] == true) ? const Color(0xFF00B4D8) : AppColors.outline,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
            if (!_isAdmin)
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Icon(Icons.attach_file, color: AppColors.outline, size: 20),
                ),
              ),
            if (!_isAdmin) const SizedBox(width: 8),
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
                  onChanged: (_) => _onTyping(),
                  onSubmitted: (value) => _sendMessage(value),
                  decoration: InputDecoration(
                    hintText: _isAdmin ? 'Reply to customer...' : 'Type your message...',
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

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File size exceeds 10MB limit'), backgroundColor: AppColors.error),
            );
          }
          return;
        }

        setState(() => _isLoading = true);

        try {
          final uploadResult = await ApiService.uploadFile(file.path!, file.name);
          final files = (uploadResult['files'] as List)
              .map((f) => Map<String, dynamic>.from(f as Map))
              .toList();

          final user = context.read<AuthProvider>().user;
          _socket!.emit('send_message', {
            'inquiry_id': _inquiryId,
            'text': '',
            'sender_id': user?.id,
            'attachments': files,
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
            );
          }
        }

        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
