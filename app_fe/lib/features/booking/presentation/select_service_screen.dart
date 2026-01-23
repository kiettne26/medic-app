import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../doctor/data/dto/doctor_dto.dart';
import '../data/source/service_api.dart';
import '../data/dto/service_dto.dart';

class SelectServiceScreen extends ConsumerStatefulWidget {
  final DoctorDto? doctor; // Made optional

  const SelectServiceScreen({super.key, this.doctor});

  @override
  ConsumerState<SelectServiceScreen> createState() =>
      _SelectServiceScreenState();
}

class _SelectServiceScreenState extends ConsumerState<SelectServiceScreen> {
  List<ServiceDto> _services = [];
  final Set<String> _selectedServiceIds = {};
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    // If we have a doctor, use their services
    if (widget.doctor != null && widget.doctor!.services != null) {
      final doctorServices = widget.doctor!.services!.map((s) {
        return ServiceDto(
          id: s.id,
          name: s.name,
          description: s.description,
          price: s.price ?? 0,
          durationMinutes: s.durationMinutes ?? 0,
          category: s.category,
          imageUrl: s.imageUrl,
        );
      }).toList();

      setState(() {
        _services = doctorServices;
        _isLoading = false;
      });
      return;
    }

    // Otherwise load all services
    final serviceApi = ref.read(serviceApiProvider);
    final services = await serviceApi.getServices();
    setState(() {
      _services = services;
      // No default selection for multi-select
      _isLoading = false;
    });
  }

  void _toggleService(String serviceId) {
    setState(() {
      if (_selectedServiceIds.contains(serviceId)) {
        _selectedServiceIds.remove(serviceId);
      } else {
        _selectedServiceIds.clear();
        _selectedServiceIds.add(serviceId);
      }
    });
  }

  List<ServiceDto> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;
    final query = _searchQuery.toLowerCase();
    return _services.where((s) {
      return s.name.toLowerCase().contains(query) ||
          (s.category?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  double get _totalPrice {
    return _services
        .where((s) => _selectedServiceIds.contains(s.id))
        .fold(0.0, (sum, s) => sum + (s.price ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      if (widget.doctor != null) ...[
                        _buildDoctorCard(),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'Dịch vụ hiện có',
                        style: TextStyle(
                          color: Color(0xFF5E718D),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Body
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 140),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([_buildServiceList()]),
                  ),
                ),
            ],
          ),

          // Bottom Bar
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDADFE7)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm dịch vụ...',
          prefixIcon: Icon(Icons.search, color: Color(0xFF5E718D)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFDADFE7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Color(0xFF101418),
              ),
            ),
          ),
          Text(
            widget.doctor != null ? 'Chọn dịch vụ khám' : 'Danh sách Dịch vụ',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF101418),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 40), // Spacer for center alignment
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    if (widget.doctor == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDADFE7)),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                image:
                    widget.doctor!.avatarUrl != null &&
                        widget.doctor!.avatarUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.doctor!.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  widget.doctor!.avatarUrl == null ||
                      widget.doctor!.avatarUrl!.isEmpty
                  ? const Icon(Icons.person, size: 32, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BS. ${widget.doctor!.fullName ?? ""}',
                    style: const TextStyle(
                      color: Color(0xFF101418),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.doctor!.specialty ?? 'Chuyên khoa',
                    style: const TextStyle(
                      color: Color(0xFF5E718D),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList() {
    final services = _filteredServices;

    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Không tìm thấy dịch vụ nào',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: services
            .map((service) => _buildServiceCard(service))
            .toList(),
      ),
    );
  }

  Widget _buildServiceCard(ServiceDto service) {
    final isSelected = _selectedServiceIds.contains(service.id);
    final priceStr = NumberFormat('#,###', 'vi').format(service.price);

    return GestureDetector(
      onTap: () => _toggleService(service.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF297EFF)
                : const Color(0xFFDADFE7),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF297EFF).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                image: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(service.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: service.imageUrl == null || service.imageUrl!.isEmpty
                  ? const Icon(
                      Icons.medical_services_outlined,
                      size: 40,
                      color: Colors.grey,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            color: Color(0xFF101418),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Checkbox
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF297EFF)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: const Color(0xFFDADFE7),
                                  width: 2,
                                ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: Color(0xFF5E718D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.durationMinutes} phút',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5E718D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        service.category == 'Video Call'
                            ? Icons.video_camera_front
                            : Icons.medical_information,
                        size: 14,
                        color: const Color(0xFF5E718D),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          service.category == 'Video Call'
                              ? 'Online'
                              : 'Tại phòng khám',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5E718D),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$priceStrđ',
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final hasSelection = _selectedServiceIds.isNotEmpty;
    final totalPriceStr = NumberFormat('#,###', 'vi').format(_totalPrice);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFDADFE7))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đã chọn (${_selectedServiceIds.length})',
                    style: const TextStyle(
                      color: Color(0xFF5E718D),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$totalPriceStrđ',
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: !hasSelection
                  ? null
                  : () {
                      final selectedServices = _services
                          .where((s) => _selectedServiceIds.contains(s.id))
                          .toList();

                      if (widget.doctor != null) {
                        // FLOW 1: Doctor > Service > DateTime
                        context.push(
                          '/select-datetime',
                          extra: {
                            'doctor': widget.doctor,
                            'services': selectedServices, // Pass list
                            // We might need to handle 'service' key if downstream expects single
                            // For now, let's assume downstream needs update or we pass first as primary
                            'service': selectedServices.first,
                            'totalPrice': _totalPrice,
                            'doctorId': widget.doctor!.id,
                            'doctorName': widget.doctor!.fullName,
                            'doctorAvatarUrl': widget.doctor!.avatarUrl,
                          },
                        );
                      } else {
                        // FLOW 2: Service > Doctor > DateTime
                        context.push(
                          '/select-doctor',
                          extra: {
                            'services': selectedServices,
                            'totalPrice': _totalPrice,
                          },
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF297EFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Tiếp tục',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
