import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/features/booking/presentation/booking_list_controller.dart';
import 'package:app_fe/features/booking/data/dto/booking_dto.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class MedicalHistoryScreen extends ConsumerStatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  ConsumerState<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends ConsumerState<MedicalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh bookings in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingListControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingListControllerProvider);

    // Lọc chỉ lấy các lịch hẹn có trạng thái là COMPLETED (Đã hoàn thành)
    final completedBookings = bookingState.completedBookings.where((b) {
      return b.status?.toUpperCase() == 'COMPLETED';
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Lịch sử khám bệnh',
          style: TextStyle(
            color: Color(0xFF101418),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF101418), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildClinicalVisitsList(bookingState.isLoading, completedBookings),
    );
  }

  Widget _buildClinicalVisitsList(bool isLoading, List<BookingDto> completedBookings) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF297EFF)));
    }

    if (completedBookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_outlined, size: 72, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'Chưa có lịch sử khám bệnh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E718D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Các ca khám đã hoàn thành sẽ hiển thị tại đây.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(bookingListControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: completedBookings.length,
        itemBuilder: (context, index) {
          final booking = completedBookings[index];
          return _buildVisitCard(booking);
        },
      ),
    );
  }

  Widget _buildVisitCard(BookingDto booking) {
    String dateStr = 'Chưa xác định';
    String timeStr = 'Chưa xác định';
    if (booking.timeSlot != null) {
      final ts = booking.timeSlot!;
      dateStr = DateFormat('dd/MM/yyyy').format(ts.date);
      timeStr = '${ts.startTime.substring(0, 5)} - ${ts.endTime.substring(0, 5)}';
    }

    final doctorName = booking.doctorName ?? 'Bác sĩ MediBook';
    final serviceName = booking.serviceName ?? 'Khám sức khỏe tổng quát';
    final notes = booking.doctorNotes ?? 'Khám sức khỏe tổng quát và theo dõi định kỳ.';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF00C853),
              size: 24,
            ),
          ),
          title: Text(
            serviceName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF101418),
            ),
          ),
          subtitle: Text(
            '$dateStr • $timeStr',
            style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
          ),
          childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Doctor Row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFF3F4F6),
                  backgroundImage: booking.doctorAvatarUrl != null && booking.doctorAvatarUrl!.isNotEmpty
                      ? NetworkImage(booking.doctorAvatarUrl!)
                      : null,
                  child: booking.doctorAvatarUrl == null || booking.doctorAvatarUrl!.isEmpty
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bác sĩ điều trị',
                        style: TextStyle(fontSize: 11, color: Color(0xFF718096)),
                      ),
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Diagnostic / Doctor advice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEDF2F7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_outlined, size: 16, color: Color(0xFF4A5568)),
                      SizedBox(width: 6),
                      Text(
                        'Chẩn đoán & Dặn dò của bác sĩ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4A5568),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Payment row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thanh toán: ${booking.paymentStatus ?? 'UNPAID'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF297EFF),
                  ),
                ),
                if (booking.totalAmount != null && booking.totalAmount! > 0)
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0)
                        .format(booking.totalAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101418),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
