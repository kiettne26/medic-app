import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../doctors/data/dto/doctor_dto.dart';
import '../../doctors/presentation/doctors_controller.dart';
import '../../services/data/dto/medical_service_dto.dart';
import '../../services/presentation/services_controller.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  String _selectedTab = 'Tất cả bác sĩ';
  DoctorDto? _selectedDoctor;
  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(doctorsControllerProvider.notifier).refresh();
      ref.read(servicesControllerProvider.notifier).refresh();
    });
  }

  void _openSidebar(DoctorDto doctor) {
    setState(() {
      _selectedDoctor = doctor;
      _isSidebarOpen = true;
    });
  }

  void _closeSidebar() {
    setState(() {
      _selectedDoctor = null;
      _isSidebarOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
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
                  _buildTabs(doctorsAsync),
                  const SizedBox(height: 24),
                  doctorsAsync.when(
                    data: (doctors) => _buildTable(doctors),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Lỗi: $e')),
                  ),
                ],
              ),
            ),
          ),
          // Sidebar
          if (_isSidebarOpen)
            Container(
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: Colors.grey.shade200)),
              ),
              child: _buildSidebar(),
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
                    color: const Color(0xFF5F718C),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('/', style: TextStyle(color: Color(0xFF5F718C))),
                const SizedBox(width: 8),
                Text(
                  'Quản lý Bác sĩ',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111418),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Danh sách Bác sĩ',
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111418),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quản lý thông tin chi tiết, chuyên khoa và trạng thái làm việc.',
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: const Color(0xFF5F718C),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            _openSidebar(
              const DoctorDto(
                id: '',
                userId: '',
                fullName: '',
                specialty: '',
                description: '',
                phone: '',
                avatarUrl: '',
                rating: 0,
                totalReviews: 0,
                isAvailable: true,
                consultationFee: 0,
                services: [],
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm bác sĩ mới'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E80FA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            textStyle: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(AsyncValue<List<DoctorDto>> doctorsAsync) {
    final doctors = doctorsAsync.valueOrNull ?? [];
    final allCount = doctors.length;
    final activeCount = doctors.where((d) => d.isAvailable).length;
    final inactiveCount = doctors.where((d) => !d.isAvailable).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Tất cả bác sĩ',
            count: allCount,
            isSelected: _selectedTab == 'Tất cả bác sĩ',
            onTap: () => setState(() => _selectedTab = 'Tất cả bác sĩ'),
          ),
          _TabItem(
            label: 'Đang hoạt động',
            count: activeCount,
            isSelected: _selectedTab == 'Đang hoạt động',
            onTap: () => setState(() => _selectedTab = 'Đang hoạt động'),
          ),
          _TabItem(
            label: 'Tạm dừng',
            count: inactiveCount,
            isSelected: _selectedTab == 'Tạm dừng',
            onTap: () => setState(() => _selectedTab = 'Tạm dừng'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<DoctorDto> doctors) {
    var filteredDoctors = doctors;
    if (_selectedTab == 'Đang hoạt động') {
      filteredDoctors = doctors.where((d) => d.isAvailable).toList();
    } else if (_selectedTab == 'Tạm dừng') {
      filteredDoctors = doctors.where((d) => !d.isAvailable).toList();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF9FAFB),
              ),
              dataRowMinHeight: 72,
              dataRowMaxHeight: 72,
              columns: const [
                DataColumn(label: _TableTitle('BÁC SĨ')),
                DataColumn(label: _TableTitle('CHUYÊN KHOA')),
                DataColumn(label: _TableTitle('KINH NGHIỆM')),
                DataColumn(label: _TableTitle('TRẠNG THÁI')),
                DataColumn(
                  label: _TableTitle('THAO TÁC', align: TextAlign.right),
                  numeric: true,
                ),
              ],
              rows: filteredDoctors.map((doctor) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                doctor.avatarUrl != null &&
                                    doctor.avatarUrl!.isNotEmpty
                                ? NetworkImage(doctor.avatarUrl!)
                                : null,
                            backgroundColor: const Color(
                              0xFF2E80FA,
                            ).withOpacity(0.1),
                            child:
                                (doctor.avatarUrl == null ||
                                    doctor.avatarUrl!.isEmpty)
                                ? Text(
                                    doctor.fullName.isNotEmpty
                                        ? doctor.fullName[0]
                                        : 'D',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E80FA),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  doctor.fullName,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: const Color(0xFF111418),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'ID: ${doctor.id.length >= 8 ? doctor.id.substring(0, 8) : doctor.id}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: const Color(0xFF5F718C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doctor.specialty,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E80FA),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text('${(doctor.totalReviews ?? 0) % 15 + 2} năm'),
                    ), // Mock experience
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: doctor.isAvailable
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              doctor.isAvailable ? 'Hoạt động' : 'Tạm dừng',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: doctor.isAvailable
                                    ? const Color(0xFF10B981)
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: const Color(0xFF5F718C),
                            onPressed: () => _openSidebar(doctor),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red.shade400,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: Text(
                                    'Bạn có chắc chắn muốn xóa bác sĩ ${doctor.fullName}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        await ref
                                            .read(
                                              doctorsControllerProvider
                                                  .notifier,
                                            )
                                            .deleteDoctor(doctor.id);
                                      },
                                      child: const Text(
                                        'Xóa',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          // Pagination (Mock UI)
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hiển thị ${filteredDoctors.take(10).length} của ${filteredDoctors.length} bác sĩ',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF5F718C),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    if (_selectedDoctor == null) return const SizedBox();

    return DoctorFormSidebar(
      doctor: _selectedDoctor!,
      onClose: _closeSidebar,
      onSave: (doctorData) async {
        final isNew = _selectedDoctor!.id.isEmpty;
        if (isNew) {
          await ref
              .read(doctorsControllerProvider.notifier)
              .createDoctor(doctorData);
        } else {
          await ref
              .read(doctorsControllerProvider.notifier)
              .updateDoctor(_selectedDoctor!.id, doctorData);
        }
        _closeSidebar();
        ref.read(doctorsControllerProvider.notifier).refresh();
      },
    );
  }
}

class DoctorFormSidebar extends ConsumerStatefulWidget {
  final DoctorDto doctor;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const DoctorFormSidebar({
    super.key,
    required this.doctor,
    required this.onClose,
    required this.onSave,
  });

  @override
  ConsumerState<DoctorFormSidebar> createState() => _DoctorFormSidebarState();
}

class _DoctorFormSidebarState extends ConsumerState<DoctorFormSidebar> {
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _descriptionController;
  late TextEditingController _experienceController; // Mock
  bool _isAvailable = false;
  List<MedicalServiceDto> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant DoctorFormSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doctor.id != widget.doctor.id) {
      _initControllers();
    }
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.doctor.fullName);
    _specialtyController = TextEditingController(text: widget.doctor.specialty);
    _descriptionController = TextEditingController(
      text: widget.doctor.description,
    );
    _experienceController = TextEditingController(
      text: '${(widget.doctor.totalReviews ?? 0) % 15 + 2} năm',
    );
    _experienceController = TextEditingController(
      text: '${(widget.doctor.totalReviews ?? 0) % 15 + 2} năm',
    );
    _isAvailable = widget.doctor.isAvailable;
    _avatarUrl = widget.doctor.avatarUrl;
    _selectedServices = List.from(widget.doctor.services ?? []);
  }

  String? _avatarUrl;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.doctor.id.isEmpty;

    return Column(
      children: [
        // Sidebar Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNew ? 'Thêm mới' : 'Thông tin chi tiết',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111418),
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
                color: const Color(0xFF5F718C),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Sidebar Form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage:
                          _avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),

                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() => _isUploading = true);
                          try {
                            final url = await ref
                                .read(doctorsControllerProvider.notifier)
                                .uploadAvatar(image);
                            if (url != null) {
                              setState(() => _avatarUrl = url);
                            }
                          } finally {
                            setState(() => _isUploading = false);
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Color(0xFF2E80FA),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text
                      : 'Bác sĩ mới',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAvailable = !_isAvailable;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isAvailable
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      _isAvailable ? 'ĐANG HOẠT ĐỘNG' : 'TẠM DỪNG',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _isAvailable
                            ? const Color(0xFF059669)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                _SidebarInput(label: 'Họ và tên', controller: _nameController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SidebarInput(
                        label: 'Chuyên khoa',
                        controller: _specialtyController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SidebarInput(
                        label: 'Kinh nghiệm',
                        controller: _experienceController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildServicesInput(),
                const SizedBox(height: 16),
                _SidebarInput(
                  label: 'Ghi chú',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),

        // Sidebar Footer
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClose,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111418),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final data = {
                      'userId': widget.doctor.userId.isNotEmpty
                          ? widget.doctor.userId
                          : '00000000-0000-0000-0000-000000000000', // Temporary Mock for Create, Real User ID for Update
                      'fullName': _nameController.text,
                      'specialty': _specialtyController.text,
                      'description': _descriptionController.text,
                      'isAvailable': _isAvailable,
                      'avatarUrl': _avatarUrl,
                      'phone': widget.doctor.phone, // Preserve existing phone
                      'consultationFee': widget.doctor.consultationFee,
                      'serviceIds': _selectedServices.map((e) => e.id).toList(),
                    };
                    widget.onSave(data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E80FA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Lưu thay đổi',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildServicesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GÁN DỊCH VỤ Y TẾ',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5F718C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: Wrap(
            spacing: 8,
            children: [
              ..._selectedServices.map(
                (s) => Chip(
                  label: Text(s.name, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    setState(() {
                      _selectedServices.remove(s);
                    });
                  },
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              TextButton.icon(
                onPressed: _showAddServiceDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm dịch vụ'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn dịch vụ'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Consumer(
              builder: (context, ref, child) {
                final servicesAsync = ref.watch(servicesControllerProvider);
                return servicesAsync.when(
                  data: (services) {
                    final availableServices = services
                        .where(
                          (s) => !_selectedServices.any(
                            (selected) => selected.id == s.id,
                          ),
                        )
                        .toList();

                    if (availableServices.isEmpty) {
                      return const Center(child: Text('Đã chọn hết dịch vụ'));
                    }

                    return ListView.builder(
                      itemCount: availableServices.length,
                      itemBuilder: (context, index) {
                        final service = availableServices[index];
                        return ListTile(
                          title: Text(service.name),
                          onTap: () {
                            setState(() {
                              _selectedServices.add(service);
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Lỗi: $e'),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF2E80FA) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF2E80FA)
                    : const Color(0xFF5F718C),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2E80FA).withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xFF2E80FA)
                      : const Color(0xFF5F718C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableTitle extends StatelessWidget {
  final String title;
  final TextAlign align;

  const _TableTitle(this.title, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: align,
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF5F718C),
      ),
    );
  }
}

class _SidebarInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _SidebarInput({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5F718C),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.manrope(fontSize: 14),
        ),
      ],
    );
  }
}
