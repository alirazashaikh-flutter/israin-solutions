import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/colors.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;
  const ResetPasswordScreen({super.key, required this.email, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  bool get _isFormValid {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    return password.length >= 6 && password == confirm;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A1628), Color(0xFF0A1E30)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.6),
                      AppColors.secondary.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.5),
                      AppColors.primary.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo.png', height: 36),
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New Password', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Create a new password for your account.', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.6))),
                          const SizedBox(height: 28),
                          Text('NEW PASSWORD', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.05)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3)),
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.4), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white.withValues(alpha: 0.4), size: 20),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.06),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('CONFIRM PASSWORD', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.05)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3)),
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.4), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white.withValues(alpha: 0.4), size: 20),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.06),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          if (_confirmController.text.isNotEmpty && _passwordController.text != _confirmController.text)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('Passwords do not match', style: GoogleFonts.inter(color: Colors.red.shade300, fontSize: 13)),
                            ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: _isFormValid ? AppColors.primaryGradient : null,
                                color: _isFormValid ? null : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isFormValid ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))] : [],
                              ),
                              child: ElevatedButton(
                                onPressed: (_isFormValid && !_isLoading) ? () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    await AuthService.resetPassword(
                                      resetToken: widget.resetToken,
                                      newPassword: _passwordController.text,
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Password reset successful!'), backgroundColor: Color(0xFF00A67E)),
                                      );
                                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      final msg = e.toString().replaceFirst('Exception: ', '');
                                      print('RESET PASSWORD ERROR: $msg');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(msg), backgroundColor: Colors.red),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _isLoading = false);
                                  }
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Text('Reset Password', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _isFormValid ? Colors.white : Colors.white.withValues(alpha: 0.3))),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, color: _isFormValid ? Colors.white : Colors.white.withValues(alpha: 0.3), size: 18),
                                      ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Back to ', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                          child: Text('Sign In', style: GoogleFonts.inter(color: AppColors.primaryContainer, fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
