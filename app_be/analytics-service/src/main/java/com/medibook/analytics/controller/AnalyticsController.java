package com.medibook.analytics.controller;

import com.medibook.analytics.dto.DashboardDto;
import com.medibook.analytics.service.AnalyticsService;
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
 * Analytics Controller - Dashboard và thống kê
 */
@RestController
@RequestMapping("/analytics")
@RequiredArgsConstructor
@Tag(name = "Analytics", description = "API thống kê và dashboard")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/dashboard")
    @Operation(summary = "Lấy thống kê tổng quan cho dashboard")
    public ResponseEntity<ApiResponse<DashboardDto>> getDashboard() {
        DashboardDto dashboard = analyticsService.getDashboardStats();
        return ResponseEntity.ok(ApiResponse.success(dashboard));
    }

    @GetMapping("/bookings/by-period")
    @Operation(summary = "Thống kê booking theo khoảng thời gian")
    public ResponseEntity<ApiResponse<List<DashboardDto.TimeSeriesData>>> getBookingsByPeriod(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(defaultValue = "DAY") String groupBy) {
        // TODO: Implement với actual data
        return ResponseEntity.ok(ApiResponse.success(List.of()));
    }

    @GetMapping("/doctors/rankings")
    @Operation(summary = "Xếp hạng bác sĩ")
    public ResponseEntity<ApiResponse<List<DashboardDto.DoctorStats>>> getDoctorRankings(
            @RequestParam(defaultValue = "10") int limit) {
        // TODO: Implement với actual data
        return ResponseEntity.ok(ApiResponse.success(List.of()));
    }
}
