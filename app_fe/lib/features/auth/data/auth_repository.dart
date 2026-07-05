import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'source/auth_api.dart';
import 'dto/auth_dto.dart';

class AuthRepository {
  final AuthApi _authApi;

  AuthRepository(this._authApi);

  Future<AuthResponse> login(String email, String password) async {
    return await _authApi.login(LoginRequest(email: email, password: password));
  }

  Future<AuthResponse> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    return await _authApi.register({
      'fullName': name,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  Future<AuthResponse> socialLogin(
    String email,
    String name,
    String avatar,
    String provider,
    String token,
  ) async {
    return await _authApi.socialLogin({
      'email': email,
      'name': name,
      'avatar': avatar,
      'provider': provider,
      'token': token,
    });
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _authApi.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = ref.watch(authApiProvider);
  return AuthRepository(authApi);
});
