package com.medibook.analytics.dto;

import lombok.*;

import java.util.List;
import java.util.Map;

/**
 * DTO cho Dashboard statistics
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardDto {

    // Tổng quan
    private long totalBookings;
    private long totalDoctors;
    private long totalPatients;
    private long todayBookings;

    // Theo trạng thái
    private long pendingBookings;
    private long confirmedBookings;
    private long completedBookings;
    private long cancelledBookings;

    // Thống kê theo thời gian (cho biểu đồ)
    private List<TimeSeriesData> bookingsByDay;
    private List<TimeSeriesData> bookingsByWeek;
    private List<TimeSeriesData> bookingsByMonth;

    // Top bác sĩ
    private List<DoctorStats> topDoctors;

    // Dịch vụ phổ biến
    private List<ServiceStats> popularServices;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TimeSeriesData {
        private String label; // Ngày/Tuần/Tháng
        private long count;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DoctorStats {
        private String doctorId;
        private String doctorName;
        private String specialty;
        private long totalBookings;
        private long completedBookings;
        private double rating;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ServiceStats {
        private String serviceId;
        private String serviceName;
        private long bookingCount;
        private double percentage;
    }
}
