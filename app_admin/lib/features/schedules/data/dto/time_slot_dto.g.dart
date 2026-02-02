// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_slot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeSlotDtoImpl _$$TimeSlotDtoImplFromJson(Map<String, dynamic> json) =>
    _$TimeSlotDtoImpl(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String?,
      doctorAvatar: json['doctorAvatar'] as String?,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      status: json['status'] as String? ?? 'PENDING',
    );

Map<String, dynamic> _$$TimeSlotDtoImplToJson(_$TimeSlotDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'doctorName': instance.doctorName,
      'doctorAvatar': instance.doctorAvatar,
      'date': instance.date,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'isAvailable': instance.isAvailable,
      'status': instance.status,
    };
