import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/booking_dto.dart';
import '../data/booking_repository.dart';
import 'booking_list_controller.dart';
import 'widgets/doctor_avatar.dart';
import '../../home/presentation/home_controller.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final BookingDto booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  late BookingDto _booking;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  Future<void> _cancelBooking() async {
    final reasonController = TextEditingController();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy lịch khám', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc chắn muốn hủy lịch khám này không?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Lý do hủy (không bắt buộc)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Nhập lý do hủy tại đây...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận hủy', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);

    try {
      final reason = reasonController.text.trim().isEmpty 
          ? 'Bệnh nhân chủ động hủy lịch' 
          : reasonController.text.trim();
          
      final wasPaid = _booking.paymentStatus?.toUpperCase() == 'PAID';
      final updatedBooking = await ref.read(bookingRepositoryProvider).cancelBooking(_booking.id, reason);
      
      if (!mounted) return;
      
      setState(() {
        _booking = updatedBooking;
        _isCancelling = false;
      });

      ref.invalidate(bookingListControllerProvider);
      ref.invalidate(homeControllerProvider);

      if (wasPaid) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF297EFF)),
                SizedBox(width: 8),
                Text('Thông báo hoàn tiền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: const Text(
              'Lịch khám đã được hủy thành công. Vì bạn đã thanh toán trực tuyến trước đó, bộ phận CSKH của MediBook sẽ liên hệ với bạn để thực hiện hoàn tiền trong vòng 24h làm việc. Xin cảm ơn!',
              style: TextStyle(height: 1.45),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đồng ý', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF297EFF))),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy lịch khám thành công.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi hủy lịch: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    final status = booking.status?.toUpperCase() ?? '';
    final paymentStatus = booking.paymentStatus?.toUpperCase() ?? 'UNPAID';
    final canPay =
        paymentStatus != 'PAID' &&
        status != 'CANCELED' &&
        status != 'CANCELLED' &&
        status != 'COMPLETED';
    Color statusColor;
    String statusText;

    switch (status) {
      case 'CONFIRMED':
        statusColor = const Color(0xFF00C853);
        statusText = 'Đã xác nhận';
        break;
      case 'COMPLETED':
        statusColor = const Color(0xFF6B7280);
        statusText = 'Đã hoàn thành';
        break;
      case 'CANCELED':
        statusColor = const Color(0xFFFF5252);
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = const Color(0xFF297EFF);
        statusText = 'Đang chờ xác nhận';
    }

    String dateStr = 'Chưa xác định';
    String timeStr = 'Chưa xác định';

    if (booking.timeSlot != null) {
      final ts = booking.timeSlot!;
      dateStr = DateFormat('EEEE, dd/MM/yyyy', 'vi').format(ts.date);
      timeStr =
          '${ts.startTime.substring(0, 5)} - ${ts.endTime.substring(0, 5)}';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text(
          'Chi tiết lịch hẹn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF101418),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Trạng thái
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      status == 'COMPLETED'
                          ? Icons.check_circle
                          : status == 'CANCELED'
                          ? Icons.cancel
                          : status == 'CONFIRMED'
                          ? Icons.event_available
                          : Icons.schedule,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mã lịch hẹn: #${booking.id.substring(0, 8).toUpperCase()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin bác sĩ
            Container(
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
                    imageUrl: booking.doctorAvatarUrl,
                    size: 70,
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5E718D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.doctorName ?? 'Bác sĩ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101418),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin lịch hẹn
            Container(
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
                    Icons.calendar_today,
                    'Ngày khám',
                    dateStr,
                    const Color(0xFF297EFF),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.access_time,
                    'Giờ khám',
                    timeStr,
                    Colors.orange,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.medical_services,
                    'Dịch vụ',
                    booking.serviceName ?? 'N/A',
                    Colors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ghi chú
            if (canPay) ...[
              _buildPaymentNotice(context),
              const SizedBox(height: 16),
            ],

            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              Container(
                width: double.infinity,
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.sticky_note_2,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Ghi chú của bạn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101418),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      booking.notes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5E718D),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Ghi chú bác sĩ
            if (booking.doctorNotes != null &&
                booking.doctorNotes!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00C853).withOpacity(0.3),
                  ),
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.medical_information,
                            color: Color(0xFF00C853),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Nhận xét của bác sĩ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101418),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      booking.doctorNotes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5E718D),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Lý do hủy
            if (status == 'CANCELED' &&
                booking.cancellationReason != null &&
                booking.cancellationReason!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF5252).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFFFF5252).withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Lý do hủy',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF5252),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.cancellationReason!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5E718D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
      bottomNavigationBar: status != 'COMPLETED' && status != 'CANCELLED' && status != 'CANCELED'
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isCancelling ? null : _cancelBooking,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5252),
                        side: const BorderSide(color: Color(0xFFFF5252)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCancelling
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFF5252),
                              ),
                            )
                          : const Text(
                              'Hủy lịch',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Chat với bác sĩ
                        context.push('/chat/${booking.doctorId}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF297EFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Nhắn tin',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildPaymentNotice(BuildContext context) {
    final amount = _booking.totalAmount ?? 0.0;
    final amountText = amount > 0
        ? '${NumberFormat('#,###', 'vi').format(amount)}đ'
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF297EFF).withOpacity(0.25)),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF297EFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_rounded, color: Color(0xFF297EFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chưa thanh toán',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101418),
                  ),
                ),
                if (amountText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    amountText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5E718D),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.push(
                '/booking-payment',
                extra: {'booking': _booking, 'totalPrice': amount},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF297EFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Thanh toán'),
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
}
