import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/core/network/dio_provider.dart';
import '../dto/doctor_dto.dart';

class DoctorApi {
  final Dio _dio;

  DoctorApi(this._dio);

  /// Lấy danh sách tất cả bác sĩ
  Future<List<DoctorDto>> getAllDoctors() async {
    try {
      final response = await _dio.get('/api/doctors');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => DoctorDto.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách bác sĩ đang available
  Future<List<DoctorDto>> getAvailableDoctors() async {
    try {
      final response = await _dio.get('/api/doctors/available');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => DoctorDto.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy thông tin bác sĩ theo ID
  Future<DoctorDto> getDoctorById(String id) async {
    try {
      final response = await _dio.get('/api/doctors/$id');
      return DoctorDto.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy bác sĩ theo chuyên khoa
  Future<List<DoctorDto>> getDoctorsBySpecialty(String specialty) async {
    try {
      final response = await _dio.get('/api/doctors/specialty/$specialty');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => DoctorDto.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Tìm kiếm bác sĩ theo tên hoặc chuyên khoa
  Future<List<DoctorDto>> searchDoctors(String query) async {
    try {
      final response = await _dio.get(
        '/api/doctors',
        queryParameters: {'search': query},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => DoctorDto.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách bác sĩ theo dịch vụ
  Future<List<DoctorDto>> getDoctorsByService(String serviceId) async {
    try {
      final response = await _dio.get('/api/doctors/service/$serviceId');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => DoctorDto.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

final doctorApiProvider = Provider<DoctorApi>((ref) {
  final dio = ref.watch(dioProvider);
  return DoctorApi(dio);
});
