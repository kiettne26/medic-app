import 'package:json_annotation/json_annotation.dart';

part 'doctor_dto.g.dart';

@JsonSerializable()
class DoctorDto {
  final String id;
  final String? userId;
  final String? fullName;
  final String? specialty;
  final String? description;
  final String? phone;
  final String? avatarUrl;
  final double? rating;
  final int? totalReviews;
  final bool? isAvailable;
  final double? consultationFee;
  final List<MedicalServiceDto>? services;

  DoctorDto({
    required this.id,
    this.userId,
    this.fullName,
    this.specialty,
    this.description,
    this.phone,
    this.avatarUrl,
    this.rating,
    this.totalReviews,
    this.isAvailable,
    this.consultationFee,
    this.services,
  });

  factory DoctorDto.fromJson(Map<String, dynamic> json) =>
      _$DoctorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DoctorDtoToJson(this);
}

@JsonSerializable()
class MedicalServiceDto {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final int? durationMinutes;
  final String? category;
  final String? imageUrl;

  MedicalServiceDto({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.durationMinutes,
    this.category,
    this.imageUrl,
  });

  factory MedicalServiceDto.fromJson(Map<String, dynamic> json) =>
      _$MedicalServiceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicalServiceDtoToJson(this);
}
