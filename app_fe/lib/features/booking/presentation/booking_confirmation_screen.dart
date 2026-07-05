import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/dto/service_dto.dart';
import 'booking_controller.dart';
import 'booking_list_controller.dart';
import '../../home/presentation/home_controller.dart';
import '../../profile/data/dto/profile_dto.dart';
import '../../profile/data/source/profile_api.dart';
import '../../profile/presentation/user_provider.dart';
import 'widgets/doctor_avatar.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final List<ServiceDto> selectedServices;
  final double totalPrice;
  final String doctorId;
  final String? doctorName;
  final String? doctorAvatarUrl;
  final DateTime selectedDate;
  final String selectedTime;
  final String timeSlotId;

  const BookingConfirmationScreen({
    super.key,
    required this.selectedServices,
    required this.totalPrice,
    required this.doctorId,
    this.doctorName,
    this.doctorAvatarUrl,
    required this.selectedDate,
    required this.selectedTime,
    required this.timeSlotId,
  });

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  final TextEditingController _notesController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  ProfileDto? _patientProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadPatientProfile();
  }

  Future<void> _loadPatientProfile() async {
    final userId = await _storage.read(key: 'user_id');
    print(
      'BookingConfirmationScreen: --- _loadPatientProfile start: userId=$userId ---',
    );

    if (userId == null) {
      if (mounted) setState(() => _isLoadingProfile = false);
      return;
    }

    final profile = await ref
        .read(profileApiProvider)
        .getProfileByUserId(userId);

    print(
      'BookingConfirmationScreen: Profile fetched: fullName="${profile?.fullName}", phone="${profile?.phone}", email="${profile?.email}", emailVerified=${profile?.emailVerified}',
    );
    if (profile != null) {
      final canBook =
          (profile.fullName?.trim().isNotEmpty ?? false) &&
          (profile.phone?.trim().isNotEmpty ?? false) &&
          (profile.email?.trim().isNotEmpty ?? false) &&
          profile.emailVerified;
      print('BookingConfirmationScreen: canBook calculation result: $canBook');
    }

    if (mounted) {
      setState(() {
        _patientProfile = profile;
        _isLoadingProfile = false;
      });
    }
  }

  bool get _canBook {
    final profile = _patientProfile;
    if (profile == null) return false;
    return (profile.fullName?.trim().isNotEmpty ?? false) &&
        (profile.phone?.trim().isNotEmpty ?? false) &&
        (profile.email?.trim().isNotEmpty ?? false) &&
        profile.emailVerified;
  }

  String get _profileIssueText {
    final profile = _patientProfile;
    if (profile == null)
      return 'Vui lòng xác thực thông tin trước khi đặt lịch.';
    if (!(profile.fullName?.trim().isNotEmpty ?? false) ||
        !(profile.phone?.trim().isNotEmpty ?? false)) {
      return 'Vui lòng xác thực thông tin trước khi đặt lịch.';
    }
    if (!(profile.email?.trim().isNotEmpty ?? false)) {
      return 'Vui lòng xác thực thông tin trước khi đặt lịch.';
    }
    if (!profile.emailVerified) {
      return 'Vui lòng xác thực thông tin trước khi đặt lịch.';
    }
    return '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProvider, (previous, next) {
      _loadPatientProfile();
    });

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
                    _buildBookingSummary(),
                    _buildDoctorInfo(),
                    _buildDateTimeInfo(),
                    _buildServicesInfo(),
                    _buildProfileVerificationNotice(),
                    _buildNotesInput(),
                    _buildRequiredPaymentNotice(),
                    _buildPaymentInfo(),
                    _buildNotice(),
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
              'Xác nhận đặt lịch',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF101418),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 40, height: 40),
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
          _buildProgressDot(true), // Step 2: Select Doctor (completed)
          const SizedBox(width: 12),
          _buildProgressDot(true), // Step 3: Select DateTime (completed)
          const SizedBox(width: 12),
          _buildProgressDot(true), // Step 4: Confirmation (current)
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

  Widget _buildBookingSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF297EFF),
            const Color(0xFF297EFF).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF297EFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Thông tin đặt lịch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_getDayName(widget.selectedDate.weekday)}, ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.selectedTime,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          DoctorAvatar(
            imageUrl: widget.doctorAvatarUrl,
            size: 60,
            radius: 12,
            backgroundColor: const Color(0xFF297EFF).withOpacity(0.1),
            iconColor: const Color(0xFF297EFF),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bác sĩ phụ trách',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5E718D)),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doctorName ?? 'Bác sĩ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101418),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 16, color: Color(0xFF00C853)),
                SizedBox(width: 4),
                Text(
                  'Xác nhận',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00C853),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInfo() {
    final formattedDate = DateFormat('dd/MM/yyyy').format(widget.selectedDate);
    final dayName = _getDayName(widget.selectedDate.weekday);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_month,
            'Ngày khám',
            '$dayName, $formattedDate',
            const Color(0xFF297EFF),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.access_time,
            'Giờ khám',
            widget.selectedTime,
            Colors.orange,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Địa điểm khám',
            'Phòng khám Đa khoa MediBook - 123 Đường Thành Thái, Phường 14, Quận 10, TP. Hồ Chí Minh',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5E718D)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101418),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Dịch vụ đã chọn (${widget.selectedServices.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101418),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.selectedServices.map(
            (service) => _buildServiceItem(service),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceDto service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101418),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${service.durationMinutes} phút',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5E718D),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_formatPrice(service.price)}đ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF297EFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileVerificationNotice() {
    if (_isLoadingProfile) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    if (_canBook) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF00C853).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF00C853).withOpacity(0.25)),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_user, color: Color(0xFF00C853)),
            SizedBox(width: 10),
            Expanded(child: Text('Thông tin đặt lịch đã được xác thực.')),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(_profileIssueText)),
          TextButton(
            onPressed: () async {
              await context.push('/edit-profile');
              _loadPatientProfile();
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredPaymentNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC46B)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.timer_outlined, color: Color(0xFFE68A00)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Xin lỗi vì sự bất tiện. Để tránh tình trạng khung giờ khám bị bỏ trống, hệ thống sẽ giữ chỗ trong 15 phút sau khi đặt lịch. Vui lòng thanh toán phí dịch vụ trong thời gian này; nếu quá hạn, lịch sẽ tự động hủy và khung giờ được mở lại.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF7A4A00),
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tạm tính',
                style: TextStyle(fontSize: 14, color: Color(0xFF5E718D)),
              ),
              Text(
                '${_formatPrice(widget.totalPrice)}đ',
                style: const TextStyle(fontSize: 14, color: Color(0xFF101418)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí dịch vụ',
                style: TextStyle(fontSize: 14, color: Color(0xFF5E718D)),
              ),
              Text(
                'Miễn phí',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF00C853),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101418),
                ),
              ),
              Text(
                '${_formatPrice(widget.totalPrice)}đ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF297EFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sticky_note_2,
                  color: Colors.amber,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Ghi chú cho bác sĩ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101418),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Nhập triệu chứng, tiền sử bệnh hoặc yêu cầu đặc biệt...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF5F7F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.amber,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lưu ý',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101418),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vui lòng đến trước giờ hẹn 15 phút để hoàn tất thủ tục khám. Mang theo CMND/CCCD và thẻ BHYT (nếu có).',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5E718D),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(fontSize: 14, color: Color(0xFF5E718D)),
              ),
              Text(
                '${_formatPrice(widget.totalPrice)}đ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF297EFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  ref.watch(bookingControllerProvider).isLoading ||
                      _isLoadingProfile ||
                      !_canBook
                  ? null
                  : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF297EFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF297EFF).withOpacity(0.3),
              ),
              child: ref.watch(bookingControllerProvider).isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Đặt lịch và thanh toán',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (!_canBook) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_profileIssueText),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Lấy ghi chú từ text field
    final notes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : null;

    // Call API to create booking
    final success = await ref
        .read(bookingControllerProvider.notifier)
        .createBooking(
          doctorId: widget.doctorId,
          serviceId: widget
              .selectedServices
              .first
              .id, // Assuming single service for now
          timeSlotId: widget.timeSlotId,
          notes: notes,
        );

    if (success && mounted) {
      // Invalidate booking list providers to refresh data
      ref.invalidate(bookingListControllerProvider);
      ref.invalidate(homeControllerProvider);

      final booking = ref.read(bookingControllerProvider).successData;
      if (booking == null) {
        context.go('/booking');
        return;
      }

      context.go(
        '/booking-payment',
        extra: {'booking': booking, 'totalPrice': widget.totalPrice},
      );
    } else if (mounted) {
      final errorMsg =
          ref.read(bookingControllerProvider).error ?? "Lỗi không xác định";
      final isFriendlyError =
          !errorMsg.contains('Lỗi hệ thống') && !errorMsg.contains('Exception');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.all(16),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2F2), // Light soft red background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD1D1),
              ), // Soft red border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE3E3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFD32F2F),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isFriendlyError
                            ? 'Lịch khám đã được đặt'
                            : 'Đặt lịch thất bại',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8C1D1D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFriendlyError
                            ? errorMsg
                            : 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB71C1C),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _getDayName(int weekday) {
    const days = [
      '',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return days[weekday];
  }
}
