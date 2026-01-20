import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/dto/auth_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as facebook;

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
  final FlutterSecureStorage _storage;

  AuthController(this._repository)
    : _storage = const FlutterSecureStorage(),
      super(AuthStateData());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthState.loading, errorMessage: null);
    try {
      final response = await _repository.login(email, password);

      // Save tokens
      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'refresh_token', value: response.refreshToken);

      state = state.copyWith(status: AuthState.success, authResponse: response);
    } catch (e) {
      state = state.copyWith(
        status: AuthState.error,
        errorMessage: e.toString(), // Simplify error handling for now
      );
    }
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    state = state.copyWith(status: AuthState.loading, errorMessage: null);
    try {
      await _repository.register(name, email, phone, password);
      // Notify success but do not auto-login
      state = state.copyWith(status: AuthState.registerSuccess);
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
        token = googleAuth.idToken;
      } else if (provider == 'facebook') {
        print('[SocialLogin] Initializing Facebook Login...');
        final facebook.LoginResult result = await facebook.FacebookAuth.instance
            .login();

        if (result.status == facebook.LoginStatus.success) {
          final facebook.AccessToken accessToken = result.accessToken!;
          final tokenData = accessToken.toJson();
          token = tokenData['token'] as String?;
          print(
            '[SocialLogin] Got Facebook token: ${token != null ? "YES" : "NO"}',
          );

          final userData = await facebook.FacebookAuth.instance.getUserData();
          email = userData['email'];
          name = userData['name'];
          avatar = userData['picture']?['data']?['url'];
          print('[SocialLogin] Facebook user: $email');
        } else {
          print('[SocialLogin] Facebook login failed: ${result.status}');
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

  /// Logout: Clear tokens and reset state
  Future<void> logout() async {
    // print('[Auth] Logging out...');
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    state = AuthStateData(); // Reset to initial state
    // print('[Auth] Logged out successfully');
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthStateData>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository);
    });
