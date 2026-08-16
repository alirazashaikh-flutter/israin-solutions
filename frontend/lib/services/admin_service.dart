import 'api_service.dart';

class AdminService {
  static Future<Map<String, dynamic>> getStats() async {
    final response = await ApiService.get('/admin/stats');
    return response;
  }

  static Future<List<Map<String, dynamic>>> getServices() async {
    final response = await ApiService.get('/services');
    return (response as List).cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createService({
    required String name,
    required String category,
    required String description,
    required double price,
    required String timeline,
    List<String>? useCases,
  }) async {
    final response = await ApiService.post('/services', {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'timeline': timeline,
      'useCases': useCases ?? [],
    });
    return response;
  }

  static Future<Map<String, dynamic>> updateService({
    required String id,
    required String name,
    required String category,
    required String description,
    required double price,
    required String timeline,
    List<String>? useCases,
  }) async {
    final response = await ApiService.put('/services/$id', {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'timeline': timeline,
      'useCases': useCases ?? [],
    });
    return response;
  }

  static Future<void> deleteService(String id) async {
    await ApiService.delete('/services/$id');
  }

  static Future<Map<String, dynamic>> resolveInquiry(String id) async {
    final response = await ApiService.put('/inquiries/$id/resolve', {});
    return response;
  }
}
