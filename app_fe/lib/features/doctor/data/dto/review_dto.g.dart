// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) => ReviewDto(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String?,
      patientId: json['patientId'] as String?,
      doctorId: json['doctorId'] as String?,
      patientName: json['patientName'] as String?,
      patientAvatar: json['patientAvatar'] as String?,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ReviewDtoToJson(ReviewDto instance) => <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'patientId': instance.patientId,
      'doctorId': instance.doctorId,
      'patientName': instance.patientName,
      'patientAvatar': instance.patientAvatar,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
