package com.medibook.user.controller;

import com.medibook.common.dto.ApiResponse;
import com.medibook.user.dto.ReviewDto;
import com.medibook.user.dto.ReviewStatsDto;
import com.medibook.user.dto.CreateReviewRequest;
import com.medibook.user.service.ReviewService;
import com.medibook.user.service.DoctorService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Review Controller - API endpoints cho đánh giá
 */
@RestController
@RequestMapping("/reviews")
@RequiredArgsConstructor
@Tag(name = "Reviews", description = "API quản lý đánh giá")
public class ReviewController {

    private final ReviewService reviewService;
    private final DoctorService doctorService;

    @GetMapping("/doctor/{doctorId}")
    @Operation(summary = "Lấy danh sách đánh giá theo bác sĩ")
    public ResponseEntity<ApiResponse<List<ReviewDto>>> getReviewsByDoctor(@PathVariable UUID doctorId) {
        return ResponseEntity.ok(ApiResponse.success(reviewService.getReviewsByDoctorId(doctorId)));
    }

    @GetMapping("/my")
    @Operation(summary = "Lấy danh sách đánh giá của bác sĩ hiện tại")
    public ResponseEntity<ApiResponse<List<ReviewDto>>> getMyReviews(@RequestHeader("X-User-Id") UUID userId) {
        UUID doctorId = doctorService.findDoctorIdByUserId(userId);
        if (doctorId == null) {
            return ResponseEntity.ok(ApiResponse.success(List.of()));
        }
        return ResponseEntity.ok(ApiResponse.success(reviewService.getReviewsByDoctorId(doctorId)));
    }

    @GetMapping("/my/stats")
    @Operation(summary = "Lấy thống kê đánh giá của bác sĩ hiện tại")
    public ResponseEntity<ApiResponse<ReviewStatsDto>> getMyReviewStats(@RequestHeader("X-User-Id") UUID userId) {
        UUID doctorId = doctorService.findDoctorIdByUserId(userId);
        if (doctorId == null) {
            return ResponseEntity.ok(ApiResponse.success(new ReviewStatsDto()));
        }
        return ResponseEntity.ok(ApiResponse.success(reviewService.getReviewStats(doctorId)));
    }

    @PostMapping
    @Operation(summary = "Tạo đánh giá mới")
    public ResponseEntity<ApiResponse<ReviewDto>> createReview(
            @RequestHeader("X-User-Id") UUID patientId,
            @Valid @RequestBody CreateReviewRequest request) {
        ReviewDto created = reviewService.createReview(request, patientId);
        return ResponseEntity.ok(ApiResponse.success("Đánh giá đã được gửi thành công", created));
    }

    @PutMapping("/{reviewId}/reply")
    @Operation(summary = "Phản hồi đánh giá của bệnh nhân")
    public ResponseEntity<ApiResponse<ReviewDto>> replyToReview(
            @PathVariable UUID reviewId,
            @RequestHeader("X-User-Id") UUID userId,
            @RequestBody Map<String, String> body) {
        String reply = body.get("reply");
        ReviewDto updated = reviewService.addDoctorReply(reviewId, userId, reply);
        return ResponseEntity.ok(ApiResponse.success("Đã gửi phản hồi thành công", updated));
    }

    @PostMapping("/sync/{doctorId}")
    @Operation(summary = "Đồng bộ lại rating của bác sĩ từ tất cả reviews (Dev/Admin)")
    public ResponseEntity<ApiResponse<String>> syncDoctorRating(@PathVariable UUID doctorId) {
        reviewService.syncDoctorRating(doctorId);
        return ResponseEntity.ok(ApiResponse.success("Đã đồng bộ rating cho bác sĩ: " + doctorId));
    }
}
