import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import 'dto/dashboard_dto.dart';

final statsApiProvider = Provider(
  (ref) => StatsApi(ref.watch(apiClientProvider)),
);

/// Enum cho các khoảng thời gian thống kê
enum StatsPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

class StatsApi {
  final ApiClient _client;

  StatsApi(this._client);

  /// Lấy thống kê tổng quan cho dashboard (không filter)
  Future<DashboardDto> getDashboardStats() async {
    final response = await _client.get('/analytics/dashboard');
    return DashboardDto.fromJson(response.data['data']);
  }

  /// Lấy thống kê theo khoảng thời gian
  Future<DashboardDto> getStatsByPeriod({
    required StatsPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    
    DateTime start;
    DateTime end = now;
    
    switch (period) {
      case StatsPeriod.today:
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
        break;
      case StatsPeriod.thisWeek:
        // Lấy ngày đầu tuần (thứ 2)
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        end = now;
        break;
      case StatsPeriod.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = now;
        break;
      case StatsPeriod.thisYear:
        start = DateTime(now.year, 1, 1);
        end = now;
        break;
      case StatsPeriod.custom:
        start = startDate ?? now.subtract(const Duration(days: 30));
        end = endDate ?? now;
        break;
    }

    final response = await _client.get(
      '/analytics/dashboard',
      queryParameters: {
        'startDate': dateFormat.format(start),
        'endDate': dateFormat.format(end),
      },
    );
    return DashboardDto.fromJson(response.data['data']);
  }

  /// Lấy dữ liệu bookings theo khoảng thời gian
  Future<List<TimeSeriesData>> getBookingsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    String groupBy = 'DAY',
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final response = await _client.get(
      '/analytics/bookings/by-period',
      queryParameters: {
        'startDate': dateFormat.format(startDate),
        'endDate': dateFormat.format(endDate),
        'groupBy': groupBy,
      },
    );
    
    final rawData = response.data['data'];
    if (rawData == null) return [];
    return (rawData as List)
        .map((e) => TimeSeriesData.fromJson(e))
        .toList();
  }
}
