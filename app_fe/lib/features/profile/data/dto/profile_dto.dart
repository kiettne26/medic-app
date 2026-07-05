import 'package:json_annotation/json_annotation.dart';

part 'profile_dto.g.dart';

@JsonSerializable()
class ProfileDto {
  final String? id;
  final String? userId;
  final String? fullName;
  final String? email;
  final bool emailVerified;
  final String? phone;
  final String? avatarUrl;
  final String? address;
  final String? gender;
  final String? dob;

  ProfileDto({
    this.id,
    this.userId,
    this.fullName,
    this.email,
    this.emailVerified = false,
    this.phone,
    this.avatarUrl,
    this.address,
    this.gender,
    this.dob,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);
}

@JsonSerializable()
class UpdateProfileRequest {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? address;
  final String? gender;
  final String? dob;

  UpdateProfileRequest({
    this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.address,
    this.gender,
    this.dob,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
class EmailVerificationRequestResult {
  final int expiresInSeconds;

  const EmailVerificationRequestResult({this.expiresInSeconds = 600});

  factory EmailVerificationRequestResult.fromJson(Map<String, dynamic> json) {
    final value = json['expiresInSeconds'];
    return EmailVerificationRequestResult(
      expiresInSeconds: value is int ? value : int.tryParse('$value') ?? 600,
    );
  }
}
