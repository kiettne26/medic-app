import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/presentation/auth_controller.dart';
import 'dashboard_controller.dart';
import 'widgets/appointment_trend_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(dashboardControllerProvider);

    return appointmentsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Lỗi tải dữ liệu: $e')),
      data: (appointments) {
        // Calculate Stats
        final today = DateTime.now();
        final todayAppointments = appointments.where((a) {
          if (a.timeSlot == null) return false;
          final date = a.timeSlot!.date;
          return date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
        }).toList();

        final pendingCount = appointments
            .where((a) => a.status == 'PENDING')
            .length;
        final completedCount = appointments
            .where((a) => a.status == 'COMPLETED')
            .length;
        final cancelledCount = appointments
            .where((a) => a.status == 'CANCELLED')
            .length;

        // Sort by time for the table
        final sortedAppointments = [...todayAppointments]
          ..sort((a, b) {
            final timeA = a.timeSlot?.startTime ?? '00:00';
            final timeB = b.timeSlot?.startTime ?? '00:00';
            return timeA.compareTo(timeB);
          });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Số lịch hôm nay',
                      value: todayAppointments.length.toString(),
                      change: '', // Mock change for now
                      icon: Icons.event_note,
                      iconColor: const Color(0xFF297EFF),
                      changeColor: const Color(0xFF00C853),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _StatCard(
                      title: 'Lịch chờ xác nhận',
                      value: pendingCount.toString(),
                      change: '',
                      icon: Icons.pending_actions,
                      iconColor: Colors.orange,
                      changeColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _StatCard(
                      title: 'Lịch đã hoàn thành',
                      value: completedCount.toString(),
                      change: '',
                      icon: Icons.task_alt,
                      iconColor: const Color(0xFF00C853),
                      changeColor: const Color(0xFF00C853),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _StatCard(
                      title: 'Lịch bị hủy',
                      value: cancelledCount.toString(),
                      change: '',
                      icon: Icons.cancel_outlined,
                      iconColor: Colors.grey,
                      changeColor: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Main Section (Chart + Table)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chart Section - Widget biểu đồ xu hướng lịch hẹn
                  Expanded(
                    flex: 5,
                    child: AppointmentTrendChart(appointments: appointments),
                  ),

                  const SizedBox(width: 32),

                  // Table Section
                  Expanded(
                    flex: 7,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE6ECF4)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lịch hẹn hôm nay',
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0C131D),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Color(0xFF297EFF),
                                ),
                                onPressed: () {
                                  ref.refresh(dashboardControllerProvider);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Table Header
                          const Row(
                            children: [
                              Expanded(flex: 3, child: _Th('BỆNH NHÂN')),
                              Expanded(flex: 2, child: _Th('THỜI GIAN')),
                              Expanded(flex: 3, child: _Th('DỊCH VỤ')),
                              Expanded(flex: 2, child: _Th('TRẠNG THÁI')),
                              Expanded(flex: 1, child: SizedBox()), // Actions
                            ],
                          ),
                          const Divider(height: 32),
                          // Rows
                          if (sortedAppointments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Chưa có lịch hẹn nào hôm nay',
                                style: GoogleFonts.manrope(color: Colors.grey),
                              ),
                            ),
                          ...sortedAppointments.map((a) {
                            final name =
                                a.patientName ?? a.patientId ?? 'Unknown';
                            final initial = name.isNotEmpty
                                ? name[0].toUpperCase()
                                : '?';
                            final time = a.timeSlot?.startTime ?? 'N/A';
                            final service = a.serviceName ?? 'N/A';
                            final status = a.status ?? 'UNKNOWN';

                            return Column(
                              children: [
                                _TableRow(
                                  name: name,
                                  initial: initial,
                                  initialColor: const Color(0xFF297EFF),
                                  time: time,
                                  service: service,
                                  status: status,
                                  statusColor: _getStatusColor(status),
                                  onConfirm: status == 'PENDING'
                                      ? () => ref
                                            .read(
                                              dashboardControllerProvider
                                                  .notifier,
                                            )
                                            .confirmBooking(a.id)
                                      : null,
                                ),
                                const Divider(height: 1),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // ... Footer Tip preserved
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF297EFF).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF297EFF).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF297EFF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mẹo hôm nay cho Bác sĩ',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF0C131D),
                          ),
                        ),
                        Text(
                          'Bạn có 3 bệnh nhân mới chưa xem hồ sơ bệnh lý trước đó. Hãy kiểm tra ngay!',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF297EFF),
                        side: const BorderSide(color: Color(0xFF297EFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Xem hồ sơ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFF297EFF); // Blue
      case 'COMPLETED':
        return const Color(0xFF00C853); // Green
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color iconColor;
  final Color changeColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.iconColor,
    required this.changeColor,
  });

  @override
  Widget build(BuildContext context) {
    // ... Copy implementation from before
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6ECF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (change.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: changeColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0C131D),
            ),
          ),
        ],
      ),
    );
  }
}

class _Th extends StatelessWidget {
  final String text;
  const _Th(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final String name;
  final String initial;
  final Color initialColor;
  final String time;
  final String service;
  final String status;
  final Color statusColor;
  final bool highlightTime;
  final Widget? action;
  final VoidCallback? onConfirm;

  const _TableRow({
    required this.name,
    required this.initial,
    required this.initialColor,
    required this.time,
    required this.service,
    required this.status,
    required this.statusColor,
    this.highlightTime = false,
    this.action,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: initialColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: initialColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0C131D),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              time,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                color: highlightTime
                    ? const Color(0xFF297EFF)
                    : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              service,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'PENDING'
                        ? Colors.orange.withOpacity(0.1)
                        : statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: status == 'PENDING' ? Colors.orange : statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  action ??
                  (onConfirm != null
                      ? IconButton(
                          onPressed: onConfirm,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.orange,
                          ),
                          tooltip: 'Xác nhận',
                        )
                      : IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.grey,
                          ),
                        )),
            ),
          ),
        ],
      ),
    );
  }
}
