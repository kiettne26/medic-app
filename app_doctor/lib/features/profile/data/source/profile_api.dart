import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../dto/profile_dto.dart';

class ProfileApi {
  final Dio _dio;

  ProfileApi(this._dio);

  Future<ProfileDto?> getProfile(String userId) async {
    try {
      final response = await _dio.get('/api/profiles/user/$userId');
      if (response.data['success'] == true && response.data['data'] != null) {
        return ProfileDto.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<ProfileDto?> updateProfile(Map<String, dynamic> data) async {
    try {
      // Backend requires PUT /api/profiles/user/{userId}
      // We should extract userId from data or passed arguments.
      // The DTO has userId, let's use it.
      final userId = data['userId'];
      if (userId == null) {
        throw Exception('UserId is required for update');
      }

      final response = await _dio.put('/api/profiles/user/$userId', data: data);
      if (response.data['success'] == true && response.data['data'] != null) {
        return ProfileDto.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(Map<String, dynamic> data) async {
    try {
      await _dio.post('/api/auth/change-password', data: data);
    } catch (e) {
      rethrow;
    }
  }
}

final profileApiProvider = Provider<ProfileApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileApi(dio);
});
