import 'package:flutter/material.dart';

class AppColors {
  static bool _isDark = true;

  static void setDarkMode(bool isDark) {
    _isDark = isDark;
  }

  static Color get primary => const Color(0xFF19ADE4);
  static Color get onPrimary => Colors.white;
  static Color get primaryContainer => const Color(0xFF19ADE4);
  static Color get onPrimaryContainer => _isDark ? const Color(0xFFEEEAFF) : const Color(0xFF001F3D);

  static Color get secondary => const Color(0xFF19ADE4);
  static Color get onSecondary => Colors.white;
  static Color get secondaryContainer => const Color(0xFF3FC0ED);
  static Color get onSecondaryContainer => Colors.white;

  static Color get tertiary => const Color(0xFF005E6E);
  static Color get tertiaryContainer => const Color(0xFF00788C);

  static Color get surface => _isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FF);
  static Color get surfaceDim => _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFCBD8F5);
  static Color get surfaceContainerLowest => _isDark ? const Color(0xFF1A1A1A) : Colors.white;
  static Color get surfaceContainerLow => _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEFF4FF);
  static Color get surfaceContainer => _isDark ? const Color(0xFF252525) : const Color(0xFFE5EEFF);
  static Color get surfaceContainerHigh => _isDark ? const Color(0xFF2C2C2C) : const Color(0xFFDCE9FF);
  static Color get surfaceContainerHighest => _isDark ? const Color(0xFF333333) : const Color(0xFFD3E4FE);

  static Color get onSurface => _isDark ? const Color(0xFFE0E0E0) : const Color(0xFF0B1C30);
  static Color get onSurfaceVariant => _isDark ? const Color(0xFF9E9E9E) : const Color(0xFF434655);

  static Color get outline => _isDark ? const Color(0xFF616161) : const Color(0xFF737686);
  static Color get outlineVariant => _isDark ? const Color(0xFF3A3A3A) : const Color(0xFFC3C6D7);

  static Color get error => _isDark ? const Color(0xFFCF6679) : const Color(0xFFBA1A1A);
  static Color get errorContainer => _isDark ? const Color(0xFF3C1A22) : const Color(0xFFFFDAD6);

  static Color get success => _isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
  static Color get successContainer => _isDark ? const Color(0xFF1B3A1D) : const Color(0xFFD7F1DB);

  static Color get inverseSurface => _isDark ? const Color(0xFFE0E0E0) : const Color(0xFF213145);
  static Color get inverseOnSurface => _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEAF1FF);

  static Color get background => _isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FF);
  static Color get onBackground => _isDark ? const Color(0xFFE0E0E0) : const Color(0xFF0B1C30);

  static Color get surfaceTint => const Color(0xFF19ADE4);

  static Color get inputBackground => _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9);
  static Color get cardBorder => _isDark ? const Color(0xFF2A2A2A) : const Color(0x0A000000);

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [Color(0xFF19ADE4), Color(0xFF19ADE4)],
  );

  static LinearGradient get heroGradient => const LinearGradient(
    colors: [Color(0xFF19ADE4), Color(0xFF19ADE4)],
  );

  static LinearGradient get cardGradient => const LinearGradient(
    colors: [Color(0xFF19ADE4), Color(0xFF19ADE4)],
  );

  static LinearGradient get darkGradient => LinearGradient(
    colors: _isDark
        ? [const Color(0xFF121212), const Color(0xFF0A1E30)]
        : [const Color(0xFF0A1628), const Color(0xFF0A1E30)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Map<String, Color> statusColors = {
    'new': const Color(0xFF19ADE4),
    'in_progress': const Color(0xFF005E6E),
    'pending': const Color(0xFFE8A317),
    'waiting': const Color(0xFF19ADE4),
    'completed': const Color(0xFF00A67E),
    'in_discussion': const Color(0xFF005E6E),
  };
}
