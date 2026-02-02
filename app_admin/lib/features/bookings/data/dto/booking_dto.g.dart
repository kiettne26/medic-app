// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingDtoImpl _$$BookingDtoImplFromJson(Map<String, dynamic> json) =>
    _$BookingDtoImpl(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      serviceId: json['serviceId'] as String,
      timeSlot: TimeSlotDto.fromJson(json['timeSlot'] as Map<String, dynamic>),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      doctorNotes: json['doctorNotes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      patientName: json['patientName'] as String?,
      patientAvatar: json['patientAvatar'] as String?,
      doctorName: json['doctorName'] as String?,
      doctorAvatar: json['doctorAvatar'] as String?,
      serviceName: json['serviceName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BookingDtoImplToJson(_$BookingDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'doctorId': instance.doctorId,
      'serviceId': instance.serviceId,
      'timeSlot': instance.timeSlot,
      'status': instance.status,
      'notes': instance.notes,
      'doctorNotes': instance.doctorNotes,
      'cancellationReason': instance.cancellationReason,
      'patientName': instance.patientName,
      'patientAvatar': instance.patientAvatar,
      'doctorName': instance.doctorName,
      'doctorAvatar': instance.doctorAvatar,
      'serviceName': instance.serviceName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$TimeSlotDtoImpl _$$TimeSlotDtoImplFromJson(Map<String, dynamic> json) =>
    _$TimeSlotDtoImpl(
      id: json['id'] as String,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );

Map<String, dynamic> _$$TimeSlotDtoImplToJson(_$TimeSlotDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };

_$BookingStatsDtoImpl _$$BookingStatsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$BookingStatsDtoImpl(
  totalToday: (json['totalToday'] as num?)?.toInt() ?? 0,
  pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
  confirmedCount: (json['confirmedCount'] as num?)?.toInt() ?? 0,
  completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
  canceledCount: (json['canceledCount'] as num?)?.toInt() ?? 0,
  todayChangePercent: (json['todayChangePercent'] as num?)?.toDouble() ?? 0.0,
  pendingChangePercent:
      (json['pendingChangePercent'] as num?)?.toDouble() ?? 0.0,
  completedChangePercent:
      (json['completedChangePercent'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$BookingStatsDtoImplToJson(
  _$BookingStatsDtoImpl instance,
) => <String, dynamic>{
  'totalToday': instance.totalToday,
  'pendingCount': instance.pendingCount,
  'confirmedCount': instance.confirmedCount,
  'completedCount': instance.completedCount,
  'canceledCount': instance.canceledCount,
  'todayChangePercent': instance.todayChangePercent,
  'pendingChangePercent': instance.pendingChangePercent,
  'completedChangePercent': instance.completedChangePercent,
};

_$BookingPageDtoImpl _$$BookingPageDtoImplFromJson(Map<String, dynamic> json) =>
    _$BookingPageDtoImpl(
      content: (json['content'] as List<dynamic>)
          .map((e) => BookingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$$BookingPageDtoImplToJson(
  _$BookingPageDtoImpl instance,
) => <String, dynamic>{
  'content': instance.content,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'pageSize': instance.pageSize,
};
