import 'package:json_annotation/json_annotation.dart';

part 'profile_dto.g.dart';

@JsonSerializable()
class ProfileDto {
  final String? id;
  final String? userId;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? address;
  final String? gender;
  final String? dob;

  ProfileDto({
    this.id,
    this.userId,
    this.fullName,
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
  final String? phone;
  final String? avatarUrl;
  final String? address;
  final String? gender;
  final String? dob;

  UpdateProfileRequest({
    this.fullName,
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
