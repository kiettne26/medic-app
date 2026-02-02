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
    
    // ============== FILTER THEO NGÀY ==============
    
    // Đếm booking theo khoảng thời gian
    @Query(value = "SELECT COUNT(*) FROM bookings WHERE created_at >= :startDate AND created_at <= :endDate", nativeQuery = true)
    long countByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    // Đếm booking theo status và khoảng thời gian
    @Query(value = "SELECT COUNT(*) FROM bookings WHERE status = :status AND created_at >= :startDate AND created_at <= :endDate", nativeQuery = true)
    long countByStatusAndDateRange(@Param("status") String status, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    // Thống kê booking theo ngày trong khoảng thời gian
    @Query(value = "SELECT TO_CHAR(created_at, 'DD/MM') as label, COUNT(*) as count " +
           "FROM bookings " +
           "WHERE created_at >= :startDate AND created_at <= :endDate " +
           "GROUP BY DATE(created_at), TO_CHAR(created_at, 'DD/MM') " +
           "ORDER BY DATE(created_at)", nativeQuery = true)
    List<Object[]> countBookingsByDayInRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    // Thống kê booking theo tuần trong khoảng thời gian
    @Query(value = "SELECT 'W' || TO_CHAR(created_at, 'WW') as label, COUNT(*) as count " +
           "FROM bookings " +
           "WHERE created_at >= :startDate AND created_at <= :endDate " +
           "GROUP BY TO_CHAR(created_at, 'WW') " +
           "ORDER BY TO_CHAR(created_at, 'WW')", nativeQuery = true)
    List<Object[]> countBookingsByWeek(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    // Thống kê booking theo tháng trong khoảng thời gian
    @Query(value = "SELECT TO_CHAR(created_at, 'MM/YYYY') as label, COUNT(*) as count " +
           "FROM bookings " +
           "WHERE created_at >= :startDate AND created_at <= :endDate " +
           "GROUP BY TO_CHAR(created_at, 'MM/YYYY'), EXTRACT(MONTH FROM created_at) " +
           "ORDER BY EXTRACT(MONTH FROM created_at)", nativeQuery = true)
    List<Object[]> countBookingsByMonth(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    // Thống kê booking theo service trong khoảng thời gian
    @Query(value = "SELECT service_id, COUNT(*) as count " +
           "FROM bookings " +
           "WHERE created_at >= :startDate AND created_at <= :endDate " +
           "GROUP BY service_id " +
           "ORDER BY count DESC " +
           "LIMIT 5", nativeQuery = true)
    List<Object[]> countBookingsByServiceInRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    // Thống kê booking theo doctor trong khoảng thời gian (top N)
    @Query(value = "SELECT doctor_id, COUNT(*) as total, " +
           "SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) as completed " +
           "FROM bookings " +
           "WHERE created_at >= :startDate AND created_at <= :endDate " +
           "GROUP BY doctor_id " +
           "ORDER BY total DESC " +
           "LIMIT :limit", nativeQuery = true)
    List<Object[]> countBookingsByDoctorInRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate, @Param("limit") int limit);
    
    // ============== DOANH THU ==============
    
    // Tính tổng doanh thu từ bookings COMPLETED (không filter)
    @Query(value = "SELECT COALESCE(SUM(ms.price), 0) " +
           "FROM bookings b " +
           "JOIN medical_services ms ON b.service_id = ms.id " +
           "WHERE b.status = 'COMPLETED'", nativeQuery = true)
    long calculateTotalRevenue();
    
    // Tính tổng doanh thu theo khoảng thời gian
    @Query(value = "SELECT COALESCE(SUM(ms.price), 0) " +
           "FROM bookings b " +
           "JOIN medical_services ms ON b.service_id = ms.id " +
           "WHERE b.status = 'COMPLETED' " +
           "AND b.created_at >= :startDate AND b.created_at <= :endDate", nativeQuery = true)
    long calculateRevenueByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    // ============== QUERIES KHÔNG CÓ FILTER ==============
    
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
