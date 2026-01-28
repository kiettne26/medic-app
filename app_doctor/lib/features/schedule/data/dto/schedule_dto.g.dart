// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleSlotDto _$ScheduleSlotDtoFromJson(Map<String, dynamic> json) =>
    ScheduleSlotDto(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      slotType: json['slotType'] as String?,
      note: json['note'] as String?,
      bookingId: json['bookingId'] as String?,
      patientName: json['patientName'] as String?,
      patientAvatar: json['patientAvatar'] as String?,
      serviceName: json['serviceName'] as String?,
      bookingStatus: json['bookingStatus'] as String?,
    );

Map<String, dynamic> _$ScheduleSlotDtoToJson(ScheduleSlotDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'date': instance.date.toIso8601String(),
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'isAvailable': instance.isAvailable,
      'slotType': instance.slotType,
      'note': instance.note,
      'bookingId': instance.bookingId,
      'patientName': instance.patientName,
      'patientAvatar': instance.patientAvatar,
      'serviceName': instance.serviceName,
      'bookingStatus': instance.bookingStatus,
    };

CreateScheduleSlotRequest _$CreateScheduleSlotRequestFromJson(
  Map<String, dynamic> json,
) => CreateScheduleSlotRequest(
  date: DateTime.parse(json['date'] as String),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  slotType: json['slotType'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$CreateScheduleSlotRequestToJson(
  CreateScheduleSlotRequest instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'slotType': instance.slotType,
  'note': instance.note,
};
