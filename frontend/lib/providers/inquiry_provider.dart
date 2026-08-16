import 'package:flutter/material.dart';
import '../models/inquiry.dart';
import '../models/inquiry_note.dart';
import '../models/rating.dart';
import '../services/inquiry_service.dart';

class InquiryProvider extends ChangeNotifier {
  List<Inquiry> _inquiries = [];
  Inquiry? _currentInquiry;
  bool _isLoading = false;
  String? _error;
  List<InquiryNote> _notes = [];
  bool _isLoadingNotes = false;
  List<Rating> _ratings = [];

  List<Inquiry> get inquiries => _inquiries;
  Inquiry? get currentInquiry => _currentInquiry;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<InquiryNote> get notes => _notes;
  bool get isLoadingNotes => _isLoadingNotes;
  List<Rating> get ratings => _ratings;

  Future<void> loadInquiries({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _inquiries = await InquiryService.getInquiries(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInquiry(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentInquiry = await InquiryService.getInquiryById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createInquiry({
    required String name,
    required String email,
    String? phone,
    required String serviceType,
    required String message,
    String? serviceId,
    String? budget,
    String? priority,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final inquiry = await InquiryService.createInquiry(
        name: name,
        email: email,
        phone: phone,
        serviceType: serviceType,
        message: message,
        serviceId: serviceId,
        budget: budget,
        priority: priority,
      );
      _inquiries.insert(0, inquiry);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateInquiryStatus(String id, String status) async {
    try {
      final updated = await InquiryService.updateInquiryStatus(id, status);
      final index = _inquiries.indexWhere((i) => i.id == id);
      if (index != -1) {
        _inquiries[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelInquiry(String id) async {
    try {
      final updated = await InquiryService.cancelInquiry(id);
      final index = _inquiries.indexWhere((i) => i.id == id);
      if (index != -1) {
        _inquiries[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resolveInquiry(String id) async {
    try {
      final updated = await InquiryService.resolveInquiry(id);
      final index = _inquiries.indexWhere((i) => i.id == id);
      if (index != -1) {
        _inquiries[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadNotes(String inquiryId) async {
    _isLoadingNotes = true;
    notifyListeners();
    try {
      _notes = await InquiryService.getInquiryNotes(inquiryId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingNotes = false;
      notifyListeners();
    }
  }

  Future<bool> addNote(String inquiryId, String text) async {
    try {
      final note = await InquiryService.addInquiryNote(inquiryId, text);
      _notes.insert(0, note);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadRatings() async {
    try {
      _ratings = await InquiryService.getRatings();
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> submitRating(
      String inquiryId, int rating, String? review) async {
    try {
      final newRating =
          await InquiryService.submitRating(inquiryId, rating, review);
      _ratings.add(newRating);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
