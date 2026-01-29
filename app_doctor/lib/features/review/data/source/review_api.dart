import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../dto/review_dto.dart';

/// API service cho Reviews
class ReviewApi {
  final Dio _dio;

  ReviewApi(this._dio);

  /// Lấy danh sách reviews của bác sĩ hiện tại
  Future<List<ReviewDto>> getMyReviews() async {
    try {
      final response = await _dio.get('/api/reviews/my');

      if (response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReviewDto.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print(
        '[ReviewApi] DioException: ${e.type}, Status: ${e.response?.statusCode}',
      );
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tải danh sách đánh giá',
      );
    }
  }

  /// Lấy thống kê đánh giá của bác sĩ hiện tại
  Future<ReviewStatsDto> getMyStats() async {
    try {
      final response = await _dio.get('/api/reviews/my/stats');

      if (response.data['data'] != null) {
        return ReviewStatsDto.fromJson(response.data['data']);
      }
      return ReviewStatsDto.empty();
    } on DioException catch (e) {
      print(
        '[ReviewApi] DioException: ${e.type}, Status: ${e.response?.statusCode}',
      );
      return ReviewStatsDto.empty();
    }
  }

  /// Phản hồi đánh giá
  Future<ReviewDto> replyToReview(String reviewId, String reply) async {
    try {
      final response = await _dio.put(
        '/api/reviews/$reviewId/reply',
        data: {'reply': reply},
      );

      return ReviewDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      print(
        '[ReviewApi] DioException: ${e.type}, Status: ${e.response?.statusCode}',
      );
      throw Exception(e.response?.data?['message'] ?? 'Không thể gửi phản hồi');
    }
  }
}

/// Provider cho ReviewApi
final reviewApiProvider = Provider<ReviewApi>((ref) {
  return ReviewApi(ref.watch(dioProvider));
});
