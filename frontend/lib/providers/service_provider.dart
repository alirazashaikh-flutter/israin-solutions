import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class ServiceProvider extends ChangeNotifier {
  List<Service> _services = [];
  List<String> _favoriteIds = [];
  bool _isLoading = false;
  bool _isFavoritesLoading = false;
  String? _error;

  List<Service> get services => _services;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  bool get isFavoritesLoading => _isFavoritesLoading;
  String? get error => _error;

  List<Service> get aiServices =>
      _services.where((s) => s.category == 'ai_dev').toList();

  List<Service> get marketingServices =>
      _services.where((s) => s.category == 'digital_marketing').toList();

  bool isFavorite(String serviceId) => _favoriteIds.contains(serviceId);

  Future<void> loadFavorites() async {
    _isFavoritesLoading = true;
    notifyListeners();

    try {
      _favoriteIds = await ApiService.getFavorites();
    } catch (e) {
      debugPrint('>>> FAVORITES ERROR: $e');
    } finally {
      _isFavoritesLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String serviceId) async {
    try {
      await ApiService.toggleFavorite(serviceId);
      if (_favoriteIds.contains(serviceId)) {
        _favoriteIds.remove(serviceId);
      } else {
        _favoriteIds.add(serviceId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('>>> TOGGLE FAVORITE ERROR: $e');
    }
  }

  Future<void> loadServices({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = '/services';
      if (category != null) {
        endpoint += '?category=$category';
      }
      final response = await ApiService.get(endpoint);
      _services = (response as List).map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('>>> SERVICES ERROR: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
