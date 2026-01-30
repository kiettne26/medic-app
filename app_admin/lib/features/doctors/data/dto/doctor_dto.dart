import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../services/data/dto/medical_service_dto.dart';

part 'doctor_dto.freezed.dart';
part 'doctor_dto.g.dart';

@freezed
class DoctorDto with _$DoctorDto {
  const factory DoctorDto({
    required String id,
    required String userId,
    required String fullName,
    required String specialty,
    required String? description,
    required String? phone,
    required String? avatarUrl,
    required double? rating,
    required int? totalReviews,
    @Default(true) bool isAvailable,
    required double? consultationFee,
    required List<MedicalServiceDto>? services,
  }) = _DoctorDto;

  factory DoctorDto.fromJson(Map<String, dynamic> json) =>
      _$DoctorDtoFromJson(json);
}
