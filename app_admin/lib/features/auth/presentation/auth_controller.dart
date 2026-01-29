import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../data/dto/auth_dto.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? userId;
  final String? role;
  final String? userName;
  final String? userEmail;

  AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.userId,
    this.role,
    this.userName,
    this.userEmail,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userId,
    String? role,
    String? userName,
    String? userEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthApi _authApi;

  AuthController(this._authApi) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authApi.login(request);

      // Kiểm tra role phải là ADMIN
      if (response.role != 'ADMIN') {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Bạn không có quyền truy cập Admin Portal',
        );
        return false;
      }

      // Lưu token và thông tin user
      await TokenStorage.saveAuthData(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.userId,
        role: response.role,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: response.userId,
        role: response.role,
        userName: response.name,
        userEmail: response.email,
      );
      return true;
    } catch (e) {
      String errorMsg = 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';
      if (e.toString().contains('401')) {
        errorMsg = 'Email hoặc mật khẩu không chính xác.';
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Connection')) {
        errorMsg = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMsg,
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {}
    await TokenStorage.clearAll();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> checkAuthStatus() async {
    final token = await TokenStorage.getAccessToken();
    final role = await TokenStorage.getUserRole();

    if (token != null && role == 'ADMIN') {
      final userId = await TokenStorage.getUserId();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
        role: role,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final authApi = ref.watch(authApiProvider);
    return AuthController(authApi);
  },
);
