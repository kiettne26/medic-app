// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DoctorDtoImpl _$$DoctorDtoImplFromJson(Map<String, dynamic> json) =>
    _$DoctorDtoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      specialty: json['specialty'] as String,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalReviews: (json['totalReviews'] as num?)?.toInt(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      consultationFee: (json['consultationFee'] as num?)?.toDouble(),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => MedicalServiceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DoctorDtoImplToJson(_$DoctorDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'specialty': instance.specialty,
      'description': instance.description,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'rating': instance.rating,
      'totalReviews': instance.totalReviews,
      'isAvailable': instance.isAvailable,
      'consultationFee': instance.consultationFee,
      'services': instance.services,
    };
