import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/dto/schedule_dto.dart';
import '../data/schedule_pdf_service.dart';
import 'schedule_controller.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  static const primaryColor = Color(0xFF297EFF);
  static const successColor = Color(0xFF00C853);
  static const warningColor = Color(0xFFFFA000);
  static const dangerColor = Color(0xFFEF4444);
  static const backgroundColor = Color(0xFFF5F7F8);
  static const borderColor = Color(0xFFE6ECF4);

  // Giờ bắt đầu và kết thúc hiển thị trên lịch
  static const int startHour = 7;
  static const int endHour = 18;
  static const double hourHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleControllerProvider);
    final controller = ref.read(scheduleControllerProvider.notifier);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(controller),
            const SizedBox(height: 24),
            Expanded(child: _buildCalendarContainer(state, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ScheduleController controller) {
    final state = ref.watch(scheduleControllerProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lịch làm việc của bác sĩ',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0C131D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cập nhật và quản lý thời gian khám chữa bệnh của bạn',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: const Color(0xFF5E718D),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Nút In lịch
            OutlinedButton.icon(
              onPressed: state.slots.isEmpty ? null : () => _printSchedule(state),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5E718D),
                side: const BorderSide(color: borderColor),
                disabledForegroundColor: const Color(0xFF9CA3AF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.print, size: 20),
              label: Text(
                'In lịch',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            // Nút Thêm khung giờ
            ElevatedButton.icon(
              onPressed: () => _showAddSlotDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
              icon: const Icon(Icons.add_circle, size: 20),
              label: Text(
                'Thêm khung giờ làm việc',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _printSchedule(ScheduleState state) async {
    try {
      await SchedulePdfService.printSchedule(
        slots: state.slots,
        weekStart: state.weekStart,
        weekEnd: state.weekDays.last,
        weekDays: state.weekDays,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi in lịch: $e'),
            backgroundColor: dangerColor,
          ),
        );
      }
    }
  }

  Widget _buildCalendarContainer(
    ScheduleState state,
    ScheduleController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildToolbar(state, controller),
          _buildDayHeaders(state),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? _buildError(state.error!, controller)
                : _buildCalendarGrid(state),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ScheduleState state, ScheduleController controller) {
    final monthYear = DateFormat('MMMM, yyyy', 'vi').format(state.weekStart);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Navigation controls
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: controller.previousWeek,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      color: const Color(0xFF5E718D),
                    ),
                    TextButton(
                      onPressed: controller.goToToday,
                      child: Text(
                        'Hôm nay',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5E718D),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.nextWeek,
                      icon: const Icon(Icons.chevron_right, size: 20),
                      color: const Color(0xFF5E718D),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                monthYear,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // View mode toggle
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _ViewModeButton(
                  label: 'Tháng',
                  isSelected: state.viewMode == 'month',
                  onTap: () => controller.setViewMode('month'),
                ),
                _ViewModeButton(
                  label: 'Tuần',
                  isSelected: state.viewMode == 'week',
                  onTap: () => controller.setViewMode('week'),
                ),
                _ViewModeButton(
                  label: 'Ngày',
                  isSelected: state.viewMode == 'day',
                  onTap: () => controller.setViewMode('day'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders(ScheduleState state) {
    final now = DateTime.now();
    final dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Time column header
          const SizedBox(width: 80),
          // Day columns
          ...List.generate(7, (index) {
            final day = state.weekDays[index];
            final isToday =
                day.year == now.year &&
                day.month == now.month &&
                day.day == now.day;
            final isWeekend = index >= 5;

            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isToday ? primaryColor.withOpacity(0.05) : null,
                  border: const Border(left: BorderSide(color: borderColor)),
                ),
                child: Column(
                  children: [
                    Text(
                      dayNames[index],
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? primaryColor
                            : (isWeekend
                                  ? dangerColor
                                  : const Color(0xFF5E718D)),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isToday
                            ? primaryColor
                            : (isWeekend ? dangerColor : null),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildError(String error, ScheduleController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: dangerColor),
          const SizedBox(height: 16),
          Text(error, style: GoogleFonts.manrope(color: dangerColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.loadSchedule,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ScheduleState state) {
    final hours = List.generate(endHour - startHour, (i) => startHour + i);
    final now = DateTime.now();

    return SingleChildScrollView(
      child: SizedBox(
        height: hours.length * hourHeight,
        child: Row(
          children: [
            // Time column
            SizedBox(
              width: 80,
              child: Column(
                children: hours.map((hour) {
                  return SizedBox(
                    height: hourHeight,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Day columns with slots
            ...List.generate(7, (dayIndex) {
              final day = state.weekDays[dayIndex];
              final isToday =
                  day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              final daySlots = state.slotsForDay(day);

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? primaryColor.withOpacity(0.02) : null,
                    border: const Border(left: BorderSide(color: borderColor)),
                  ),
                  child: Stack(
                    children: [
                      // Hour grid lines
                      Column(
                        children: hours.map((hour) {
                          return Container(
                            height: hourHeight,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFF3F4F6)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      // Time slots
                      ...daySlots.map((slot) => _buildSlotBlock(slot)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotBlock(ScheduleSlotDto slot) {
    // Tính vị trí và chiều cao
    final startMinutes = slot.startMinutes;
    final durationMinutes = slot.durationMinutes;
    final top = ((startMinutes - startHour * 60) / 60) * hourHeight;
    final height = (durationMinutes / 60) * hourHeight;

    final isBooked = slot.bookingId != null;
    final color = isBooked ? successColor : primaryColor;

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      height: height - 4,
      child: GestureDetector(
        onTap: () => _showSlotDetails(slot),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      isBooked ? 'Đã đặt lịch' : (slot.slotType ?? 'Ca khám'),
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(slot.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          slot.statusText,
                          style: GoogleFonts.manrope(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(slot.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isBooked ? Icons.visibility : Icons.edit,
                        size: 12,
                        color: color,
                      ),
                    ],
                  ),
                ],
              ),
              if (isBooked && slot.patientName != null)
                Flexible(
                  child: Text(
                    'BN. ${slot.patientName}',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else if (slot.note != null)
                Flexible(
                  child: Text(
                    slot.note!,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text(
                '${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}',
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  color: const Color(0xFF5E718D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSlotDetails(ScheduleSlotDto slot) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          slot.bookingId != null ? 'Chi tiết lịch hẹn' : 'Chi tiết khung giờ',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Ngày', DateFormat('dd/MM/yyyy').format(slot.date)),
            _detailRow(
              'Giờ',
              '${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}',
            ),
            if (slot.patientName != null)
              _detailRow('Bệnh nhân', slot.patientName!),
            if (slot.serviceName != null)
              _detailRow('Dịch vụ', slot.serviceName!),
            if (slot.note != null) _detailRow('Ghi chú', slot.note!),
          ],
        ),
        actions: [
          if (slot.bookingId == null)
            TextButton(
              onPressed: () async {
                // Check if slot is booked (extra validation)
                if (slot.bookingId != null) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không thể xóa slot đã có lịch hẹn'),
                      backgroundColor: dangerColor,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final success = await ref
                    .read(scheduleControllerProvider.notifier)
                    .deleteSlot(slot.id);
                if (mounted) {
                  final state = ref.read(scheduleControllerProvider);
                  String errorMsg = state.error ?? 'Không thể xóa khung giờ';
                  // Parse error message for better UX
                  if (errorMsg.contains('booked slot') ||
                      errorMsg.contains(
                        'InvalidDataAccessResourceUsageException',
                      )) {
                    errorMsg = 'Không thể xóa slot đã có lịch hẹn';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Đã xóa khung giờ' : errorMsg),
                      backgroundColor: success ? successColor : dangerColor,
                    ),
                  );
                }
              },
              child: const Text('Xóa', style: TextStyle(color: dangerColor)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.manrope(
                color: const Color(0xFF5E718D),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lấy màu theo trạng thái slot
  Color _getStatusColor(SlotStatus status) {
    switch (status) {
      case SlotStatus.PENDING:
        return const Color(0xFFF59E0B); // Vàng
      case SlotStatus.APPROVED:
        return successColor; // Xanh
      case SlotStatus.REJECTED:
        return dangerColor; // Đỏ
    }
  }

  void _showAddSlotDialog() {
    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Thêm khung giờ làm việc',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF5E718D),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Ngày làm việc',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color(0xFF5E718D),
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                const Divider(),
                // Time pickers row
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.schedule,
                          color: Color(0xFF5E718D),
                        ),
                        title: Text(
                          'Bắt đầu',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: const Color(0xFF5E718D),
                          ),
                        ),
                        subtitle: Text(
                          startTime.format(ctx),
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: startTime,
                          );
                          if (picked != null) {
                            setDialogState(() => startTime = picked);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.schedule,
                          color: Color(0xFF5E718D),
                        ),
                        title: Text(
                          'Kết thúc',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: const Color(0xFF5E718D),
                          ),
                        ),
                        subtitle: Text(
                          endTime.format(ctx),
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: endTime,
                          );
                          if (picked != null) {
                            setDialogState(() => endTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Hủy bỏ',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validation 1: Check time range (07:00-17:00)
                const minHour = 7;
                const maxHour = 17;
                if (startTime.hour < minHour ||
                    startTime.hour >= maxHour ||
                    endTime.hour < minHour ||
                    endTime.hour > maxHour) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Khung giờ phải trong khoảng 07:00 - 17:00',
                      ),
                      backgroundColor: dangerColor,
                    ),
                  );
                  return;
                }

                // Validation 2: End time must be after start time
                final startMinutes = startTime.hour * 60 + startTime.minute;
                final endMinutes = endTime.hour * 60 + endTime.minute;
                if (endMinutes <= startMinutes) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Giờ kết thúc phải sau giờ bắt đầu'),
                      backgroundColor: dangerColor,
                    ),
                  );
                  return;
                }

                // Validation 3: Check for overlapping slots
                final state = ref.read(scheduleControllerProvider);
                final slotsOnDay = state.slotsForDay(selectedDate);
                final hasOverlap = slotsOnDay.any((slot) {
                  final slotStart =
                      int.parse(slot.startTime.split(':')[0]) * 60 +
                      int.parse(slot.startTime.split(':')[1]);
                  final slotEnd =
                      int.parse(slot.endTime.split(':')[0]) * 60 +
                      int.parse(slot.endTime.split(':')[1]);
                  // Check if ranges overlap
                  return startMinutes < slotEnd && endMinutes > slotStart;
                });

                if (hasOverlap) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Khung giờ bị trùng với khung giờ đã có'),
                      backgroundColor: dangerColor,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final request = CreateScheduleSlotRequest(
                  date: selectedDate,
                  startTime:
                      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                  endTime:
                      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                );
                final success = await ref
                    .read(scheduleControllerProvider.notifier)
                    .createSlot(request);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Đã thêm khung giờ' : 'Có lỗi xảy ra',
                      ),
                      backgroundColor: success ? successColor : dangerColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Lưu khung giờ',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? const Color(0xFF297EFF)
                : const Color(0xFF5E718D),
          ),
        ),
      ),
    );
  }
}
