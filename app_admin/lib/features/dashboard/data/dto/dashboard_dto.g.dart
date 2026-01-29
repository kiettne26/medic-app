// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardDto _$DashboardDtoFromJson(Map<String, dynamic> json) => DashboardDto(
  totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
  totalDoctors: (json['totalDoctors'] as num?)?.toInt() ?? 0,
  totalPatients: (json['totalPatients'] as num?)?.toInt() ?? 0,
  todayBookings: (json['todayBookings'] as num?)?.toInt() ?? 0,
  pendingBookings: (json['pendingBookings'] as num?)?.toInt() ?? 0,
  confirmedBookings: (json['confirmedBookings'] as num?)?.toInt() ?? 0,
  completedBookings: (json['completedBookings'] as num?)?.toInt() ?? 0,
  cancelledBookings: (json['cancelledBookings'] as num?)?.toInt() ?? 0,
  bookingsByDay: (json['bookingsByDay'] as List<dynamic>?)
      ?.map((e) => TimeSeriesData.fromJson(e as Map<String, dynamic>))
      .toList(),
  bookingsByWeek: (json['bookingsByWeek'] as List<dynamic>?)
      ?.map((e) => TimeSeriesData.fromJson(e as Map<String, dynamic>))
      .toList(),
  bookingsByMonth: (json['bookingsByMonth'] as List<dynamic>?)
      ?.map((e) => TimeSeriesData.fromJson(e as Map<String, dynamic>))
      .toList(),
  topDoctors: (json['topDoctors'] as List<dynamic>?)
      ?.map((e) => DoctorStats.fromJson(e as Map<String, dynamic>))
      .toList(),
  popularServices: (json['popularServices'] as List<dynamic>?)
      ?.map((e) => ServiceStats.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DashboardDtoToJson(DashboardDto instance) =>
    <String, dynamic>{
      'totalBookings': instance.totalBookings,
      'totalDoctors': instance.totalDoctors,
      'totalPatients': instance.totalPatients,
      'todayBookings': instance.todayBookings,
      'pendingBookings': instance.pendingBookings,
      'confirmedBookings': instance.confirmedBookings,
      'completedBookings': instance.completedBookings,
      'cancelledBookings': instance.cancelledBookings,
      'bookingsByDay': instance.bookingsByDay,
      'bookingsByWeek': instance.bookingsByWeek,
      'bookingsByMonth': instance.bookingsByMonth,
      'topDoctors': instance.topDoctors,
      'popularServices': instance.popularServices,
    };

TimeSeriesData _$TimeSeriesDataFromJson(Map<String, dynamic> json) =>
    TimeSeriesData(
      label: json['label'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$TimeSeriesDataToJson(TimeSeriesData instance) =>
    <String, dynamic>{'label': instance.label, 'count': instance.count};

DoctorStats _$DoctorStatsFromJson(Map<String, dynamic> json) => DoctorStats(
  doctorId: json['doctorId'] as String,
  doctorName: json['doctorName'] as String,
  specialty: json['specialty'] as String?,
  totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
  completedBookings: (json['completedBookings'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  avatarUrl: json['avatarUrl'] as String?,
  isOnline: json['isOnline'] as bool?,
);

Map<String, dynamic> _$DoctorStatsToJson(DoctorStats instance) =>
    <String, dynamic>{
      'doctorId': instance.doctorId,
      'doctorName': instance.doctorName,
      'specialty': instance.specialty,
      'totalBookings': instance.totalBookings,
      'completedBookings': instance.completedBookings,
      'rating': instance.rating,
      'avatarUrl': instance.avatarUrl,
      'isOnline': instance.isOnline,
    };

ServiceStats _$ServiceStatsFromJson(Map<String, dynamic> json) => ServiceStats(
  serviceId: json['serviceId'] as String,
  serviceName: json['serviceName'] as String,
  bookingCount: (json['bookingCount'] as num?)?.toInt() ?? 0,
  percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$ServiceStatsToJson(ServiceStats instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'bookingCount': instance.bookingCount,
      'percentage': instance.percentage,
    };
