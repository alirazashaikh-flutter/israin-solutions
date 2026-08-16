import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeLogo;
  late Animation<double> _fadeText;
  late Animation<double> _fadeTagline;
  late Animation<double> _fadeLoader;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _fadeLogo = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _fadeText = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));
    _fadeTagline = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.9, curve: Curves.easeOut)));
    _fadeLoader = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAuth() {
    final auth = context.read<AuthProvider>();

    if (auth.isInitialized) {
      _navigate(auth);
      return;
    }

    auth.addListener(() {
      if (auth.isInitialized && mounted) {
        _navigate(auth);
      }
    });
  }

  void _navigate(AuthProvider auth) async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (onboardingDone) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeLogo,
              
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Image.asset('assets/logo.png', height: 80),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeText,
              child: Text(
                'Israin Solutions',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.01),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _fadeTagline,
              child: Text(
                'Developing Beyond Imagination',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fadeLoader,
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
