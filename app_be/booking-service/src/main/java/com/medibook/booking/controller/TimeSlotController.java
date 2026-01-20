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
}
