import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_slot_dto.freezed.dart';
part 'time_slot_dto.g.dart';

@freezed
class TimeSlotDto with _$TimeSlotDto {
  const factory TimeSlotDto({
    required String id,
    required String doctorId,
    String? doctorName,
    String? doctorAvatar,
    required String date,
    required String startTime,
    required String endTime,
    @Default(true) bool isAvailable,
    @Default('PENDING') String status,
  }) = _TimeSlotDto;

  factory TimeSlotDto.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotDtoFromJson(json);
}
