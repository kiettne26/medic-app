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
  // Thông tin hiển thị (từ Backend)
  final String? doctorName;
  final String? doctorAvatarUrl;
  final String? serviceName;
  final String? patientName;
  final String? patientAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.doctorName,
    this.doctorAvatarUrl,
    this.serviceName,
    this.patientName,
    this.patientAvatar,
    this.createdAt,
    this.updatedAt,
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

@JsonSerializable()
class CreateBookingRequest {
  final String doctorId;
  final String serviceId;
  final String timeSlotId;
  final String? notes;

  CreateBookingRequest({
    required this.doctorId,
    required this.serviceId,
    required this.timeSlotId,
    this.notes,
  });

  Map<String, dynamic> toJson() => _$CreateBookingRequestToJson(this);
}
