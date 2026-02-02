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

/// DTO cho thống kê lịch hẹn
@freezed
class BookingStatsDto with _$BookingStatsDto {
  const factory BookingStatsDto({
    @Default(0) int totalToday,
    @Default(0) int pendingCount,
    @Default(0) int confirmedCount,
    @Default(0) int completedCount,
    @Default(0) int canceledCount,
    @Default(0.0) double todayChangePercent,
    @Default(0.0) double pendingChangePercent,
    @Default(0.0) double completedChangePercent,
  }) = _BookingStatsDto;

  factory BookingStatsDto.fromJson(Map<String, dynamic> json) =>
      _$BookingStatsDtoFromJson(json);
}

/// DTO cho danh sách booking với phân trang
@freezed
class BookingPageDto with _$BookingPageDto {
  const factory BookingPageDto({
    required List<BookingDto> content,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
    @Default(0) int currentPage,
    @Default(10) int pageSize,
  }) = _BookingPageDto;

  factory BookingPageDto.fromJson(Map<String, dynamic> json) =>
      _$BookingPageDtoFromJson(json);
}
