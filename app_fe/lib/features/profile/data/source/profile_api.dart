import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/core/network/dio_provider.dart';
import 'package:image_picker/image_picker.dart';
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


  Future<EmailVerificationRequestResult?> requestEmailVerification(
    String userId,
    String email,
  ) async {
    try {
      final response = await _dio.post(
        '/api/profiles/user/$userId/email-verification/request',
        data: {'email': email},
      );
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return EmailVerificationRequestResult.fromJson(data);
      }
      return const EmailVerificationRequestResult();
    } catch (e) {
      print('Error requesting email verification: $e');
      return null;
    }
  }

  Future<ProfileDto?> confirmEmailVerification(
    String userId,
    String code,
  ) async {
    try {
      final response = await _dio.post(
        '/api/profiles/user/$userId/email-verification/confirm',
        data: {'code': code},
      );
      final data = response.data['data'];
      if (data == null) return null;
      return ProfileDto.fromJson(data);
    } catch (e) {
      print('Error confirming email verification: $e');
      return null;
    }
  }

  Future<String?> uploadAvatar(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: file.name),
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
