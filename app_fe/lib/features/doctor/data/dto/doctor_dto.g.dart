// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorDto _$DoctorDtoFromJson(Map<String, dynamic> json) => DoctorDto(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      fullName: json['fullName'] as String?,
      specialty: json['specialty'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalReviews: (json['totalReviews'] as num?)?.toInt(),
      isAvailable: json['isAvailable'] as bool?,
      consultationFee: (json['consultationFee'] as num?)?.toDouble(),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => MedicalServiceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DoctorDtoToJson(DoctorDto instance) => <String, dynamic>{
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

MedicalServiceDto _$MedicalServiceDtoFromJson(Map<String, dynamic> json) =>
    MedicalServiceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$MedicalServiceDtoToJson(MedicalServiceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'durationMinutes': instance.durationMinutes,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
    };
