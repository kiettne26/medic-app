import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

import '../../../core/websocket/slot_websocket_service.dart';
import '../data/dto/time_slot_dto.dart';
import '../data/schedule_pdf_service.dart';
import 'schedules_controller.dart';

class SchedulesScreen extends ConsumerStatefulWidget {
  const SchedulesScreen({super.key});

  @override
  ConsumerState<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends ConsumerState<SchedulesScreen> {
  String _selectedTab = 'all';
  final Set<String> _selectedSlotIds = {};
  
  // Date formatter
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _dayFormat = DateFormat('EEEE', 'vi');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(timeSlotsControllerProvider.notifier).refresh();
      // Connect to WebSocket
      ref.read(slotWebSocketServiceProvider).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(timeSlotsControllerProvider);
    final filter = ref.watch(scheduleFilterProvider);
    
    // Listen to WebSocket notifications
    ref.listen<AsyncValue<SlotNotification>>(slotNotificationsProvider, (previous, next) {
      next.whenData((notification) {
        // Show toast notification
        toastification.show(
          context: context,
          type: ToastificationType.info,
          style: ToastificationStyle.fillColored,
          title: Text(notification.message),
          description: Text('Loại: ${notification.type}'),
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.topRight,
        );
        
        // Auto refresh the list
        _refreshCurrentTab();
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildWeekFilter(filter),
            const SizedBox(height: 16),
            _buildTabs(slotsAsync),
            const SizedBox(height: 16),
            if (_selectedSlotIds.isNotEmpty) _buildBulkActions(),
            if (_selectedSlotIds.isNotEmpty) const SizedBox(height: 16),
            slotsAsync.when(
              data: (slots) => _buildTable(slots),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, s) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Text('Lỗi: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _refreshCurrentTab() {
    String? status;
    if (_selectedTab == 'pending') {
      status = 'PENDING';
    } else if (_selectedTab == 'approved') {
      status = 'APPROVED';
    } else if (_selectedTab == 'rejected') {
      status = 'REJECTED';
    }
    ref.read(timeSlotsControllerProvider.notifier).refresh(status: status);
  }

  void _onTabChanged(String tab) {
    setState(() {
      _selectedTab = tab;
      _selectedSlotIds.clear();
    });
    
    String? status;
    if (tab == 'pending') {
      status = 'PENDING';
    } else if (tab == 'approved') {
      status = 'APPROVED';
    } else if (tab == 'rejected') {
      status = 'REJECTED';
    }
    
    ref.read(timeSlotsControllerProvider.notifier).refresh(status: status);
  }

  void _toggleSelection(String slotId) {
    setState(() {
      if (_selectedSlotIds.contains(slotId)) {
        _selectedSlotIds.remove(slotId);
      } else {
        _selectedSlotIds.add(slotId);
      }
    });
  }

  void _toggleSelectAll(List<TimeSlotDto> slots) {
    setState(() {
      if (_selectedSlotIds.length == slots.length) {
        _selectedSlotIds.clear();
      } else {
        _selectedSlotIds.clear();
        _selectedSlotIds.addAll(slots.map((s) => s.id));
      }
    });
  }

  Future<void> _approveBulk() async {
    if (_selectedSlotIds.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận duyệt'),
        content: Text('Bạn có chắc chắn muốn duyệt ${_selectedSlotIds.length} lịch làm việc?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(timeSlotsControllerProvider.notifier).approveBulkSlots(_selectedSlotIds.toList());
      setState(() => _selectedSlotIds.clear());
    }
  }

  Future<void> _rejectBulk() async {
    if (_selectedSlotIds.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận từ chối'),
        content: Text('Bạn có chắc chắn muốn từ chối ${_selectedSlotIds.length} lịch làm việc?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(timeSlotsControllerProvider.notifier).rejectBulkSlots(_selectedSlotIds.toList());
      setState(() => _selectedSlotIds.clear());
    }
  }

  Future<void> _approveSlot(String slotId) async {
    await ref.read(timeSlotsControllerProvider.notifier).approveSlot(slotId);
  }

  Future<void> _rejectSlot(String slotId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận từ chối'),
        content: const Text('Bạn có chắc chắn muốn từ chối lịch làm việc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(timeSlotsControllerProvider.notifier).rejectSlot(slotId);
    }
  }

  Widget _buildHeader() {
    final slotsAsync = ref.watch(timeSlotsControllerProvider);
    final filter = ref.watch(scheduleFilterProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Admin',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5F718C),
              ),
            ),
            const SizedBox(width: 8),
            const Text('/', style: TextStyle(color: Color(0xFF5F718C))),
            const SizedBox(width: 8),
            Text(
              'Duyệt lịch làm việc',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111418),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duyệt lịch làm việc',
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111418),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Xem xét và phê duyệt lịch làm việc do bác sĩ đăng ký.',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: const Color(0xFF5F718C),
                  ),
                ),
              ],
            ),
            // Print button
            slotsAsync.when(
              data: (slots) => ElevatedButton.icon(
                onPressed: slots.isEmpty ? null : () => _printSchedules(slots, filter),
                icon: const Icon(Icons.print_outlined, size: 20),
                label: const Text('In lịch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E80FA),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _printSchedules(List<TimeSlotDto> slots, ScheduleFilter filter) async {
    String title = 'Lịch làm việc bác sĩ';
    
    if (_selectedTab == 'pending') {
      title = 'Lịch chờ duyệt';
    } else if (_selectedTab == 'approved') {
      title = 'Lịch đã duyệt';
    } else if (_selectedTab == 'rejected') {
      title = 'Lịch từ chối';
    }

    try {
      await SchedulePdfService.printSchedules(
        slots: slots,
        title: title,
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          title: const Text('Lỗi in lịch'),
          description: Text('$e'),
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.topRight,
        );
      }
    }
  }

  Widget _buildWeekFilter(ScheduleFilter filter) {
    final hasDateFilter = filter.startDate != null && filter.endDate != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          // Week navigation
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _navigateWeek(-1),
                  tooltip: 'Tuần trước',
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _navigateWeek(1),
                  tooltip: 'Tuần sau',
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Current week display
          Expanded(
            child: InkWell(
              onTap: () => _showDateRangePicker(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: Color(0xFF2E80FA),
                    ),
                    const SizedBox(width: 12),
                    if (hasDateFilter) ...[
                      Text(
                        _dateFormat.format(filter.startDate!),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111418),
                        ),
                      ),
                      Text(
                        ' - ',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF5F718C),
                        ),
                      ),
                      Text(
                        _dateFormat.format(filter.endDate!),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111418),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_getWeekLabel(filter.startDate!)})',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: const Color(0xFF5F718C),
                        ),
                      ),
                    ] else
                      Text(
                        'Chọn khoảng thời gian',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF5F718C),
                        ),
                      ),
                    const Spacer(),
                    const Icon(
                      Icons.unfold_more,
                      size: 20,
                      color: Color(0xFF5F718C),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Quick filters
          _QuickFilterButton(
            label: 'Tuần này',
            isSelected: _isCurrentWeek(filter),
            onTap: () => _setCurrentWeek(),
          ),
          const SizedBox(width: 8),
          _QuickFilterButton(
            label: 'Tuần sau',
            isSelected: _isNextWeek(filter),
            onTap: () => _setNextWeek(),
          ),
          const SizedBox(width: 8),
          _QuickFilterButton(
            label: 'Tháng này',
            isSelected: _isCurrentMonth(filter),
            onTap: () => _setCurrentMonth(),
          ),
          const SizedBox(width: 16),
          
          // Clear filter
          if (hasDateFilter)
            TextButton.icon(
              onPressed: () => ref.read(timeSlotsControllerProvider.notifier).clearDateFilter(),
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Xóa bộ lọc'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5F718C),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateWeek(int direction) {
    final filter = ref.read(scheduleFilterProvider);
    if (filter.startDate != null && filter.endDate != null) {
      final newStart = filter.startDate!.add(Duration(days: 7 * direction));
      final newEnd = filter.endDate!.add(Duration(days: 7 * direction));
      ref.read(timeSlotsControllerProvider.notifier).setDateRange(newStart, newEnd);
    }
  }

  Future<void> _showDateRangePicker() async {
    final filter = ref.read(scheduleFilterProvider);
    final now = DateTime.now();
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: filter.startDate != null && filter.endDate != null
          ? DateTimeRange(start: filter.startDate!, end: filter.endDate!)
          : null,
      locale: const Locale('vi'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E80FA),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      ref.read(timeSlotsControllerProvider.notifier).setDateRange(
        picked.start,
        picked.end,
      );
    }
  }

  void _setCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    ref.read(timeSlotsControllerProvider.notifier).setDateRange(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    );
  }

  void _setNextWeek() {
    final now = DateTime.now();
    final startOfNextWeek = now.subtract(Duration(days: now.weekday - 1)).add(const Duration(days: 7));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
    ref.read(timeSlotsControllerProvider.notifier).setDateRange(
      DateTime(startOfNextWeek.year, startOfNextWeek.month, startOfNextWeek.day),
      DateTime(endOfNextWeek.year, endOfNextWeek.month, endOfNextWeek.day),
    );
  }

  void _setCurrentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    ref.read(timeSlotsControllerProvider.notifier).setDateRange(startOfMonth, endOfMonth);
  }

  bool _isCurrentWeek(ScheduleFilter filter) {
    if (filter.startDate == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return filter.startDate!.year == startOfWeek.year &&
           filter.startDate!.month == startOfWeek.month &&
           filter.startDate!.day == startOfWeek.day;
  }

  bool _isNextWeek(ScheduleFilter filter) {
    if (filter.startDate == null) return false;
    final now = DateTime.now();
    final startOfNextWeek = now.subtract(Duration(days: now.weekday - 1)).add(const Duration(days: 7));
    return filter.startDate!.year == startOfNextWeek.year &&
           filter.startDate!.month == startOfNextWeek.month &&
           filter.startDate!.day == startOfNextWeek.day;
  }

  bool _isCurrentMonth(ScheduleFilter filter) {
    if (filter.startDate == null || filter.endDate == null) return false;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return filter.startDate!.day == startOfMonth.day &&
           filter.startDate!.month == startOfMonth.month &&
           filter.endDate!.day == endOfMonth.day &&
           filter.endDate!.month == endOfMonth.month;
  }

  String _getWeekLabel(DateTime date) {
    final now = DateTime.now();
    final startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfTargetWeek = date.subtract(Duration(days: date.weekday - 1));
    
    final diffWeeks = startOfTargetWeek.difference(startOfCurrentWeek).inDays ~/ 7;
    
    if (diffWeeks == 0) return 'Tuần này';
    if (diffWeeks == 1) return 'Tuần sau';
    if (diffWeeks == -1) return 'Tuần trước';
    return 'Tuần ${DateFormat('w').format(date)}';
  }

  Widget _buildTabs(AsyncValue<List<TimeSlotDto>> slotsAsync) {
    final slots = slotsAsync.valueOrNull ?? [];
    
    // Count based on current data - when filtered, only show that count
    int allCount = slots.length;
    int pendingCount = _selectedTab == 'pending' ? slots.length : slots.where((s) => s.status == 'PENDING').length;
    int approvedCount = _selectedTab == 'approved' ? slots.length : slots.where((s) => s.status == 'APPROVED').length;
    int rejectedCount = _selectedTab == 'rejected' ? slots.length : slots.where((s) => s.status == 'REJECTED').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Tất cả',
            count: allCount,
            isSelected: _selectedTab == 'all',
            onTap: () => _onTabChanged('all'),
          ),
          _TabItem(
            label: 'Chờ duyệt',
            count: pendingCount,
            isSelected: _selectedTab == 'pending',
            onTap: () => _onTabChanged('pending'),
            badgeColor: const Color(0xFFF59E0B),
          ),
          _TabItem(
            label: 'Đã duyệt',
            count: approvedCount,
            isSelected: _selectedTab == 'approved',
            onTap: () => _onTabChanged('approved'),
            badgeColor: const Color(0xFF10B981),
          ),
          _TabItem(
            label: 'Từ chối',
            count: rejectedCount,
            isSelected: _selectedTab == 'rejected',
            onTap: () => _onTabChanged('rejected'),
            badgeColor: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E80FA).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E80FA).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF2E80FA), size: 20),
          const SizedBox(width: 12),
          Text(
            'Đã chọn ${_selectedSlotIds.length} lịch',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E80FA),
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: _approveBulk,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Duyệt'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              side: const BorderSide(color: Color(0xFF10B981)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _rejectBulk,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Từ chối'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => setState(() => _selectedSlotIds.clear()),
            child: Text(
              'Bỏ chọn',
              style: GoogleFonts.manrope(color: const Color(0xFF5F718C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<TimeSlotDto> slots) {
    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Không có lịch làm việc nào',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5F718C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thử thay đổi bộ lọc hoặc chọn khoảng thời gian khác',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
              dataRowMinHeight: 72,
              dataRowMaxHeight: 72,
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: slots.isNotEmpty && _selectedSlotIds.length == slots.length,
                    onChanged: (_) => _toggleSelectAll(slots),
                    activeColor: const Color(0xFF2E80FA),
                  ),
                ),
                const DataColumn(label: _TableTitle('BÁC SĨ')),
                const DataColumn(label: _TableTitle('NGÀY')),
                const DataColumn(label: _TableTitle('THỨ')),
                const DataColumn(label: _TableTitle('GIỜ BẮT ĐẦU')),
                const DataColumn(label: _TableTitle('GIỜ KẾT THÚC')),
                const DataColumn(label: _TableTitle('TRẠNG THÁI')),
                const DataColumn(
                  label: _TableTitle('THAO TÁC', align: TextAlign.right),
                  numeric: true,
                ),
              ],
              rows: slots.map((slot) {
                final isSelected = _selectedSlotIds.contains(slot.id);
                return DataRow(
                  selected: isSelected,
                  cells: [
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleSelection(slot.id),
                        activeColor: const Color(0xFF2E80FA),
                      ),
                    ),
                    DataCell(_buildDoctorCell(slot)),
                    DataCell(Text(
                      _formatDate(slot.date),
                      style: GoogleFonts.manrope(fontSize: 14),
                    )),
                    DataCell(Text(
                      _getDayOfWeek(slot.date),
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: const Color(0xFF5F718C),
                      ),
                    )),
                    DataCell(Text(
                      slot.startTime,
                      style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
                    )),
                    DataCell(Text(
                      slot.endTime,
                      style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
                    )),
                    DataCell(_buildStatusBadge(slot.status)),
                    DataCell(_buildActions(slot)),
                  ],
                );
              }).toList(),
            ),
          ),
          // Pagination
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hiển thị ${slots.length} lịch làm việc',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF5F718C),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right),
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

  Widget _buildDoctorCell(TimeSlotDto slot) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: slot.doctorAvatar != null && slot.doctorAvatar!.isNotEmpty
              ? NetworkImage(slot.doctorAvatar!)
              : null,
          backgroundColor: const Color(0xFF2E80FA).withValues(alpha: 0.1),
          child: (slot.doctorAvatar == null || slot.doctorAvatar!.isEmpty)
              ? Text(
                  slot.doctorName?.isNotEmpty == true ? slot.doctorName![0] : 'D',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E80FA),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slot.doctorName ?? 'Bác sĩ',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF111418),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'ID: ${slot.doctorId.length >= 8 ? slot.doctorId.substring(0, 8) : slot.doctorId}',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: const Color(0xFF5F718C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'APPROVED':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF10B981);
        label = 'Đã duyệt';
        icon = Icons.check_circle_outline;
        break;
      case 'REJECTED':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFEF4444);
        label = 'Từ chối';
        icon = Icons.cancel_outlined;
        break;
      case 'PENDING':
      default:
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFF59E0B);
        label = 'Chờ duyệt';
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(TimeSlotDto slot) {
    if (slot.status == 'PENDING') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            color: const Color(0xFF10B981),
            tooltip: 'Duyệt',
            onPressed: () => _approveSlot(slot.id),
          ),
          IconButton(
            icon: const Icon(Icons.cancel_outlined),
            color: const Color(0xFFEF4444),
            tooltip: 'Từ chối',
            onPressed: () => _rejectSlot(slot.id),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined),
          color: const Color(0xFF5F718C),
          tooltip: 'Xem chi tiết',
          onPressed: () {
            // TODO: Show detail dialog
          },
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  String _getDayOfWeek(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        return _dayFormat.format(dt);
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}

class _QuickFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E80FA) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E80FA) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF5F718C),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? badgeColor;

  const _TabItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBadgeColor = badgeColor ?? const Color(0xFF2E80FA);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF2E80FA) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF2E80FA) : const Color(0xFF5F718C),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? effectiveBadgeColor.withValues(alpha: 0.1)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? effectiveBadgeColor : const Color(0xFF5F718C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableTitle extends StatelessWidget {
  final String title;
  final TextAlign align;

  const _TableTitle(this.title, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: align,
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF5F718C),
      ),
    );
  }
}
