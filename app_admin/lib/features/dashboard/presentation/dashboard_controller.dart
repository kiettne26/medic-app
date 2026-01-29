import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../data/dto/dashboard_dto.dart';

/// State cho Dashboard
class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final DashboardDto? data;
  final DateTime? lastUpdated;

  DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    DashboardDto? data,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Controller cho Dashboard
class DashboardController extends StateNotifier<DashboardState> {
  final ApiClient _apiClient;

  DashboardController(this._apiClient) : super(DashboardState());

  /// Load dashboard data
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiClient.get('/analytics/dashboard');
      final data = response.data['data'];
      final dashboard = DashboardDto.fromJson(data);

      state = state.copyWith(
        isLoading: false,
        data: dashboard,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải dữ liệu dashboard. Vui lòng thử lại.',
      );
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboard();
  }
}

/// Provider cho DashboardController
final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardController(apiClient);
});
