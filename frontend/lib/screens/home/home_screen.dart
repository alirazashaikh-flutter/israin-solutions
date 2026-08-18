import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../models/rating.dart';
import '../../models/service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/inquiry_service.dart';
import '../../services/language_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<Service> _selectedForCompare = [];
  List<Rating> _ratings = [];
  bool _isLoadingRatings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sp = context.read<ServiceProvider>();
      sp.loadServices();
      sp.loadFavorites();
      _loadRatings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Service> _filteredServices(ServiceProvider provider) {
    List<Service> all = provider.services;
    if (_searchQuery.isNotEmpty) {
      all = all.where((s) =>
        s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    if (_selectedFilter != 'All') {
      final cat = _selectedFilter == 'AI Development' ? 'ai_dev' : 'digital_marketing';
      all = all.where((s) => s.category == cat).toList();
    }
    return all;
  }

  Future<void> _loadRatings() async {
    setState(() => _isLoadingRatings = true);
    try {
      final ratings = await InquiryService.getRatings();
      if (mounted) setState(() => _ratings = ratings);
    } catch (_) {}
    if (mounted) setState(() => _isLoadingRatings = false);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final serviceProvider = context.watch<ServiceProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildHeroBanner(context),
              _buildShopCard(context),
              _buildSearchBar(),
              _buildServicesSection(context, serviceProvider),
              _buildFeaturedCards(serviceProvider),
              _buildWhyIsrainSection(),
              _buildTestimonialsSection(),
              const SizedBox(height: 100,)
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedForCompare.length == 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/compare',
                    arguments: List<Service>.from(_selectedForCompare),
                  );
                },
                backgroundColor: AppColors.primary,
                heroTag: 'compare',
                icon: const Icon(Icons.compare_arrows, color: Colors.white),
                label: Text(
                  'Compare (${_selectedForCompare.length})',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (!context.read<AuthProvider>().isAdmin)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/chat-ai'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                heroTag: 'chat',
                child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Image.asset('assets/logo.png', height: 40),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/notifications'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.onSurface,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final userName = context.read<AuthProvider>().user?.name ?? 'User';
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? LanguageService.t('good_morning') : hour < 17 ? LanguageService.t('good_afternoon') : LanguageService.t('good_evening');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF88),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  LanguageService.t('live_analytics'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$greeting, $userName',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LanguageService.t('ready_scale'),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/shop'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.store_outlined, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Browse graphics, web, marketing, AI & more',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.outline, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: LanguageService.t('search_services'),
                hintStyle: GoogleFonts.inter(fontSize: 15, color: AppColors.outline),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurface),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () { _searchController.clear(); setState(() => _searchQuery = ''); },
              child: Icon(Icons.close, color: AppColors.outline, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context, ServiceProvider serviceProvider) {
    final filtered = _filteredServices(serviceProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LanguageService.t('services'), style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/service-categories'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(LanguageService.t('browse_category'), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'AI Development', 'Digital Marketing'].map((f) {
                final isActive = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant)),
                    selected: isActive,
                    onSelected: (_) => setState(() => _selectedFilter = f),
                    backgroundColor: AppColors.surfaceContainerLow,
                    selectedColor: AppColors.primary.withValues(alpha: 0.1),
                    checkmarkColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.outlineVariant)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (serviceProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: AppColors.outline),
                    const SizedBox(height: 8),
                    Text('No services found', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            ...filtered.map((service) => _buildServiceCard(context, service)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Service service) {
    final isAi = service.category == 'ai_dev';
    final icon = isAi ? Icons.psychology : Icons.campaign_outlined;
    final color = isAi ? AppColors.primary : AppColors.secondary;
    final serviceProvider = context.read<ServiceProvider>();
    final isFav = serviceProvider.isFavorite(service.id);
    final isComparing = _selectedForCompare.any((s) => s.id == service.id);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/service-detail', arguments: service.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isComparing ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant,
            width: isComparing ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description.length > 80
                        ? '${service.description.substring(0, 80)}...'
                        : service.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${LanguageService.t('from')} \$${service.price.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        service.timeline,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                      const Spacer(),
                      if (service.requestCount > 10)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            LanguageService.t('popular'),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (service.requestCount > 0)
                        Text(
                          '${service.requestCount} ${LanguageService.t('requests')}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    serviceProvider.toggleFavorite(service.id);
                  },
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.error : AppColors.outline,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isComparing) {
                        _selectedForCompare.removeWhere((s) => s.id == service.id);
                      } else if (_selectedForCompare.length < 2) {
                        _selectedForCompare.add(service);
                      }
                    });
                  },
                  child: Icon(
                    isComparing ? Icons.check_circle : Icons.check_circle_outline,
                    color: isComparing ? AppColors.primary : AppColors.outline,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCards(ServiceProvider serviceProvider) {
    final aiServices = serviceProvider.aiServices;
    if (aiServices.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Development',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...aiServices.take(3).map((service) => _buildServiceCard(context, service)),
        ],
      ),
    );
  }

  Widget _buildWhyIsrainSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.t('why_choose_us'),
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.verified, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      LanguageService.t('verified_ethics'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LanguageService.t('responsible_ai'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.bolt, color: AppColors.secondary, size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      LanguageService.t('high_velocity'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LanguageService.t('deployment_days'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    final placeholders = [
      {'name': 'Ahmed K.', 'text': 'Excellent AI development services!', 'rating': 5},
      {'name': 'Sara M.', 'text': 'Great team, delivered on time.', 'rating': 5},
      {'name': 'Usman R.', 'text': 'Professional digital marketing.', 'rating': 4},
    ];

    final displayItems = _ratings.isNotEmpty
        ? _ratings.map((r) => {
            'name': 'Customer',
            'text': r.review ?? '',
            'rating': r.rating,
          }).toList()
        : placeholders;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.t('what_clients_say'),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: _isLoadingRatings
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: displayItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      final stars = item['rating'] as int;
                      final name = item['name'] as String;
                      final text = item['text'] as String;
                      return _buildTestimonialCard(name: name, text: text, stars: stars);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String name,
    required String text,
    required int stars,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < stars ? Icons.star : Icons.star_border,
                size: 16,
                color: i < stars ? const Color(0xFFF59E0B) : AppColors.outline,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  name[0],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
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
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 16 : 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive
                            ? item['activeIcon'] as IconData
                            : item['icon'] as IconData,
                        color: isActive ? AppColors.primary : AppColors.outline,
                        size: 22,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          item['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
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
