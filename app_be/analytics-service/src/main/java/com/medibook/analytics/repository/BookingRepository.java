package com.medibook.analytics.repository;

import com.medibook.analytics.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Repository cho Booking - chỉ đọc dữ liệu để thống kê
 */
@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {
    
    // Đếm theo status
    long countByStatus(String status);
    
    // Đếm booking hôm nay (native query để tránh lỗi type)
    @Query(value = "SELECT COUNT(*) FROM bookings WHERE DATE(created_at) = CURRENT_DATE", nativeQuery = true)
    long countTodayBookings();
    
    // Đếm booking theo doctor
    long countByDoctorId(UUID doctorId);
    
    // Đếm booking hoàn thành theo doctor
    long countByDoctorIdAndStatus(UUID doctorId, String status);
    
    // Thống kê booking theo ngày (7 ngày gần nhất)
    @Query(value = "SELECT TO_CHAR(created_at, 'Dy') as label, COUNT(*) as count " +
           "FROM bookings " +
           "WHERE created_at >= CURRENT_DATE - INTERVAL '7 days' " +
           "GROUP BY DATE(created_at), TO_CHAR(created_at, 'Dy') " +
           "ORDER BY DATE(created_at)", nativeQuery = true)
    List<Object[]> countBookingsByDay();
    
    // Thống kê booking theo service
    @Query(value = "SELECT service_id, COUNT(*) as count " +
           "FROM bookings " +
           "GROUP BY service_id " +
           "ORDER BY count DESC " +
           "LIMIT 5", nativeQuery = true)
    List<Object[]> countBookingsByService();
    
    // Thống kê booking theo doctor (top 10)
    @Query(value = "SELECT doctor_id, COUNT(*) as total, " +
           "SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) as completed " +
           "FROM bookings " +
           "GROUP BY doctor_id " +
           "ORDER BY total DESC " +
           "LIMIT 10", nativeQuery = true)
    List<Object[]> countBookingsByDoctor();
}
