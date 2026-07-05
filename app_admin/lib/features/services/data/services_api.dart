import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import 'dto/medical_service_dto.dart';

final servicesApiProvider = Provider(
  (ref) => ServicesApi(ref.watch(apiClientProvider)),
);

class ServicesApi {
  final ApiClient _client;

  ServicesApi(this._client);

  Future<List<MedicalServiceDto>> getServices({bool includeInactive = false}) async {
    final response = await _client.get(
      '/services',
      queryParameters: includeInactive ? {'includeInactive': true} : null,
    );
    final data = response.data['data'];
    if (data == null) return [];
    final list = data as List;
    return list.map((e) => MedicalServiceDto.fromJson(e)).toList();
  }

  Future<List<MedicalServiceDto>> getServicesByCategory(String category) async {
    final response = await _client.get('/services/category/$category');
    final data = response.data['data'];
    if (data == null) return [];
    final list = data as List;
    return list.map((e) => MedicalServiceDto.fromJson(e)).toList();
  }

  // Admin Endpoints
  Future<MedicalServiceDto> createService(Map<String, dynamic> data) async {
    final response = await _client.post('/services', data: data);
    return MedicalServiceDto.fromJson(response.data['data']);
  }

  Future<MedicalServiceDto> updateService(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put('/services/$id', data: data);
    return MedicalServiceDto.fromJson(response.data['data']);
  }

  Future<void> deleteService(String id) async {
    await _client.delete('/services/$id');
  }

  Future<MedicalServiceDto> toggleService(String id) async {
    final response = await _client.patch('/services/$id/toggle-active');
    return MedicalServiceDto.fromJson(response.data['data']);
  }

  /// Upload ảnh dịch vụ lên Supabase Storage
  /// Returns URL của ảnh đã upload
  Future<String> uploadServiceImage(String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _client.post('/users/upload', data: formData);
    return response.data['data']['url'];
  }
}
