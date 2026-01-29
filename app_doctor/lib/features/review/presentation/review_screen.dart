import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/dto/review_dto.dart';
import 'review_controller.dart';

/// Trang Quản lý Đánh giá
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  // Colors matching design
  static const primaryColor = Color(0xFF297EFF);
  static const successColor = Color(0xFF00C853);
  static const warningColor = Color(0xFFFFA000);
  static const dangerColor = Color(0xFFEF4444);
  static const backgroundColor = Color(0xFFF5F7F8);
  static const borderColor = Color(0xFFE6ECF4);

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewControllerProvider);
    final controller = ref.read(reviewControllerProvider.notifier);

    return Scaffold(
      backgroundColor: ReviewScreen.backgroundColor,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? _buildError(state.error!, controller)
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(controller),
                    const SizedBox(height: 32),

                    // Rating Summary Section
                    _buildRatingSummary(state.stats),
                    const SizedBox(height: 32),

                    // Filter Chips
                    _buildFilters(state, controller),
                    const SizedBox(height: 24),

                    // Review List
                    _buildReviewList(state.filteredReviews),
                    const SizedBox(height: 32),

                    // Pagination
                    if (state.reviews.isNotEmpty) _buildPagination(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildError(String error, ReviewController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: ReviewScreen.dangerColor),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(color: const Color(0xFF5E718D)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refresh,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ReviewController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý đánh giá',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0C131D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Theo dõi phản hồi và mức độ hài lòng của bệnh nhân.',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: const Color(0xFF5E718D),
              ),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: controller.refresh,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(
            'Làm mới',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0C131D),
            side: const BorderSide(color: ReviewScreen.borderColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSummary(ReviewStatsDto? stats) {
    final avgRating = stats?.averageRating ?? 0;
    final totalReviews = stats?.totalReviews ?? 0;
    final distribution = stats?.ratingDistribution ?? {};
    final monthlyGrowth = stats?.monthlyGrowth ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average Rating Card
        Container(
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ReviewScreen.borderColor),
          ),
          child: Column(
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: GoogleFonts.manrope(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: ReviewScreen.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < avgRating.floor()
                        ? Icons.star
                        : (index < avgRating
                              ? Icons.star_half
                              : Icons.star_border),
                    color: const Color(0xFFFACC15),
                    size: 28,
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'Dựa trên $totalReviews lượt đánh giá',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: const Color(0xFF5E718D),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ReviewScreen.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      monthlyGrowth >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: ReviewScreen.successColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${monthlyGrowth >= 0 ? '+' : ''}${monthlyGrowth.toStringAsFixed(0)}% tháng này',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ReviewScreen.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Rating Breakdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ReviewScreen.borderColor),
            ),
            child: Column(
              children: [5, 4, 3, 2, 1].map((rating) {
                final percentage = distribution[rating] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$rating',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: ReviewScreen.backgroundColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getRatingColor(rating),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 45,
                        child: Text(
                          '$percentage%',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: const Color(0xFF5E718D),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return ReviewScreen.successColor;
      case 4:
        return ReviewScreen.primaryColor;
      case 3:
        return const Color(0xFFFACC15);
      case 2:
        return Colors.orange;
      case 1:
        return ReviewScreen.dangerColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilters(ReviewState state, ReviewController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Filter Chips
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ReviewScreen.borderColor),
          ),
          child: Row(
            children: [
              _buildFilterChip(
                'all',
                'Tất cả',
                state.selectedFilter,
                controller,
              ),
              _buildFilterChip('5', '5 sao', state.selectedFilter, controller),
              _buildFilterChip('4', '4 sao', state.selectedFilter, controller),
              _buildFilterChip(
                'attention',
                'Cần chú ý',
                state.selectedFilter,
                controller,
              ),
            ],
          ),
        ),

        // Sort Dropdown
        Row(
          children: [
            Text(
              'Sắp xếp theo:',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: const Color(0xFF5E718D),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: state.sortBy,
              underline: const SizedBox(),
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0C131D),
                fontSize: 13,
              ),
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Mới nhất')),
                DropdownMenuItem(value: 'oldest', child: Text('Cũ nhất')),
                DropdownMenuItem(value: 'highest', child: Text('Đánh giá cao')),
              ],
              onChanged: (value) {
                if (value != null) controller.setSort(value);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
    String selectedFilter,
    ReviewController controller,
  ) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => controller.setFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ReviewScreen.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF5E718D),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewList(List<ReviewDto> reviews) {
    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Icon(
                Icons.star_outline,
                size: 64,
                color: const Color(0xFFD1D5DB),
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có đánh giá nào',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: const Color(0xFF5E718D),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: reviews.map((review) => _buildReviewCard(review)).toList(),
    );
  }

  Widget _buildReviewCard(ReviewDto review) {
    final Color avatarColor = review.needsAttention
        ? Colors.orange
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: review.needsAttention
            ? const Border(
                left: BorderSide(color: Colors.orange, width: 4),
                top: BorderSide(color: ReviewScreen.borderColor),
                right: BorderSide(color: ReviewScreen.borderColor),
                bottom: BorderSide(color: ReviewScreen.borderColor),
              )
            : Border.all(color: ReviewScreen.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: avatarColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      image: review.patientAvatar != null
                          ? DecorationImage(
                              image: NetworkImage(review.patientAvatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: review.patientAvatar == null
                        ? Center(
                            child: Text(
                              review.initials,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.bold,
                                color: avatarColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.patientName,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFFACC15),
                            size: 14,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(review.createdAt),
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comment
          if (review.comment != null && review.comment!.isNotEmpty)
            Text(
              review.comment!,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: const Color(0xFF374151),
                height: 1.6,
              ),
            ),
          const SizedBox(height: 20),

          // Doctor Reply (if exists)
          if (review.doctorReply != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ReviewScreen.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ReviewScreen.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right,
                        color: ReviewScreen.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Phản hồi của bác sĩ',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (review.doctorReplyAt != null)
                        Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(review.doctorReplyAt!),
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.doctorReply!,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Footer
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ReviewScreen.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (review.doctorReply != null)
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: ReviewScreen.successColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Đã phản hồi',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ReviewScreen.successColor,
                        ),
                      ),
                    ],
                  )
                else if (review.needsAttention)
                  Text(
                    'Chờ phản hồi từ bác sĩ...',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  const SizedBox(),

                // Reply Button
                if (review.doctorReply == null)
                  ElevatedButton.icon(
                    onPressed: () => _showReplyDialog(review),
                    icon: const Icon(Icons.reply, size: 18),
                    label: Text(
                      review.needsAttention ? 'Phản hồi ngay' : 'Phản hồi',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: review.needsAttention
                          ? ReviewScreen.primaryColor
                          : Colors.transparent,
                      foregroundColor: review.needsAttention
                          ? Colors.white
                          : ReviewScreen.primaryColor,
                      elevation: review.needsAttention ? 2 : 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => _showReplyDialog(review),
                    child: Text(
                      'Chỉnh sửa',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(ReviewDto review) {
    final controller = TextEditingController(text: review.doctorReply);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Phản hồi đánh giá',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phản hồi cho ${review.patientName}:',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: const Color(0xFF5E718D),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung phản hồi...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(reviewControllerProvider.notifier)
                  .replyToReview(review.id, controller.text);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Đã gửi phản hồi thành công!'
                          : 'Không thể gửi phản hồi',
                    ),
                    backgroundColor: success
                        ? ReviewScreen.successColor
                        : ReviewScreen.dangerColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ReviewScreen.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Gửi phản hồi',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageButton(icon: Icons.chevron_left, enabled: false),
        _buildPageButton(label: '1', isSelected: true),
        _buildPageButton(icon: Icons.chevron_right, enabled: false),
      ],
    );
  }

  Widget _buildPageButton({
    String? label,
    IconData? icon,
    bool isSelected = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: enabled ? () {} : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? ReviewScreen.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? null
                : Border.all(color: ReviewScreen.borderColor),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: enabled
                        ? const Color(0xFF5E718D)
                        : const Color(0xFFD1D5DB),
                    size: 20,
                  )
                : Text(
                    label ?? '',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0C131D),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
