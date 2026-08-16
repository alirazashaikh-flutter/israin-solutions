import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxContentWidth = 1200,
  });

  final Widget child;
  final double maxContentWidth;

  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 700;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 700 && width < 1000;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1000;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop(context)) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? const Color(0xFF0B0F14) : const Color(0xFFE6E9EF),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
