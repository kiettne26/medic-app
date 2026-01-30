import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import 'dto/doctor_dto.dart';

final doctorsApiProvider = Provider(
  (ref) => DoctorsApi(ref.watch(apiClientProvider)),
);

class DoctorsApi {
  final ApiClient _client;

  DoctorsApi(this._client);

  Future<List<DoctorDto>> getDoctors() async {
    final response = await _client.get('/doctors');
    final rawData = response.data['data'];
    if (rawData == null) return [];
    final data = rawData as List;
    return data.map((e) => DoctorDto.fromJson(e)).toList();
  }

  Future<DoctorDto> getDoctorById(String id) async {
    final response = await _client.get('/doctors/$id');
    return DoctorDto.fromJson(response.data['data']);
  }

  // Admin Endpoints
  Future<void> createDoctor(Map<String, dynamic> data) async {
    await _client.post('/doctors', data: data);
  }

  Future<void> updateDoctor(String id, Map<String, dynamic> data) async {
    await _client.put('/doctors/$id', data: data);
  }

  Future<void> deleteDoctor(String id) async {
    await _client.delete('/doctors/$id');
  }

  Future<String> uploadAvatar(FormData formData) async {
    final response = await _client.post('/users/upload', data: formData);
    return response.data['data']['url'];
  }
}
