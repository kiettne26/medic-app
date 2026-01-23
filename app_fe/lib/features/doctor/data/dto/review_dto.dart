import 'package:json_annotation/json_annotation.dart';

part 'review_dto.g.dart';

@JsonSerializable()
class ReviewDto {
  final String id;
  final String? bookingId;
  final String? patientId;
  final String? doctorId;
  final String? patientName;
  final String? patientAvatar;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  ReviewDto({
    required this.id,
    this.bookingId,
    this.patientId,
    this.doctorId,
    this.patientName,
    this.patientAvatar,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDtoToJson(this);

  String get timeAgo {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else {
      return 'Vừa xong';
    }
  }
}
