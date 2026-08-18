import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/theme_provider.dart';
import '../../services/shop_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders = await ShopService.getOrders();
      if (mounted) setState(() => _orders = orders);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'accepted':
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppColors.outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'accepted':
        return 'ACCEPTED';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'delivered':
        return 'DELIVERED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  List<Map<String, dynamic>> _filteredOrders() {
    if (_selectedFilter == 'all') return _orders;
    return _orders.where((o) => o['status'] == _selectedFilter).toList();
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await ShopService.updateOrderStatus(id, newStatus);
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.replaceAll('_', ' ')}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close, color: AppColors.outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Customer', order['customer_name'] ?? order['customerName'] ?? 'Customer'),
              _buildDetailRow('Item', order['item_name'] ?? order['itemName'] ?? order['name'] ?? 'Product'),
              _buildDetailRow('Category', order['category'] ?? 'N/A'),
              _buildDetailRow('Quantity', '${order['quantity'] ?? 1}'),
              _buildDetailRow('Price', '\$${order['price'] ?? 0}'),
              _buildDetailRow('Total', '\$${order['totalAmount'] ?? order['total'] ?? 0}'),
              if (order['requirements'] != null && (order['requirements'] as String).isNotEmpty)
                _buildDetailRow('Requirements', order['requirements']),
              _buildDetailRow('Date', '${order['createdAt'] ?? ''}'),
              const SizedBox(height: 20),
              Text(
                'Update Status',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              ),
              const SizedBox(height: 12),
              _buildStatusButtons(order, status),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButtons(Map<String, dynamic> order, String currentStatus) {
    final id = order['_id'] ?? order['id'];
    final nextStatuses = <Map<String, dynamic>>[];

    switch (currentStatus) {
      case 'pending':
        nextStatuses.add({'status': 'accepted', 'label': 'Accept', 'icon': Icons.check, 'color': AppColors.primary});
        nextStatuses.add({'status': 'cancelled', 'label': 'Cancel', 'icon': Icons.close, 'color': AppColors.error});
        break;
      case 'accepted':
        nextStatuses.add({'status': 'in_progress', 'label': 'Start', 'icon': Icons.play_arrow, 'color': AppColors.primary});
        nextStatuses.add({'status': 'cancelled', 'label': 'Cancel', 'icon': Icons.close, 'color': AppColors.error});
        break;
      case 'in_progress':
        nextStatuses.add({'status': 'delivered', 'label': 'Deliver', 'icon': Icons.check_circle, 'color': AppColors.success});
        nextStatuses.add({'status': 'cancelled', 'label': 'Cancel', 'icon': Icons.close, 'color': AppColors.error});
        break;
    }

    return Wrap(
      spacing: 8,
      children: nextStatuses.map((s) {
        return SizedBox(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(id, s['status']);
            },
            icon: Icon(s['icon'] as IconData, size: 16, color: s['color'] as Color),
            label: Text(
              s['label'],
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: s['color'] as Color,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: s['color'] as Color,
              side: BorderSide(color: s['color'] as Color),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/admin');
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text(
            'Orders',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                      : _filteredOrders().isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadOrders,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                                itemCount: _filteredOrders().length,
                                itemBuilder: (context, index) => _buildOrderCard(_filteredOrders()[index]),
                              ),
                            ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(context, 1),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'all', 'pending', 'accepted', 'in_progress', 'delivered', 'cancelled',
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return FilterChip(
            label: Text(
              filter == 'all' ? 'All' : filter.replaceAll('_', ' ').toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedFilter = filter),
            selectedColor: _selectedFilter == 'pending'
                ? const Color(0xFFF59E0B)
                : _selectedFilter == 'delivered'
                    ? AppColors.success
                    : _selectedFilter == 'cancelled'
                        ? AppColors.error
                        : AppColors.primary,
            backgroundColor: AppColors.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(
              color: isSelected ? Colors.transparent : AppColors.outlineVariant,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final name = order['item_name'] ?? order['itemName'] ?? order['name'] ?? 'Product';
    final customerName = order['customer_name'] ?? order['customerName'] ?? 'Customer';
    final total = order['totalAmount'] ?? order['total'] ?? 0;
    final status = order['status'] ?? 'pending';
    final color = _statusColor(status);
    final date = order['createdAt'] ?? '';

    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$$total',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(status),
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
              ],
            ),
            if (date.toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                date.toString().substring(0, date.toString().length > 10 ? 10 : date.toString().length),
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.outline),
            const SizedBox(height: 12),
            Text('Failed to load orders', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.outline),
            const SizedBox(height: 12),
            Text(
              'No orders found',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedFilter == 'all'
                  ? 'Orders will appear here once customers place them.'
                  : 'No $_selectedFilter orders.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 16 : 12,
                    vertical: 8,
                  ),
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
