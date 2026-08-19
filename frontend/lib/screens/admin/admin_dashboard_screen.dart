import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../models/rating.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/admin_service.dart';
import '../../services/inquiry_service.dart';
import '../../services/language_service.dart';
import '../../services/notification_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;
  List<Rating> _ratings = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final stats = await AdminService.getStats();
      final ratings = await InquiryService.getRatings();
      if (mounted) setState(() { _stats = stats; _ratings = ratings; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final userName = context.read<AuthProvider>().user?.name ?? 'Admin';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildGreeting(userName),
                _buildActionButtons(context),
                if (_isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ))
                else if (_error != null)
                  Center(child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.outline),
                        const SizedBox(height: 12),
                        Text(LanguageService.t('failed_load_services'), style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        TextButton(onPressed: _loadStats, child: Text(LanguageService.t('retry'))),
                      ],
                    ),
                  ))
                else ...[
                  _buildStatsGrid(),
                  _buildStatusBreakdownChart(),
                  _buildRecentReviews(),
                  _buildInquiryBreakdown(),
                  _buildRecentInquiries(),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 36),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.notifications_outlined, color: AppColors.onSurface, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(String userName) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? LanguageService.t('good_morning') : hour < 17 ? LanguageService.t('good_afternoon') : LanguageService.t('good_evening');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  LanguageService.t('live_analytics'),
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
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
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/admin-services'),
                  icon: const Icon(Icons.build_outlined, size: 18),
                  label: Text(LanguageService.t('manage_services'), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/admin-inquiries'),
                    icon: const Icon(Icons.list_alt, size: 18, color: Colors.white),
                    label: Text(LanguageService.t('view_inquiries'), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showBroadcastDialog,
              icon: const Icon(Icons.campaign_outlined, size: 18),
              label: Text(LanguageService.t('broadcast_message'), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox.shrink();
    final stats = [
      {
        'title': LanguageService.t('total_inquiries'),
        'value': '${_stats!['totalInquiries'] ?? 0}',
        'subtitle': '${_stats!['newInquiries'] ?? 0} ${LanguageService.t('new')}',
        'icon': Icons.chat_bubble_outline,
        'color': AppColors.primary,
      },
      {
        'title': LanguageService.t('in_discussion'),
        'value': '${_stats!['inDiscussion'] ?? 0}',
        'subtitle': LanguageService.t('active_conversations'),
        'icon': Icons.forum_outlined,
        'color': const Color(0xFFE8A317),
      },
      {
        'title': LanguageService.t('resolved'),
        'value': '${_stats!['completed'] ?? 0}',
        'subtitle': LanguageService.t('projects_delivered'),
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF00A67E),
      },
      {
        'title': LanguageService.t('total_customers'),
        'value': '${_stats!['totalCustomers'] ?? 0}',
        'subtitle': LanguageService.t('registered_users'),
        'icon': Icons.people_outline,
        'color': AppColors.secondary,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Wrap(
            children: stats.map((s) {
              return Container(
                width: wide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth,
                margin: EdgeInsets.only(bottom: 10, right: wide ? 10 : 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['title'] as String, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 6),
                          Text(
                            s['value'] as String,
                            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.02),
                          ),
                          const SizedBox(height: 4),
                          Text(s['subtitle'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline)),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (s['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 22),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatusBreakdownChart() {
    if (_stats == null) return const SizedBox.shrink();
    final newCount = (_stats!['newInquiries'] as num?)?.toInt() ?? 0;
    final discussionCount = (_stats!['inDiscussion'] as num?)?.toInt() ?? 0;
    final resolvedCount = (_stats!['completed'] as num?)?.toInt() ?? 0;
    final totalCount = newCount + discussionCount + resolvedCount;

    if (totalCount == 0) return const SizedBox.shrink();

    final statuses = [
      {'label': LanguageService.t('new'), 'count': newCount, 'color': const Color(0xFFE8A317)},
      {'label': LanguageService.t('in_discussion'), 'count': discussionCount, 'color': const Color(0xFF005E6E)},
      {'label': LanguageService.t('resolved'), 'count': resolvedCount, 'color': const Color(0xFF00A67E)},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageService.t('inquiry_status'),
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Text('$totalCount total inquiries',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 20),
          ...statuses.map((s) {
            final count = s['count'] as int;
            final fraction = totalCount > 0 ? count / totalCount : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: s['color'] as Color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(s['label'] as String,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurface)),
                        ],
                      ),
                      Text('$count',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(
                              width: constraints.maxWidth,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.outlineVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              width: constraints.maxWidth * fraction,
                              height: 8,
                              decoration: BoxDecoration(
                                color: s['color'] as Color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat(
                icon: Icons.people_outline,
                label: LanguageService.t('customers'),
                value: '${_stats!['totalCustomers'] ?? 0}',
                color: AppColors.secondary,
              ),
              Container(width: 1, height: 32, color: AppColors.outlineVariant),
              _buildMiniStat(
                icon: Icons.build_outlined,
                label: LanguageService.t('services'),
                value: '${_stats!['totalServices'] ?? 0}',
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface)),
        const SizedBox(height: 2),
        Text(label,
            style:
                GoogleFonts.inter(fontSize: 12, color: AppColors.outline)),
      ],
    );
  }

  Widget _buildRecentReviews() {
    if (_ratings.isEmpty) return const SizedBox.shrink();

    final recent = _ratings.length > 5 ? _ratings.sublist(0, 5) : _ratings;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LanguageService.t('view_all_reviews'),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_ratings.length}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            LanguageService.t('recent_reviews'),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...recent.map((r) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            'C',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LanguageService.t('customer'),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < r.rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: i < r.rating ? const Color(0xFFF59E0B) : AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ),
                if (r.review != null && r.review!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    r.review!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInquiryBreakdown() {
    if (_stats == null) return const SizedBox.shrink();
    final byService = _stats!['inquiriesByService'] as List? ?? [];
    final botRate = _stats!['botResolutionRate'] ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageService.t('breakdown'), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          const SizedBox(height: 16),
          ...byService.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      item['_id'] == 'ai_dev' ? Icons.psychology : Icons.campaign_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['_id'] == 'ai_dev' ? LanguageService.t('ai_development') : LanguageService.t('digital_marketing'),
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item['count']}',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          )),
          if (byService.isEmpty)
            Text(LanguageService.t('no_inquiries_yet'), style: GoogleFonts.inter(fontSize: 14, color: AppColors.outline)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LanguageService.t('bot_resolution_rate'), style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface)),
              Text(
                '$botRate%',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (botRate as num).toDouble() / 100,
              backgroundColor: AppColors.outlineVariant,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInquiries() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LanguageService.t('quick_actions'), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            icon: Icons.list_alt,
            color: AppColors.primary,
            title: LanguageService.t('manage_inquiries'),
            subtitle: LanguageService.t('manage_inquiries_desc'),
            onTap: () => Navigator.pushNamed(context, '/admin-inquiries'),
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            icon: Icons.build_outlined,
            color: AppColors.secondary,
            title: LanguageService.t('manage_services'),
            subtitle: LanguageService.t('manage_services_desc'),
            onTap: () => Navigator.pushNamed(context, '/admin-services'),
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            icon: Icons.shopping_bag_outlined,
            color: const Color(0xFF00A67E),
            title: LanguageService.t('manage_orders'),
            subtitle: LanguageService.t('manage_orders_desc'),
            onTap: () => Navigator.pushNamed(context, '/admin-orders'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': LanguageService.t('nav_home'), 'route': '/admin'},
      {'icon': Icons.store_outlined, 'activeIcon': Icons.store, 'label': LanguageService.t('nav_shop'), 'route': '/shop'},
      {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': LanguageService.t('nav_inquiries'), 'route': '/admin-inquiries'},
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
                        Text(item['label'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
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

  void _showBroadcastDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LanguageService.t('broadcast_message'), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: AppColors.outline)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(LanguageService.t('send_message_all'), style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: LanguageService.t('title'),
                    hintText: LanguageService.t('title_hint'),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? LanguageService.t('title_required') : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: LanguageService.t('message'),
                    hintText: LanguageService.t('message_hint'),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? LanguageService.t('message_required') : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(context);
                        try {
                          final result = await NotificationService.broadcast(
                            title: titleController.text.trim(),
                            message: messageController.text.trim(),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'] ?? 'Broadcast sent'), backgroundColor: AppColors.success),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(LanguageService.t('send_to_all'), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
