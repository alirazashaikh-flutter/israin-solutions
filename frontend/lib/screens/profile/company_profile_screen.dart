import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/theme_provider.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

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
              _buildCompanyBanner(),
              _buildCompanyInfo(),
              _buildStatsRow(),
              _buildAboutSection(),
              _buildServicesList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Text('Company Profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset('assets/logo.png', color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text('Israin Solutions', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Developing Beyond Imagination', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on_outlined, 'Location', 'Lahore, Pakistan'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email_outlined, 'Email', 'arappsstudio10@gmail.com'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.language_outlined, 'Website', 'israin.com'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today_outlined, 'Founded', '2024'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _buildStatCard('10+', 'Projects\nCompleted'),
          const SizedBox(width: 10),
          _buildStatCard('5+', 'Team\nMembers'),
          const SizedBox(width: 10),
          _buildStatCard('98%', 'Client\nSatisfaction'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Text(number, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About Us', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          const SizedBox(height: 10),
          Text(
            'Israin Solutions is a forward-thinking digital agency specializing in AI-powered solutions and digital marketing. We help businesses transform their operations through cutting-edge technology and data-driven strategies.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    final services = [
      {'icon': Icons.psychology_outlined, 'name': 'AI Development', 'desc': 'Custom AI agents, chatbots, automation'},
      {'icon': Icons.campaign_outlined, 'name': 'Digital Marketing', 'desc': 'SEO, SEM, social media, content'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Our Services', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          const SizedBox(height: 12),
          ...services.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(s['icon'] as IconData, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                      const SizedBox(height: 2),
                      Text(s['desc'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.outline),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
