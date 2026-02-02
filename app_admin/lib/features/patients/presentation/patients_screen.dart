import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/dto/patient_dto.dart';
import 'patients_controller.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  String _selectedTab = 'Tất cả bệnh nhân';
  PatientDto? _selectedPatient;
  bool _isSidebarOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(patientsControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSidebar(PatientDto patient) {
    setState(() {
      _selectedPatient = patient;
      _isSidebarOpen = true;
    });
  }

  void _closeSidebar() {
    setState(() {
      _selectedPatient = null;
      _isSidebarOpen = false;
    });
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    ref.read(patientsControllerProvider.notifier).refresh(
      search: query.isEmpty ? null : query,
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsControllerProvider);

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
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildTabs(patientsAsync),
                  const SizedBox(height: 24),
                  patientsAsync.when(
                    data: (patients) => _buildTable(patients),
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
                  'Quản lý Bệnh nhân',
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
              'Danh sách Bệnh nhân',
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111418),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quản lý thông tin hồ sơ, lịch sử khám và trạng thái bệnh nhân.',
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: const Color(0xFF5F718C),
              ),
            ),
          ],
        ),
        // Nút làm mới
        ElevatedButton.icon(
          onPressed: () {
            ref.read(patientsControllerProvider.notifier).refresh();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Làm mới'),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF5F718C)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên bệnh nhân...',
                hintStyle: GoogleFonts.manrope(color: const Color(0xFF9CA3AF)),
                border: InputBorder.none,
              ),
              style: GoogleFonts.manrope(fontSize: 14),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          TextButton(
            onPressed: _onSearch,
            child: Text(
              'Tìm kiếm',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E80FA),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(AsyncValue<List<PatientDto>> patientsAsync) {
    final patients = patientsAsync.valueOrNull ?? [];
    final allCount = patients.length;
    final maleCount = patients.where((p) => 
        p.gender?.toUpperCase() == 'MALE' || p.gender == 'Nam').length;
    final femaleCount = patients.where((p) => 
        p.gender?.toUpperCase() == 'FEMALE' || p.gender == 'Nữ').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Tất cả bệnh nhân',
            count: allCount,
            isSelected: _selectedTab == 'Tất cả bệnh nhân',
            onTap: () => setState(() => _selectedTab = 'Tất cả bệnh nhân'),
          ),
          _TabItem(
            label: 'Nam',
            count: maleCount,
            isSelected: _selectedTab == 'Nam',
            onTap: () => setState(() => _selectedTab = 'Nam'),
          ),
          _TabItem(
            label: 'Nữ',
            count: femaleCount,
            isSelected: _selectedTab == 'Nữ',
            onTap: () => setState(() => _selectedTab = 'Nữ'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<PatientDto> patients) {
    var filteredPatients = patients;
    if (_selectedTab == 'Nam') {
      filteredPatients = patients.where((p) => 
          p.gender?.toUpperCase() == 'MALE' || p.gender == 'Nam').toList();
    } else if (_selectedTab == 'Nữ') {
      filteredPatients = patients.where((p) => 
          p.gender?.toUpperCase() == 'FEMALE' || p.gender == 'Nữ').toList();
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
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFFF9FAFB),
              ),
              dataRowMinHeight: 72,
              dataRowMaxHeight: 72,
              columns: const [
                DataColumn(label: _TableTitle('BỆNH NHÂN')),
                DataColumn(label: _TableTitle('SỐ ĐIỆN THOẠI')),
                DataColumn(label: _TableTitle('GIỚI TÍNH')),
                DataColumn(label: _TableTitle('NGÀY SINH')),
                DataColumn(label: _TableTitle('ĐỊA CHỈ')),
                DataColumn(
                  label: _TableTitle('THAO TÁC', align: TextAlign.right),
                  numeric: true,
                ),
              ],
              rows: filteredPatients.map((patient) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                patient.avatarUrl != null &&
                                    patient.avatarUrl!.isNotEmpty
                                ? NetworkImage(patient.avatarUrl!)
                                : null,
                            backgroundColor: const Color(
                              0xFF2E80FA,
                            ).withOpacity(0.1),
                            child:
                                (patient.avatarUrl == null ||
                                    patient.avatarUrl!.isEmpty)
                                ? Text(
                                    (patient.fullName?.isNotEmpty ?? false)
                                        ? patient.fullName![0]
                                        : 'P',
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
                                  patient.fullName ?? 'Chưa cập nhật',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: const Color(0xFF111418),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'ID: ${patient.userId.length >= 8 ? patient.userId.substring(0, 8) : patient.userId}',
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
                      Text(
                        patient.phone ?? 'Chưa cập nhật',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: const Color(0xFF111418),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getGenderColor(patient.gender).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getGenderText(patient.gender),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getGenderColor(patient.gender),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatDate(patient.dob),
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: const Color(0xFF111418),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          patient.address ?? 'Chưa cập nhật',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: const Color(0xFF111418),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined),
                            color: const Color(0xFF5F718C),
                            tooltip: 'Xem chi tiết',
                            onPressed: () => _openSidebar(patient),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red.shade400,
                            tooltip: 'Xóa',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: Text(
                                    'Bạn có chắc chắn muốn xóa bệnh nhân ${patient.fullName ?? 'này'}?',
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
                                              patientsControllerProvider
                                                  .notifier,
                                            )
                                            .deletePatient(patient.userId);
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
          // Pagination
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hiển thị ${filteredPatients.take(10).length} của ${filteredPatients.length} bệnh nhân',
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
    if (_selectedPatient == null) return const SizedBox();

    return PatientDetailSidebar(
      patient: _selectedPatient!,
      onClose: _closeSidebar,
      onSave: (patientData) async {
        await ref
            .read(patientsControllerProvider.notifier)
            .updatePatient(_selectedPatient!.userId, patientData);
        _closeSidebar();
        ref.read(patientsControllerProvider.notifier).refresh();
      },
    );
  }

  String _getGenderText(String? gender) {
    if (gender == null) return 'Chưa rõ';
    switch (gender.toUpperCase()) {
      case 'MALE':
      case 'NAM':
        return 'Nam';
      case 'FEMALE':
      case 'NỮ':
      case 'NU':
        return 'Nữ';
      default:
        return 'Khác';
    }
  }

  Color _getGenderColor(String? gender) {
    if (gender == null) return const Color(0xFF6B7280);
    switch (gender.toUpperCase()) {
      case 'MALE':
      case 'NAM':
        return const Color(0xFF2E80FA);
      case 'FEMALE':
      case 'NỮ':
      case 'NU':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(String? dob) {
    if (dob == null || dob.isEmpty) return 'Chưa cập nhật';
    try {
      final date = DateTime.parse(dob);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dob;
    }
  }
}

// ===================== Sidebar Detail =====================

class PatientDetailSidebar extends ConsumerStatefulWidget {
  final PatientDto patient;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const PatientDetailSidebar({
    super.key,
    required this.patient,
    required this.onClose,
    required this.onSave,
  });

  @override
  ConsumerState<PatientDetailSidebar> createState() => _PatientDetailSidebarState();
}

class _PatientDetailSidebarState extends ConsumerState<PatientDetailSidebar> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  String _selectedGender = 'MALE';

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant PatientDetailSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient.userId != widget.patient.userId) {
      _initControllers();
    }
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.patient.fullName ?? '');
    _phoneController = TextEditingController(text: widget.patient.phone ?? '');
    _addressController = TextEditingController(text: widget.patient.address ?? '');
    _dobController = TextEditingController(text: widget.patient.dob ?? '');
    _selectedGender = widget.patient.gender?.toUpperCase() ?? 'MALE';
    if (_selectedGender == 'NAM') _selectedGender = 'MALE';
    if (_selectedGender == 'NỮ' || _selectedGender == 'NU') _selectedGender = 'FEMALE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sidebar Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thông tin bệnh nhân',
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

        // Sidebar Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      widget.patient.avatarUrl != null && widget.patient.avatarUrl!.isNotEmpty
                      ? NetworkImage(widget.patient.avatarUrl!)
                      : null,
                  backgroundColor: const Color(0xFF2E80FA).withOpacity(0.1),
                  child: (widget.patient.avatarUrl == null || widget.patient.avatarUrl!.isEmpty)
                      ? Text(
                          (widget.patient.fullName?.isNotEmpty ?? false)
                              ? widget.patient.fullName![0]
                              : 'P',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: const Color(0xFF2E80FA),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.patient.fullName ?? 'Bệnh nhân',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.patient.userId}',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF5F718C),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                _SidebarInput(label: 'Họ và tên', controller: _nameController),
                const SizedBox(height: 16),
                _SidebarInput(label: 'Số điện thoại', controller: _phoneController),
                const SizedBox(height: 16),
                
                // Gender Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GIỚI TÍNH',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5F718C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          items: const [
                            DropdownMenuItem(value: 'MALE', child: Text('Nam')),
                            DropdownMenuItem(value: 'FEMALE', child: Text('Nữ')),
                            DropdownMenuItem(value: 'OTHER', child: Text('Khác')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedGender = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _SidebarInput(label: 'Ngày sinh (YYYY-MM-DD)', controller: _dobController),
                const SizedBox(height: 16),
                _SidebarInput(label: 'Địa chỉ', controller: _addressController, maxLines: 2),
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
                      'fullName': _nameController.text,
                      'phone': _phoneController.text,
                      'gender': _selectedGender,
                      'dob': _dobController.text.isNotEmpty ? _dobController.text : null,
                      'address': _addressController.text,
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
}

// ===================== Shared Widgets =====================

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
