import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/theme_provider.dart';
import '../../services/language_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final String title;
  const PrivacyPolicyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final isPrivacy = title.toLowerCase().contains('privacy');
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
                      title,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPrivacy ? LanguageService.t('privacy_policy') : LanguageService.t('terms_of_service'),
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LanguageService.t('last_updated'),
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline),
                    ),
                    const SizedBox(height: 24),
                    if (isPrivacy) ..._buildPrivacyContent() else ..._buildTermsContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPrivacyContent() {
    return [
      _buildSection('1. Information We Collect',
        'We collect information you provide directly: name, email, phone number, and project details when you submit an inquiry. We also collect usage data including device information, IP address, and browsing patterns within the app.'),
      _buildSection('2. How We Use Your Information',
        'Your information is used to: respond to your inquiries, provide requested services, send project updates, improve our AI models, and communicate about our services. We do not sell your personal information to third parties.'),
      _buildSection('3. Data Storage & Security',
        'All data is stored securely using industry-standard encryption. We use MongoDB Atlas with SSL/TLS encryption. Your data is retained for as long as your account is active or as needed to provide services.'),
      _buildSection('4. AI & Data Processing',
        'Our AI chatbot may process your messages to provide automated responses. This data is used to improve our services and is not shared externally. You can opt out of AI processing at any time.'),
      _buildSection('5. Your Rights',
        'You have the right to: access your data, correct inaccurate data, delete your account and data, and opt out of marketing communications. Contact us at privacy@israin.com for any requests.'),
      _buildSection('6. Contact Us',
        'For privacy-related inquiries, contact us at privacy@israin.com or through the app\'s support chat.'),
    ];
  }

  List<Widget> _buildTermsContent() {
    return [
      _buildSection('1. Acceptance of Terms',
        'By using Israin Solutions, you agree to these Terms of Service. If you do not agree, please do not use our services.'),
      _buildSection('2. Services',
        'Israin Solutions provides AI development and digital marketing services. Service details, pricing, and timelines are provided in individual proposals and agreements.'),
      _buildSection('3. User Responsibilities',
        'You are responsible for maintaining the confidentiality of your account, providing accurate information, and complying with applicable laws.'),
      _buildSection('4. Payment Terms',
        'Payment terms are specified in individual service agreements. Late payments may result in service suspension.'),
      _buildSection('5. Intellectual Property',
        'Project deliverables become your property upon full payment. Israin Solutions retains rights to general methodologies and tools developed.'),
      _buildSection('6. Limitation of Liability',
        'Israin Solutions shall not be liable for indirect, incidental, or consequential damages. Our total liability shall not exceed the amount paid for the specific service.'),
      _buildSection('7. Contact Us',
        'For questions about these terms, contact us at legal@israin.com.'),
    ];
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.6),
          ),
        ],
      ),
    );
  }
}
