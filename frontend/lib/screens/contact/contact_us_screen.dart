import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      await ApiService.post('/inquiries', {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'serviceType': 'contact_form',
        'message': _messageController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message sent! We\'ll get back to you soon.'), backgroundColor: AppColors.success),
        );
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Get in Touch', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                    const SizedBox(height: 8),
                    Text('Have a project in mind? We\'d love to hear from you.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    _buildContactCard(icon: Icons.email_outlined, title: 'Email', subtitle: 'arappsstudio10@gmail.com', onTap: () {}),
                    const SizedBox(height: 12),
                    _buildContactCard(icon: Icons.phone_outlined, title: 'Phone', subtitle: '+92 300 1234567', onTap: () {}),
                    const SizedBox(height: 12),
                    _buildContactCard(icon: Icons.location_on_outlined, title: 'Office', subtitle: 'Lahore, Pakistan', onTap: () {}),
                    const SizedBox(height: 32),
                    Text('Send us a Message', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    const SizedBox(height: 16),
                    _buildContactForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)))),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Text('Contact Us', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineVariant)),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
            ])),
            Icon(Icons.open_in_new, size: 16, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineVariant)),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(controller: _nameController, hint: 'Your Name', validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null),
            const SizedBox(height: 12),
            _buildTextField(controller: _emailController, hint: 'Your Email', keyboardType: TextInputType.emailAddress, validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter valid email';
              return null;
            }),
            const SizedBox(height: 12),
            _buildTextField(controller: _messageController, hint: 'Your Message', maxLines: 4, validator: (v) => (v == null || v.trim().isEmpty) ? 'Message is required' : null),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: _isSending ? null : AppColors.primaryGradient, color: _isSending ? AppColors.outline.withValues(alpha: 0.3) : null, borderRadius: BorderRadius.circular(12)),
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Send Message', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        errorStyle: GoogleFonts.inter(fontSize: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.error)),
      ),
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
    );
  }
}
