// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingDto _$BookingDtoFromJson(Map<String, dynamic> json) => BookingDto(
      id: json['id'] as String,
      patientId: json['patientId'] as String?,
      doctorId: json['doctorId'] as String?,
      serviceId: json['serviceId'] as String?,
      timeSlot: json['timeSlot'] == null
          ? null
          : TimeSlotDto.fromJson(json['timeSlot'] as Map<String, dynamic>),
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      doctorNotes: json['doctorNotes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BookingDtoToJson(BookingDto instance) =>
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
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

TimeSlotDto _$TimeSlotDtoFromJson(Map<String, dynamic> json) => TimeSlotDto(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );

Map<String, dynamic> _$TimeSlotDtoToJson(TimeSlotDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };

CreateBookingRequest _$CreateBookingRequestFromJson(
        Map<String, dynamic> json) =>
    CreateBookingRequest(
      doctorId: json['doctorId'] as String,
      serviceId: json['serviceId'] as String,
      timeSlotId: json['timeSlotId'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateBookingRequestToJson(
        CreateBookingRequest instance) =>
    <String, dynamic>{
      'doctorId': instance.doctorId,
      'serviceId': instance.serviceId,
      'timeSlotId': instance.timeSlotId,
      'notes': instance.notes,
    };
