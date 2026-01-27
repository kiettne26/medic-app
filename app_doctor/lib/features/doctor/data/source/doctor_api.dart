import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../dto/doctor_dto.dart';

class DoctorApi {
  final Dio _dio;

  DoctorApi(this._dio);

  Future<DoctorDto?> getDoctorByUserId(String userId) async {
    try {
      final response = await _dio.get('/api/doctors/user/$userId');
      if (response.data['success'] == true && response.data['data'] != null) {
        return DoctorDto.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<DoctorDto?> updateDoctor(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/doctors/$id', data: data);
      if (response.data['success'] == true && response.data['data'] != null) {
        return DoctorDto.fromJson(response.data['data']);
      }
      return null; // Or throw error
    } catch (e) {
      rethrow;
    }
  }
}

final doctorApiProvider = Provider<DoctorApi>((ref) {
  final dio = ref.watch(dioProvider);
  return DoctorApi(dio);
});
