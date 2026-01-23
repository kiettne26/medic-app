import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/dto/service_dto.dart';
import 'booking_controller.dart';
import '../data/dto/booking_dto.dart';

class SelectDateTimeScreen extends ConsumerStatefulWidget {
  final List<ServiceDto> selectedServices;
  final double totalPrice;
  final String doctorId;
  final String? doctorName;
  final String? doctorAvatarUrl;

  const SelectDateTimeScreen({
    super.key,
    required this.selectedServices,
    required this.totalPrice,
    required this.doctorId,
    this.doctorName,
    this.doctorAvatarUrl,
  });

  @override
  ConsumerState<SelectDateTimeScreen> createState() =>
      _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends ConsumerState<SelectDateTimeScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeSlotDto? _selectedSlot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSlots();
    });
  }

  void _loadSlots() {
    ref
        .read(timeSlotsProvider.notifier)
        .loadAvailableSlots(widget.doctorId, _selectedDate);
  }

  // Generate next 7 days
  List<DateTime> get _availableDates {
    return List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slotsState = ref.watch(timeSlotsProvider);

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
                    _buildDoctorInfo(),
                    _buildDateSelector(),
                    _buildTimeSlots(slotsState),
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
              'Chọn ngày giờ',
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
          _buildProgressDot(true), // Step 2: Select Doctor (completed)
          const SizedBox(width: 12),
          _buildProgressDot(true), // Step 3: Select DateTime (current)
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

  Widget _buildDoctorInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF297EFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF297EFF).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
              image:
                  widget.doctorAvatarUrl != null &&
                      widget.doctorAvatarUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.doctorAvatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child:
                widget.doctorAvatarUrl == null ||
                    widget.doctorAvatarUrl!.isEmpty
                ? const Icon(Icons.person, size: 28, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BÁC SĨ PHỤ TRÁCH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF297EFF),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doctorName ?? 'Bác sĩ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101418),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified,
              color: Color(0xFF00C853),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chọn ngày',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101418),
                ),
              ),
              Row(
                children: [
                  Text(
                    DateFormat('MMMM, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF297EFF),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: Color(0xFF297EFF),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableDates.length,
              itemBuilder: (context, index) {
                final date = _availableDates[index];
                final isSelected = _isSameDay(date, _selectedDate);
                return _buildDateCard(date, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(DateTime date, bool isSelected) {
    final dayName = _getDayName(date.weekday);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          _selectedSlot = null; // Reset selection on date change
        });
        _loadSlots(); // Reload slots for new date
      },
      child: Container(
        width: 64,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF297EFF) : const Color(0xFFF5F7F8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF297EFF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: isSelected ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF101418),
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots(AsyncValue<List<TimeSlotDto>> slotsState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Giờ khám khả dụng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101418),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          slotsState.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text('Lỗi tải lịch: $error', textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _loadSlots,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
            data: (slots) {
              if (slots.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('Không có lịch trống cho ngày này'),
                  ),
                );
              }

              // Separate slots into morning and afternoon logic if needed,
              // or just simple grid. Doing simple grid for now as backend returns list.
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  final isSelected = _selectedSlot?.id == slot.id;
                  return _buildTimeSlotCard(slot, isSelected);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlotDto slot, bool isSelected) {
    // Format time: "08:00:00" -> "08:00"
    final startTime = slot.startTime.substring(0, 5);

    return GestureDetector(
      onTap: () => setState(() => _selectedSlot = slot),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF297EFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF297EFF)
                : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF297EFF).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            startTime,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF101418),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final startTime = _selectedSlot?.startTime.substring(0, 5);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _selectedSlot != null
                        ? '$startTime • $formattedDate'
                        : 'Chưa chọn thời gian',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                '${_formatPrice(widget.totalPrice)}đ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF297EFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedSlot == null
                  ? null
                  : () {
                      // Navigate to confirmation screen (Step 4)
                      context.push(
                        '/booking-confirmation',
                        extra: {
                          'services': widget.selectedServices,
                          'totalPrice': widget.totalPrice,
                          'doctorId': widget.doctorId,
                          'doctorName': widget.doctorName,
                          'doctorAvatarUrl': widget.doctorAvatarUrl,
                          'selectedDate': _selectedDate,
                          'selectedTime': _selectedSlot!.startTime.substring(
                            0,
                            5,
                          ), // Provide string for display
                          'timeSlotId': _selectedSlot!.id, // Provide ID for API
                        },
                      );
                    },
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
              child: const Text(
                'Xác nhận đặt lịch',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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

  String _getDayName(int weekday) {
    const days = ['', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'];
    return days[weekday];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
