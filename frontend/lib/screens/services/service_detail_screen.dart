import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/language_service.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  String _selectedTier = 'Professional';

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final serviceId = ModalRoute.of(context)?.settings.arguments as String?;
    final serviceProvider = context.read<ServiceProvider>();
    final service = serviceProvider.services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => Service(
        id: '',
        name: 'Service',
        category: 'ai_dev',
        description: 'Service details loading...',
        price: 0,
        timeline: 'TBD',
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(service),
                    _buildServiceInfo(service),
                    _buildPricingTiers(service),
                    _buildDescription(service),
                    if (service.useCases.isNotEmpty) _buildUseCases(service),
                    const SizedBox(height: 20),
                    _buildRequestButton(context, service),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final serviceId = ModalRoute.of(context)?.settings.arguments as String?;
    final serviceProvider = context.watch<ServiceProvider>();
    final isFav = serviceProvider.isFavorite(serviceId ?? '');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 36),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (serviceId != null) {
                      serviceProvider.toggleFavorite(serviceId);
                    }
                  },
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.error : AppColors.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(Service service) {
    final isAi = service.category == 'ai_dev';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAi ? 'AI DEVELOPMENT' : 'DIGITAL MARKETING',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.05,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            service.name,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(Service service) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.attach_money,
              label: '${LanguageService.t('from')} Price',
              value: '\$${service.price.toStringAsFixed(0)}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.schedule,
              label: 'Timeline',
              value: service.timeline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.people_outline,
              label: LanguageService.t('requests'),
              value: service.requestCount > 0 ? '${service.requestCount}' : '0',
              badge: service.requestCount > 10 ? LanguageService.t('popular') : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTiers(Service service) {
    final basePrice = service.price;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pricing Tiers', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTierCard('Starter', '\$${(basePrice * 0.8).toStringAsFixed(0)}', '1-2 weeks', ['Basic features', 'Email support', '1 revision'], false)),
              const SizedBox(width: 8),
              Expanded(child: _buildTierCard('Professional', '\$${basePrice.toStringAsFixed(0)}', service.timeline, ['Full features', 'Priority support', '3 revisions', 'Analytics'], true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTierCard('Enterprise', '\$${(basePrice * 1.5).toStringAsFixed(0)}', 'Custom', ['Everything in Pro', 'Dedicated manager', 'Unlimited revisions', 'SLA guarantee'], false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(String name, String price, String timeline, List<String> features, bool isPopular) {
    final isSelected = _selectedTier == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedTier = name),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                child: Text('Popular', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            if (isPopular) const SizedBox(height: 6),
            Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.onSurface)),
            const SizedBox(height: 6),
            Text(price, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(timeline, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
            const SizedBox(height: 8),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check, size: 12, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(f, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(Service service) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Service',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            service.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseCases(Service service) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Use Cases',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...service.useCases.map((useCase) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    useCase,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRequestButton(BuildContext context, Service service) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/inquiry-form',
                arguments: {'serviceId': service.id, 'serviceType': service.category},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  LanguageService.t('request_service'),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    final isAdmin = context.read<AuthProvider>().isAdmin;
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': LanguageService.t('nav_home'), 'route': isAdmin ? '/admin' : '/home'},
      {'icon': Icons.store_outlined, 'activeIcon': Icons.store, 'label': 'Shop', 'route': '/shop'},
      {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': LanguageService.t('nav_inquiries'), 'route': isAdmin ? '/admin-inquiries' : '/my-inquiries'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': LanguageService.t('nav_profile'), 'route': '/profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == currentIndex;
              return GestureDetector(
                onTap: () {
                  if (index != currentIndex) {
                    Navigator.pushReplacementNamed(context, item['route'] as String);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? item['activeIcon'] as IconData : item['icon'] as IconData,
                        color: isActive ? AppColors.primary : AppColors.outline,
                        size: 22,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          item['label'] as String,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
