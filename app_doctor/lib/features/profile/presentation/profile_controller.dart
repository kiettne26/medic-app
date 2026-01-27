import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/profile_repository.dart';
import '../data/dto/profile_dto.dart';

class ProfileController extends StateNotifier<AsyncValue<ProfileDto?>> {
  final ProfileRepository _repository;
  final _storage = const FlutterSecureStorage();

  ProfileController(this._repository) : super(const AsyncValue.loading()) {
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      state = const AsyncValue.loading();
      final userId = await _storage.read(key: 'user_id');
      if (userId != null) {
        final profile = await _repository.getProfile(userId);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final current = state.value;
      // Optimistic update or waiting? Let's wait.
      state = const AsyncValue.loading();
      final updated = await _repository.updateProfile(data);
      if (updated != null) {
        state = AsyncValue.data(updated);
      } else {
        // Reload or revert
        await getProfile();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      state = const AsyncValue.loading();
      await _repository.changePassword({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      // reload profile or just set success?
      // State remains current profile.
      await getProfile(); // Refresh to be safe
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<ProfileDto?>>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      return ProfileController(repository);
    });
