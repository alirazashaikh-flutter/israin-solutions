import '../models/inquiry.dart';
import '../models/inquiry_note.dart';
import '../models/rating.dart';
import 'api_service.dart';

class InquiryService {
  static Future<List<Inquiry>> getInquiries({String? status}) async {
    String endpoint = '/inquiries';
    if (status != null) {
      endpoint += '?status=$status';
    }
    final response = await ApiService.get(endpoint);
    return (response as List).map((json) => Inquiry.fromJson(json)).toList();
  }

  static Future<Inquiry> getInquiryById(String id) async {
    final response = await ApiService.get('/inquiries/$id');
    return Inquiry.fromJson(response);
  }

  static Future<Inquiry> createInquiry({
    required String name,
    required String email,
    String? phone,
    required String serviceType,
    required String message,
    String? serviceId,
    String? budget,
    String? priority,
  }) async {
    final response = await ApiService.post('/inquiries', {
      'name': name,
      'email': email,
      'phone': phone,
      'service_type': serviceType,
      'message': message,
      'service_id': serviceId,
      'budget': budget ?? '',
      'priority': priority ?? 'standard',
    });
    return Inquiry.fromJson(response);
  }

  static Future<Inquiry> updateInquiryStatus(String id, String status) async {
    final response = await ApiService.put('/inquiries/$id', {
      'status': status,
    });
    return Inquiry.fromJson(response);
  }

  static Future<Inquiry> cancelInquiry(String id) async {
    final response = await ApiService.put('/inquiries/$id/cancel', {});
    return Inquiry.fromJson(response);
  }

  static Future<Inquiry> resolveInquiry(String id) async {
    final response = await ApiService.put('/inquiries/$id/resolve', {});
    return Inquiry.fromJson(response);
  }

  static Future<List<InquiryNote>> getInquiryNotes(String id) async {
    final response = await ApiService.get('/inquiries/$id/notes');
    return (response as List)
        .map((json) => InquiryNote.fromJson(json))
        .toList();
  }

  static Future<InquiryNote> addInquiryNote(String id, String text) async {
    final response = await ApiService.post('/inquiries/$id/notes', {
      'text': text,
    });
    return InquiryNote.fromJson(response);
  }

  static Future<List<Rating>> getRatings() async {
    final response = await ApiService.get('/ratings');
    return (response as List)
        .map((json) => Rating.fromJson(json))
        .toList();
  }

  static Future<Rating> submitRating(
      String inquiryId, int rating, String? review) async {
    final response = await ApiService.post('/ratings', {
      'inquiry_id': inquiryId,
      'rating': rating,
      'review': review,
    });
    return Rating.fromJson(response);
  }
}
