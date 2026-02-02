import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import 'dto/patient_dto.dart';

final patientsApiProvider = Provider(
  (ref) => PatientsApi(ref.watch(apiClientProvider)),
);

class PatientsApi {
  final ApiClient _client;

  PatientsApi(this._client);

  /// Lấy danh sách tất cả bệnh nhân (không phân trang)
  Future<List<PatientDto>> getPatients({String? search}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    final response = await _client.get(
      '/profiles/admin/patients/all',
      queryParameters: queryParams,
    );
    
    final rawData = response.data['data'];
    if (rawData == null) return [];
    final data = rawData as List;
    return data.map((e) => PatientDto.fromJson(e)).toList();
  }

  /// Lấy danh sách bệnh nhân có phân trang
  Future<Map<String, dynamic>> getPatientsPaged({
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    final response = await _client.get(
      '/profiles/admin/patients',
      queryParameters: queryParams,
    );
    
    return response.data['data'];
  }

  /// Cập nhật thông tin bệnh nhân
  Future<void> updatePatient(String userId, Map<String, dynamic> data) async {
    await _client.put('/profiles/user/$userId', data: data);
  }

  /// Xóa bệnh nhân
  Future<void> deletePatient(String userId) async {
    await _client.delete('/profiles/admin/patients/$userId');
  }
}
