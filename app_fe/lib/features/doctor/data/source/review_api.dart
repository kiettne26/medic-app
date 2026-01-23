import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/core/network/dio_provider.dart';
import '../dto/review_dto.dart';

class ReviewApi {
  final Dio _dio;

  ReviewApi(this._dio);

  /// Lấy reviews theo doctor ID
  Future<List<ReviewDto>> getReviewsByDoctorId(String doctorId) async {
    try {
      final response = await _dio.get('/api/reviews/doctor/$doctorId');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ReviewDto.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }
}

final reviewApiProvider = Provider<ReviewApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewApi(dio);
});
