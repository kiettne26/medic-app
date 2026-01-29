import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _statusFilter = 'ALL';
  final _searchController = TextEditingController();

  // Mock data - sẽ thay bằng API thực
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': '1',
      'patient': 'Nguyễn Văn A',
      'doctor': 'BS. Trần Thị B',
      'service': 'Khám tổng quát',
      'date': '2026-01-29',
      'time': '09:00',
      'status': 'CONFIRMED',
    },
    {
      'id': '2',
      'patient': 'Lê Văn C',
      'doctor': 'BS. Phạm Văn D',
      'service': 'Tư vấn dinh dưỡng',
      'date': '2026-01-29',
      'time': '10:30',
      'status': 'PENDING',
    },
    {
      'id': '3',
      'patient': 'Hoàng Thị E',
      'doctor': 'BS. Nguyễn Văn F',
      'service': 'Tư vấn tâm lý',
      'date': '2026-01-28',
      'time': '14:00',
      'status': 'COMPLETED',
    },
    {
      'id': '4',
      'patient': 'Trần Văn G',
      'doctor': 'BS. Lê Thị H',
      'service': 'Khám tổng quát',
      'date': '2026-01-28',
      'time': '15:30',
      'status': 'CANCELED',
    },
    {
      'id': '5',
      'patient': 'Phạm Thị K',
      'doctor': 'BS. Trần Thị B',
      'service': 'Khám tổng quát',
      'date': '2026-01-30',
      'time': '08:00',
      'status': 'PENDING',
    },
  ];

  List<Map<String, dynamic>> get _filteredBookings {
    if (_statusFilter == 'ALL') return _bookings;
    return _bookings.where((b) => b['status'] == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters Row
          Row(
            children: [
              // Search
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên bệnh nhân, bác sĩ...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Status Filter
              _FilterChip(
                label: 'Tất cả',
                isSelected: _statusFilter == 'ALL',
                onTap: () => setState(() => _statusFilter = 'ALL'),
              ),
              _FilterChip(
                label: 'Chờ xác nhận',
                isSelected: _statusFilter == 'PENDING',
                onTap: () => setState(() => _statusFilter = 'PENDING'),
                color: Colors.orange,
              ),
              _FilterChip(
                label: 'Đã xác nhận',
                isSelected: _statusFilter == 'CONFIRMED',
                onTap: () => setState(() => _statusFilter = 'CONFIRMED'),
                color: const Color(0xFF3949AB),
              ),
              _FilterChip(
                label: 'Hoàn thành',
                isSelected: _statusFilter == 'COMPLETED',
                onTap: () => setState(() => _statusFilter = 'COMPLETED'),
                color: Colors.green,
              ),
              _FilterChip(
                label: 'Đã hủy',
                isSelected: _statusFilter == 'CANCELED',
                onTap: () => setState(() => _statusFilter = 'CANCELED'),
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats Summary
          Row(
            children: [
              _MiniStat(
                value: _bookings.length.toString(),
                label: 'Tổng cộng',
                color: const Color(0xFF3949AB),
              ),
              _MiniStat(
                value: _bookings
                    .where((b) => b['status'] == 'PENDING')
                    .length
                    .toString(),
                label: 'Chờ xác nhận',
                color: Colors.orange,
              ),
              _MiniStat(
                value: _bookings
                    .where((b) => b['status'] == 'CONFIRMED')
                    .length
                    .toString(),
                label: 'Đã xác nhận',
                color: const Color(0xFF3949AB),
              ),
              _MiniStat(
                value: _bookings
                    .where((b) => b['status'] == 'COMPLETED')
                    .length
                    .toString(),
                label: 'Hoàn thành',
                color: Colors.green,
              ),
              _MiniStat(
                value: _bookings
                    .where((b) => b['status'] == 'CANCELED')
                    .length
                    .toString(),
                label: 'Đã hủy',
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bookings Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        _tableHeader('Mã', flex: 1),
                        _tableHeader('Bệnh nhân', flex: 2),
                        _tableHeader('Bác sĩ', flex: 2),
                        _tableHeader('Dịch vụ', flex: 2),
                        _tableHeader('Ngày', flex: 1),
                        _tableHeader('Giờ', flex: 1),
                        _tableHeader('Trạng thái', flex: 1),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Table Body
                  Expanded(
                    child: _filteredBookings.isEmpty
                        ? Center(
                            child: Text(
                              'Không có lịch hẹn nào',
                              style: GoogleFonts.manrope(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _filteredBookings.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              return _BookingRow(
                                booking: _filteredBookings[index],
                              );
                            },
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

  Widget _tableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? const Color(0xFF3949AB);

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? chipColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Colors.grey[600],
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

class _BookingRow extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ID
          Expanded(
            flex: 1,
            child: Text(
              '#${booking['id']}',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          // Patient
          Expanded(
            flex: 2,
            child: Text(
              booking['patient'],
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
          // Doctor
          Expanded(
            flex: 2,
            child: Text(
              booking['doctor'],
              style: GoogleFonts.manrope(color: Colors.grey[700]),
            ),
          ),
          // Service
          Expanded(
            flex: 2,
            child: Text(
              booking['service'],
              style: GoogleFonts.manrope(color: Colors.grey[700]),
            ),
          ),
          // Date
          Expanded(
            flex: 1,
            child: Text(booking['date'], style: GoogleFonts.manrope()),
          ),
          // Time
          Expanded(
            flex: 1,
            child: Text(
              booking['time'],
              style: GoogleFonts.manrope(fontWeight: FontWeight.w500),
            ),
          ),
          // Status
          Expanded(flex: 1, child: _StatusBadge(status: booking['status'])),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'CONFIRMED':
        color = const Color(0xFF3949AB);
        label = 'Đã xác nhận';
        break;
      case 'COMPLETED':
        color = Colors.green;
        label = 'Hoàn thành';
        break;
      case 'PENDING':
        color = Colors.orange;
        label = 'Chờ xác nhận';
        break;
      case 'CANCELED':
        color = Colors.red;
        label = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
