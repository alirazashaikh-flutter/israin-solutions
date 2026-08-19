import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/colors.dart';
import '../../models/service.dart';
import '../../providers/theme_provider.dart';
import '../../services/language_service.dart';
import 'package:provider/provider.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final services = ModalRoute.of(context)?.settings.arguments as List<Service>? ?? const [];

    if (services.length < 2) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainerLowest,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            LanguageService.t('compare_services'),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Text(LanguageService.t('select_2_compare')),
        ),
      );
    }

    final a = services[0];
    final b = services[1];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LanguageService.t('compare_services'),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildServiceHeader(a, AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _buildServiceHeader(b, AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 20),
            _buildCompareTable(a, b),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceHeader(Service service, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              service.category == 'ai_dev' ? LanguageService.t('ai_development') : LanguageService.t('marketing'),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            service.name,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            service.description.length > 60
                ? '${service.description.substring(0, 60)}...'
                : service.description,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompareTable(Service a, Service b) {
    final rows = [
      (LanguageService.t('price'), '\$${a.price.toStringAsFixed(0)}', '\$${b.price.toStringAsFixed(0)}'),
      (LanguageService.t('timeline'), a.timeline, b.timeline),
      (LanguageService.t('category'), a.category == 'ai_dev' ? LanguageService.t('ai_development') : LanguageService.t('digital_marketing'),
          b.category == 'ai_dev' ? LanguageService.t('ai_development') : LanguageService.t('digital_marketing')),
      (LanguageService.t('use_cases'), '${a.useCases.length} included', '${b.useCases.length} included'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    LanguageService.t('feature'),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    a.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    b.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Data rows
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            final isEven = i % 2 == 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: isEven ? Colors.transparent : AppColors.surfaceContainerLow.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$3,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
          // Use cases section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.t('use_cases'),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildUseCases(a.useCases, AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildUseCases(b.useCases, AppColors.secondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseCases(List<String> useCases, Color color) {
    if (useCases.isEmpty) {
      return Text(
        LanguageService.t('no_use_cases'),
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.outline,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: useCases.map((uc) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                uc,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
