package com.medibook.user.controller;

import com.medibook.common.dto.ApiResponse;
import com.medibook.user.dto.ReviewDto;
import com.medibook.user.dto.CreateReviewRequest;
import com.medibook.user.service.ReviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
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

    @GetMapping("/doctor/{doctorId}")
    @Operation(summary = "Lấy danh sách đánh giá theo bác sĩ")
    public ResponseEntity<ApiResponse<List<ReviewDto>>> getReviewsByDoctor(@PathVariable UUID doctorId) {
        return ResponseEntity.ok(ApiResponse.success(reviewService.getReviewsByDoctorId(doctorId)));
    }

    @PostMapping
    @Operation(summary = "Tạo đánh giá mới")
    public ResponseEntity<ApiResponse<ReviewDto>> createReview(
            @RequestHeader("X-User-Id") UUID patientId,
            @Valid @RequestBody CreateReviewRequest request) {
        ReviewDto created = reviewService.createReview(request, patientId);
        return ResponseEntity.ok(ApiResponse.success("Đánh giá đã được gửi thành công", created));
    }

    @PostMapping("/sync/{doctorId}")
    @Operation(summary = "Đồng bộ lại rating của bác sĩ từ tất cả reviews (Dev/Admin)")
    public ResponseEntity<ApiResponse<String>> syncDoctorRating(@PathVariable UUID doctorId) {
        reviewService.syncDoctorRating(doctorId);
        return ResponseEntity.ok(ApiResponse.success("Đã đồng bộ rating cho bác sĩ: " + doctorId));
    }
}
