import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/review_dto.dart';
import '../data/repository/review_repository.dart';

/// State cho Review screen
class ReviewState {
  final bool isLoading;
  final List<ReviewDto> reviews;
  final ReviewStatsDto? stats;
  final String? error;
  final String selectedFilter; // 'all', '5', '4', 'attention'
  final String sortBy; // 'newest', 'oldest', 'highest'

  ReviewState({
    this.isLoading = false,
    this.reviews = const [],
    this.stats,
    this.error,
    this.selectedFilter = 'all',
    this.sortBy = 'newest',
  });

  ReviewState copyWith({
    bool? isLoading,
    List<ReviewDto>? reviews,
    ReviewStatsDto? stats,
    String? error,
    String? selectedFilter,
    String? sortBy,
  }) {
    return ReviewState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
      stats: stats ?? this.stats,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Get filtered reviews
  List<ReviewDto> get filteredReviews {
    var result = List<ReviewDto>.from(reviews);

    // Filter
    switch (selectedFilter) {
      case '5':
        result = result.where((r) => r.rating == 5).toList();
        break;
      case '4':
        result = result.where((r) => r.rating == 4).toList();
        break;
      case 'attention':
        result = result.where((r) => r.needsAttention).toList();
        break;
    }

    // Sort
    switch (sortBy) {
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default: // newest
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return result;
  }
}

/// Controller cho Review screen
class ReviewController extends StateNotifier<ReviewState> {
  final ReviewRepository _repository;

  ReviewController(this._repository) : super(ReviewState()) {
    loadData();
  }

  /// Load reviews and stats
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _repository.getMyReviews(),
        _repository.getMyStats(),
      ]);

      state = state.copyWith(
        isLoading: false,
        reviews: results[0] as List<ReviewDto>,
        stats: results[1] as ReviewStatsDto,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh data
  Future<void> refresh() => loadData();

  /// Set filter
  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Set sort
  void setSort(String sort) {
    state = state.copyWith(sortBy: sort);
  }

  /// Reply to review
  Future<bool> replyToReview(String reviewId, String reply) async {
    try {
      final updated = await _repository.replyToReview(reviewId, reply);

      // Update review in list
      final reviews = state.reviews.map((r) {
        if (r.id == reviewId) return updated;
        return r;
      }).toList();

      state = state.copyWith(reviews: reviews);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider cho ReviewController
final reviewControllerProvider =
    StateNotifierProvider<ReviewController, ReviewState>((ref) {
      return ReviewController(ref.watch(reviewRepositoryProvider));
    });
