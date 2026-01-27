import 'package:json_annotation/json_annotation.dart';

part 'booking_dto.g.dart';

@JsonSerializable()
class BookingDto {
  final String id;
  final String? patientId;
  final String? doctorId;
  final String? serviceId;
  final TimeSlotDto? timeSlot;
  final String? status;
  final String? notes;
  final String? doctorNotes;
  final String? cancellationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? patientName; // Added for convenience if backend sends it
  final String? serviceName; // Added for convenience

  BookingDto({
    required this.id,
    this.patientId,
    this.doctorId,
    this.serviceId,
    this.timeSlot,
    this.status,
    this.notes,
    this.doctorNotes,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
    this.patientName,
    this.serviceName,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) =>
      _$BookingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingDtoToJson(this);
}

@JsonSerializable()
class TimeSlotDto {
  final String id;
  final DateTime date;
  final String startTime; // LocalTime format "HH:mm:ss"
  final String endTime; // LocalTime format "HH:mm:ss"

  TimeSlotDto({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlotDto.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotDtoToJson(this);
}
