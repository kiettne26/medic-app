import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/dto/booking_dto.dart';
import 'bookings_controller.dart';
import '../../layout/admin_layout.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final _searchController = TextEditingController();
  String? _selectedDoctor;
  String? _selectedStatus;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(bookingsControllerProvider.notifier).applyFilters(
          status: _selectedStatus,
          doctorId: _selectedDoctor,
          date: _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : null,
        );
  }

  void _resetFilters() {
    setState(() {
      _selectedDoctor = null;
      _selectedStatus = null;
      _selectedDate = null;
      _searchController.clear();
    });
    ref.read(bookingsControllerProvider.notifier).resetFilters();
  }

  void _onFilterChanged() {
    // Tự động apply filter khi thay đổi
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingsControllerProvider);

    return Container(
      color: AdminColors.backgroundLight,
      child: Column(
        children: [
          // Stats Section - Compact
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: _buildStatsSection(state),
          ),

          // Filters Section - Collapsible
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildFiltersSection(state),
          ),

          const SizedBox(height: 16),

          // Table Section - Takes remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _buildTableSection(state),
            ),
          ),
        ],
      ),
    );
  }

  /// Stats Cards Section - Compact
  Widget _buildStatsSection(BookingsState state) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: _CompactStatCard(
              title: 'Hôm nay',
              value: state.stats.totalToday.toString(),
              icon: Icons.event_note_rounded,
              iconColor: AdminColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _CompactStatCard(
              title: 'Chờ duyệt',
              value: state.stats.pendingCount.toString(),
              icon: Icons.pending_actions_rounded,
              iconColor: Colors.amber.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _CompactStatCard(
              title: 'Đã xác nhận',
              value: state.stats.confirmedCount.toString(),
              icon: Icons.check_circle_outline,
              iconColor: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _CompactStatCard(
              title: 'Hoàn thành',
              value: state.stats.completedCount.toString(),
              icon: Icons.task_alt_rounded,
              iconColor: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _CompactStatCard(
              title: 'Đã hủy',
              value: state.stats.canceledCount.toString(),
              icon: Icons.cancel_outlined,
              iconColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// Filters Section - Inline compact
  Widget _buildFiltersSection(BookingsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Row(
        children: [
          // Status Filter
          Expanded(
            flex: 2,
            child: _CompactFilterDropdown<String>(
              hint: 'Trạng thái',
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(value: null, child: Text('Tất cả')),
                DropdownMenuItem(value: 'PENDING', child: Text('Chờ duyệt')),
                DropdownMenuItem(value: 'CONFIRMED', child: Text('Đã xác nhận')),
                DropdownMenuItem(value: 'COMPLETED', child: Text('Hoàn thành')),
                DropdownMenuItem(value: 'CANCELED', child: Text('Đã hủy')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _onFilterChanged();
              },
            ),
          ),
          const SizedBox(width: 12),

          // Doctor Filter
          Expanded(
            flex: 3,
            child: _CompactFilterDropdown<String>(
              hint: 'Bác sĩ',
              value: _selectedDoctor,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tất cả bác sĩ')),
                ...state.doctors.map((d) => DropdownMenuItem(
                      value: d.id,
                      child: Text('BS. ${d.fullName}', overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedDoctor = value);
                _onFilterChanged();
              },
            ),
          ),
          const SizedBox(width: 12),

          // Date Filter
          Expanded(
            flex: 2,
            child: _CompactDatePicker(
              hint: 'Ngày khám',
              value: _selectedDate,
              onChanged: (date) {
                setState(() => _selectedDate = date);
                _onFilterChanged();
              },
            ),
          ),
          const SizedBox(width: 12),

          // Reset Button
          IconButton(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh),
            tooltip: 'Đặt lại bộ lọc',
            style: IconButton.styleFrom(
              foregroundColor: AdminColors.textSecondary,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }

  /// Table Section
  Widget _buildTableSection(BookingsState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _TableHeaderCell('Mã lịch', flex: 1),
                _TableHeaderCell('Bệnh nhân', flex: 2),
                _TableHeaderCell('Bác sĩ', flex: 2),
                _TableHeaderCell('Ngày & Giờ', flex: 2),
                _TableHeaderCell('Trạng thái', flex: 1),
                _TableHeaderCell('Thao tác', flex: 1, alignment: Alignment.centerRight),
              ],
            ),
          ),
          const Divider(height: 1, color: AdminColors.borderLight),

          // Table Body
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'Có lỗi xảy ra',
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AdminColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.error!,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    color: AdminColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      ref.read(bookingsControllerProvider.notifier).refresh(),
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : state.bookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'Không có lịch hẹn nào',
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    color: AdminColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.bookings.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: AdminColors.borderLight),
                            itemBuilder: (context, index) {
                              return _BookingRow(
                                booking: state.bookings[index],
                                onConfirm: () => _confirmBooking(state.bookings[index]),
                                onCancel: () => _showCancelDialog(state.bookings[index]),
                                onComplete: () => _completeBooking(state.bookings[index]),
                                onView: () => _showBookingDetail(state.bookings[index]),
                              );
                            },
                          ),
          ),

          // Pagination
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: const Border(top: BorderSide(color: AdminColors.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hiển thị ${state.bookings.length} trong tổng số ${state.totalElements} lịch hẹn',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AdminColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    _PaginationButton(
                      icon: Icons.chevron_left,
                      onPressed: state.currentPage > 0
                          ? () => ref.read(bookingsControllerProvider.notifier).previousPage()
                          : null,
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(
                      state.totalPages > 5 ? 5 : state.totalPages,
                      (index) {
                        int pageNum;
                        if (state.totalPages <= 5) {
                          pageNum = index;
                        } else if (state.currentPage < 3) {
                          pageNum = index;
                        } else if (state.currentPage > state.totalPages - 4) {
                          pageNum = state.totalPages - 5 + index;
                        } else {
                          pageNum = state.currentPage - 2 + index;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _PaginationButton(
                            label: '${pageNum + 1}',
                            isActive: pageNum == state.currentPage,
                            onPressed: () =>
                                ref.read(bookingsControllerProvider.notifier).goToPage(pageNum),
                          ),
                        );
                      },
                    ),
                    _PaginationButton(
                      icon: Icons.chevron_right,
                      onPressed: state.currentPage < state.totalPages - 1
                          ? () => ref.read(bookingsControllerProvider.notifier).nextPage()
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Actions
  Future<void> _confirmBooking(BookingDto booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận lịch hẹn', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc chắn muốn xác nhận lịch hẹn của ${booking.patientName}?',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(bookingsControllerProvider.notifier).confirmBooking(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã xác nhận lịch hẹn' : 'Không thể xác nhận lịch hẹn'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeBooking(BookingDto booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hoàn thành lịch hẹn', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc chắn muốn đánh dấu hoàn thành lịch hẹn của ${booking.patientName}?',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(bookingsControllerProvider.notifier).completeBooking(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã hoàn thành lịch hẹn' : 'Không thể hoàn thành lịch hẹn'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCancelDialog(BookingDto booking) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hủy lịch hẹn', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn hủy lịch hẹn của ${booking.patientName}?',
              style: GoogleFonts.manrope(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Lý do hủy (tùy chọn)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(bookingsControllerProvider.notifier).cancelBooking(
            booking.id,
            reason: reasonController.text.isNotEmpty ? reasonController.text : null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã hủy lịch hẹn' : 'Không thể hủy lịch hẹn'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
    reasonController.dispose();
  }

  void _showBookingDetail(BookingDto booking) {
    showDialog(
      context: context,
      builder: (context) => _BookingDetailDialog(booking: booking),
    );
  }
}

/// Compact Stat Card Widget
class _CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _CompactStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AdminColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact Filter Dropdown Widget
class _CompactFilterDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _CompactFilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AdminColors.borderLight),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: GoogleFonts.manrope(fontSize: 13, color: AdminColors.textSecondary)),
          items: items,
          onChanged: onChanged,
          style: GoogleFonts.manrope(fontSize: 13, color: AdminColors.textPrimary),
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        ),
      ),
    );
  }
}

/// Compact Date Picker Widget
class _CompactDatePicker extends StatelessWidget {
  final String hint;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _CompactDatePicker({
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        onChanged(date);
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AdminColors.borderLight),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? DateFormat('dd/MM/yyyy').format(value!) : hint,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: value != null ? AdminColors.textPrimary : AdminColors.textSecondary,
                ),
              ),
            ),
            Icon(Icons.calendar_today, size: 16, color: AdminColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Table Header Cell Widget
class _TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final Alignment alignment;

  const _TableHeaderCell(this.text, {this.flex = 1, this.alignment = Alignment.centerLeft});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AdminColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Booking Row Widget
class _BookingRow extends StatelessWidget {
  final BookingDto booking;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onComplete;
  final VoidCallback onView;

  const _BookingRow({
    required this.booking,
    required this.onConfirm,
    required this.onCancel,
    required this.onComplete,
    required this.onView,
  });

  Color _getAvatarColor(String? name) {
    if (name == null || name.isEmpty) return Colors.grey;
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[name.hashCode % colors.length];
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onView,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ID
            Expanded(
              flex: 1,
              child: Text(
                '#${booking.id.substring(0, booking.id.length >= 8 ? 8 : booking.id.length)}',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: AdminColors.primary,
                  fontSize: 13,
                ),
              ),
            ),

            // Patient
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getAvatarColor(booking.patientName).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(booking.patientName),
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getAvatarColor(booking.patientName),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      booking.patientName ?? 'N/A',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Doctor
            Expanded(
              flex: 2,
              child: Text(
                booking.doctorName != null ? 'BS. ${booking.doctorName}' : 'N/A',
                style: GoogleFonts.manrope(
                  color: AdminColors.textSecondary,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Date & Time
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(booking.timeSlot.date),
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color: AdminColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    booking.timeSlot.startTime,
                    style: GoogleFonts.manrope(
                      color: AdminColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Status
            Expanded(
              flex: 1,
              child: _StatusBadge(status: booking.status),
            ),

            // Actions
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (booking.status == 'PENDING') ...[
                    _ActionButton(
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                      tooltip: 'Xác nhận',
                      onPressed: onConfirm,
                    ),
                    _ActionButton(
                      icon: Icons.cancel_outlined,
                      color: Colors.red,
                      tooltip: 'Hủy',
                      onPressed: onCancel,
                    ),
                  ],
                  if (booking.status == 'CONFIRMED')
                    _ActionButton(
                      icon: Icons.task_alt,
                      color: Colors.green,
                      tooltip: 'Hoàn thành',
                      onPressed: onComplete,
                    ),
                  _ActionButton(
                    icon: Icons.visibility_outlined,
                    color: AdminColors.textSecondary,
                    tooltip: 'Xem chi tiết',
                    onPressed: onView,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'CONFIRMED':
        color = Colors.blue;
        label = 'Đã xác nhận';
        break;
      case 'COMPLETED':
        color = Colors.green;
        label = 'Hoàn thành';
        break;
      case 'PENDING':
        color = Colors.amber.shade700;
        label = 'Chờ duyệt';
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
        label.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

/// Pagination Button Widget
class _PaginationButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final bool isActive;
  final VoidCallback? onPressed;

  const _PaginationButton({
    this.icon,
    this.label,
    this.isActive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AdminColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? AdminColors.primary : AdminColors.borderLight,
          ),
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  size: 18,
                  color: isDisabled
                      ? AdminColors.textSecondary.withOpacity(0.5)
                      : AdminColors.textSecondary,
                )
              : Text(
                  label ?? '',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AdminColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Booking Detail Dialog
class _BookingDetailDialog extends StatelessWidget {
  final BookingDto booking;

  const _BookingDetailDialog({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chi tiết lịch hẹn',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _DetailRow('Mã lịch', '#${booking.id}'),
            _DetailRow('Bệnh nhân', booking.patientName ?? 'N/A'),
            _DetailRow('Bác sĩ', booking.doctorName ?? 'N/A'),
            _DetailRow('Dịch vụ', booking.serviceName ?? 'N/A'),
            _DetailRow('Ngày khám', booking.timeSlot.date),
            _DetailRow('Giờ khám', '${booking.timeSlot.startTime} - ${booking.timeSlot.endTime}'),
            _DetailRow('Trạng thái', _getStatusLabel(booking.status)),
            if (booking.notes != null && booking.notes!.isNotEmpty)
              _DetailRow('Ghi chú', booking.notes!),
            if (booking.cancellationReason != null && booking.cancellationReason!.isNotEmpty)
              _DetailRow('Lý do hủy', booking.cancellationReason!),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ duyệt';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELED':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                color: AdminColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
