import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../data/dto/booking_dto.dart';
import 'appointment_controller.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  final BookingDto booking;

  const AppointmentDetailScreen({super.key, required this.booking});

  static const primaryColor = Color(0xFF297EFF);
  static const successColor = Color(0xFF00C853);
  static const warningColor = Color(0xFFFFA000);
  static const dangerColor = Color(0xFFEF4444);
  static const backgroundColor = Color(0xFFF5F7F8);
  static const borderColor = Color(0xFFE6ECF4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appointmentControllerProvider.notifier);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: borderColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Chi tiết lịch hẹn',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0C131D),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(booking.status ?? 'PENDING'),
              ],
            ),
            const SizedBox(height: 32),

            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Patient info
                Expanded(flex: 2, child: _buildPatientCard()),
                const SizedBox(width: 24),

                // Right column - Booking details
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildBookingDetailsCard(),
                      const SizedBox(height: 24),
                      _buildNotesCard(),
                      const SizedBox(height: 24),
                      _buildActionsCard(context, controller),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: booking.patientAvatar != null
                  ? CachedNetworkImage(
                      imageUrl: booking.patientAvatar!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            booking.patientName ?? 'Bệnh nhân',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'ID: #${booking.patientId?.substring(0, 8) ?? 'N/A'}',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: const Color(0xFF5E718D),
            ),
          ),
          const SizedBox(height: 24),

          // Contact info placeholder
          _buildInfoRow(Icons.email_outlined, 'patient@email.com'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, '+84 xxx xxx xxx'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF5E718D)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: const Color(0xFF5E718D),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin lịch hẹn',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildDetailRow('Dịch vụ', booking.serviceName ?? 'Khám tổng quát'),
          const Divider(height: 24),
          _buildDetailRow(
            'Ngày khám',
            booking.timeSlot != null
                ? DateFormat(
                    'EEEE, dd/MM/yyyy',
                    'vi',
                  ).format(booking.timeSlot!.date)
                : 'Chưa xác định',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            'Giờ khám',
            booking.timeSlot != null
                ? '${booking.timeSlot!.startTime.substring(0, 5)} - ${booking.timeSlot!.endTime.substring(0, 5)}'
                : 'Chưa xác định',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            'Ngày tạo',
            booking.createdAt != null
                ? DateFormat('dd/MM/yyyy HH:mm').format(booking.createdAt!)
                : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: const Color(0xFF5E718D),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ghi chú từ bệnh nhân',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            booking.notes?.isNotEmpty == true
                ? booking.notes!
                : 'Không có ghi chú',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: const Color(0xFF5E718D),
              fontStyle: booking.notes?.isNotEmpty == true
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
          if (booking.doctorNotes?.isNotEmpty == true) ...[
            const Divider(height: 24),
            Text(
              'Ghi chú của bác sĩ',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              booking.doctorNotes!,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: const Color(0xFF5E718D),
              ),
            ),
          ],
          if (booking.cancellationReason?.isNotEmpty == true) ...[
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    color: dangerColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lý do hủy',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: dangerColor,
                          ),
                        ),
                        Text(
                          booking.cancellationReason!,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: dangerColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    AppointmentController controller,
  ) {
    final status = booking.status ?? 'PENDING';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thao tác',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (status == 'PENDING') ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final success = await controller.confirmBooking(
                        booking.id,
                      );
                      if (success && context.mounted) {
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check),
                    label: Text(
                      'Xác nhận',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(context, controller),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dangerColor,
                      side: const BorderSide(color: dangerColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.close),
                    label: Text(
                      'Từ chối',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (status == 'CONFIRMED') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCompleteDialog(context, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.task_alt),
                label: Text(
                  'Hoàn thành khám',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else if (status == 'COMPLETED') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: successColor),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch hẹn đã hoàn thành',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: successColor,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status == 'CANCELLED') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, color: dangerColor),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch hẹn đã bị hủy',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: dangerColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    AppointmentController controller,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.cancelBooking(
                booking.id,
                reasonController.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (success && context.mounted) context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(
    BuildContext context,
    AppointmentController controller,
  ) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hoàn thành lịch hẹn',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: 'Nhập ghi chú của bác sĩ (không bắt buộc)...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.completeBooking(
                booking.id,
                notes: notesController.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (success && context.mounted) context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: successColor),
            child: const Text('Hoàn thành'),
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
        bgColor = warningColor.withOpacity(0.1);
        textColor = warningColor;
        label = 'Chờ xác nhận';
        break;
      case 'CONFIRMED':
        bgColor = primaryColor.withOpacity(0.1);
        textColor = primaryColor;
        label = 'Đã xác nhận';
        break;
      case 'COMPLETED':
        bgColor = successColor.withOpacity(0.1);
        textColor = successColor;
        label = 'Hoàn thành';
        break;
      case 'CANCELLED':
        bgColor = dangerColor.withOpacity(0.1);
        textColor = dangerColor;
        label = 'Đã hủy';
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
