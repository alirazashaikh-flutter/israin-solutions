import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String appName = 'Israin Solutions';

  // Backend URL — Bonto par deploy hai, kisi bhi WiFi/phone se chalega
  static const String _bontoHost = 'https://israin-backend.bonto.run';

  static String get baseUrl {
    if (kIsWeb) return '$_bontoHost/api';
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return '$_bontoHost/api';
    }
    return '$_bontoHost/api';
  }
}
