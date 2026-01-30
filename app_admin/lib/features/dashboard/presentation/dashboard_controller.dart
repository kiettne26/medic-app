import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/data/dto/dashboard_dto.dart';
import '../../dashboard/data/stats_api.dart';

final statsControllerProvider =
    AsyncNotifierProvider<StatsController, DashboardDto>(() {
      return StatsController();
    });

class StatsController extends AsyncNotifier<DashboardDto> {
  @override
  FutureOr<DashboardDto> build() async {
    return _fetchStats();
  }

  Future<DashboardDto> _fetchStats() async {
    final api = ref.read(statsApiProvider);
    return api.getDashboardStats();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}
