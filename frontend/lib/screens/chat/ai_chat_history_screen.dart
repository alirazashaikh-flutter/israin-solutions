import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/colors.dart';
import '../../models/chatbot_log.dart';
import '../../services/chatbot_service.dart';

class AiChatHistoryScreen extends StatefulWidget {
  const AiChatHistoryScreen({super.key});

  @override
  State<AiChatHistoryScreen> createState() => _AiChatHistoryScreenState();
}

class _AiChatHistoryScreenState extends State<AiChatHistoryScreen> {
  List<ChatbotLog> _logs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final logs = await ChatbotService.getHistory();
      if (mounted) setState(() { _logs = logs; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: Text('AI Chat History', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: GoogleFonts.inter(color: AppColors.error)))
              : _logs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.outline.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('No chat history yet', style: GoogleFonts.inter(fontSize: 16, color: AppColors.outline)),
                          const SizedBox(height: 8),
                          Text('Start a conversation with AI Assistant', style: GoogleFonts.inter(fontSize: 13, color: AppColors.outlineVariant)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) => _buildLogItem(_logs[index]),
                      ),
                    ),
    );
  }

  Widget _buildLogItem(ChatbotLog log) {
    final date = log.createdAt;
    final timeStr = '${date.day}/${date.month}/${date.year} ${date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  log.customerQuery,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.smart_toy, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  log.botResponse,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(timeStr, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
              if (log.escalated) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Escalated', style: GoogleFonts.inter(fontSize: 10, color: Colors.orange)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
