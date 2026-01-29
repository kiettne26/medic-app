import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dto/review_dto.dart';
import '../source/review_api.dart';

/// Repository cho Reviews
class ReviewRepository {
  final ReviewApi _api;

  ReviewRepository(this._api);

  /// Lấy danh sách reviews
  Future<List<ReviewDto>> getMyReviews() => _api.getMyReviews();

  /// Lấy thống kê
  Future<ReviewStatsDto> getMyStats() => _api.getMyStats();

  /// Phản hồi đánh giá
  Future<ReviewDto> replyToReview(String reviewId, String reply) =>
      _api.replyToReview(reviewId, reply);
}

/// Provider cho ReviewRepository
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(reviewApiProvider));
});
