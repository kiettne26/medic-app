import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final UserInfo? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.user,
  });

  // Helper getters để lấy thông tin từ user
  String get userId => user?.id ?? '';
  String get role => user?.role ?? '';
  String? get name => user?.fullName;
  String? get email => user?.email;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class UserInfo {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;

  UserInfo({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    required this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}
