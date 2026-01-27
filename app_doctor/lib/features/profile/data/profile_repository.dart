import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'source/profile_api.dart';
import 'dto/profile_dto.dart';

class ProfileRepository {
  final ProfileApi _api;

  ProfileRepository(this._api);

  Future<ProfileDto?> getProfile(String userId) async {
    return await _api.getProfile(userId);
  }

  Future<ProfileDto?> updateProfile(Map<String, dynamic> data) async {
    return await _api.updateProfile(data);
  }

  Future<void> changePassword(Map<String, dynamic> data) async {
    return await _api.changePassword(data);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final api = ref.watch(profileApiProvider);
  return ProfileRepository(api);
});
