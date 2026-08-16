import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/colors.dart';
import '../../services/auth_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otp.length == 6;

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
                          Text('Verify OTP', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Enter the 6-digit code sent to ${widget.email}', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.6))),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (i) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: i < 5 ? 6 : 0),
                                  height: 56,
                                  child: TextField(
                                    controller: _controllers[i],
                                    focusNode: _focusNodes[i],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.06),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                                    ),
                                    onChanged: (val) {
                                      if (val.isNotEmpty && i < 5) {
                                        _focusNodes[i + 1].requestFocus();
                                      } else if (val.isEmpty && i > 0) {
                                        _focusNodes[i - 1].requestFocus();
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: _isOtpComplete ? AppColors.primaryGradient : null,
                                color: _isOtpComplete ? null : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isOtpComplete ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))] : [],
                              ),
                              child: ElevatedButton(
                                onPressed: (_isOtpComplete && !_isLoading) ? () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    final resetToken = await AuthService.verifyOtp(email: widget.email, otp: _otp);
                                    if (mounted) {
                                      Navigator.pushNamed(context, '/reset-password', arguments: {'email': widget.email, 'resetToken': resetToken});
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      final msg = e.toString().replaceFirst('Exception: ', '');
                                      print('OTP VERIFY ERROR: $msg');
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
                                        Text('Verify', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _isOtpComplete ? Colors.white : Colors.white.withValues(alpha: 0.3))),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, color: _isOtpComplete ? Colors.white : Colors.white.withValues(alpha: 0.3), size: 18),
                                      ]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () async {
                                try {
                                  await AuthService.forgotPassword(email: widget.email);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('OTP resent'), backgroundColor: Color(0xFF00A67E)),
                                    );
                                  }
                                } catch (e) {
                                  // silent
                                }
                              },
                              child: Text('Resend OTP', style: GoogleFonts.inter(color: AppColors.primaryContainer, fontWeight: FontWeight.w500, fontSize: 14)),
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
                          onTap: () => Navigator.pop(context),
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
