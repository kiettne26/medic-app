package com.medibook.user.service;

import com.medibook.user.dto.ReviewDto;
import com.medibook.user.dto.ReviewStatsDto;
import com.medibook.user.dto.CreateReviewRequest;
import com.medibook.user.entity.Review;
import com.medibook.user.entity.Profile;
import com.medibook.user.repository.ReviewRepository;
import com.medibook.user.repository.ProfileRepository;
import com.medibook.common.exception.ResourceNotFoundException;
import com.medibook.common.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Review Service - Quản lý đánh giá
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final DoctorService doctorService;
    private final ProfileRepository profileRepository;

    /**
     * Lấy reviews theo doctor ID
     */
    public List<ReviewDto> getReviewsByDoctorId(UUID doctorId) {
        return reviewRepository.findByDoctorIdOrderByCreatedAtDesc(doctorId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Đếm số reviews của bác sĩ
     */
    public long countReviewsByDoctorId(UUID doctorId) {
        return reviewRepository.countByDoctorId(doctorId);
    }

    /**
     * Lấy thống kê đánh giá của bác sĩ
     */
    public ReviewStatsDto getReviewStats(UUID doctorId) {
        List<Review> reviews = reviewRepository.findByDoctorIdOrderByCreatedAtDesc(doctorId);

        double avg = reviews.isEmpty() ? 0 : reviews.stream().mapToInt(Review::getRating).average().orElse(0);

        Map<Integer, Integer> distribution = new HashMap<>();
        for (int i = 1; i <= 5; i++) {
            int rating = i;
            int count = (int) reviews.stream().filter(r -> r.getRating() == rating).count();
            int percentage = reviews.isEmpty() ? 0 : (count * 100 / reviews.size());
            distribution.put(rating, percentage);
        }

        // TODO: Calculate monthly growth
        double monthlyGrowth = 12.0; // Mock for now

        return ReviewStatsDto.builder()
                .averageRating(Math.round(avg * 10.0) / 10.0)
                .totalReviews(reviews.size())
                .ratingDistribution(distribution)
                .monthlyGrowth(monthlyGrowth)
                .build();
    }

    /**
     * Thêm phản hồi của bác sĩ
     */
    @Transactional
    public ReviewDto addDoctorReply(UUID reviewId, UUID userId, String reply) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Review", "id", reviewId));

        // Verify doctor owns this review
        UUID doctorId = doctorService.findDoctorIdByUserId(userId);
        if (doctorId == null || !doctorId.equals(review.getDoctorId())) {
            throw new BadRequestException("Bạn không có quyền phản hồi đánh giá này");
        }

        review.setDoctorReply(reply);
        review.setDoctorReplyAt(LocalDateTime.now());
        review = reviewRepository.save(review);

        log.info("Doctor reply added to review: id={}", reviewId);
        return toDto(review);
    }

    /**
     * Tạo review mới và tự động cập nhật rating của bác sĩ
     */
    @Transactional
    public ReviewDto createReview(CreateReviewRequest request, UUID patientId) {
        Review review = Review.builder()
                .bookingId(request.getBookingId())
                .patientId(patientId)
                .doctorId(request.getDoctorId())
                .rating(request.getRating())
                .comment(request.getComment())
                .build();

        review = reviewRepository.save(review);
        log.info("Review created: id={}, doctorId={}, rating={}", review.getId(), review.getDoctorId(),
                review.getRating());

        // Auto-update doctor rating
        syncDoctorRating(request.getDoctorId());

        return toDto(review);
    }

    /**
     * Đồng bộ rating của bác sĩ từ tất cả reviews
     */
    @Transactional
    public void syncDoctorRating(UUID doctorId) {
        Double avgRating = reviewRepository.getAverageRatingByDoctorId(doctorId);
        long totalReviews = reviewRepository.countByDoctorId(doctorId);
        doctorService.updateDoctorRating(doctorId, avgRating, totalReviews);
    }

    /**
     * Convert entity to DTO
     */
    private ReviewDto toDto(Review review) {
        String patientName = "Bệnh nhân";
        String patientAvatar = null;

        // Fetch patient info
        if (review.getPatientId() != null) {
            profileRepository.findByUserId(review.getPatientId()).ifPresent(profile -> {
                // Can't reassign in lambda, so we build DTO differently
            });
            Profile profile = profileRepository.findByUserId(review.getPatientId()).orElse(null);
            if (profile != null) {
                patientName = profile.getFullName() != null ? profile.getFullName() : "Bệnh nhân";
                patientAvatar = profile.getAvatarUrl();
            }
        }

        return ReviewDto.builder()
                .id(review.getId())
                .bookingId(review.getBookingId())
                .patientId(review.getPatientId())
                .doctorId(review.getDoctorId())
                .rating(review.getRating())
                .comment(review.getComment())
                .doctorReply(review.getDoctorReply())
                .doctorReplyAt(review.getDoctorReplyAt())
                .createdAt(review.getCreatedAt())
                .patientName(patientName)
                .patientAvatar(patientAvatar)
                .build();
    }
}
