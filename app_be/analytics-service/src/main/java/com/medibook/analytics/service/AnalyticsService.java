package com.medibook.analytics.service;

import com.medibook.analytics.dto.DashboardDto;
import com.medibook.analytics.entity.Doctor;
import com.medibook.analytics.entity.MedicalService;
import com.medibook.analytics.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

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
     * Lấy thống kê tổng quan cho Dashboard
     */
    public DashboardDto getDashboardStats() {
        log.info("Fetching dashboard statistics from database");

        try {
            // Đếm tổng số
            long totalPatients = profileRepository.count();
            long totalDoctors = doctorRepository.count();
            long totalBookings = bookingRepository.count();
            long todayBookings = 0;
            try {
                todayBookings = bookingRepository.countTodayBookings();
            } catch (Exception e) {
                log.warn("Error counting today bookings: {}", e.getMessage());
            }

            // Đếm theo trạng thái
            long pendingBookings = bookingRepository.countByStatus("PENDING");
            long confirmedBookings = bookingRepository.countByStatus("CONFIRMED");
            long completedBookings = bookingRepository.countByStatus("COMPLETED");
            long cancelledBookings = bookingRepository.countByStatus("CANCELLED");

            // Thống kê booking theo ngày
            List<DashboardDto.TimeSeriesData> bookingsByDay = getBookingsByDay();

            // Top doctors
            List<DashboardDto.DoctorStats> topDoctors = getTopDoctors();

            // Dịch vụ phổ biến
            List<DashboardDto.ServiceStats> popularServices = getPopularServices();

            return DashboardDto.builder()
                    .totalPatients(totalPatients)
                    .totalDoctors(totalDoctors)
                    .totalBookings(totalBookings)
                    .todayBookings(todayBookings)
                    .pendingBookings(pendingBookings)
                    .confirmedBookings(confirmedBookings)
                    .completedBookings(completedBookings)
                    .cancelledBookings(cancelledBookings)
                    .bookingsByDay(bookingsByDay)
                    .topDoctors(topDoctors)
                    .popularServices(popularServices)
                    .build();
        } catch (Exception e) {
            log.error("Error fetching dashboard stats: {}", e.getMessage(), e);
            // Return empty dashboard on error
            return DashboardDto.builder()
                    .totalPatients(0)
                    .totalDoctors(0)
                    .totalBookings(0)
                    .todayBookings(0)
                    .pendingBookings(0)
                    .confirmedBookings(0)
                    .completedBookings(0)
                    .cancelledBookings(0)
                    .bookingsByDay(new ArrayList<>())
                    .topDoctors(new ArrayList<>())
                    .popularServices(new ArrayList<>())
                    .build();
        }
    }

    /**
     * Thống kê booking theo ngày
     */
    private List<DashboardDto.TimeSeriesData> getBookingsByDay() {
        List<DashboardDto.TimeSeriesData> result = new ArrayList<>();
        try {
            List<Object[]> data = bookingRepository.countBookingsByDay();
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
     * Lấy top bác sĩ theo số booking
     */
    private List<DashboardDto.DoctorStats> getTopDoctors() {
        List<DashboardDto.DoctorStats> result = new ArrayList<>();
        try {
            List<Object[]> bookingData = bookingRepository.countBookingsByDoctor();
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
     * Lấy dịch vụ phổ biến
     */
    private List<DashboardDto.ServiceStats> getPopularServices() {
        List<DashboardDto.ServiceStats> result = new ArrayList<>();
        try {
            List<Object[]> data = bookingRepository.countBookingsByService();
            long totalBookings = bookingRepository.count();
            
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
                        .percentage(Math.round(percentage * 10.0) / 10.0) // Round to 1 decimal
                        .build());
            }
        } catch (Exception e) {
            log.warn("Error fetching popular services: {}", e.getMessage());
        }
        return result;
    }
}
