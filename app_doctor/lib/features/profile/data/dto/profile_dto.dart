class ProfileDto {
  final String id;
  final String userId;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String? address;
  final String? gender;
  final String? dob;
  final String? specialty; // Chuyên khoa (nếu là bác sĩ)

  ProfileDto({
    required this.id,
    required this.userId,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.address,
    this.gender,
    this.dob,
    this.specialty,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
      address: json['address'],
      gender: json['gender'],
      dob: json['dob'],
      specialty: json['specialty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'address': address,
      'gender': gender,
      'dob': dob,
      'specialty': specialty,
    };
  }

  ProfileDto copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? address,
    String? gender,
    String? dob,
    String? specialty,
  }) {
    return ProfileDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      specialty: specialty ?? this.specialty,
    );
  }
}
