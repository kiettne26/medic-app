import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/schedule_repository.dart';
import '../data/dto/schedule_dto.dart';

/// State cho màn hình lịch làm việc
class ScheduleState {
  final List<ScheduleSlotDto> slots;
  final DateTime weekStart; // Ngày đầu tuần đang xem
  final bool isLoading;
  final String? error;
  final String viewMode; // 'week', 'day', 'month'

  const ScheduleState({
    this.slots = const [],
    required this.weekStart,
    this.isLoading = false,
    this.error,
    this.viewMode = 'week',
  });

  ScheduleState copyWith({
    List<ScheduleSlotDto>? slots,
    DateTime? weekStart,
    bool? isLoading,
    String? error,
    String? viewMode,
    bool clearError = false,
  }) {
    return ScheduleState(
      slots: slots ?? this.slots,
      weekStart: weekStart ?? this.weekStart,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      viewMode: viewMode ?? this.viewMode,
    );
  }

  /// Lấy ngày cuối tuần
  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  /// Lấy danh sách 7 ngày trong tuần
  List<DateTime> get weekDays {
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  /// Lọc slots theo ngày
  List<ScheduleSlotDto> slotsForDay(DateTime day) {
    return slots.where((s) {
      return s.date.year == day.year &&
          s.date.month == day.month &&
          s.date.day == day.day;
    }).toList();
  }
}

/// Controller cho schedule
class ScheduleController extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleController(this._repository)
    : super(ScheduleState(weekStart: _getWeekStart(DateTime.now()))) {
    loadSchedule();
  }

  /// Lấy ngày đầu tuần (Thứ 2)
  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Load lịch làm việc
  Future<void> loadSchedule() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final slots = await _repository.getTimeSlots(
        startDate: state.weekStart,
        endDate: state.weekEnd,
      );
      state = state.copyWith(slots: slots, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Chuyển sang tuần trước
  void previousWeek() {
    state = state.copyWith(
      weekStart: state.weekStart.subtract(const Duration(days: 7)),
    );
    loadSchedule();
  }

  /// Chuyển sang tuần sau
  void nextWeek() {
    state = state.copyWith(
      weekStart: state.weekStart.add(const Duration(days: 7)),
    );
    loadSchedule();
  }

  /// Chuyển về tuần hiện tại
  void goToToday() {
    state = state.copyWith(weekStart: _getWeekStart(DateTime.now()));
    loadSchedule();
  }

  /// Đổi chế độ xem
  void setViewMode(String mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Tạo khung giờ mới
  Future<bool> createSlot(CreateScheduleSlotRequest request) async {
    try {
      await _repository.createTimeSlot(request);
      await loadSchedule();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Xóa khung giờ
  Future<bool> deleteSlot(String slotId) async {
    try {
      await _repository.deleteTimeSlot(slotId);
      await loadSchedule();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Provider cho ScheduleController
final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
      final repository = ref.watch(scheduleRepositoryProvider);
      return ScheduleController(repository);
    });
