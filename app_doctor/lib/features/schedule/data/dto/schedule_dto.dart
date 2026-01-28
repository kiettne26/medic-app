import 'package:json_annotation/json_annotation.dart';

part 'schedule_dto.g.dart';

/// DTO cho một khung giờ làm việc của bác sĩ
@JsonSerializable()
class ScheduleSlotDto {
  final String id;
  final String doctorId;
  final DateTime date;
  final String startTime; // Format "HH:mm" hoặc "HH:mm:ss"
  final String endTime;
  final bool isAvailable;
  final String? slotType; // Ca sáng, Ca chiều, etc.
  final String? note;

  // Booking info if slot is booked
  final String? bookingId;
  final String? patientName;
  final String? patientAvatar;
  final String? serviceName;
  final String? bookingStatus;

  ScheduleSlotDto({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.slotType,
    this.note,
    this.bookingId,
    this.patientName,
    this.patientAvatar,
    this.serviceName,
    this.bookingStatus,
  });

  factory ScheduleSlotDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSlotDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleSlotDtoToJson(this);

  /// Parse startTime thành phút từ đầu ngày (dùng cho vị trí trên lịch)
  int get startMinutes {
    final parts = startTime.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Parse endTime thành phút từ đầu ngày
  int get endMinutes {
    final parts = endTime.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Thời lượng slot tính bằng phút
  int get durationMinutes => endMinutes - startMinutes;
}

/// Request tạo khung giờ mới
@JsonSerializable()
class CreateScheduleSlotRequest {
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? slotType;
  final String? note;

  CreateScheduleSlotRequest({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.slotType,
    this.note,
  });

  factory CreateScheduleSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateScheduleSlotRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateScheduleSlotRequestToJson(this);
}
