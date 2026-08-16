import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static Future<void> init() async {
    await ApiService.loadToken();
    final userData = await ApiService.loadUserAsync();
    if (userData != null) {
      _currentUser = User.fromJson(userData);
    }
  }

  static Future<User> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'customer',
  }) async {
    final response = await ApiService.post('/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    });

    await ApiService.setToken(response['token']);
    await ApiService.saveUser(response['user']);
    _currentUser = User.fromJson(response['user']);
    return _currentUser!;
  }

  static Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final user = User.fromJson(response['user']);

    if (user.twoFactorEnabled) {
      return user;
    }

    await ApiService.setToken(response['token']);
    await ApiService.saveUser(response['user']);
    _currentUser = user;
    return _currentUser!;
  }

  static Future<void> send2faOtp({required String email}) async {
    await ApiService.post('/auth/send-2fa-otp', {'email': email});
  }

  static Future<User> verify2faOtp({required String email, required String otp}) async {
    final response = await ApiService.post('/auth/verify-2fa-otp', {
      'email': email,
      'otp': otp,
    });

    await ApiService.setToken(response['token']);
    await ApiService.saveUser(response['user']);
    _currentUser = User.fromJson(response['user']);
    return _currentUser!;
  }

  static Future<void> toggle2FA({required bool enabled}) async {
    await ApiService.put('/auth/toggle-2fa', {'enabled': enabled});
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (_) {}
    await ApiService.setToken(null);
    await ApiService.clearUser();
    _currentUser = null;
  }

  static Future<void> forgotPassword({required String email}) async {
    await ApiService.post('/auth/forgot-password', {'email': email});
  }

  static Future<String> verifyOtp({required String email, required String otp}) async {
    final response = await ApiService.post('/auth/verify-otp', {
      'email': email,
      'otp': otp,
    });
    return response['resetToken'];
  }

  static Future<void> resetPassword({required String resetToken, required String newPassword}) async {
    await ApiService.post('/auth/reset-password', {
      'resetToken': resetToken,
      'newPassword': newPassword,
    });
  }
}
