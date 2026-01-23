import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/core/network/dio_provider.dart';
import '../dto/profile_dto.dart';

class ProfileApi {
  final Dio _dio;

  ProfileApi(this._dio);

  /// Lấy profile theo user ID
  Future<ProfileDto?> getProfileByUserId(String userId) async {
    try {
      final response = await _dio.get('/api/profiles/user/$userId');
      final data = response.data['data'];
      if (data == null) return null;
      return ProfileDto.fromJson(data);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// Cập nhật profile
  Future<ProfileDto?> updateProfile(
    String userId,
    UpdateProfileRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/profiles/user/$userId',
        data: request.toJson(),
      );
      return ProfileDto.fromJson(response.data['data']);
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  Future<String?> uploadAvatar(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post('/api/users/upload', data: formData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['url'];
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}

final profileApiProvider = Provider<ProfileApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileApi(dio);
});
