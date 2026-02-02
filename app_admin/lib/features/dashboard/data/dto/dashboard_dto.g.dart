// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardDtoImpl _$$DashboardDtoImplFromJson(Map<String, dynamic> json) =>
    _$DashboardDtoImpl(
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      totalDoctors: (json['totalDoctors'] as num?)?.toInt() ?? 0,
      totalPatients: (json['totalPatients'] as num?)?.toInt() ?? 0,
      todayBookings: (json['todayBookings'] as num?)?.toInt() ?? 0,
      pendingBookings: (json['pendingBookings'] as num?)?.toInt() ?? 0,
      confirmedBookings: (json['confirmedBookings'] as num?)?.toInt() ?? 0,
      completedBookings: (json['completedBookings'] as num?)?.toInt() ?? 0,
      cancelledBookings: (json['cancelledBookings'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toInt() ?? 0,
      bookingsByDay:
          (json['bookingsByDay'] as List<dynamic>?)
              ?.map((e) => TimeSeriesData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bookingsByWeek:
          (json['bookingsByWeek'] as List<dynamic>?)
              ?.map((e) => TimeSeriesData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bookingsByMonth:
          (json['bookingsByMonth'] as List<dynamic>?)
              ?.map((e) => TimeSeriesData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      topDoctors:
          (json['topDoctors'] as List<dynamic>?)
              ?.map((e) => DoctorStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      popularServices:
          (json['popularServices'] as List<dynamic>?)
              ?.map((e) => ServiceStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DashboardDtoImplToJson(_$DashboardDtoImpl instance) =>
    <String, dynamic>{
      'totalBookings': instance.totalBookings,
      'totalDoctors': instance.totalDoctors,
      'totalPatients': instance.totalPatients,
      'todayBookings': instance.todayBookings,
      'pendingBookings': instance.pendingBookings,
      'confirmedBookings': instance.confirmedBookings,
      'completedBookings': instance.completedBookings,
      'cancelledBookings': instance.cancelledBookings,
      'totalRevenue': instance.totalRevenue,
      'bookingsByDay': instance.bookingsByDay,
      'bookingsByWeek': instance.bookingsByWeek,
      'bookingsByMonth': instance.bookingsByMonth,
      'topDoctors': instance.topDoctors,
      'popularServices': instance.popularServices,
    };

_$TimeSeriesDataImpl _$$TimeSeriesDataImplFromJson(Map<String, dynamic> json) =>
    _$TimeSeriesDataImpl(
      label: json['label'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$$TimeSeriesDataImplToJson(
  _$TimeSeriesDataImpl instance,
) => <String, dynamic>{'label': instance.label, 'count': instance.count};

_$DoctorStatsImpl _$$DoctorStatsImplFromJson(Map<String, dynamic> json) =>
    _$DoctorStatsImpl(
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      specialty: json['specialty'] as String,
      totalBookings: (json['totalBookings'] as num).toInt(),
      completedBookings: (json['completedBookings'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
    );

Map<String, dynamic> _$$DoctorStatsImplToJson(_$DoctorStatsImpl instance) =>
    <String, dynamic>{
      'doctorId': instance.doctorId,
      'doctorName': instance.doctorName,
      'specialty': instance.specialty,
      'totalBookings': instance.totalBookings,
      'completedBookings': instance.completedBookings,
      'rating': instance.rating,
    };

_$ServiceStatsImpl _$$ServiceStatsImplFromJson(Map<String, dynamic> json) =>
    _$ServiceStatsImpl(
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      bookingCount: (json['bookingCount'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$$ServiceStatsImplToJson(_$ServiceStatsImpl instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'bookingCount': instance.bookingCount,
      'percentage': instance.percentage,
    };
