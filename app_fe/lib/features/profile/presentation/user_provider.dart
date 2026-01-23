import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/dto/profile_dto.dart';
import '../data/source/profile_api.dart';

class UserState {
  final String id;
  final String name;
  final String email;
  final String avatar;

  UserState({
    this.id = '',
    this.name = 'Người dùng',
    this.email = '',
    this.avatar = '',
  });

  UserState copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
  }) {
    return UserState(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
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

    state = state.copyWith(id: id, name: name, email: email, avatar: avatar);

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
          avatar: profile.avatarUrl,
        );

        // Update storage
        if (profile.fullName != null) {
          await _storage.write(key: 'user_name', value: profile.fullName);
        }
        if (profile.avatarUrl != null) {
          await _storage.write(key: 'user_avatar', value: profile.avatarUrl);
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
