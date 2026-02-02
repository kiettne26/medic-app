import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/data/dto/dashboard_dto.dart';
import '../../dashboard/data/stats_api.dart';

/// Provider để lưu trữ period hiện tại được chọn
final selectedPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.thisMonth);

/// Provider để lưu custom date range
final customDateRangeProvider = StateProvider<CustomDateRange?>((ref) => null);

/// Model cho date range (tránh xung đột với Flutter's DateTimeRange)
class CustomDateRange {
  final DateTime start;
  final DateTime end;
  
  CustomDateRange({required this.start, required this.end});
}

final statsControllerProvider =
    AsyncNotifierProvider<StatsController, DashboardDto>(() {
      return StatsController();
    });

class StatsController extends AsyncNotifier<DashboardDto> {
  @override
  FutureOr<DashboardDto> build() async {
    // Watch the selected period to auto-refresh when it changes
    final period = ref.watch(selectedPeriodProvider);
    final customRange = ref.watch(customDateRangeProvider);
    return _fetchStats(period: period, customRange: customRange);
  }

  Future<DashboardDto> _fetchStats({
    StatsPeriod period = StatsPeriod.thisMonth,
    CustomDateRange? customRange,
  }) async {
    final api = ref.read(statsApiProvider);
    return api.getStatsByPeriod(
      period: period,
      startDate: customRange?.start,
      endDate: customRange?.end,
    );
  }

  /// Refresh với period hiện tại
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final period = ref.read(selectedPeriodProvider);
    final customRange = ref.read(customDateRangeProvider);
    state = await AsyncValue.guard(() => _fetchStats(
      period: period,
      customRange: customRange,
    ));
  }

  /// Thay đổi period và fetch data mới
  Future<void> changePeriod(StatsPeriod period) async {
    ref.read(selectedPeriodProvider.notifier).state = period;
    // Data sẽ tự động được fetch lại do build() watch selectedPeriodProvider
  }

  /// Set custom date range
  Future<void> setCustomDateRange(DateTime start, DateTime end) async {
    ref.read(customDateRangeProvider.notifier).state = CustomDateRange(
      start: start,
      end: end,
    );
    ref.read(selectedPeriodProvider.notifier).state = StatsPeriod.custom;
  }
}
