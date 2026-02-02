import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/time_slot_dto.dart';
import '../data/time_slots_api.dart';

/// Filter state for schedules
class ScheduleFilter {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const ScheduleFilter({
    this.status,
    this.startDate,
    this.endDate,
  });

  ScheduleFilter copyWith({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStatus = false,
    bool clearDates = false,
  }) {
    return ScheduleFilter(
      status: clearStatus ? null : (status ?? this.status),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }
}

/// Provider for current filter
final scheduleFilterProvider = StateProvider<ScheduleFilter>((ref) {
  // Default to current week
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  
  return ScheduleFilter(
    startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
    endDate: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
  );
});

final timeSlotsControllerProvider =
    AsyncNotifierProvider<TimeSlotsController, List<TimeSlotDto>>(() {
      return TimeSlotsController();
    });

class TimeSlotsController extends AsyncNotifier<List<TimeSlotDto>> {

  @override
  FutureOr<List<TimeSlotDto>> build() async {
    final filter = ref.watch(scheduleFilterProvider);
    return _fetchSlots(filter);
  }

  Future<List<TimeSlotDto>> _fetchSlots(ScheduleFilter filter) async {
    final api = ref.read(timeSlotsApiProvider);
    return api.getAllSlots(
      status: filter.status,
      startDate: filter.startDate,
      endDate: filter.endDate,
    );
  }

  Future<void> refresh({String? status}) async {
    final currentFilter = ref.read(scheduleFilterProvider);
    final newFilter = status != null 
        ? currentFilter.copyWith(status: status, clearStatus: status.isEmpty)
        : currentFilter;
    
    if (status != null) {
      ref.read(scheduleFilterProvider.notifier).state = newFilter;
    }
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSlots(newFilter));
  }

  Future<void> setDateRange(DateTime startDate, DateTime endDate) async {
    final currentFilter = ref.read(scheduleFilterProvider);
    final newFilter = currentFilter.copyWith(
      startDate: startDate,
      endDate: endDate,
    );
    ref.read(scheduleFilterProvider.notifier).state = newFilter;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSlots(newFilter));
  }

  Future<void> clearDateFilter() async {
    final currentFilter = ref.read(scheduleFilterProvider);
    final newFilter = currentFilter.copyWith(clearDates: true);
    ref.read(scheduleFilterProvider.notifier).state = newFilter;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSlots(newFilter));
  }

  Future<void> approveSlot(String slotId) async {
    final api = ref.read(timeSlotsApiProvider);
    final filter = ref.read(scheduleFilterProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.approveSlot(slotId);
      return _fetchSlots(filter);
    });
  }

  Future<void> rejectSlot(String slotId) async {
    final api = ref.read(timeSlotsApiProvider);
    final filter = ref.read(scheduleFilterProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.rejectSlot(slotId);
      return _fetchSlots(filter);
    });
  }

  Future<void> approveBulkSlots(List<String> slotIds) async {
    final api = ref.read(timeSlotsApiProvider);
    final filter = ref.read(scheduleFilterProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.approveBulkSlots(slotIds);
      return _fetchSlots(filter);
    });
  }

  Future<void> rejectBulkSlots(List<String> slotIds) async {
    final api = ref.read(timeSlotsApiProvider);
    final filter = ref.read(scheduleFilterProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.rejectBulkSlots(slotIds);
      return _fetchSlots(filter);
    });
  }
}
