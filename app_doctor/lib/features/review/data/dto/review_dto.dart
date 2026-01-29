/// DTO cho Review
class ReviewDto {
  final String id;
  final String? bookingId;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String? patientAvatar;
  final int rating;
  final String? comment;
  final String? doctorReply;
  final DateTime? doctorReplyAt;
  final DateTime createdAt;

  ReviewDto({
    required this.id,
    this.bookingId,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    this.patientAvatar,
    required this.rating,
    this.comment,
    this.doctorReply,
    this.doctorReplyAt,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: json['id'],
      bookingId: json['bookingId'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      patientName: json['patientName'] ?? 'Bệnh nhân',
      patientAvatar: json['patientAvatar'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      doctorReply: json['doctorReply'],
      doctorReplyAt: json['doctorReplyAt'] != null
          ? DateTime.parse(json['doctorReplyAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Lấy initials (2 ký tự đầu) từ tên
  String get initials {
    final parts = patientName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    }
    return patientName
        .substring(0, patientName.length.clamp(0, 2))
        .toUpperCase();
  }

  /// Check if needs doctor attention (rating < 4 and no reply)
  bool get needsAttention => rating < 4 && doctorReply == null;
}

/// DTO cho Review Statistics
class ReviewStatsDto {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final double monthlyGrowth;

  ReviewStatsDto({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.monthlyGrowth,
  });

  factory ReviewStatsDto.fromJson(Map<String, dynamic> json) {
    final distribution = <int, int>{};
    if (json['ratingDistribution'] != null) {
      (json['ratingDistribution'] as Map<String, dynamic>).forEach((
        key,
        value,
      ) {
        distribution[int.parse(key)] = value as int;
      });
    }

    return ReviewStatsDto(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ratingDistribution: distribution,
      monthlyGrowth: (json['monthlyGrowth'] ?? 0).toDouble(),
    );
  }

  factory ReviewStatsDto.empty() {
    return ReviewStatsDto(
      averageRating: 0,
      totalReviews: 0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      monthlyGrowth: 0,
    );
  }
}
