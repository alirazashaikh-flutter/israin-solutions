import 'api_service.dart';

class PaypalService {
  static Future<Map<String, dynamic>> createOrder({
    required double total,
    String? description,
  }) async {
    final response = await ApiService.post('/paypal/create-order', {
      'total': total,
      if (description != null) 'description': description,
    });
    return Map<String, dynamic>.from(response);
  }

  static Future<Map<String, dynamic>> captureOrder(String paypalOrderId) async {
    final response = await ApiService.post('/paypal/capture-order', {
      'paypalOrderId': paypalOrderId,
    });
    return Map<String, dynamic>.from(response);
  }

  static Future<Map<String, dynamic>> simulatePayment({
    required double total,
    String? description,
  }) async {
    final response = await ApiService.post('/paypal/capture-order', {
      'simulate': true,
      'amount': total,
      'paypalOrderId': 'SIM-${DateTime.now().millisecondsSinceEpoch}',
    });
    return Map<String, dynamic>.from(response);
  }
}
