import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_dto.freezed.dart';
part 'patient_dto.g.dart';

@freezed
class PatientDto with _$PatientDto {
  const factory PatientDto({
    required String id,
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? address,
    String? gender,
    String? dob,
  }) = _PatientDto;

  factory PatientDto.fromJson(Map<String, dynamic> json) =>
      _$PatientDtoFromJson(json);
}
