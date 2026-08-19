import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inquiry_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/language_service.dart';

class InquiryFormScreen extends StatefulWidget {
  const InquiryFormScreen({super.key});

  @override
  State<InquiryFormScreen> createState() => _InquiryFormScreenState();
}

class _InquiryFormScreenState extends State<InquiryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String _serviceType = 'ai_dev';
  String? _serviceId;
  String _budget = '';
  String _priority = 'standard';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        if (args['serviceType'] != null) {
          setState(() => _serviceType = args['serviceType']);
        }
        if (args['serviceId'] != null) {
          setState(() => _serviceId = args['serviceId']);
        }
        if (args['serviceName'] != null) {
          _messageController.text = 'I am interested in ${args['serviceName']}. ';
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final inquiryProvider = context.watch<InquiryProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                children: [
                  Text(
                    LanguageService.t('submit_inquiry'),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.t('tell_about_project'),
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.01,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LanguageService.t('respond_24h'),
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    _buildLabel(LanguageService.t('full_name')),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _nameController, hint: LanguageService.t('name_hint'), icon: Icons.person_outline, readOnly: true),
                    const SizedBox(height: 20),
                    _buildLabel(LanguageService.t('email_address')),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _emailController, hint: LanguageService.t('email_hint'), icon: Icons.mail_outline, readOnly: true),
                    const SizedBox(height: 20),
                    _buildLabel(LanguageService.t('phone_optional')),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _phoneController, hint: LanguageService.t('phone_hint'), icon: Icons.phone_outlined),
                    const SizedBox(height: 20),
                    _buildLabel(LanguageService.t('service_type')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildServiceChip(LanguageService.t('ai_development'), 'ai_dev', AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildServiceChip(LanguageService.t('digital_marketing'), 'digital_marketing', AppColors.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel(LanguageService.t('budget')),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _budget.isEmpty ? null : _budget,
                          hint: Text(LanguageService.t('select_budget'), style: GoogleFonts.inter(color: AppColors.outline, fontSize: 14)),
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceContainerLowest,
                          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.outline),
                          items: [
                            DropdownMenuItem(value: '\$100-\$500', child: Text(LanguageService.t('budget_100_500'), style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface))),
                            DropdownMenuItem(value: '\$500-\$1000', child: Text(LanguageService.t('budget_500_1000'), style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface))),
                            DropdownMenuItem(value: '\$1000+', child: Text(LanguageService.t('budget_1000_plus'), style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface))),
                          ],
                          onChanged: (val) => setState(() => _budget = val ?? ''),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel(LanguageService.t('delivery_priority')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _priority = 'urgent'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _priority == 'urgent' ? AppColors.error.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _priority == 'urgent' ? AppColors.error : AppColors.outlineVariant,
                                  width: _priority == 'urgent' ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(LanguageService.t('urgent_fast'), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _priority == 'urgent' ? AppColors.error : AppColors.onSurfaceVariant)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _priority = 'standard'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _priority == 'standard' ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _priority == 'standard' ? AppColors.primary : AppColors.outlineVariant,
                                  width: _priority == 'standard' ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(LanguageService.t('standard_time'), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _priority == 'standard' ? AppColors.primary : AppColors.onSurfaceVariant)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel(LanguageService.t('your_message')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      maxLines: 5,
                      style: GoogleFonts.inter(fontSize: 14),
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: LanguageService.t('message_hint_form'),
                        hintStyle: GoogleFonts.inter(color: AppColors.outline),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8, top: 14),
                          child: Icon(Icons.message_outlined, color: AppColors.outline, size: 20),
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (inquiryProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(inquiryProvider.error!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: inquiryProvider.isLoading ? null : () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (_budget.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(LanguageService.t('select_budget_error')), backgroundColor: AppColors.error),
                              );
                              return;
                            }
                            try {
                              final success = await inquiryProvider.createInquiry(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                serviceType: _serviceType,
                                message: _messageController.text.trim(),
                                serviceId: _serviceId,
                                budget: _budget,
                                priority: _priority,
                              );
                              if (mounted && success) {
                                _showThankYouDialog();
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed: ${inquiryProvider.error ?? "Unknown error"}'), backgroundColor: AppColors.error),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: inquiryProvider.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(
                                  LanguageService.t('submit_inquiry'),
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                        ),
                      ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.05,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: GoogleFonts.inter(fontSize: 14, color: readOnly ? AppColors.onSurfaceVariant : AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.outline),
        prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildServiceChip(String label, String value, Color color) {
    final isSelected = _serviceType == value;
    return GestureDetector(
      onTap: () => setState(() => _serviceType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? color : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                LanguageService.t('thank_you'),
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                LanguageService.t('thanks_submit'),
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  LanguageService.t('discuss_now'),
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pushReplacementNamed(context, '/chat-ai');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(LanguageService.t('chat_with_ai_bot'), style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    final inquiryProvider = context.read<InquiryProvider>();
                    final lastInquiry = inquiryProvider.inquiries.isNotEmpty ? inquiryProvider.inquiries.first : null;
                    Navigator.pop(dialogContext);
                    Navigator.pushReplacementNamed(context, '/chat', arguments: lastInquiry?.id);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.support_agent, size: 20),
                      const SizedBox(width: 8),
                      Text(LanguageService.t('chat_with_team'), style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text(LanguageService.t('back_to_home'), style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
