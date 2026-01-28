import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../data/dto/booking_dto.dart';
import 'appointment_controller.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  static const primaryColor = Color(0xFF297EFF);
  static const successColor = Color(0xFF00C853);
  static const warningColor = Color(0xFFFFA000);
  static const dangerColor = Color(0xFFEF4444);
  static const backgroundColor = Color(0xFFF5F7F8);
  static const borderColor = Color(0xFFE6ECF4);

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-refresh khi app quay lại từ background
    if (state == AppLifecycleState.resumed) {
      ref.read(appointmentControllerProvider.notifier).loadAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentControllerProvider);
    final controller = ref.read(appointmentControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppointmentScreen.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Filters
            _buildFilters(
              context,
              controller,
              state.selectedStatus,
              state.selectedDate,
            ),
            const SizedBox(height: 24),

            // Table
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? _buildError(state.error!, controller)
                  : _buildTable(
                      context,
                      state.filteredAppointments,
                      controller,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quản lý lịch hẹn',
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0C131D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Theo dõi và xử lý các yêu cầu đặt lịch từ bệnh nhân',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: const Color(0xFF5E718D),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(
    BuildContext context,
    AppointmentController controller,
    String? selected,
    DateTime? selectedDate,
  ) {
    final filters = [
      {'label': 'Tất cả', 'value': null},
      {'label': 'Chờ xác nhận', 'value': 'PENDING'},
      {'label': 'Đã xác nhận', 'value': 'CONFIRMED'},
      {'label': 'Hoàn thành', 'value': 'COMPLETED'},
      {'label': 'Đã hủy', 'value': 'CANCELED'},
    ];

    final displayDate = selectedDate ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppointmentScreen.borderColor),
      ),
      child: Row(
        children: [
          // Date selector with picker
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: displayDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                locale: const Locale('vi', 'VN'),
              );
              if (picked != null) {
                controller.filterByDate(picked);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppointmentScreen.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppointmentScreen.borderColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF5E718D),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy', 'vi').format(displayDate),
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.expand_more,
                    size: 16,
                    color: Color(0xFF5E718D),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Clear date filter button
          if (selectedDate != null)
            IconButton(
              onPressed: () => controller.filterByDate(null),
              icon: const Icon(Icons.clear, size: 18),
              tooltip: 'Xóa bộ lọc ngày',
              style: IconButton.styleFrom(
                backgroundColor: AppointmentScreen.backgroundColor,
                foregroundColor: const Color(0xFF5E718D),
              ),
            ),
          const SizedBox(width: 16),
          // Status filters
          ...filters.map(
            (f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: f['label'] as String,
                isSelected: selected == f['value'],
                onTap: () => controller.filterByStatus(f['value'] as String?),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, AppointmentController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppointmentScreen.dangerColor,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: GoogleFonts.manrope(color: AppointmentScreen.dangerColor),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.loadAppointments(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
    List<BookingDto> appointments,
    AppointmentController controller,
  ) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Không có lịch hẹn nào',
              style: GoogleFonts.manrope(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppointmentScreen.borderColor),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppointmentScreen.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('Bệnh nhân', flex: 2),
                _buildHeaderCell('Dịch vụ', flex: 2),
                _buildHeaderCell('Ngày giờ'),
                _buildHeaderCell('Trạng thái'),
                _buildHeaderCell('Thao tác', isRight: true),
              ],
            ),
          ),
          // Table body
          Expanded(
            child: ListView.separated(
              itemCount: appointments.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: AppointmentScreen.borderColor),
              itemBuilder: (context, index) {
                return _buildTableRow(context, appointments[index], controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1, bool isRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text.toUpperCase(),
        textAlign: isRight ? TextAlign.right : TextAlign.left,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF5E718D),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    BookingDto booking,
    AppointmentController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Patient info
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppointmentScreen.borderColor),
                  ),
                  child: ClipOval(
                    child: booking.patientAvatar != null
                        ? CachedNetworkImage(
                            imageUrl: booking.patientAvatar!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.patientName ?? 'Bệnh nhân',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: #${booking.patientId?.substring(0, 8) ?? 'N/A'}',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: const Color(0xFF5E718D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Service
          Expanded(
            flex: 2,
            child: Text(
              booking.serviceName ?? 'Khám tổng quát',
              style: GoogleFonts.manrope(fontSize: 14),
            ),
          ),
          // Date/Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.timeSlot?.startTime.substring(0, 5) ?? '--:--',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  booking.timeSlot != null
                      ? DateFormat('dd/MM/yyyy').format(booking.timeSlot!.date)
                      : '--/--/----',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF5E718D),
                  ),
                ),
              ],
            ),
          ),
          // Status
          Expanded(child: _buildStatusBadge(booking.status ?? 'PENDING')),
          // Actions
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(context, booking, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'PENDING':
        bgColor = AppointmentScreen.warningColor.withOpacity(0.1);
        textColor = AppointmentScreen.warningColor;
        label = 'Chờ xác nhận';
        break;
      case 'CONFIRMED':
        bgColor = AppointmentScreen.primaryColor.withOpacity(0.1);
        textColor = AppointmentScreen.primaryColor;
        label = 'Đã xác nhận';
        break;
      case 'COMPLETED':
        bgColor = AppointmentScreen.successColor.withOpacity(0.1);
        textColor = AppointmentScreen.successColor;
        label = 'Hoàn thành';
        break;
      case 'CANCELED':
        bgColor = AppointmentScreen.dangerColor.withOpacity(0.1);
        textColor = AppointmentScreen.dangerColor;
        label = 'Đã hủy';
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(
    BuildContext context,
    BookingDto booking,
    AppointmentController controller,
  ) {
    final status = booking.status ?? 'PENDING';

    switch (status) {
      case 'PENDING':
        return [
          _ActionButton(
            icon: Icons.check,
            color: AppointmentScreen.primaryColor,
            tooltip: 'Xác nhận',
            onTap: () async {
              final success = await controller.confirmBooking(booking.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Đã xác nhận lịch hẹn' : 'Có lỗi xảy ra',
                    ),
                    backgroundColor: success
                        ? AppointmentScreen.successColor
                        : AppointmentScreen.dangerColor,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.close,
            color: AppointmentScreen.dangerColor,
            tooltip: 'Từ chối',
            onTap: () => _showCancelDialog(context, booking.id, controller),
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.visibility,
            color: Colors.grey,
            tooltip: 'Chi tiết',
            onTap: () => context.push('/appointments/detail', extra: booking),
          ),
        ];
      case 'CONFIRMED':
        return [
          ElevatedButton.icon(
            onPressed: () async {
              final success = await controller.completeBooking(booking.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Đã hoàn thành lịch hẹn' : 'Có lỗi xảy ra',
                    ),
                    backgroundColor: success
                        ? AppointmentScreen.successColor
                        : AppointmentScreen.dangerColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppointmentScreen.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            icon: const Icon(Icons.task_alt, size: 16),
            label: Text(
              'Hoàn thành',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.visibility,
            color: Colors.grey,
            tooltip: 'Chi tiết',
            onTap: () => context.push('/appointments/detail', extra: booking),
          ),
        ];
      case 'COMPLETED':
        return [
          OutlinedButton(
            onPressed: () =>
                context.push('/appointments/detail', extra: booking),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Xem bệnh án',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      case 'CANCELED':
        return [
          Text(
            booking.cancellationReason ?? 'Đã hủy',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ];
      default:
        return [];
    }
  }

  void _showCancelDialog(
    BuildContext context,
    String bookingId,
    AppointmentController controller,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Từ chối lịch hẹn',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Nhập lý do từ chối...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await controller.cancelBooking(
                bookingId,
                reasonController.text,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Đã từ chối lịch hẹn' : 'Có lỗi xảy ra',
                    ),
                    backgroundColor: success
                        ? AppointmentScreen.warningColor
                        : AppointmentScreen.dangerColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppointmentScreen.dangerColor,
            ),
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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
          color: isSelected
              ? AppointmentScreen.primaryColor
              : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF5E718D),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color == Colors.grey ? const Color(0xFFF0F2F5) : color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color == Colors.grey
                ? const Color(0xFF5E718D)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
