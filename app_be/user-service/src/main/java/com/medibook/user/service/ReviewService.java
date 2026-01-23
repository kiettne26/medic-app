package com.medibook.user.service;

import com.medibook.user.dto.ReviewDto;
import com.medibook.user.dto.CreateReviewRequest;
import com.medibook.user.entity.Review;
import com.medibook.user.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
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
        return ReviewDto.builder()
                .id(review.getId())
                .bookingId(review.getBookingId())
                .patientId(review.getPatientId())
                .doctorId(review.getDoctorId())
                .rating(review.getRating())
                .comment(review.getComment())
                .createdAt(review.getCreatedAt())
                .patientName("Bệnh nhân") // TODO: Join with profiles table
                .build();
    }
}
