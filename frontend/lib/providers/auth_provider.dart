import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  String? _error;
  bool _isInitialized = false;
  bool _pending2fa = false;
  String? _pending2faEmail;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isInitialized => _isInitialized;
  bool get pending2fa => _pending2fa;
  String? get pending2faEmail => _pending2faEmail;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await AuthService.init();
    _user = AuthService.currentUser;
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      print('SIGNUP SUCCESS: ${_user!.name} (${_user!.role})');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      print('SIGNUP ERROR: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    _pending2fa = false;
    _pending2faEmail = null;
    notifyListeners();

    try {
      final user = await AuthService.login(
        email: email,
        password: password,
      );

      if (user.twoFactorEnabled && _user == null) {
        _pending2fa = true;
        _pending2faEmail = email;
        await AuthService.send2faOtp(email: email);
        print('2FA REQUIRED for: $email');
      } else {
        _user = user;
        print('LOGIN SUCCESS: ${_user!.name} (${_user!.role})');
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      print('LOGIN ERROR: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verify2fa({required String otp}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.verify2faOtp(
        email: _pending2faEmail!,
        otp: otp,
      );
      _pending2fa = false;
      _pending2faEmail = null;
      print('2FA VERIFY SUCCESS: ${_user!.name}');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      print('2FA VERIFY ERROR: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void cancel2fa() {
    _pending2fa = false;
    _pending2faEmail = null;
    _error = null;
    notifyListeners();
  }

  Future<void> toggle2FA({required bool enabled}) async {
    final current = _user;
    if (current == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.toggle2FA(enabled: enabled);
      _user = User(
        id: current.id,
        name: current.name,
        email: current.email,
        phone: current.phone,
        role: current.role,
        twoFactorEnabled: enabled,
        createdAt: current.createdAt,
      );
      await ApiService.saveUser(_user!.toJson());
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _pending2fa = false;
    _pending2faEmail = null;
    notifyListeners();
  }
}
