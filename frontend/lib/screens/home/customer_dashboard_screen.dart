import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../models/inquiry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inquiry_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/inquiry_service.dart';
import '../../services/language_service.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  List<Inquiry> _recentInquiries = [];
  int _ratingsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final inquiryProvider = context.read<InquiryProvider>();
    try {
      await inquiryProvider.loadInquiries();
      final ratings = await InquiryService.getRatings();
      if (mounted) {
        setState(() {
          _recentInquiries = inquiryProvider.inquiries.take(5).toList();
          _ratingsCount = ratings.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final inquiryProvider = context.watch<InquiryProvider>();
    final userName = auth.user?.name ?? 'User';
    final inquiries = inquiryProvider.inquiries;

    final totalInquiries = inquiries.length;
    final activeChats =
        inquiries.where((i) => i.status == 'in_discussion').length;
    final resolved =
        inquiries.where((i) => i.status == 'completed').length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    _buildWelcome(userName),
                    _buildStatsGrid(
                      totalInquiries: totalInquiries,
                      activeChats: activeChats,
                      resolved: resolved,
                      ratingsCount: _ratingsCount,
                    ),
                    _buildRecentActivity(),
                    _buildQuickActions(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 36),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back, color: AppColors.onSurface, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(String userName) {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? LanguageService.t('good_morning') : hour < 17 ? LanguageService.t('good_afternoon') : LanguageService.t('good_evening');
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
          Text(
            '$greeting, $userName!',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LanguageService.t('overview_account'),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid({
    required int totalInquiries,
    required int activeChats,
    required int resolved,
    required int ratingsCount,
  }) {
    final stats = [
      {'label': LanguageService.t('total_inquiries'), 'value': totalInquiries, 'icon': Icons.help_outline, 'color': AppColors.primary},
      {'label': LanguageService.t('active_chats'), 'value': activeChats, 'icon': Icons.chat_bubble_outline, 'color': const Color(0xFF005E6E)},
      {'label': LanguageService.t('resolved'), 'value': resolved, 'icon': Icons.check_circle_outline, 'color': AppColors.success},
      {'label': LanguageService.t('ratings_given'), 'value': ratingsCount, 'icon': Icons.star_outline, 'color': const Color(0xFFF59E0B)},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 18),
                ),
                const Spacer(),
                Text(
                  '${stat['value']}',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat['label'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.t('recent_activity'),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (_recentInquiries.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Center(
                child: Text(
                  LanguageService.t('no_recent_activity'),
                  style: GoogleFonts.inter(color: AppColors.outline),
                ),
              ),
            )
          else
            ..._recentInquiries.map((inquiry) => _buildActivityItem(inquiry)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Inquiry inquiry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inquiry.serviceType,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  inquiry.message.length > 50
                      ? '${inquiry.message.substring(0, 50)}...'
                      : inquiry.message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusBadge(inquiry.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = AppColors.statusColors[status] ?? AppColors.outline;
    final label = _statusLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'new':
        return LanguageService.t('new');
      case 'in_discussion':
        return LanguageService.t('in_discussion');
      case 'completed':
        return LanguageService.t('resolved');
      case 'pending':
        return LanguageService.t('pending');
      default:
        return status;
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.t('quick_actions'),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: LanguageService.t('new_inquiry'),
                  onTap: () => Navigator.pushNamed(context, '/inquiry-form'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.psychology_outlined,
                  label: LanguageService.t('chat_with_ai'),
                  onTap: () => Navigator.pushNamed(context, '/chat-ai'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.help_outline,
                  label: LanguageService.t('faq'),
                  onTap: () => Navigator.pushNamed(context, '/faq'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
