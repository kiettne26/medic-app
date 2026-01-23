import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../dto/service_dto.dart';

/// API Service cho Medical Services
class ServiceApi {
  final Dio _dio;

  ServiceApi(this._dio);

  /// Lấy tất cả dịch vụ
  Future<List<ServiceDto>> getServices() async {
    try {
      print('ServiceApi: Fetching services from /api/services');
      final response = await _dio.get('/api/services');
      print('ServiceApi: Response status: ${response.statusCode}');
      print('ServiceApi: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        print('ServiceApi: Parsed data list length: ${data?.length ?? 0}');
        if (data != null) {
          return data.map((json) => ServiceDto.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('ServiceApi: Error fetching services: $e');
      return [];
    }
  }

  /// Lấy dịch vụ theo danh mục
  Future<List<ServiceDto>> getServicesByCategory(String category) async {
    try {
      final response = await _dio.get('/api/services/category/$category');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data != null) {
          return data.map((json) => ServiceDto.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching services by category: $e');
      return [];
    }
  }
}

/// Provider cho ServiceApi
final serviceApiProvider = Provider<ServiceApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ServiceApi(dio);
});
