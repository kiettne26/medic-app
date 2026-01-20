package com.medibook.analytics.controller;

import com.medibook.analytics.dto.DashboardDto;
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

    @GetMapping("/dashboard")
    @Operation(summary = "Lấy thống kê tổng quan cho dashboard")
    public ResponseEntity<ApiResponse<DashboardDto>> getDashboard() {
        // TODO: Implement với actual data từ database
        DashboardDto dashboard = DashboardDto.builder()
                .totalBookings(100)
                .totalDoctors(15)
                .totalPatients(80)
                .todayBookings(5)
                .pendingBookings(10)
                .confirmedBookings(20)
                .completedBookings(65)
                .cancelledBookings(5)
                .bookingsByDay(List.of(
                        DashboardDto.TimeSeriesData.builder().label("Mon").count(15).build(),
                        DashboardDto.TimeSeriesData.builder().label("Tue").count(20).build(),
                        DashboardDto.TimeSeriesData.builder().label("Wed").count(18).build(),
                        DashboardDto.TimeSeriesData.builder().label("Thu").count(22).build(),
                        DashboardDto.TimeSeriesData.builder().label("Fri").count(25).build()))
                .topDoctors(List.of(
                        DashboardDto.DoctorStats.builder()
                                .doctorId("1")
                                .doctorName("Dr. Nguyễn Văn A")
                                .specialty("Nội khoa")
                                .totalBookings(50)
                                .completedBookings(45)
                                .rating(4.8)
                                .build()))
                .popularServices(List.of(
                        DashboardDto.ServiceStats.builder()
                                .serviceId("1")
                                .serviceName("Khám tổng quát")
                                .bookingCount(40)
                                .percentage(40.0)
                                .build(),
                        DashboardDto.ServiceStats.builder()
                                .serviceId("2")
                                .serviceName("Tư vấn dinh dưỡng")
                                .bookingCount(30)
                                .percentage(30.0)
                                .build()))
                .build();

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
