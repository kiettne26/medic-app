import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_dto.freezed.dart';
part 'booking_dto.g.dart';

@freezed
class BookingDto with _$BookingDto {
  const factory BookingDto({
    required String id,
    required String patientId,
    required String doctorId,
    required String serviceId,
    required TimeSlotDto timeSlot,
    required String status, // BookingStatus enum as String
    required String? notes,
    required String? doctorNotes,
    required String? cancellationReason,
    required String? patientName,
    required String? patientAvatar,
    required String? doctorName,
    required String? doctorAvatar,
    required String? serviceName,
    required DateTime? createdAt,
    required DateTime? updatedAt,
  }) = _BookingDto;

  factory BookingDto.fromJson(Map<String, dynamic> json) =>
      _$BookingDtoFromJson(json);
}

@freezed
class TimeSlotDto with _$TimeSlotDto {
  const factory TimeSlotDto({
    required String id,
    required String date, // LocalDate as String
    required String startTime, // LocalTime as String
    required String endTime, // LocalTime as String
  }) = _TimeSlotDto;

  factory TimeSlotDto.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotDtoFromJson(json);
}
