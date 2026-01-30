import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bookings/data/dto/booking_dto.dart';
import 'bookings_controller.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _statusFilter = 'ALL';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Search listener to setState and re-filter client side
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(String status) {
    if (_statusFilter == status) return;
    setState(() {
      _statusFilter = status;
    });
    // Call controller to refresh with new status
    // Note: status 'ALL' maps to null for API
    ref
        .read(bookingsControllerProvider.notifier)
        .refresh(status: status == 'ALL' ? null : status);
  }

  List<BookingDto> _applySearch(List<BookingDto> bookings) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return bookings;
    return bookings.where((b) {
      final patient = b.patientName?.toLowerCase() ?? '';
      final doctor = b.doctorName?.toLowerCase() ?? '';
      final id = b.id.toLowerCase();
      return patient.contains(query) ||
          doctor.contains(query) ||
          id.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsControllerProvider);

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
                onTap: () => _onFilterChanged('ALL'),
              ),
              _FilterChip(
                label: 'Chờ xác nhận',
                isSelected: _statusFilter == 'PENDING',
                onTap: () => _onFilterChanged('PENDING'),
                color: Colors.orange,
              ),
              _FilterChip(
                label: 'Đã xác nhận',
                isSelected: _statusFilter == 'CONFIRMED',
                onTap: () => _onFilterChanged('CONFIRMED'),
                color: const Color(0xFF3949AB),
              ),
              _FilterChip(
                label: 'Hoàn thành',
                isSelected: _statusFilter == 'COMPLETED',
                onTap: () => _onFilterChanged('COMPLETED'),
                color: Colors.green,
              ),
              _FilterChip(
                label: 'Đã hủy',
                isSelected: _statusFilter == 'CANCELED',
                onTap: () => _onFilterChanged('CANCELED'),
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats Summary (Calculated from current filtered list or separate API?)
          // Since we are filtering on server, we might not have counts for OTHER statuses.
          // Ideally we need a separate "BookingStats" API.
          // For now, we can just show counts of current loaded list or remove this stats row
          // if it's misleading when filtered.
          // Or we fetch ALL first then filter client side to keep stats correct?
          // Let's stick to server filtering for performance, and maybe hide stats or
          // just show "Hiển thị X kết quả".
          // The UI has _MiniStat. Let's just show count of current list.
          bookingsAsync.when(
            data: (bookings) {
              final filtered = _applySearch(bookings);
              return Column(
                children: [
                  // Stats Row (Optional: simplified)
                  // If we only have filtered data, we can't show "Pending" count if we are viewing "Completed".
                  // So either we fetch ALL and filter client side (simpler for small apps)
                  // OR we have a stats API.
                  // Given "PredictedTaskSize", let's assuming fetching ALL and filtering Client Side is safer for now
                  // to keep UI consistent, UNLESS result set is huge.
                  // Let's try client side filtering if the API supports it,
                  // BUT Controller has refresh(status).
                  // Let's modify logic: Load ALL initially. Filter client side.
                  // If user clicks filter, we update _statusFilter.
                  // Does controller.refresh(status) overwrite state? Yes.
                  // So if we switch tabs, we lose other data.
                  // Let's just show "Bookings Count: X" for now.
                  Row(
                    children: [
                      _MiniStat(
                        value: filtered.length.toString(),
                        label: 'Kết quả hiển thị',
                        color: const Color(0xFF3949AB),
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
                            color: Colors.black.withOpacity(0.04),
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
                            child: filtered.isEmpty
                                ? Center(
                                    child: Text(
                                      'Không có lịch hẹn nào',
                                      style: GoogleFonts.manrope(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      return _BookingRow(
                                        booking: filtered[index],
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Lỗi: $e')),
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
              color: Colors.black.withOpacity(0.03),
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
  final BookingDto booking;

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
              '#${booking.id.substring(0, 8)}',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Patient
          Expanded(
            flex: 2,
            child: Text(
              booking.patientName ?? 'N/A',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
          // Doctor
          Expanded(
            flex: 2,
            child: Text(
              booking.doctorName ?? 'N/A',
              style: GoogleFonts.manrope(color: Colors.grey[700]),
            ),
          ),
          // Service
          Expanded(
            flex: 2,
            child: Text(
              booking.serviceName ?? 'N/A',
              style: GoogleFonts.manrope(color: Colors.grey[700]),
            ),
          ),
          // Date
          Expanded(
            flex: 1,
            child: Text(
              booking.timeSlot.date,
              style: GoogleFonts.manrope(fontSize: 12),
            ),
          ),
          // Time
          Expanded(
            flex: 1,
            child: Text(
              '${booking.timeSlot.startTime}',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          // Status
          Expanded(flex: 1, child: _StatusBadge(status: booking.status)),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
