import '../models/chatbot_log.dart';
import 'api_service.dart';

class ChatbotService {
  static Future<Map<String, dynamic>> sendMessage({
    required String inquiryId,
    required String message,
  }) async {
    final response = await ApiService.post('/chatbot/message', {
      'inquiry_id': inquiryId,
      'message': message,
    });
    return response;
  }

  static Future<List<ChatbotLog>> getHistory() async {
    final response = await ApiService.get('/chatbot/history');
    return (response as List)
        .map((json) => ChatbotLog.fromJson(json))
        .toList();
  }
}
