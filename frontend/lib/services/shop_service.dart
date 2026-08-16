import 'api_service.dart';

class ShopService {
  static Future<List<Map<String, dynamic>>> getShopItems({String? category}) async {
    String endpoint = '/shop';
    if (category != null && category != 'All') {
      endpoint += '?category=$category';
    }
    final response = await ApiService.get(endpoint);
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return List<Map<String, dynamic>>.from(response['items'] ?? []);
  }

  static Future<Map<String, dynamic>> getShopItemById(String id) async {
    final response = await ApiService.get('/shop/$id');
    return Map<String, dynamic>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await ApiService.get('/orders');
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return List<Map<String, dynamic>>.from(response['orders'] ?? []);
  }

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final response = await ApiService.post('/orders', {
      'item_id': data['itemId'] ?? data['item_id'],
      'customer_name': data['customer_name'] ?? '',
      'customer_email': data['customer_email'] ?? '',
      'customer_phone': data['customer_phone'] ?? '',
      'quantity': data['quantity'] ?? 1,
      'requirements': data['requirements'] ?? '',
      'paymentMethod': data['paymentMethod'] ?? 'cash',
      'paypalOrderId': data['paypalOrderId'] ?? '',
      'paypalCaptureId': data['paypalCaptureId'] ?? '',
    });
    return Map<String, dynamic>.from(response);
  }

  static Future<Map<String, dynamic>> markOrderPaid(String orderId, String paypalOrderId, String captureId) async {
    final response = await ApiService.put('/orders/$orderId/pay', {
      'paypalOrderId': paypalOrderId,
      'paypalCaptureId': captureId,
    });
    return Map<String, dynamic>.from(response);
  }

  static Future<Map<String, dynamic>> cancelOrder(String id) async {
    final response = await ApiService.put('/orders/$id/cancel', {});
    return Map<String, dynamic>.from(response);
  }

  static Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    final response = await ApiService.put('/orders/$id/status', {'status': status});
    return Map<String, dynamic>.from(response);
  }
}
