import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/theme_provider.dart';
import '../../services/admin_service.dart';
import '../../services/language_service.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await AdminService.getServices();
      if (mounted) setState(() { _services = services; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.t('failed_load_services')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteService(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: Text(LanguageService.t('delete_service'), style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('${LanguageService.t('delete_confirm')} "$name"?', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(LanguageService.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(LanguageService.t('delete'), style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminService.deleteService(id);
        await _loadServices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LanguageService.t('service_deleted')), backgroundColor: const Color(0xFF00A67E)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LanguageService.t('failed_delete')), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadServices,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LanguageService.t('manage_services_title'),
                                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.02),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  LanguageService.t('manage_services_desc'),
                                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showServiceForm(null),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_services.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.build_outlined, size: 48, color: AppColors.outline),
                                const SizedBox(height: 12),
                                Text(LanguageService.t('no_services_yet'), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                Text(LanguageService.t('tap_plus_create'), style: GoogleFonts.inter(fontSize: 13, color: AppColors.outline)),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._services.map((service) => _buildServiceCard(service)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
            Image.asset('assets/logo.png', height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final isAi = service['category'] == 'ai_dev';
    final price = (service['price'] as num?)?.toDouble() ?? 0;

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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isAi ? AppColors.primary : AppColors.secondary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isAi ? Icons.psychology : Icons.campaign_outlined,
                  color: isAi ? AppColors.primary : AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'] ?? '',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAi ? LanguageService.t('ai_development') : LanguageService.t('digital_marketing'),
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                color: AppColors.surfaceContainerLowest,
                onSelected: (value) {
                  if (value == 'edit') _showServiceForm(service);
                  if (value == 'delete') _deleteService(service['_id'], service['name']);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppColors.onSurface), const SizedBox(width: 8), Text(LanguageService.t('edit'), style: GoogleFonts.inter())])),
                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.error), const SizedBox(width: 8), Text(LanguageService.t('delete'), style: GoogleFonts.inter(color: AppColors.error))])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            (service['description'] ?? '').toString().length > 120
                ? '${(service['description'] as String).substring(0, 120)}...'
                : service['description'] ?? '',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.attach_money, '\$${price.toStringAsFixed(0)}'),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.schedule, service['timeline'] ?? 'TBD'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.outline),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _showServiceForm(Map<String, dynamic>? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ServiceFormSheet(
        existing: existing,
        onSaved: () {
          Navigator.pop(ctx);
          _loadServices();
        },
      ),
    );
  }
}

class _ServiceFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final VoidCallback onSaved;

  const _ServiceFormSheet({this.existing, required this.onSaved});

  @override
  State<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<_ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _timelineController;
  late TextEditingController _useCasesController;
  String _category = 'ai_dev';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?['name'] ?? '');
    _descController = TextEditingController(text: widget.existing?['description'] ?? '');
    _priceController = TextEditingController(text: widget.existing?['price']?.toString() ?? '');
    _timelineController = TextEditingController(text: widget.existing?['timeline'] ?? '');
    final useCases = widget.existing?['useCases'] as List? ?? [];
    _useCasesController = TextEditingController(text: useCases.join(', '));
    _category = widget.existing?['category'] ?? 'ai_dev';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _timelineController.dispose();
    _useCasesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final useCases = _useCasesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final price = double.tryParse(_priceController.text) ?? 0;

      if (widget.existing != null) {
        await AdminService.updateService(
          id: widget.existing!['_id'],
          name: _nameController.text.trim(),
          category: _category,
          description: _descController.text.trim(),
          price: price,
          timeline: _timelineController.text.trim(),
          useCases: useCases,
        );
      } else {
        await AdminService.createService(
          name: _nameController.text.trim(),
          category: _category,
          description: _descController.text.trim(),
          price: price,
          timeline: _timelineController.text.trim(),
          useCases: useCases,
        );
      }
      widget.onSaved();
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.t('failed_save_service')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing != null ? LanguageService.t('edit_service') : LanguageService.t('create_service'),
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const SizedBox(height: 20),
            _buildLabel(LanguageService.t('service_name')),
            const SizedBox(height: 8),
            _buildTextField(_nameController, LanguageService.t('service_name_hint')),
            const SizedBox(height: 16),
            _buildLabel(LanguageService.t('category_label')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildCategoryChip(LanguageService.t('ai_development'), 'ai_dev', AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryChip(LanguageService.t('digital_marketing'), 'digital_marketing', AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel(LanguageService.t('description')),
            const SizedBox(height: 8),
            _buildTextField(_descController, LanguageService.t('describe_service'), maxLines: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(LanguageService.t('price_label')),
                      const SizedBox(height: 8),
                      _buildTextField(_priceController, '0', isNumber: true),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(LanguageService.t('timeline_label')),
                      const SizedBox(height: 8),
                      _buildTextField(_timelineController, LanguageService.t('timeline_hint')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel(LanguageService.t('use_cases_label')),
            const SizedBox(height: 8),
            _buildTextField(_useCasesController, LanguageService.t('use_cases_hint')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          widget.existing != null ? LanguageService.t('update_service') : LanguageService.t('create_service'),
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant, letterSpacing: 0.05));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.inter(fontSize: 14),
      validator: (v) => (v == null || v.trim().isEmpty) ? LanguageService.t('required') : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.outline),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value, Color color) {
    final isSelected = _category == value;
    return GestureDetector(
      onTap: () => setState(() => _category = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.outlineVariant, width: isSelected ? 2 : 1),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? color : AppColors.onSurfaceVariant)),
        ),
      ),
    );
  }
}
