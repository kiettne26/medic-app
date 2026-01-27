import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_doctor/core/network/dio_provider.dart';
import '../dto/auth_dto.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(Map<String, dynamic> body) async {
    try {
      await _dio.post('/api/auth/register', data: body);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> socialLogin(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post('/api/auth/social-login', data: body);
      return AuthResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});
