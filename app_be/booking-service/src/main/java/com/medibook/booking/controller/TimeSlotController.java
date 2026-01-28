package com.medibook.booking.controller;

import com.medibook.booking.dto.TimeSlotDto;
import com.medibook.booking.service.BookingService;
import com.medibook.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * TimeSlot Controller - API lấy lịch trống
 */
@RestController
@RequestMapping("/slots")
@RequiredArgsConstructor
@Tag(name = "Time Slots", description = "API lấy khung giờ trống")
public class TimeSlotController {

    private final BookingService bookingService;

    @GetMapping("/available")
    @Operation(summary = "Lấy khung giờ trống của bác sĩ trong ngày")
    public ResponseEntity<ApiResponse<List<TimeSlotDto>>> getAvailableSlots(
            @RequestParam UUID doctorId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(ApiResponse.success(bookingService.getAvailableSlots(doctorId, date)));
    }

    @PostMapping("/init")
    @Operation(summary = "Tạo lịch mẫu cho bác sĩ (Dev only)")
    public ResponseEntity<ApiResponse<List<TimeSlotDto>>> initSlots(
            @RequestParam UUID doctorId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(ApiResponse.success(bookingService.generateSlots(doctorId, date)));
    }

    @GetMapping("/doctor/week")
    @Operation(summary = "Lấy lịch làm việc của bác sĩ theo tuần")
    public ResponseEntity<ApiResponse<List<TimeSlotDto>>> getDoctorSlotsForWeek(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestHeader(value = "X-User-Id", required = false) String userIdHeader,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        // Lấy doctorId từ token/header (bác sĩ đăng nhập)
        UUID userId = null;
        if (userIdHeader != null && !userIdHeader.isEmpty()) {
            userId = UUID.fromString(userIdHeader);
        }
        return ResponseEntity.ok(ApiResponse.success(
                bookingService.getDoctorSlotsForWeek(userId, startDate, endDate)));
    }
}
