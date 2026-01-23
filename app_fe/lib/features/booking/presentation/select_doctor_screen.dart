import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/dto/service_dto.dart';
import '../../doctor/data/dto/doctor_dto.dart';
import '../../doctor/presentation/doctor_controller.dart';

class SelectDoctorScreen extends ConsumerStatefulWidget {
  final List<ServiceDto> selectedServices;
  final double totalPrice;

  const SelectDoctorScreen({
    super.key,
    required this.selectedServices,
    required this.totalPrice,
  });

  @override
  ConsumerState<SelectDoctorScreen> createState() => _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends ConsumerState<SelectDoctorScreen> {
  String? _selectedDoctorId;
  String _selectedSpecialty = 'Tất cả';

  @override
  void initState() {
    super.initState();
    // Load doctors when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedServices.isNotEmpty) {
        ref
            .read(doctorControllerProvider.notifier)
            .loadDoctorsByService(widget.selectedServices.first.id);
      } else {
        ref.read(doctorControllerProvider.notifier).loadDoctors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 140),
                child: Column(
                  children: [
                    _buildProgressIndicator(),
                    _buildSpecialtyFilter(),
                    _buildDoctorList(doctorState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Color(0xFF101418),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Chọn bác sĩ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF101418),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.info_outline, color: Color(0xFF297EFF)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressDot(true), // Step 1: Select Service (completed)
          const SizedBox(width: 12),
          _buildProgressDot(true), // Step 2: Select Doctor (current)
          const SizedBox(width: 12),
          _buildProgressDot(false), // Step 3: Select DateTime
          const SizedBox(width: 12),
          _buildProgressDot(false), // Step 4: Confirmation
        ],
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 32,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF297EFF) : const Color(0xFFDADFE7),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildSpecialtyFilter() {
    final specialties = [
      'Tất cả',
      'Nội khoa',
      'Ngoại khoa',
      'Nhi khoa',
      'Da liễu',
      'Tim mạch',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: specialties.map((specialty) {
            final isSelected = specialty == _selectedSpecialty;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedSpecialty = specialty);
                  if (specialty == 'Tất cả') {
                    ref.read(doctorControllerProvider.notifier).loadDoctors();
                  } else {
                    ref
                        .read(doctorControllerProvider.notifier)
                        .filterByCategory(specialty);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF297EFF) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF297EFF)
                          : Colors.grey.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    specialty,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF101418),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDoctorList(DoctorState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Lỗi: ${state.errorMessage}',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (state.doctors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_search, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Không tìm thấy bác sĩ',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bác sĩ (${state.doctors.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101418),
            ),
          ),
          const SizedBox(height: 12),
          ...state.doctors.map((doctor) => _buildDoctorCard(doctor)),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorDto doctor) {
    final isSelected = doctor.id == _selectedDoctorId;

    return GestureDetector(
      onTap: () => setState(() => _selectedDoctorId = doctor.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF297EFF) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF297EFF).withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Doctor Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                image: doctor.avatarUrl != null && doctor.avatarUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(doctor.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: doctor.avatarUrl == null || doctor.avatarUrl!.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor.fullName ?? 'Bác sĩ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101418),
                          ),
                        ),
                      ),
                      if (doctor.isAvailable == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Color(0xFF00C853),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Sẵn sàng',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00C853),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialty ?? 'Chuyên khoa',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5E718D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            doctor.rating?.toStringAsFixed(1) ?? '0.0',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101418),
                            ),
                          ),
                          Text(
                            ' (${doctor.totalReviews ?? 0})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5E718D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Consultation Fee
                      if (doctor.consultationFee != null)
                        Text(
                          '${_formatPrice(doctor.consultationFee!)}đ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF297EFF),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Selection Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF297EFF)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final selectedDoctor = _selectedDoctorId != null
        ? ref
              .read(doctorControllerProvider)
              .doctors
              .firstWhere(
                (d) => d.id == _selectedDoctorId,
                orElse: () => DoctorDto(id: ''),
              )
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedDoctor?.fullName ?? 'Chưa chọn bác sĩ',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedDoctorId != null
                      ? const Color(0xFF101418)
                      : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_formatPrice(widget.totalPrice)}đ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101418),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _selectedDoctorId == null
                ? null
                : () {
                    // Navigate to datetime selection (Step 3)
                    // Flow 2: Service > Doctor > DateTime
                    context.push(
                      '/select-datetime',
                      extra: {
                        'services': widget.selectedServices,
                        'totalPrice': widget.totalPrice,
                        'doctorId': _selectedDoctorId,
                        'doctorName': selectedDoctor?.fullName,
                        'doctorAvatarUrl': selectedDoctor?.avatarUrl,
                        // Important: The router for select-datetime expects 'services' list.
                      },
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF297EFF),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tiếp tục',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
