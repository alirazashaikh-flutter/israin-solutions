import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../models/inquiry.dart';
import '../../models/rating.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inquiry_provider.dart';
import '../../providers/theme_provider.dart';

class MyInquiriesScreen extends StatefulWidget {
  const MyInquiriesScreen({super.key});

  @override
  State<MyInquiriesScreen> createState() => _MyInquiriesScreenState();
}

class _MyInquiriesScreenState extends State<MyInquiriesScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InquiryProvider>().loadInquiries();
      context.read<InquiryProvider>().loadRatings();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return const Color(0xFFF59E0B);
      case 'in_discussion':
        return const Color(0xFF3B82F6);
      case 'resolved':
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppColors.outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'new':
        return 'NEW';
      case 'in_discussion':
        return 'IN DISCUSSION';
      case 'resolved':
        return 'RESOLVED';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  List<Inquiry> _filteredInquiries(List<Inquiry> inquiries) {
    if (_selectedFilter == 'all') return inquiries;
    return inquiries.where((i) => i.status == _selectedFilter).toList();
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'new', 'label': 'New'},
      {'key': 'in_discussion', 'label': 'In Discussion'},
      {'key': 'resolved', 'label': 'Resolved'},
      {'key': 'cancelled', 'label': 'Cancelled'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          return FilterChip(
            label: Text(
              filter['label']!,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter['key']!;
              });
            },
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceContainerLow,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Future<void> _cancelInquiry(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Inquiry',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to cancel this inquiry?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes, Cancel', style: GoogleFonts.inter(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<InquiryProvider>().cancelInquiry(id);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to cancel inquiry',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Rating? _existingRating(Inquiry inquiry) {
    final ratings = context.read<InquiryProvider>().ratings;
    for (final r in ratings) {
      if (r.inquiryId == inquiry.id) return r;
    }
    return null;
  }

  void _showRatingDialog(Inquiry inquiry) {
    final existing = _existingRating(inquiry);
    final isRated = existing != null;
    int selectedRating = existing?.rating ?? 0;
    final reviewController =
        TextEditingController(text: existing?.review ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            isRated ? 'Your Rating' : 'Rate Service',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: isRated
                        ? null
                        : () => setDialogState(() {
                              selectedRating = starIndex;
                            }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starIndex <= selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        size: 36,
                        color: starIndex <= selectedRating
                            ? const Color(0xFFF59E0B)
                            : AppColors.outline,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                readOnly: isRated,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Optional review',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.outline,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isRated ? 'Close' : 'Cancel',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
              ),
            ),
            if (!isRated)
              TextButton(
                onPressed: selectedRating == 0
                    ? null
                    : () async {
                        Navigator.pop(context);
                        final success =
                            await context.read<InquiryProvider>().submitRating(
                                  inquiry.id,
                                  selectedRating,
                                  reviewController.text.isEmpty
                                      ? null
                                      : reviewController.text,
                                );
                        if (mounted && !success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to submit rating',
                                style: GoogleFonts.inter(),
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                child: Text(
                  'Submit',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final inquiryProvider = context.watch<InquiryProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'My Inquiries',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.02,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track and manage your ongoing AI project collaborations.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                    const SizedBox(height: 20),
                    if (inquiryProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (inquiryProvider.error != null)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.error_outline, size: 48, color: AppColors.outline),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load inquiries',
                              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => inquiryProvider.loadInquiries(),
                              child: Text('Retry', style: GoogleFonts.inter(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      )
                    else if (inquiryProvider.inquiries.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.inbox_outlined, size: 48, color: AppColors.outline),
                            const SizedBox(height: 12),
                            Text(
                              'No inquiries yet',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Submit your first inquiry to get started.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._filteredInquiries(inquiryProvider.inquiries).map((inquiry) => _buildInquiryCard(inquiry)),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Need to start something new?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
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
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/inquiry-form'),
                          icon: const Icon(Icons.add, color: Colors.white, size: 20),
                          label: Text(
                            'Submit New Inquiry',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/notifications'),
              child: Icon(Icons.notifications_outlined, color: AppColors.onSurface, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryCard(Inquiry inquiry) {
    final color = _statusColor(inquiry.status);
    final label = _statusLabel(inquiry.status);
    final date = '${inquiry.createdAt.day}/${inquiry.createdAt.month}/${inquiry.createdAt.year}';
    final existing = _existingRating(inquiry);
    final isRated = existing != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inquiry.serviceType == 'ai_dev' ? 'AI Development' : 'Digital Marketing',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Submitted on $date',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.05,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              inquiry.message.length > 120
                  ? '${inquiry.message.substring(0, 120)}...'
                  : inquiry.message,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (inquiry.status == 'new' || inquiry.status == 'in_discussion')
                TextButton(
                  onPressed: () => _cancelInquiry(inquiry.id),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                )
              else if (inquiry.status == 'resolved')
                isRated
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: const Color(0xFFF59E0B), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${existing.rating}.0',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 6),
                          TextButton(
                            onPressed: () => _showRatingDialog(inquiry),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.onSurfaceVariant,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'View',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )
                    : TextButton.icon(
                        onPressed: () => _showRatingDialog(inquiry),
                        icon: const Icon(Icons.star_border, size: 16),
                        label: Text(
                          'Rate Service',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFF59E0B),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
              else
                const SizedBox.shrink(),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/chat', arguments: inquiry.id);
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  inquiry.status == 'completed' || inquiry.status == 'resolved'
                      ? 'View Details'
                      : 'Open Conversation',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home', 'route': '/home'},
      {'icon': Icons.store_outlined, 'activeIcon': Icons.store, 'label': 'Shop', 'route': '/shop'},
      {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': 'Inquiries', 'route': isAdmin ? '/admin' : '/my-inquiries'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profile', 'route': '/profile'},
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
