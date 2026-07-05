import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../data/dto/medical_service_dto.dart';
import '../data/services_api.dart';
import 'services_controller.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _selectedTab = 'Tất cả';
  MedicalServiceDto? _selectedService;
  bool _isSidebarOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(servicesControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSidebar(MedicalServiceDto service) {
    setState(() {
      _selectedService = service;
      _isSidebarOpen = true;
    });
  }

  void _closeSidebar() {
    setState(() {
      _selectedService = null;
      _isSidebarOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTabs(servicesAsync),
                  const SizedBox(height: 24),
                  servicesAsync.when(
                    data: (services) => _buildServicesList(services),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3949AB)),
                        ),
                      ),
                    ),
                    error: (e, s) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'Lỗi: $e',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sidebar
          if (_isSidebarOpen && _selectedService != null)
            Container(
              width: 420,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(-4, 0),
                  ),
                ],
                border: Border(left: BorderSide(color: Colors.grey.shade100)),
              ),
              child: _ServiceFormSidebar(
                service: _selectedService!,
                onClose: _closeSidebar,
                onSave: (data) async {
                  final isNew = _selectedService!.id.isEmpty;
                  try {
                    if (isNew) {
                      await ref
                          .read(servicesControllerProvider.notifier)
                          .createService(data);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tạo dịch vụ thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      await ref
                          .read(servicesControllerProvider.notifier)
                          .updateService(_selectedService!.id, data);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật dịch vụ thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                    _closeSidebar();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Admin',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('/', style: TextStyle(color: Color(0xFFCBD5E1))),
                const SizedBox(width: 8),
                Text(
                  'Quản lý Dịch vụ',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Danh sách Dịch vụ',
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Quản lý các dịch vụ khám bệnh và tư vấn sức khỏe của phòng khám.',
              style: GoogleFonts.manrope(
                fontSize: 15,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Ô tìm kiếm dịch vụ
            Container(
              width: 320,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tên dịch vụ...',
                  hintStyle: GoogleFonts.manrope(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                _openSidebar(
                  const MedicalServiceDto(
                    id: '',
                    name: '',
                    description: '',
                    price: 200000,
                    durationMinutes: 30,
                    category: 'GENERAL',
                    isActive: true,
                    imageUrl: null,
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'Thêm dịch vụ',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3949AB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                elevation: 2,
                shadowColor: const Color(0xFF3949AB).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs(AsyncValue<List<MedicalServiceDto>> servicesAsync) {
    final categories = ['Tất cả', 'GENERAL', 'NUTRITION', 'PSYCHOLOGY', 'SPECIALIST'];
    final categoryLabels = {
      'Tất cả': 'Tất cả',
      'GENERAL': 'Khám tổng quát',
      'NUTRITION': 'Dinh dưỡng',
      'PSYCHOLOGY': 'Tâm lý',
      'SPECIALIST': 'Chuyên khoa',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedTab == cat;
          int count = 0;
          servicesAsync.whenData((services) {
            if (cat == 'Tất cả') {
              count = services.length;
            } else {
              count = services.where((s) => s.category == cat).length;
            }
          });

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Text('${categoryLabels[cat]} ($count)'),
              onSelected: (_) => setState(() => _selectedTab = cat),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF3949AB).withValues(alpha: 0.08),
              checkmarkColor: const Color(0xFF3949AB),
              labelStyle: GoogleFonts.manrope(
                color: isSelected ? const Color(0xFF3949AB) : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF3949AB) : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServicesList(List<MedicalServiceDto> services) {
    final filtered = services.where((s) {
      final matchesTab = _selectedTab == 'Tất cả' || s.category == _selectedTab;
      final matchesQuery = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery) ||
          (s.description ?? '').toLowerCase().contains(_searchQuery);
      return matchesTab && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_services_outlined, size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy dịch vụ nào phù hợp',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'DỊCH VỤ',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'DANH MỤC',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'GIÁ DỊCH VỤ',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'THỜI LƯỢNG',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'TRẠNG THÁI',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'THAO TÁC',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Body List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final service = filtered[index];
              return _ServiceRow(
                service: service,
                onTap: () => _openSidebar(service),
                onToggle: () {
                  ref.read(servicesControllerProvider.notifier).toggleService(service.id);
                },
                onDelete: () => _confirmDelete(context, service),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MedicalServiceDto service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Xác nhận xóa',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa dịch vụ "${service.name}" không? Hành động này sẽ ẩn dịch vụ khỏi danh sách hiển thị với người dùng.',
          style: GoogleFonts.manrope(fontSize: 15, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(servicesControllerProvider.notifier)
                  .deleteService(service.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Xóa',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Service Card Widget
/// Service Row Widget
class _ServiceRow extends StatefulWidget {
  final MedicalServiceDto service;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ServiceRow({
    required this.service,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_ServiceRow> createState() => _ServiceRowState();
}

class _ServiceRowState extends State<_ServiceRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final categoryColors = {
      'GENERAL': const Color(0xFF0EA5E9),
      'NUTRITION': const Color(0xFF10B981),
      'PSYCHOLOGY': const Color(0xFF8B5CF6),
      'SPECIALIST': const Color(0xFFF97316),
    };

    final categoryLabels = {
      'GENERAL': 'Khám tổng quát',
      'NUTRITION': 'Dinh dưỡng',
      'PSYCHOLOGY': 'Tâm lý',
      'SPECIALIST': 'Chuyên khoa',
    };

    final color = categoryColors[widget.service.category] ?? Colors.grey;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF8FAFC) : Colors.white,
          ),
          child: Row(
            children: [
              // 1. Service Name and Thumbnail
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.service.imageUrl != null &&
                                widget.service.imageUrl!.isNotEmpty
                            ? Image.network(
                                widget.service.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildThumbPlaceholder(color),
                              )
                            : _buildThumbPlaceholder(color),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.name,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.service.description != null && widget.service.description!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.service.description!,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 2. Category Badge
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      categoryLabels[widget.service.category] ?? widget.service.category,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              // 3. Price
              Expanded(
                flex: 2,
                child: Text(
                  _formatPrice(widget.service.price),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              // 4. Duration
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.service.durationMinutes} phút',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              // 5. Status Toggle Switch
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.service.isActive
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.service.isActive ? 'Hiện' : 'Ẩn',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.service.isActive
                              ? const Color(0xFF15803D)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 24,
                      width: 40,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Switch(
                          value: widget.service.isActive,
                          onChanged: (_) => widget.onToggle(),
                          activeThumbColor: const Color(0xFF3949AB),
                          activeTrackColor: const Color(0xFF3949AB).withValues(alpha: 0.2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 6. Actions (Edit / Delete)
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: const Color(0xFF3949AB),
                      onPressed: widget.onTap,
                      tooltip: 'Chỉnh sửa',
                      splashRadius: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: Colors.red.shade500,
                      onPressed: widget.onDelete,
                      tooltip: 'Xóa',
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbPlaceholder(Color color) {
    return Container(
      color: color.withValues(alpha: 0.06),
      child: Center(
        child: Icon(
          Icons.medical_services_outlined,
          size: 20,
          color: color.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final cleanPrice = price.toInt();
    final buffer = StringBuffer();
    final str = cleanPrice.toString();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join('')} đ';
  }
}

/// Sidebar Form Widget
class _ServiceFormSidebar extends ConsumerStatefulWidget {
  final MedicalServiceDto service;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const _ServiceFormSidebar({
    required this.service,
    required this.onClose,
    required this.onSave,
  });

  @override
  ConsumerState<_ServiceFormSidebar> createState() => _ServiceFormSidebarState();
}

class _ServiceFormSidebarState extends ConsumerState<_ServiceFormSidebar> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late String _selectedCategory;
  String? _imageUrl;
  XFile? _pickedImage;
  bool _isUploading = false;
  bool _isSaving = false;

  final List<Map<String, String>> _categories = [
    {'value': 'GENERAL', 'label': 'Khám tổng quát'},
    {'value': 'NUTRITION', 'label': 'Tư vấn dinh dưỡng'},
    {'value': 'PSYCHOLOGY', 'label': 'Tư vấn tâm lý'},
    {'value': 'SPECIALIST', 'label': 'Khám chuyên khoa'},
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.service.name);
    _descController = TextEditingController(text: widget.service.description ?? '');
    _priceController = TextEditingController(text: widget.service.price.toStringAsFixed(0));
    _durationController = TextEditingController(text: widget.service.durationMinutes.toString());
    _selectedCategory = widget.service.category.isNotEmpty ? widget.service.category : 'GENERAL';
    _imageUrl = widget.service.imageUrl;
  }

  @override
  void didUpdateWidget(covariant _ServiceFormSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service.id != widget.service.id) {
      _initControllers();
      _pickedImage = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) return _imageUrl;

    setState(() => _isUploading = true);
    try {
      final api = ref.read(servicesApiProvider);
      final fileName = 'service_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await api.uploadServiceImage(_pickedImage!.path, fileName);
      setState(() {
        _imageUrl = url;
        _isUploading = false;
      });
      return url;
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return _imageUrl;
    }
  }

  Future<void> _handleSave() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên dịch vụ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Upload image if picked
    String? finalImageUrl = _imageUrl;
    if (_pickedImage != null) {
      finalImageUrl = await _uploadImage();
    }

    final data = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 200000,
      'durationMinutes': int.tryParse(_durationController.text) ?? 30,
      'category': _selectedCategory,
      'imageUrl': finalImageUrl,
      'isActive': true,
    };

    setState(() => _isSaving = false);
    widget.onSave(data);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.service.id.isEmpty;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isNew ? 'Thêm dịch vụ mới' : 'Chỉnh sửa dịch vụ',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                splashRadius: 20,
              ),
            ],
          ),
        ),
        // Form Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload Section
                _buildLabel('Ảnh đại diện dịch vụ'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _isUploading
                          ? const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3949AB)),
                              ),
                            )
                          : _buildImagePreview(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                _buildLabel('Tên dịch vụ *'),
                const SizedBox(height: 10),
                _buildTextField(_nameController, 'Nhập tên dịch vụ y tế...'),
                const SizedBox(height: 20),

                // Category Dropdown
                _buildLabel('Danh mục dịch vụ'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat['value'],
                          child: Text(
                            cat['label']!,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Price & Duration Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Giá dịch vụ (đ)'),
                          const SizedBox(height: 10),
                          _buildTextField(
                            _priceController,
                            '200.000',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Thời lượng (phút)'),
                          const SizedBox(height: 10),
                          _buildTextField(
                            _durationController,
                            '30',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                _buildLabel('Mô tả dịch vụ'),
                const SizedBox(height: 10),
                _buildTextField(
                  _descController,
                  'Nhập chi tiết mô tả dịch vụ y tế để bác sĩ và người dùng dễ hiểu...',
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
        // Footer Actions
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(top: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClose,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3949AB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isNew ? 'Thêm dịch vụ' : 'Lưu thay đổi',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(_pickedImage!.path),
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => setState(() => _pickedImage = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildUploadPlaceholder(),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => setState(() => _imageUrl = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    return _buildUploadPlaceholder();
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 44, color: const Color(0xFF3949AB).withValues(alpha: 0.8)),
        const SizedBox(height: 10),
        Text(
          'Nhấp để chọn ảnh tải lên',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hỗ trợ PNG, JPG tối đa 5MB',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF334155),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.manrope(
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3949AB), width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
