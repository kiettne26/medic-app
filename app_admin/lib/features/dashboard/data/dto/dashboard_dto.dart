import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_dto.freezed.dart';
part 'dashboard_dto.g.dart';

@freezed
class DashboardDto with _$DashboardDto {
  const factory DashboardDto({
    @Default(0) int totalBookings,
    @Default(0) int totalDoctors,
    @Default(0) int totalPatients,
    @Default(0) int todayBookings,
    @Default(0) int pendingBookings,
    @Default(0) int confirmedBookings,
    @Default(0) int completedBookings,
    @Default(0) int cancelledBookings,
    @Default([]) List<TimeSeriesData> bookingsByDay,
    @Default([]) List<TimeSeriesData> bookingsByWeek,
    @Default([]) List<TimeSeriesData> bookingsByMonth,
    @Default([]) List<DoctorStats> topDoctors,
    @Default([]) List<ServiceStats> popularServices,
  }) = _DashboardDto;

  factory DashboardDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardDtoFromJson(json);
}

@freezed
class TimeSeriesData with _$TimeSeriesData {
  const factory TimeSeriesData({required String label, required int count}) =
      _TimeSeriesData;

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesDataFromJson(json);
}

@freezed
class DoctorStats with _$DoctorStats {
  const factory DoctorStats({
    required String doctorId,
    required String doctorName,
    required String specialty,
    required int totalBookings,
    required int completedBookings,
    required double rating,
  }) = _DoctorStats;

  factory DoctorStats.fromJson(Map<String, dynamic> json) =>
      _$DoctorStatsFromJson(json);
}

@freezed
class ServiceStats with _$ServiceStats {
  const factory ServiceStats({
    required String serviceId,
    required String serviceName,
    required int bookingCount,
    required double percentage,
  }) = _ServiceStats;

  factory ServiceStats.fromJson(Map<String, dynamic> json) =>
      _$ServiceStatsFromJson(json);
}
