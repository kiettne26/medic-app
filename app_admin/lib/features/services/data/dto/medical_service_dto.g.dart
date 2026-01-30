// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_service_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicalServiceDtoImpl _$$MedicalServiceDtoImplFromJson(
  Map<String, dynamic> json,
) => _$MedicalServiceDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  category: json['category'] as String,
  isActive: json['isActive'] as bool? ?? true,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$$MedicalServiceDtoImplToJson(
  _$MedicalServiceDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'durationMinutes': instance.durationMinutes,
  'category': instance.category,
  'isActive': instance.isActive,
  'imageUrl': instance.imageUrl,
};
