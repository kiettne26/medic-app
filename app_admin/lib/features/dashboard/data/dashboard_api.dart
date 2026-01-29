import 'package:dio/dio.dart';
import 'dto/dashboard_dto.dart';

/// API service cho Dashboard
class DashboardApi {
  final Dio _dio;

  DashboardApi(this._dio);

  /// Lấy thống kê tổng quan cho dashboard
  Future<DashboardDto> getDashboard() async {
    try {
      final response = await _dio.get('/analytics/dashboard');
      final data = response.data['data'];
      return DashboardDto.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Thống kê booking theo khoảng thời gian
  Future<List<TimeSeriesData>> getBookingsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    String groupBy = 'DAY',
  }) async {
    try {
      final response = await _dio.get(
        '/analytics/bookings/by-period',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          'groupBy': groupBy,
        },
      );
      final data = response.data['data'] as List;
      return data.map((e) => TimeSeriesData.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Xếp hạng bác sĩ
  Future<List<DoctorStats>> getDoctorRankings({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/analytics/doctors/rankings',
        queryParameters: {'limit': limit},
      );
      final data = response.data['data'] as List;
      return data.map((e) => DoctorStats.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
