import 'api_service.dart';

class MessageService {
  static Future<List<Map<String, dynamic>>> getMessages(String inquiryId) async {
    final response = await ApiService.get('/messages/$inquiryId');
    return (response as List).cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> sendMessage(String inquiryId, String text) async {
    final response = await ApiService.post('/messages', {
      'inquiry_id': inquiryId,
      'text': text,
    });
    return response;
  }
}
