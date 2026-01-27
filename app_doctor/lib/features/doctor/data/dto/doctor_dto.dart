class DoctorDto {
  final String id;
  final String userId;
  final String fullName;
  final String? specialty;
  final String? description;
  final String? phone;
  final String? avatarUrl;
  final double? rating;
  final int? totalReviews;
  final bool? isAvailable;
  final double? consultationFee;

  DoctorDto({
    required this.id,
    required this.userId,
    required this.fullName,
    this.specialty,
    this.description,
    this.phone,
    this.avatarUrl,
    this.rating,
    this.totalReviews,
    this.isAvailable,
    this.consultationFee,
  });

  factory DoctorDto.fromJson(Map<String, dynamic> json) {
    return DoctorDto(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      specialty: json['specialty'],
      description: json['description'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
      rating: json['rating']?.toDouble(),
      totalReviews: json['totalReviews'],
      isAvailable: json['isAvailable'],
      consultationFee: json['consultationFee']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'specialty': specialty,
      'description': description,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'isAvailable': isAvailable,
      'consultationFee': consultationFee,
    };
  }

  DoctorDto copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? specialty,
    String? description,
    String? phone,
    String? avatarUrl,
    double? rating,
    int? totalReviews,
    bool? isAvailable,
    double? consultationFee,
  }) {
    return DoctorDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isAvailable: isAvailable ?? this.isAvailable,
      consultationFee: consultationFee ?? this.consultationFee,
    );
  }
}
