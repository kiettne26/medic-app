import 'package:json_annotation/json_annotation.dart';

part 'schedule_dto.g.dart';

/// Trạng thái phê duyệt slot
enum SlotStatus { PENDING, APPROVED, REJECTED }

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
  final SlotStatus status; // Trạng thái phê duyệt

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
    this.status = SlotStatus.PENDING,
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

  /// Helper để lấy tên trạng thái tiếng Việt
  String get statusText {
    switch (status) {
      case SlotStatus.PENDING:
        return 'Chờ duyệt';
      case SlotStatus.APPROVED:
        return 'Đã duyệt';
      case SlotStatus.REJECTED:
        return 'Từ chối';
    }
  }
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
