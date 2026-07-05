import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/source/profile_api.dart';

class UserState {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final bool emailVerified;

  UserState({
    this.id = '',
    this.name = 'Người dùng',
    this.email = '',
    this.avatar = '',
    this.emailVerified = false,
  });

  UserState copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    bool? emailVerified,
  }) {
    return UserState(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final FlutterSecureStorage _storage;
  final ProfileApi _profileApi;

  UserNotifier(this._storage, this._profileApi) : super(UserState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final id = await _storage.read(key: 'user_id');
    final name = await _storage.read(key: 'user_name');
    final email = await _storage.read(key: 'user_email');
    final avatar = await _storage.read(key: 'user_avatar');
    final emailVerified = await _storage.read(key: 'email_verified');

    state = state.copyWith(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      emailVerified: emailVerified == 'true',
    );

    if (id != null) {
      await refreshProfile();
    }
  }

  Future<void> refreshProfile() async {
    if (state.id.isEmpty) return;

    try {
      final profile = await _profileApi.getProfileByUserId(state.id);
      if (profile != null) {
        // Update state
        state = state.copyWith(
          name: profile.fullName,
          email: profile.email,
          avatar: profile.avatarUrl,
          emailVerified: profile.emailVerified,
        );

        // Update storage
        if (profile.fullName != null) {
          await _storage.write(key: 'user_name', value: profile.fullName);
        }
        if (profile.email != null) {
          await _storage.write(key: 'user_email', value: profile.email);
        }
        await _storage.write(
          key: 'email_verified',
          value: profile.emailVerified.toString(),
        );
        if (profile.avatarUrl != null) {
          await _storage.write(key: 'user_avatar', value: profile.avatarUrl);
        }
        if (profile.phone != null) {
          await _storage.write(key: 'user_phone', value: profile.phone);
        }
        if (profile.address != null) {
          await _storage.write(key: 'user_address', value: profile.address);
        }
        if (profile.dob != null) {
          await _storage.write(key: 'user_dob', value: profile.dob);
        }
        if (profile.gender != null) {
          await _storage.write(key: 'user_gender', value: profile.gender);
        }
      }
    } catch (e) {
      print('Error refreshing profile: $e');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final profileApi = ref.watch(profileApiProvider);
  return UserNotifier(const FlutterSecureStorage(), profileApi);
});
