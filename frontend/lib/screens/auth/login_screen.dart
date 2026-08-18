import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _show2faDialog = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    return email.isNotEmpty &&
        email.contains('@') &&
        email.contains('.') &&
        password.length >= 6;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _show2faOtpDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final controllers = List.generate(6, (_) => TextEditingController());
    final focusNodes = List.generate(6, (_) => FocusNode());
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final otp = controllers.map((c) => c.text).join();
          final isComplete = otp.length == 6;

          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.security, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Two-Factor Authentication',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to ${auth.pending2faEmail}',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 5 ? 6 : 0),
                        height: 50,
                        child: TextField(
                          controller: controllers[i],
                          focusNode: focusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.outlineVariant)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.outlineVariant)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && i < 5) {
                              focusNodes[i + 1].requestFocus();
                            } else if (val.isEmpty && i > 0) {
                              focusNodes[i - 1].requestFocus();
                            }
                            setDialogState(() {});
                          },
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: isComplete ? AppColors.primaryGradient : null,
                      color: isComplete ? null : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: (isComplete && !isLoading) ? () async {
                        setDialogState(() => isLoading = true);
                        await auth.verify2fa(otp: otp);
                        setDialogState(() => isLoading = false);
                        if (ctx.mounted && auth.user != null) {
                          Navigator.pop(ctx);
                          Navigator.pushNamedAndRemoveUntil(context, auth.isAdmin ? '/admin' : '/home', (route) => false);
                        } else if (ctx.mounted && auth.error != null) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error),
                          );
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                          : Text('Verify', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: isComplete ? Colors.white : AppColors.outline)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    try {
                      await auth.login(email: _emailController.text.trim(), password: _passwordController.text);
                    } catch (_) {}
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('OTP resent'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: Text('Resend OTP', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13)),
                ),
                TextButton(
                  onPressed: () {
                    auth.cancel2fa();
                    Navigator.pop(ctx);
                  },
                  child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.outline, fontSize: 13)),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      for (final c in controllers) { c.dispose(); }
      for (final f in focusNodes) { f.dispose(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.pending2fa && !_show2faDialog) {
      _show2faDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _show2faOtpDialog(context);
      });
    }

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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
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
                          Text('Welcome Back', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Sign in to continue to your AI portal', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.6))),
                          const SizedBox(height: 28),
                          Text('EMAIL ADDRESS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.05)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'name@company.com',
                              hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3)),
                              prefixIcon: Icon(Icons.mail_outline, color: Colors.white.withValues(alpha: 0.4), size: 20),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.06),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('PASSWORD', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.05)),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                child: Text('Forgot Password?', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryContainer, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
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
                                onPressed: auth.isLoading || !_isFormValid ? null : () async {
                                  _show2faDialog = false;
                                  await auth.login(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );
                                  if (mounted) {
                                    if (auth.error != null && !auth.pending2fa) {
                                      print('LOGIN ERROR: ${auth.error}');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(auth.error!), backgroundColor: Colors.red),
                                      );
                                    } else if (auth.user != null && !auth.pending2fa) {
                                      print('LOGIN SUCCESS: ${auth.user!.name} (${auth.user!.role})');
                                      Navigator.pushNamedAndRemoveUntil(context, auth.isAdmin ? '/admin' : '/home', (route) => false);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Text('Sign In', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _isFormValid ? Colors.white : Colors.white.withValues(alpha: 0.3))),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, color: _isFormValid ? Colors.white : Colors.white.withValues(alpha: 0.3), size: 18),
                                      ]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: Text('Sign Up', style: GoogleFonts.inter(color: AppColors.primaryContainer, fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
