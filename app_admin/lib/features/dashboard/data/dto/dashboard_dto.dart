import 'package:json_annotation/json_annotation.dart';

part 'dashboard_dto.g.dart';

/// DTO cho Dashboard statistics
@JsonSerializable()
class DashboardDto {
  final int totalBookings;
  final int totalDoctors;
  final int totalPatients;
  final int todayBookings;
  final int pendingBookings;
  final int confirmedBookings;
  final int completedBookings;
  final int cancelledBookings;
  final List<TimeSeriesData>? bookingsByDay;
  final List<TimeSeriesData>? bookingsByWeek;
  final List<TimeSeriesData>? bookingsByMonth;
  final List<DoctorStats>? topDoctors;
  final List<ServiceStats>? popularServices;

  DashboardDto({
    this.totalBookings = 0,
    this.totalDoctors = 0,
    this.totalPatients = 0,
    this.todayBookings = 0,
    this.pendingBookings = 0,
    this.confirmedBookings = 0,
    this.completedBookings = 0,
    this.cancelledBookings = 0,
    this.bookingsByDay,
    this.bookingsByWeek,
    this.bookingsByMonth,
    this.topDoctors,
    this.popularServices,
  });

  factory DashboardDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardDtoToJson(this);

  /// Empty dashboard for loading state
  factory DashboardDto.empty() => DashboardDto();
}

@JsonSerializable()
class TimeSeriesData {
  final String label;
  final int count;

  TimeSeriesData({
    required this.label,
    required this.count,
  });

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesDataFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSeriesDataToJson(this);
}

@JsonSerializable()
class DoctorStats {
  final String doctorId;
  final String doctorName;
  final String? specialty;
  final int totalBookings;
  final int completedBookings;
  final double rating;
  final String? avatarUrl;
  final bool? isOnline;

  DoctorStats({
    required this.doctorId,
    required this.doctorName,
    this.specialty,
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.rating = 0.0,
    this.avatarUrl,
    this.isOnline,
  });

  factory DoctorStats.fromJson(Map<String, dynamic> json) =>
      _$DoctorStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DoctorStatsToJson(this);
}

@JsonSerializable()
class ServiceStats {
  final String serviceId;
  final String serviceName;
  final int bookingCount;
  final double percentage;

  ServiceStats({
    required this.serviceId,
    required this.serviceName,
    this.bookingCount = 0,
    this.percentage = 0.0,
  });

  factory ServiceStats.fromJson(Map<String, dynamic> json) =>
      _$ServiceStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceStatsToJson(this);
}
