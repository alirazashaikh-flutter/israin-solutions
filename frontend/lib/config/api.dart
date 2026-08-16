import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String appName = 'Israin Solutions';

  // REAL PHONE ka LAN IP yahan daalo (same WiFi par). Web/desktop par localhost use hota hai.
  // Note: Router ke DHCP Reservation se IP kabhi na bade (PC config badalne ki zaroorat nahi).
  static const String _lanHost = '192.168.18.14';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://$_lanHost:5000/api';
    }
    return 'http://localhost:5000/api';
  }
}
