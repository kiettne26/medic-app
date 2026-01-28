import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'schedule_api.dart';
import 'dto/schedule_dto.dart';

/// Repository cho schedule
class ScheduleRepository {
  final ScheduleApi _api;

  ScheduleRepository(this._api);

  Future<List<ScheduleSlotDto>> getTimeSlots({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _api.getTimeSlots(startDate: startDate, endDate: endDate);
  }

  Future<ScheduleSlotDto> createTimeSlot(CreateScheduleSlotRequest request) {
    return _api.createTimeSlot(request);
  }

  Future<void> deleteTimeSlot(String slotId) {
    return _api.deleteTimeSlot(slotId);
  }
}

/// Provider cho ScheduleRepository
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final api = ref.watch(scheduleApiProvider);
  return ScheduleRepository(api);
});
