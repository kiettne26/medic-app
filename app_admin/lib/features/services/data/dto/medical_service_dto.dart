import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_service_dto.freezed.dart';
part 'medical_service_dto.g.dart';

@freezed
class MedicalServiceDto with _$MedicalServiceDto {
  const factory MedicalServiceDto({
    required String id,
    required String name,
    required String? description,
    required double price,
    required int durationMinutes,
    required String category,
    @Default(true) bool isActive,
    required String? imageUrl,
  }) = _MedicalServiceDto;

  factory MedicalServiceDto.fromJson(Map<String, dynamic> json) =>
      _$MedicalServiceDtoFromJson(json);
}
