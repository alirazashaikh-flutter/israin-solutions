import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../models/inquiry.dart';
import '../../models/inquiry_note.dart';
import '../../providers/inquiry_provider.dart';
import '../../providers/theme_provider.dart';

class AdminInquiriesScreen extends StatefulWidget {
  const AdminInquiriesScreen({super.key});

  @override
  State<AdminInquiriesScreen> createState() => _AdminInquiriesScreenState();
}

class _AdminInquiriesScreenState extends State<AdminInquiriesScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InquiryProvider>().loadInquiries();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return const Color(0xFFE8A317);
      case 'in_discussion':
        return const Color(0xFF005E6E);
      case 'completed':
      case 'resolved':
        return const Color(0xFF00A67E);
      case 'cancelled':
        return const Color(0xFFCF6679);
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
      case 'completed':
      case 'resolved':
        return 'RESOLVED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  List<Inquiry> _filteredList(List<Inquiry> inquiries) {
    if (_filter == 'all') return inquiries;
    if (_filter == 'resolved') {
      return inquiries
          .where((i) => i.status == 'completed' || i.status == 'resolved')
          .toList();
    }
    return inquiries.where((i) => i.status == _filter).toList();
  }

  Future<void> _updateStatus(Inquiry inquiry, String newStatus) async {
    final provider = context.read<InquiryProvider>();
    final success = await provider.updateInquiryStatus(inquiry.id, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Status updated to ${_statusLabel(newStatus)}'
              : 'Failed to update status'),
          backgroundColor: success ? const Color(0xFF00A67E) : AppColors.error,
        ),
      );
    }
  }

  Future<void> _resolveInquiry(Inquiry inquiry) async {
    final provider = context.read<InquiryProvider>();
    final success = await provider.resolveInquiry(inquiry.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Inquiry marked as resolved' : 'Failed to resolve inquiry'),
          backgroundColor: success ? const Color(0xFF00A67E) : AppColors.error,
        ),
      );
    }
  }

  void _showStatusDialog(Inquiry inquiry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Status',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Inquiry: ${inquiry.serviceType == 'ai_dev' ? 'AI Development' : 'Digital Marketing'}',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _buildStatusOption(
                  ctx, inquiry, 'new', 'New', const Color(0xFFE8A317)),
              _buildStatusOption(ctx, inquiry, 'in_discussion',
                  'In Discussion', const Color(0xFF005E6E)),
              _buildStatusOption(ctx, inquiry, 'completed', 'Resolved',
                  const Color(0xFF00A67E)),
              _buildStatusOption(ctx, inquiry, 'cancelled', 'Cancelled',
                  const Color(0xFFCF6679)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(BuildContext ctx, Inquiry inquiry, String value,
      String label, Color color) {
    final isSelected = inquiry.status == value;
    return ListTile(
      onTap: () {
        Navigator.pop(ctx);
        if (!isSelected) _updateStatus(inquiry, value);
      },
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: color,
          size: 20,
        ),
      ),
      title: Text(label,
          style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface)),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: color, size: 20)
          : null,
    );
  }

  void _showInquiryDetail(Inquiry inquiry) {
    final provider = context.read<InquiryProvider>();
    provider.loadNotes(inquiry.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inquiry.name.isNotEmpty
                                ? inquiry.name
                                : (inquiry.serviceType == 'ai_dev'
                                    ? 'AI Development'
                                    : 'Digital Marketing'),
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            inquiry.email,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(inquiry.status)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(inquiry.status),
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(inquiry.status),
                            letterSpacing: 0.05),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    inquiry.message,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (inquiry.status != 'completed' &&
                  inquiry.status != 'resolved' &&
                  inquiry.status != 'cancelled')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A67E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF00A67E).withValues(alpha: 0.3)),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _resolveInquiry(inquiry);
                        },
                        icon: const Icon(Icons.check_circle_outline,
                            size: 18, color: Color(0xFF00A67E)),
                        label: Text('Mark Resolved',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00A67E))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Notes',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface)),
                    const Spacer(),
                    if (inquiry.status != 'completed' &&
                        inquiry.status != 'resolved' &&
                        inquiry.status != 'cancelled')
                      GestureDetector(
                        onTap: () {
                          _showAddNoteDialog(ctx, inquiry, setSheetState);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text('Add',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<InquiryProvider>(
                  builder: (_, prov, _) {
                    if (prov.isLoadingNotes) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (prov.notes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notes_outlined,
                                  size: 36, color: AppColors.outline),
                              const SizedBox(height: 8),
                              Text('No notes yet',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: prov.notes.length,
                      itemBuilder: (_, index) =>
                          _buildNoteItem(prov.notes[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog(
      BuildContext ctx, Inquiry inquiry, StateSetter setSheetState) {
    final noteController = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Note',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface)),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write your note...',
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outlineVariant)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () async {
              final text = noteController.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(dialogCtx);
              final provider = context.read<InquiryProvider>();
              final success = await provider.addNote(inquiry.id, text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Note added' : 'Failed to add note'),
                    backgroundColor:
                        success ? const Color(0xFF00A67E) : AppColors.error,
                  ),
                );
              }
            },
            child: Text('Add',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(InquiryNote note) {
    final date =
        '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(note.authorName,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
              Text(date,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 6),
          Text(note.text,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final inquiryProvider = context.watch<InquiryProvider>();
    final filtered = _filteredList(inquiryProvider.inquiries);

    return Scaffold(
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
                      'All Inquiries',
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          letterSpacing: -0.02),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and respond to customer inquiries.',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                    const SizedBox(height: 16),
                    if (inquiryProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 48, color: AppColors.outline),
                              const SizedBox(height: 12),
                              Text('No inquiries found',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...filtered.map(
                          (inquiry) => _buildInquiryCard(inquiry)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home', 'route': '/admin'},
      {'icon': Icons.store_outlined, 'activeIcon': Icons.store, 'label': 'Shop', 'route': '/shop'},
      {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': 'Inquiries', 'route': '/admin-inquiries'},
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
            bottom: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Image.asset('assets/logo.png', height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'value': 'all', 'label': 'All'},
      {'value': 'new', 'label': 'New'},
      {'value': 'in_discussion', 'label': 'In Discussion'},
      {'value': 'resolved', 'label': 'Resolved'},
    ];

    return Row(
      children: filters.map((f) {
        final isSelected = _filter == f['value'];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(f['label'] as String,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            selected: isSelected,
            selectedColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundColor: AppColors.surfaceContainerLow,
            side: BorderSide(
                color:
                    isSelected ? AppColors.primary : AppColors.outlineVariant),
            onSelected: (_) =>
                setState(() => _filter = f['value'] as String),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInquiryCard(Inquiry inquiry) {
    final color = _statusColor(inquiry.status);
    final label = _statusLabel(inquiry.status);
    final date =
        '${inquiry.createdAt.day}/${inquiry.createdAt.month}/${inquiry.createdAt.year}';
    final isResolved =
        inquiry.status == 'completed' || inquiry.status == 'resolved';
    final isCancelled = inquiry.status == 'cancelled';

    return GestureDetector(
      onTap: () => _showInquiryDetail(inquiry),
      child: Container(
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
                        inquiry.name.isNotEmpty
                            ? inquiry.name
                            : (inquiry.serviceType == 'ai_dev'
                                ? 'AI Development'
                                : 'Digital Marketing'),
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${inquiry.email} • $date',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.outline),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showStatusDialog(inquiry),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                              letterSpacing: 0.05),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 14, color: color),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                inquiry.message.length > 150
                    ? '${inquiry.message.substring(0, 150)}...'
                    : inquiry.message,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.onSurfaceVariant),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: AppColors.outline),
                const SizedBox(width: 4),
                Text(inquiry.phone ?? 'No phone',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.outline)),
                const Spacer(),
                if (!isResolved && !isCancelled)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => _resolveInquiry(inquiry),
                      icon: const Icon(Icons.check_circle_outline, size: 14),
                      label: Text('Mark Resolved',
                          style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00A67E),
                        side: BorderSide(
                            color: const Color(0xFF00A67E)
                                .withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat', arguments: inquiry.id);
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 14),
                  label: Text('Reply',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
