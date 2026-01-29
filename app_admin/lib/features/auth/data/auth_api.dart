import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import 'dto/auth_dto.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _client.post('/auth/login', data: request.toJson());
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApi(client);
});
