package com.medibook.analytics.service;

import com.medibook.analytics.dto.DashboardDto;
import com.medibook.analytics.entity.Doctor;
import com.medibook.analytics.entity.MedicalService;
import com.medibook.analytics.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

/**
 * Service xử lý logic thống kê cho Dashboard
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AnalyticsService {

    private final ProfileRepository profileRepository;
    private final DoctorRepository doctorRepository;
    private final BookingRepository bookingRepository;
    private final MedicalServiceRepository medicalServiceRepository;

    /**
     * Lấy thống kê tổng quan cho Dashboard với filter theo ngày
     */
    public DashboardDto getDashboardStats(LocalDate startDate, LocalDate endDate) {
        log.info("Fetching dashboard statistics from database with date filter: {} to {}", startDate, endDate);

        try {
            // Xác định khoảng thời gian
            LocalDateTime startDateTime = startDate != null 
                ? startDate.atStartOfDay() 
                : null;
            LocalDateTime endDateTime = endDate != null 
                ? endDate.atTime(LocalTime.MAX) 
                : null;

            // Đếm tổng số (không filter theo ngày)
            long totalPatients = profileRepository.count();
            long totalDoctors = doctorRepository.count();
            
            // Đếm bookings theo khoảng thời gian
            long totalBookings;
            long todayBookings = 0;
            long pendingBookings;
            long confirmedBookings;
            long completedBookings;
            long cancelledBookings;

            if (startDateTime != null && endDateTime != null) {
                // Có filter theo ngày
                totalBookings = bookingRepository.countByDateRange(startDateTime, endDateTime);
                pendingBookings = bookingRepository.countByStatusAndDateRange("PENDING", startDateTime, endDateTime);
                confirmedBookings = bookingRepository.countByStatusAndDateRange("CONFIRMED", startDateTime, endDateTime);
                completedBookings = bookingRepository.countByStatusAndDateRange("COMPLETED", startDateTime, endDateTime);
                cancelledBookings = bookingRepository.countByStatusAndDateRange("CANCELLED", startDateTime, endDateTime);
            } else {
                // Không có filter - lấy tất cả
                totalBookings = bookingRepository.count();
                try {
                    todayBookings = bookingRepository.countTodayBookings();
                } catch (Exception e) {
                    log.warn("Error counting today bookings: {}", e.getMessage());
                }
                pendingBookings = bookingRepository.countByStatus("PENDING");
                confirmedBookings = bookingRepository.countByStatus("CONFIRMED");
                completedBookings = bookingRepository.countByStatus("COMPLETED");
                cancelledBookings = bookingRepository.countByStatus("CANCELLED");
            }

            // Tính tổng doanh thu từ giá dịch vụ của bookings COMPLETED
            long totalRevenue = 0;
            try {
                if (startDateTime != null && endDateTime != null) {
                    totalRevenue = bookingRepository.calculateRevenueByDateRange(startDateTime, endDateTime);
                } else {
                    totalRevenue = bookingRepository.calculateTotalRevenue();
                }
            } catch (Exception e) {
                log.warn("Error calculating revenue: {}", e.getMessage());
            }

            // Thống kê booking theo ngày
            List<DashboardDto.TimeSeriesData> bookingsByDay = getBookingsByDay(startDateTime, endDateTime);

            // Top doctors
            List<DashboardDto.DoctorStats> topDoctors = getTopDoctors(10, startDate, endDate);

            // Dịch vụ phổ biến
            List<DashboardDto.ServiceStats> popularServices = getPopularServices(startDateTime, endDateTime);

            return DashboardDto.builder()
                    .totalPatients(totalPatients)
                    .totalDoctors(totalDoctors)
                    .totalBookings(totalBookings)
                    .todayBookings(todayBookings)
                    .pendingBookings(pendingBookings)
                    .confirmedBookings(confirmedBookings)
                    .completedBookings(completedBookings)
                    .cancelledBookings(cancelledBookings)
                    .totalRevenue(totalRevenue)
                    .bookingsByDay(bookingsByDay)
                    .topDoctors(topDoctors)
                    .popularServices(popularServices)
                    .build();
        } catch (Exception e) {
            log.error("Error fetching dashboard stats: {}", e.getMessage(), e);
            return getEmptyDashboard();
        }
    }

    /**
     * Lấy thống kê tổng quan (không filter)
     */
    public DashboardDto getDashboardStats() {
        return getDashboardStats(null, null);
    }

    /**
     * Lấy bookings theo period với group by
     */
    public List<DashboardDto.TimeSeriesData> getBookingsByPeriod(LocalDate startDate, LocalDate endDate, String groupBy) {
        List<DashboardDto.TimeSeriesData> result = new ArrayList<>();
        try {
            LocalDateTime startDateTime = startDate.atStartOfDay();
            LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
            
            List<Object[]> data;
            switch (groupBy.toUpperCase()) {
                case "WEEK":
                    data = bookingRepository.countBookingsByWeek(startDateTime, endDateTime);
                    break;
                case "MONTH":
                    data = bookingRepository.countBookingsByMonth(startDateTime, endDateTime);
                    break;
                default: // DAY
                    data = bookingRepository.countBookingsByDayInRange(startDateTime, endDateTime);
                    break;
            }
            
            for (Object[] row : data) {
                result.add(DashboardDto.TimeSeriesData.builder()
                        .label(String.valueOf(row[0]))
                        .count(((Number) row[1]).longValue())
                        .build());
            }     
        } catch (Exception e) {
            log.warn("Error fetching bookings by period: {}", e.getMessage());
        }
        return result;
    }

    /**
     * Thống kê booking theo ngày
     */
    private List<DashboardDto.TimeSeriesData> getBookingsByDay(LocalDateTime startDateTime, LocalDateTime endDateTime) {
        List<DashboardDto.TimeSeriesData> result = new ArrayList<>();
        try {
            List<Object[]> data;
            if (startDateTime != null && endDateTime != null) {
                data = bookingRepository.countBookingsByDayInRange(startDateTime, endDateTime);
            } else {
                data = bookingRepository.countBookingsByDay();
            }
            
            for (Object[] row : data) {
                result.add(DashboardDto.TimeSeriesData.builder()
                        .label(String.valueOf(row[0]))
                        .count(((Number) row[1]).longValue())
                        .build());
            }
        } catch (Exception e) {
            log.warn("Error fetching bookings by day: {}", e.getMessage());
            // Return default data if query fails
            result.add(DashboardDto.TimeSeriesData.builder().label("Mon").count(0).build());
            result.add(DashboardDto.TimeSeriesData.builder().label("Tue").count(0).build());
            result.add(DashboardDto.TimeSeriesData.builder().label("Wed").count(0).build());
            result.add(DashboardDto.TimeSeriesData.builder().label("Thu").count(0).build());
            result.add(DashboardDto.TimeSeriesData.builder().label("Fri").count(0).build());
        }
        return result;
    }

    /**
     * Lấy top bác sĩ theo số booking với filter ngày
     */
    public List<DashboardDto.DoctorStats> getTopDoctors(int limit, LocalDate startDate, LocalDate endDate) {
        List<DashboardDto.DoctorStats> result = new ArrayList<>();
        try {
            List<Object[]> bookingData;
            
            if (startDate != null && endDate != null) {
                LocalDateTime startDateTime = startDate.atStartOfDay();
                LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);
                bookingData = bookingRepository.countBookingsByDoctorInRange(startDateTime, endDateTime, limit);
            } else {
                bookingData = bookingRepository.countBookingsByDoctor();
            }
            
            Map<UUID, long[]> bookingMap = new HashMap<>();
            for (Object[] row : bookingData) {
                UUID doctorId = (UUID) row[0];
                long total = ((Number) row[1]).longValue();
                long completed = ((Number) row[2]).longValue();
                bookingMap.put(doctorId, new long[]{total, completed});
            }

            // Lấy thông tin doctor
            List<Doctor> doctors = doctorRepository.findTop10ByOrderByRatingDesc();
            for (Doctor doctor : doctors) {
                long[] counts = bookingMap.getOrDefault(doctor.getId(), new long[]{0, 0});
                result.add(DashboardDto.DoctorStats.builder()
                        .doctorId(doctor.getId().toString())
                        .doctorName(doctor.getFullName() != null ? doctor.getFullName() : "Bác sĩ")
                        .specialty(doctor.getSpecialty())
                        .totalBookings(counts[0])
                        .completedBookings(counts[1])
                        .rating(doctor.getRating() != null ? doctor.getRating() : 0.0)
                        .build());
            }
        } catch (Exception e) {
            log.warn("Error fetching top doctors: {}", e.getMessage());
        }
        return result;
    }

    /**
     * Lấy dịch vụ phổ biến với filter ngày
     */
    private List<DashboardDto.ServiceStats> getPopularServices(LocalDateTime startDateTime, LocalDateTime endDateTime) {
        List<DashboardDto.ServiceStats> result = new ArrayList<>();
        try {
            List<Object[]> data;
            long totalBookings;
            
            if (startDateTime != null && endDateTime != null) {
                data = bookingRepository.countBookingsByServiceInRange(startDateTime, endDateTime);
                totalBookings = bookingRepository.countByDateRange(startDateTime, endDateTime);
            } else {
                data = bookingRepository.countBookingsByService();
                totalBookings = bookingRepository.count();
            }
            
            for (Object[] row : data) {
                UUID serviceId = (UUID) row[0];
                long count = ((Number) row[1]).longValue();
                
                // Lấy tên service
                MedicalService service = medicalServiceRepository.findById(serviceId).orElse(null);
                String serviceName = service != null ? service.getName() : "Dịch vụ khác";
                
                double percentage = totalBookings > 0 ? (count * 100.0 / totalBookings) : 0;
                
                result.add(DashboardDto.ServiceStats.builder()
                        .serviceId(serviceId.toString())
                        .serviceName(serviceName)
                        .bookingCount(count)
                        .percentage(Math.round(percentage * 10.0) / 10.0)
                        .build());
            }
        } catch (Exception e) {
            log.warn("Error fetching popular services: {}", e.getMessage());
        }
        return result;
    }

    /**
     * Trả về dashboard rỗng khi có lỗi
     */
    private DashboardDto getEmptyDashboard() {
        return DashboardDto.builder()
                .totalPatients(0)
                .totalDoctors(0)
                .totalBookings(0)
                .todayBookings(0)
                .pendingBookings(0)
                .confirmedBookings(0)
                .completedBookings(0)
                .cancelledBookings(0)
                .totalRevenue(0)
                .bookingsByDay(new ArrayList<>())
                .topDoctors(new ArrayList<>())
                .popularServices(new ArrayList<>())
                .build();
    }
}
