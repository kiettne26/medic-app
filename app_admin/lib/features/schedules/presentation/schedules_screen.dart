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
  String _doctorSearchQuery = '';
  String? _selectedDoctorId;
  
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
              data: (slots) => _buildMasterDetailLayout(slots),
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
      _selectedDoctorId = null;
      _doctorSearchQuery = '';
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

  Widget _buildMasterDetailLayout(List<TimeSlotDto> slots) {
    // 1. Trích xuất danh sách bác sĩ độc bản từ slots
    final doctorsMap = <String, _DoctorSummary>{};
    for (final slot in slots) {
      if (slot.doctorId.isNotEmpty) {
        doctorsMap.putIfAbsent(
          slot.doctorId,
          () => _DoctorSummary(
            id: slot.doctorId,
            name: slot.doctorName ?? 'Bác sĩ',
            avatar: slot.doctorAvatar,
          ),
        );
        final doc = doctorsMap[slot.doctorId]!;
        if (slot.status == 'PENDING') doc.pendingCount++;
        if (slot.status == 'APPROVED') doc.approvedCount++;
        if (slot.status == 'REJECTED') doc.rejectedCount++;
      }
    }

    // 2. Lọc theo thanh tìm kiếm tên bác sĩ
    final filteredDoctors = doctorsMap.values.where((doc) {
      if (_doctorSearchQuery.isEmpty) return true;
      return doc.name.toLowerCase().contains(_doctorSearchQuery.toLowerCase());
    }).toList();

    // 3. Tự động chọn bác sĩ đầu tiên nếu chưa chọn hoặc id không còn hợp lệ
    if (_selectedDoctorId == null && filteredDoctors.isNotEmpty) {
      _selectedDoctorId = filteredDoctors.first.id;
    } else if (_selectedDoctorId != null && !filteredDoctors.any((d) => d.id == _selectedDoctorId)) {
      _selectedDoctorId = filteredDoctors.isNotEmpty ? filteredDoctors.first.id : null;
    }

    // 4. Lấy slots của bác sĩ đang chọn
    final doctorSlots = slots.where((s) => s.doctorId == _selectedDoctorId).toList();

    // 5. Nhóm các slots của bác sĩ đó theo ngày
    final slotsByDate = <String, List<TimeSlotDto>>{};
    for (final slot in doctorSlots) {
      slotsByDate.putIfAbsent(slot.date, () => []).add(slot);
    }
    final sortedDates = slotsByDate.keys.toList()..sort((a, b) => a.compareTo(b));

    if (slots.isEmpty) {
      return _buildEmptyState();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MASTER PANEL - BÊN TRÁI
        Expanded(
          flex: 3,
          child: _buildMasterPanel(filteredDoctors),
        ),
        const SizedBox(width: 24),
        // DETAIL PANEL - BÊN PHẢI
        Expanded(
          flex: 7,
          child: _buildDetailPanel(
            filteredDoctors.firstWhere(
              (d) => d.id == _selectedDoctorId,
              orElse: () => _DoctorSummary(id: '', name: 'Không rõ'),
            ),
            doctorSlots,
            slotsByDate,
            sortedDates,
          ),
        ),
      ],
    );
  }

  Widget _buildMasterPanel(List<_DoctorSummary> doctors) {
    return Container(
      height: 700,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề & Tìm kiếm bác sĩ
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danh sách Bác sĩ (${doctors.length})',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111418),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _doctorSearchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bác sĩ...',
                      hintStyle: GoogleFonts.manrope(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          
          // Danh sách bác sĩ cuộn
          Expanded(
            child: doctors.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy bác sĩ',
                      style: GoogleFonts.manrope(color: Colors.grey[500]),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: doctors.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) {
                      final doc = doctors[index];
                      final isSelected = doc.id == _selectedDoctorId;
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDoctorId = doc.id;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEBF3FF) : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? const Color(0xFF2E80FA) : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: doc.avatar != null && doc.avatar!.isNotEmpty
                                    ? NetworkImage(doc.avatar!)
                                    : null,
                                backgroundColor: const Color(0xFF2E80FA).withValues(alpha: 0.1),
                                child: (doc.avatar == null || doc.avatar!.isEmpty)
                                    ? Text(
                                        doc.name.isNotEmpty ? doc.name[0] : 'D',
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2E80FA),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.name,
                                      style: GoogleFonts.manrope(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 14,
                                        color: isSelected ? const Color(0xFF2E80FA) : const Color(0xFF111418),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${doc.id.length >= 8 ? doc.id.substring(0, 8) : doc.id}',
                                      style: GoogleFonts.manrope(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Badge counts
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (doc.pendingCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        '${doc.pendingCount} chờ',
                                        style: GoogleFonts.manrope(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                  if (doc.pendingCount == 0 && doc.approvedCount > 0)
                                    Text(
                                      '${doc.approvedCount} đã duyệt',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(
    _DoctorSummary doc,
    List<TimeSlotDto> doctorSlots,
    Map<String, List<TimeSlotDto>> slotsByDate,
    List<String> sortedDates,
  ) {
    if (doc.id.isEmpty) {
      return Container(
        height: 700,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Center(
          child: Text(
            'Vui lòng chọn bác sĩ bên trái để xem chi tiết lịch',
            style: GoogleFonts.manrope(color: Colors.grey[500]),
          ),
        ),
      );
    }

    // Tính toán số lượng slots được chọn cho bác sĩ này
    final selectedSlotsOfThisDoctor = doctorSlots.where((s) => _selectedSlotIds.contains(s.id)).toList();
    final hasSelected = selectedSlotsOfThisDoctor.isNotEmpty;
    final allSelected = selectedSlotsOfThisDoctor.isNotEmpty && selectedSlotsOfThisDoctor.length == doctorSlots.length;

    return Container(
      height: 700,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detail Header - Thông tin bác sĩ
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: doc.avatar != null && doc.avatar!.isNotEmpty
                      ? NetworkImage(doc.avatar!)
                      : null,
                  backgroundColor: const Color(0xFF2E80FA).withValues(alpha: 0.1),
                  child: (doc.avatar == null || doc.avatar!.isEmpty)
                      ? Text(
                          doc.name.isNotEmpty ? doc.name[0] : 'D',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E80FA),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.name,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111418),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng số: ${doctorSlots.length} lịch (${doc.pendingCount} chờ duyệt, ${doc.approvedCount} đã duyệt, ${doc.rejectedCount} bị từ chối)',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: const Color(0xFF5F718C),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Select all / Bulk actions
                if (doctorSlots.isNotEmpty) ...[
                  Checkbox(
                    value: allSelected,
                    onChanged: (_) {
                      setState(() {
                        if (allSelected) {
                          // Bỏ chọn tất cả slot của bác sĩ này
                          for (final s in doctorSlots) {
                            _selectedSlotIds.remove(s.id);
                          }
                        } else {
                          // Chọn tất cả slot của bác sĩ này
                          for (final s in doctorSlots) {
                            _selectedSlotIds.add(s.id);
                          }
                        }
                      });
                    },
                    activeColor: const Color(0xFF2E80FA),
                  ),
                  Text(
                    'Chọn tất cả',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5F718C),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          
          // Bulk actions banner riêng cho bác sĩ này
          if (hasSelected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF2E80FA).withValues(alpha: 0.06),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2E80FA), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Đã chọn ${selectedSlotsOfThisDoctor.length} / ${doctorSlots.length} khung giờ',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E80FA),
                    ),
                  ),
                  const Spacer(),
                  // Approve bulk for this doctor
                  ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận duyệt'),
                          content: Text('Bạn có chắc muốn duyệt ${selectedSlotsOfThisDoctor.length} khung giờ của bác sĩ ${doc.name}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                              child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(timeSlotsControllerProvider.notifier).approveBulkSlots(selectedSlotsOfThisDoctor.map((s) => s.id).toList());
                        setState(() {
                          _selectedSlotIds.removeAll(selectedSlotsOfThisDoctor.map((s) => s.id));
                        });
                      }
                    },
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Duyệt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reject bulk for this doctor
                  ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận từ chối'),
                          content: Text('Bạn có chắc muốn từ chối ${selectedSlotsOfThisDoctor.length} khung giờ của bác sĩ ${doc.name}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                              child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(timeSlotsControllerProvider.notifier).rejectBulkSlots(selectedSlotsOfThisDoctor.map((s) => s.id).toList());
                        setState(() {
                          _selectedSlotIds.removeAll(selectedSlotsOfThisDoctor.map((s) => s.id));
                        });
                      }
                    },
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Từ chối'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          
          // Danh sách các ngày cuộn
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final daySlots = slotsByDate[date]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ngày Header
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            '${_getDayOfWeek(date)} - ${_formatDate(date)}',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111418),
                            ),
                          ),
                          const Spacer(),
                          // Nút duyệt nhanh các slot PENDING của ngày này
                          if (daySlots.any((s) => s.status == 'PENDING'))
                            TextButton.icon(
                              onPressed: () async {
                                final pendingIds = daySlots.where((s) => s.status == 'PENDING').map((s) => s.id).toList();
                                await ref.read(timeSlotsControllerProvider.notifier).approveBulkSlots(pendingIds);
                              },
                              icon: const Icon(Icons.done_all, size: 14, color: Color(0xFF10B981)),
                              label: Text(
                                'Duyệt nhanh ngày này',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Grid of Time Slots
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: daySlots.length,
                      itemBuilder: (context, idx) {
                        final slot = daySlots[idx];
                        final isSelected = _selectedSlotIds.contains(slot.id);
                        
                        Color bgColor;
                        Color borderColor;
                        Color textColor;
                        String statusLabel;
                        
                        if (slot.status == 'APPROVED') {
                          bgColor = const Color(0xFFECFDF5);
                          borderColor = const Color(0xFFA7F3D0);
                          textColor = const Color(0xFF047857);
                          statusLabel = 'Đã duyệt';
                        } else if (slot.status == 'REJECTED') {
                          bgColor = const Color(0xFFFEF2F2);
                          borderColor = const Color(0xFFFCA5A5);
                          textColor = const Color(0xFFB91C1C);
                          statusLabel = 'Từ chối';
                        } else {
                          bgColor = const Color(0xFFFFFBEB);
                          borderColor = const Color(0xFFFDE68A);
                          textColor = const Color(0xFFB45309);
                          statusLabel = 'Chờ duyệt';
                        }
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSlotIds.remove(slot.id);
                              } else {
                                _selectedSlotIds.add(slot.id);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2E80FA) : borderColor,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF2E80FA).withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                // Checkbox ở góc trên bên trái
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedSlotIds.add(slot.id);
                                          } else {
                                            _selectedSlotIds.remove(slot.id);
                                          }
                                        });
                                      },
                                      activeColor: const Color(0xFF2E80FA),
                                    ),
                                  ),
                                ),
                                
                                // Khung giờ ở giữa
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}',
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF111418),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        statusLabel,
                                        style: GoogleFonts.manrope(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Nút thao tác nhanh ở góc trên bên phải khi ở trạng thái PENDING
                                if (slot.status == 'PENDING')
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Duyệt nhanh
                                        InkWell(
                                          onTap: () => _approveSlot(slot.id),
                                          borderRadius: BorderRadius.circular(100),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF10B981),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check, size: 10, color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        // Từ chối nhanh
                                        InkWell(
                                          onTap: () => _rejectSlot(slot.id),
                                          borderRadius: BorderRadius.circular(100),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEF4444),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, size: 10, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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

class _DoctorSummary {
  final String id;
  final String name;
  final String? avatar;
  int pendingCount;
  int approvedCount;
  int rejectedCount;

  _DoctorSummary({
    required this.id,
    required this.name,
    this.avatar,
    this.pendingCount = 0,
    this.approvedCount = 0,
    this.rejectedCount = 0,
  });
}
