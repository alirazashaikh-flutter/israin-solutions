import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/shop_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _error;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view},
    {'name': 'Graphics', 'icon': Icons.design_services},
    {'name': 'Web', 'icon': Icons.language},
    {'name': 'Marketing', 'icon': Icons.campaign_outlined},
    {'name': 'AI', 'icon': Icons.psychology},
    {'name': 'Animation', 'icon': Icons.animation},
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await ShopService.getShopItems(
        category: _selectedCategory == 'All' ? null : _selectedCategory.toLowerCase(),
      );
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text(
            'Shop',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/my-orders'),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.onSurface,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildCategoryFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                      : _items.isEmpty
                          ? _buildEmptyState()
                          : _buildItemsGrid(),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(context, 1),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isActive = _selectedCategory == cat['name'];
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat['name'] == 'All' ? Icons.grid_view : cat['icon'] as IconData,
                  size: 14,
                  color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    cat['name'] as String,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            selected: isActive,
            onSelected: (_) {
              setState(() => _selectedCategory = cat['name'] as String);
              _loadItems();
            },
            backgroundColor: AppColors.surfaceContainerLow,
            selectedColor: AppColors.primary.withValues(alpha: 0.1),
            checkmarkColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.outlineVariant,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100 ? 4 : width >= 700 ? 3 : 2;
        final aspectRatio = crossAxisCount >= 4 ? 0.9 : crossAxisCount == 3 ? 0.8 : 0.72;

        return RefreshIndicator(
          onRefresh: _loadItems,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            itemCount: _items.length,
            itemBuilder: (context, index) => _buildProductCard(_items[index]),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Product';
    final price = item['price'] ?? 30;
    final category = item['category'] ?? 'Graphics';
    final deliveryTime = item['deliveryTime'] ?? '3-5 days';
    final icon = _getCategoryIcon(category);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'From \$$price',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              deliveryTime,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/product-detail', arguments: item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Order Now',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
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
            Text(
              'Failed to load shop items',
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadItems, child: const Text('Retry')),
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
            Icon(Icons.store_outlined, size: 48, color: AppColors.outline),
            const SizedBox(height: 12),
            Text(
              'No items in this category',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later for new products.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'graphics':
        return Icons.design_services;
      case 'web':
        return Icons.language;
      case 'marketing':
        return Icons.campaign_outlined;
      case 'ai':
        return Icons.psychology;
      case 'animation':
        return Icons.animation;
      default:
        return Icons.inventory_2_outlined;
    }
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
