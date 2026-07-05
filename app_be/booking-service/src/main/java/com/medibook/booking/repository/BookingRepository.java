package com.medibook.booking.repository;

import com.medibook.booking.entity.Booking;
import com.medibook.common.enums.BookingStatus;
import com.medibook.common.enums.PaymentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {

    /**
     * Override findAll để nạp sẵn timeSlot tránh N+1 select
     */
    @Override
    @EntityGraph(attributePaths = {"timeSlot"})
    Page<Booking> findAll(Pageable pageable);

    /**
     * Lấy booking của patient
     */
    @EntityGraph(attributePaths = {"timeSlot"})
    Page<Booking> findByPatientIdOrderByCreatedAtDesc(UUID patientId, Pageable pageable);

    /**
     * Lấy booking của doctor
     */
    @EntityGraph(attributePaths = {"timeSlot"})
    Page<Booking> findByDoctorIdOrderByCreatedAtDesc(UUID doctorId, Pageable pageable);

    /**
     * Lấy booking theo status có phân trang
     */
    @EntityGraph(attributePaths = {"timeSlot"})
    Page<Booking> findByStatusOrderByCreatedAtDesc(BookingStatus status, Pageable pageable);

    /**
     * Lấy booking theo status (List)
     */
    @EntityGraph(attributePaths = {"timeSlot"})
    List<Booking> findByStatus(BookingStatus status);

    /**
     * Lấy booking của doctor trong ngày
     */
    @Query("SELECT b FROM Booking b WHERE b.doctorId = :doctorId AND b.timeSlot.date = :date ORDER BY b.timeSlot.startTime")
    List<Booking> findByDoctorIdAndDate(@Param("doctorId") UUID doctorId, @Param("date") LocalDate date);

    /**
     * Lấy booking của patient theo status
     */
    @EntityGraph(attributePaths = {"timeSlot"})
    List<Booking> findByPatientIdAndStatusOrderByCreatedAtDesc(UUID patientId, BookingStatus status);

    Optional<Booking> findByPaymentReference(String paymentReference);

    @Query("""
            SELECT b FROM Booking b
            JOIN FETCH b.timeSlot
            WHERE b.status = :status
              AND b.paymentStatus <> :paidStatus
              AND b.createdAt < :expiresBefore
            """)
    List<Booking> findExpiredPaymentHolds(
            @Param("status") BookingStatus status,
            @Param("paidStatus") PaymentStatus paidStatus,
            @Param("expiresBefore") LocalDateTime expiresBefore);

    /**
     * Thống kê số booking theo status
     */
    @Query("SELECT b.status, COUNT(b) FROM Booking b GROUP BY b.status")
    List<Object[]> countByStatus();

    /**
     * Thống kê booking của doctor
     */
    @Query("SELECT COUNT(b) FROM Booking b WHERE b.doctorId = :doctorId AND b.status = :status")
    long countByDoctorIdAndStatus(@Param("doctorId") UUID doctorId, @Param("status") BookingStatus status);

    /**
     * Đếm số lượng booking trong ngày
     */
    @Query("SELECT COUNT(b) FROM Booking b WHERE b.timeSlot.date = :date")
    long countByDate(@Param("date") LocalDate date);
}

