import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_repository.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final _storage = const FlutterSecureStorage();

  AuthController(this._repository) : super(const AsyncValue.data(null));

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.login(email, password);

      // Save tokens
      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'refresh_token', value: response.refreshToken);
      if (response.user != null) {
        await _storage.write(key: 'user_id', value: response.user!.id);
        await _storage.write(key: 'user_role', value: response.user!.role);
      }

      state = const AsyncValue.data(null);
      return true;
    } on DioException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      if (e.response?.statusCode == 401) {
        throw Exception('Email hoặc mật khẩu không đúng');
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.',
        );
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AsyncValue.data(null);
  }

  Future<bool> checkAuth() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository);
    });
