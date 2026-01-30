package com.medibook.booking.controller;

import com.medibook.booking.dto.*;
import com.medibook.booking.service.BookingService;
import com.medibook.common.dto.ApiResponse;
import com.medibook.common.dto.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Booking Controller - API endpoints cho đặt lịch
 */
@RestController
@RequestMapping("/bookings")
@RequiredArgsConstructor
@Tag(name = "Bookings", description = "API đặt lịch khám")
public class BookingController {

    private final BookingService bookingService;

    /**
     * 🔐 Đặt lịch mới - Core endpoint
     */
    @PostMapping
    @Operation(summary = "Đặt lịch khám mới")
    public ResponseEntity<ApiResponse<BookingDto>> createBooking(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody CreateBookingRequest request) {
        BookingDto booking = bookingService.createBooking(userId, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Đặt lịch thành công", booking));
    }

    @GetMapping("/admin")
    @Operation(summary = "Lấy danh sách tất cả booking (Admin)")
    public ResponseEntity<ApiResponse<PageResponse<BookingDto>>> getAllBookings(
            @RequestParam(required = false) com.medibook.common.enums.BookingStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<BookingDto> bookings = bookingService.getAllBookings(status, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(bookings.getContent(), page, size, bookings.getTotalElements())));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Lấy thông tin booking theo ID")
    public ResponseEntity<ApiResponse<BookingDto>> getBookingById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success(bookingService.getBookingById(id)));
    }

    @GetMapping("/patient")
    @Operation(summary = "Lấy danh sách booking của bệnh nhân hiện tại")
    public ResponseEntity<ApiResponse<PageResponse<BookingDto>>> getPatientBookings(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<BookingDto> bookings = bookingService.getPatientBookings(userId, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(bookings.getContent(), page, size, bookings.getTotalElements())));
    }

    @GetMapping("/doctor")
    @Operation(summary = "Lấy danh sách booking của bác sĩ hiện tại")
    public ResponseEntity<ApiResponse<PageResponse<BookingDto>>> getDoctorBookings(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<BookingDto> bookings = bookingService.getDoctorBookings(userId, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(bookings.getContent(), page, size, bookings.getTotalElements())));
    }

    @GetMapping("/doctor/date/{date}")
    @Operation(summary = "Lấy lịch khám của bác sĩ trong ngày")
    public ResponseEntity<ApiResponse<List<BookingDto>>> getDoctorBookingsByDate(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(ApiResponse.success(bookingService.getDoctorBookingsByDate(userId, date)));
    }

    @PutMapping("/{id}/confirm")
    @Operation(summary = "Xác nhận lịch (Bác sĩ)")
    public ResponseEntity<ApiResponse<BookingDto>> confirmBooking(
            @PathVariable UUID id,
            @RequestHeader("X-User-Id") UUID userId) {
        return ResponseEntity.ok(ApiResponse.success("Xác nhận thành công", bookingService.confirmBooking(id, userId)));
    }

    @PutMapping("/{id}/complete")
    @Operation(summary = "Hoàn thành lịch (Bác sĩ)")
    public ResponseEntity<ApiResponse<BookingDto>> completeBooking(
            @PathVariable UUID id,
            @RequestHeader("X-User-Id") UUID userId,
            @RequestParam(required = false) String doctorNotes) {
        return ResponseEntity.ok(
                ApiResponse.success("Hoàn thành thành công", bookingService.completeBooking(id, userId, doctorNotes)));
    }

    @PutMapping("/{id}/cancel")
    @Operation(summary = "Hủy lịch")
    public ResponseEntity<ApiResponse<BookingDto>> cancelBooking(
            @PathVariable UUID id,
            @RequestHeader("X-User-Id") UUID userId,
            @RequestBody CancelBookingRequest request) {
        return ResponseEntity
                .ok(ApiResponse.success("Hủy lịch thành công", bookingService.cancelBooking(id, userId, request)));
    }
}
