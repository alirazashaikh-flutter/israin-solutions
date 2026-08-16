import 'api_service.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await ApiService.get('/notifications');
    return (response as List).cast<Map<String, dynamic>>();
  }

  static Future<int> getUnreadCount() async {
    final response = await ApiService.get('/notifications/unread-count');
    return response['count'] ?? 0;
  }

  static Future<void> markAsRead(String id) async {
    await ApiService.put('/notifications/$id/read', {});
  }

  static Future<void> markAllAsRead() async {
    await ApiService.put('/notifications/read-all', {});
  }

  static Future<Map<String, dynamic>> broadcast({
    required String title,
    required String message,
  }) async {
    final response = await ApiService.post('/admin/broadcast', {
      'title': title,
      'message': message,
    });
    return response;
  }
}
