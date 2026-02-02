package com.medibook.booking.controller;

import com.medibook.booking.dto.TimeSlotDto;
import com.medibook.booking.service.BookingService;
import com.medibook.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * TimeSlot Controller - API lấy lịch trống
 */
@Slf4j
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

        log.debug("getDoctorSlotsForWeek called: startDate={}, endDate={}, X-User-Id={}",
                startDate, endDate, userIdHeader);

        // Lấy doctorId từ token/header (bác sĩ đăng nhập)
        UUID userId = null;
        if (userIdHeader != null && !userIdHeader.isEmpty()) {
            try {
                userId = UUID.fromString(userIdHeader);
            } catch (IllegalArgumentException e) {
                log.warn("Invalid X-User-Id header format: '{}'. Ignoring.", userIdHeader);
            }
        }

        if (userId == null) {
            log.warn("No valid userId found for getDoctorSlotsForWeek. Returning empty list.");
        }

        return ResponseEntity.ok(ApiResponse.success(
                bookingService.getDoctorSlotsForWeek(userId, startDate, endDate)));
    }

    @PostMapping("/init-week")
    @Operation(summary = "Tạo lịch làm việc cho bác sĩ trong khoảng ngày (Dev/Admin)")
    public ResponseEntity<ApiResponse<String>> initSlotsForWeek(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestHeader(value = "X-User-Id", required = false) String userIdHeader) {

        log.info("initSlotsForWeek called: startDate={}, endDate={}, X-User-Id={}",
                startDate, endDate, userIdHeader);

        UUID userId = null;
        if (userIdHeader != null && !userIdHeader.isEmpty()) {
            try {
                userId = UUID.fromString(userIdHeader);
            } catch (IllegalArgumentException e) {
                log.warn("Invalid X-User-Id: {}", userIdHeader);
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Invalid X-User-Id format"));
            }
        }

        if (userId == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Missing X-User-Id header"));
        }

        int totalSlots = 0;
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            // Skip weekends (Saturday = 6, Sunday = 7)
            if (current.getDayOfWeek().getValue() < 6) {
                List<TimeSlotDto> slots = bookingService.generateSlotsForUser(userId, current);
                totalSlots += slots.size();
            }
            current = current.plusDays(1);
        }

        return ResponseEntity.ok(ApiResponse.success(
                "Created " + totalSlots + " slots from " + startDate + " to " + endDate));
    }

    @PostMapping
    @Operation(summary = "Tạo khung giờ làm việc mới")
    public ResponseEntity<ApiResponse<TimeSlotDto>> createSlot(
            @RequestBody CreateSlotRequest request,
            @RequestHeader(value = "X-User-Id", required = false) String userIdHeader) {

        log.info("createSlot called: date={}, startTime={}, endTime={}, X-User-Id={}",
                request.getDate(), request.getStartTime(), request.getEndTime(), userIdHeader);

        UUID userId = parseUserId(userIdHeader);
        if (userId == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Missing or invalid X-User-Id header"));
        }

        TimeSlotDto slot = bookingService.createTimeSlot(
                userId,
                request.getDate(),
                request.getStartTime(),
                request.getEndTime());
        return ResponseEntity.ok(ApiResponse.success(slot));
    }

    @DeleteMapping("/{slotId}")
    @Operation(summary = "Xóa khung giờ làm việc (chỉ slot chưa đặt)")
    public ResponseEntity<ApiResponse<String>> deleteSlot(
            @PathVariable UUID slotId,
            @RequestHeader(value = "X-User-Id", required = false) String userIdHeader) {

        log.info("deleteSlot called: slotId={}, X-User-Id={}", slotId, userIdHeader);

        UUID userId = parseUserId(userIdHeader);
        if (userId == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Missing or invalid X-User-Id header"));
        }

        bookingService.deleteTimeSlot(slotId, userId);
        return ResponseEntity.ok(ApiResponse.success("Slot deleted successfully"));
    }

    // ==================== ADMIN ENDPOINTS ====================

    @GetMapping("/admin/all")
    @Operation(summary = "Lấy tất cả slot (Admin) - có thể filter theo status và khoảng ngày")
    public ResponseEntity<ApiResponse<List<TimeSlotDto>>> getAllSlots(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        log.info("getAllSlots called with status={}, startDate={}, endDate={}", status, startDate, endDate);
        return ResponseEntity.ok(ApiResponse.success(bookingService.getAllSlots(status, startDate, endDate)));
    }

    @GetMapping("/pending")
    @Operation(summary = "Lấy danh sách slot chờ duyệt (Admin)")
    public ResponseEntity<ApiResponse<List<TimeSlotDto>>> getPendingSlots() {
        log.info("getPendingSlots called");
        return ResponseEntity.ok(ApiResponse.success(bookingService.getPendingSlots()));
    }

    @PutMapping("/{slotId}/approve")
    @Operation(summary = "Duyệt slot (Admin)")
    public ResponseEntity<ApiResponse<TimeSlotDto>> approveSlot(@PathVariable UUID slotId) {
        log.info("approveSlot called: slotId={}", slotId);
        return ResponseEntity.ok(ApiResponse.success(bookingService.approveSlot(slotId)));
    }

    @PutMapping("/{slotId}/reject")
    @Operation(summary = "Từ chối slot (Admin)")
    public ResponseEntity<ApiResponse<TimeSlotDto>> rejectSlot(@PathVariable UUID slotId) {
        log.info("rejectSlot called: slotId={}", slotId);
        return ResponseEntity.ok(ApiResponse.success(bookingService.rejectSlot(slotId)));
    }

    @PutMapping("/approve-bulk")
    @Operation(summary = "Duyệt nhiều slot cùng lúc (Admin)")
    public ResponseEntity<ApiResponse<String>> approveBulkSlots(@RequestBody List<UUID> slotIds) {
        log.info("approveBulkSlots called: {} slots", slotIds.size());
        int count = bookingService.approveBulkSlots(slotIds);
        return ResponseEntity.ok(ApiResponse.success("Đã duyệt " + count + " lịch"));
    }

    @PutMapping("/reject-bulk")
    @Operation(summary = "Từ chối nhiều slot cùng lúc (Admin)")
    public ResponseEntity<ApiResponse<String>> rejectBulkSlots(@RequestBody List<UUID> slotIds) {
        log.info("rejectBulkSlots called: {} slots", slotIds.size());
        int count = bookingService.rejectBulkSlots(slotIds);
        return ResponseEntity.ok(ApiResponse.success("Đã từ chối " + count + " lịch"));
    }

    // ==================== HELPER METHODS ====================

    private UUID parseUserId(String userIdHeader) {
        if (userIdHeader == null || userIdHeader.isEmpty()) {
            return null;
        }
        try {
            return UUID.fromString(userIdHeader);
        } catch (IllegalArgumentException e) {
            log.warn("Invalid X-User-Id: {}", userIdHeader);
            return null;
        }
    }

    @Data
    public static class CreateSlotRequest {
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        private LocalDate date;
        private String startTime;
        private String endTime;
    }
}
