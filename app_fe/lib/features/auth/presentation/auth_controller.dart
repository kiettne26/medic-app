import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/dto/auth_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as facebook;
import '../../profile/data/source/profile_api.dart';
import '../../profile/data/dto/profile_dto.dart';

// State definition (Loading, Success, Error)
enum AuthState { initial, loading, success, error, registerSuccess }

class AuthStateData {
  final AuthState status;
  final String? errorMessage;
  final AuthResponse? authResponse;

  AuthStateData({
    this.status = AuthState.initial,
    this.errorMessage,
    this.authResponse,
  });

  AuthStateData copyWith({
    AuthState? status,
    String? errorMessage,
    AuthResponse? authResponse,
  }) {
    return AuthStateData(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      authResponse: authResponse ?? this.authResponse,
    );
  }
}

class AuthController extends StateNotifier<AuthStateData> {
  final AuthRepository _repository;
  final ProfileApi _profileApi;
  final FlutterSecureStorage _storage;

  AuthController(this._repository, this._profileApi)
    : _storage = const FlutterSecureStorage(),
      super(AuthStateData());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthState.loading, errorMessage: null);
    try {
      final response = await _repository.login(email, password);

      // Save tokens
      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'refresh_token', value: response.refreshToken);

      // Save user info
      if (response.user != null) {
        await _storage.write(key: 'user_id', value: response.user!.id);
        await _storage.write(key: 'user_email', value: response.user!.email);
        await _storage.write(
          key: 'user_name',
          value: response.user!.fullName ?? 'User',
        );
        await _storage.write(
          key: 'user_avatar',
          value: response.user!.avatarUrl ?? '',
        );
      }

      state = state.copyWith(status: AuthState.success, authResponse: response);
    } catch (e) {
      state = state.copyWith(
        status: AuthState.error,
        errorMessage: e.toString(), // Simplify error handling for now
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String address,
    required String gender,
    required String dob,
  }) async {
    state = state.copyWith(status: AuthState.loading, errorMessage: null);
    try {
      // 1. Đăng ký tài khoản và nhận AuthResponse
      final response = await _repository.register(name, email, phone, password);

      // 2. Lưu token để tự động đăng nhập
      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'refresh_token', value: response.refreshToken);

      if (response.user != null) {
        final userId = response.user!.id;
        await _storage.write(key: 'user_id', value: userId);
        await _storage.write(key: 'user_email', value: response.user!.email);
        await _storage.write(
          key: 'user_name',
          value: response.user!.fullName ?? name,
        );
        await _storage.write(
          key: 'user_avatar',
          value: response.user!.avatarUrl ?? '',
        );

        // 3. Gọi API cập nhật profile bổ sung (Địa chỉ, Ngày sinh, Giới tính)
        await _profileApi.updateProfile(
          userId,
          UpdateProfileRequest(
            fullName: name,
            phone: phone,
            address: address,
            gender: gender,
            dob: dob,
          ),
        );
      }

      state = state.copyWith(status: AuthState.success, authResponse: response);
    } catch (e) {
      state = state.copyWith(
        status: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> socialLogin(String provider) async {
    state = state.copyWith(status: AuthState.loading, errorMessage: null);
    print('[SocialLogin] Starting $provider login...');
    try {
      String? email;
      String? name;
      String? avatar;
      String? token;

      if (provider == 'google') {
        print('[SocialLogin] Initializing GoogleSignIn...');
        final google.GoogleSignIn googleSignIn = google.GoogleSignIn(
          scopes: ['email'],
          clientId:
              '1035135642767-bp8s63atsnmc74si6oimi29eqtjjdpej.apps.googleusercontent.com',
          serverClientId:
              '1035135642767-bp8s63atsnmc74si6oimi29eqtjjdpej.apps.googleusercontent.com',
        );

        // Sign out first to force account picker to show
        await googleSignIn.signOut();

        print('[SocialLogin] Calling signIn()...');
        final google.GoogleSignInAccount? googleUser = await googleSignIn
            .signIn();

        if (googleUser == null) {
          print('[SocialLogin] User cancelled Google Sign-In');
          state = state.copyWith(status: AuthState.initial);
          return;
        }
        print('[SocialLogin] Google user: ${googleUser.email}');

        print('[SocialLogin] Getting authentication tokens...');
        final google.GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        print(
          '[SocialLogin] Got idToken: ${googleAuth.idToken != null ? "YES" : "NO"}',
        );

        email = googleUser.email;
        name = googleUser.displayName;
        avatar = googleUser.photoUrl;
        token = googleAuth.idToken ?? googleAuth.accessToken ?? googleUser.id;
      } else if (provider == 'facebook') {
        print('[SocialLogin] Initializing Facebook Login...');
        final facebook.LoginResult result = await facebook.FacebookAuth.instance
            .login(permissions: const ['email', 'public_profile']);

        if (result.status == facebook.LoginStatus.success) {
          final facebook.AccessToken accessToken = result.accessToken!;
          token = accessToken.tokenString;
          print(
            '[SocialLogin] Got Facebook token: ${token != null ? "YES" : "NO"}',
          );

          final userData = await facebook.FacebookAuth.instance.getUserData(
            fields: 'id,name,email,picture.width(200).height(200)',
          );
          email = userData['email'] as String?;
          name = userData['name'] as String?;
          avatar = userData['picture']?['data']?['url'];
          print('[SocialLogin] Facebook user: $email');

          if (email == null || email!.trim().isEmpty) {
            throw Exception(
              'Facebook không cung cấp email. Vui lòng cấp quyền email hoặc đăng nhập bằng phương thức khác.',
            );
          }
        } else {
          print('[SocialLogin] Facebook login failed: ${result.status}');
          if (result.message != null && result.message!.isNotEmpty) {
            throw Exception(result.message);
          }
          state = state.copyWith(status: AuthState.initial);
          return;
        }
      }

      print(
        '[SocialLogin] email=$email, token=${token != null ? "present" : "null"}',
      );

      if (email != null && token != null) {
        print('[SocialLogin] Calling backend API...');
        final response = await _repository.socialLogin(
          email,
          name ?? "User",
          avatar ?? "",
          provider.toUpperCase(),
          token,
        );
        print('[SocialLogin] Backend responded successfully!');

        // Xóa TOÀN BỘ dữ liệu cũ để tránh hiển thị thông tin tài khoản trước
        await _storage.deleteAll();
        print('[SocialLogin] Cleared old storage data');

        await _storage.write(key: 'access_token', value: response.accessToken);
        await _storage.write(
          key: 'refresh_token',
          value: response.refreshToken,
        );

        // Save user info to storage
        if (response.user != null) {
          await _storage.write(
            key: 'user_name',
            value: response.user!.fullName ?? 'User',
          );
          await _storage.write(key: 'user_email', value: response.user!.email);
          await _storage.write(
            key: 'user_avatar',
            value: response.user!.avatarUrl ?? '',
          );
          await _storage.write(key: 'user_id', value: response.user!.id);
        }
        print(
          '[SocialLogin] Tokens and user info saved, setting success state',
        );

        state = state.copyWith(
          status: AuthState.success,
          authResponse: response,
        );
      } else {
        print('[SocialLogin] Missing email or token!');
        throw Exception("Could not retrieve user data from $provider");
      }
    } catch (e, stackTrace) {
      print('[SocialLogin] ERROR: $e');
      print('[SocialLogin] StackTrace: $stackTrace');
      state = state.copyWith(
        status: AuthState.error,
        errorMessage: "Social Login Failed: ${e.toString()}",
      );
    }
  }

  Future<void> logout() async {
    // print('[Auth] Logging out...');
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');

    // Clear user info
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_avatar');

    state = AuthStateData(); // Reset to initial state
    // print('[Auth] Logged out successfully');
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthStateData>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      final profileApi = ref.watch(profileApiProvider);
      return AuthController(repository, profileApi);
    });
