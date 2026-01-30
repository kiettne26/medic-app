import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import 'dto/dashboard_dto.dart';

final statsApiProvider = Provider(
  (ref) => StatsApi(ref.watch(apiClientProvider)),
);

class StatsApi {
  final ApiClient _client;

  StatsApi(this._client);

  Future<DashboardDto> getDashboardStats() async {
    final response = await _client.get('/analytics/dashboard');
    return DashboardDto.fromJson(response.data['data']);
  }

  // Future methods for revenue charts once backend is ready
}
