package com.medibook.booking.repository;

import com.medibook.booking.entity.Booking;
import com.medibook.common.enums.BookingStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {

    /**
     * Lấy booking của patient
     */
    Page<Booking> findByPatientIdOrderByCreatedAtDesc(UUID patientId, Pageable pageable);

    /**
     * Lấy booking của doctor
     */
    Page<Booking> findByDoctorIdOrderByCreatedAtDesc(UUID doctorId, Pageable pageable);

    /**
     * Lấy booking theo status có phân trang
     */
    Page<Booking> findByStatusOrderByCreatedAtDesc(BookingStatus status, Pageable pageable);

    /**
     * Lấy booking theo status (List)
     */
    List<Booking> findByStatus(BookingStatus status);

    /**
     * Lấy booking của doctor trong ngày
     */
    @Query("SELECT b FROM Booking b WHERE b.doctorId = :doctorId AND b.timeSlot.date = :date ORDER BY b.timeSlot.startTime")
    List<Booking> findByDoctorIdAndDate(@Param("doctorId") UUID doctorId, @Param("date") LocalDate date);

    /**
     * Lấy booking của patient theo status
     */
    List<Booking> findByPatientIdAndStatusOrderByCreatedAtDesc(UUID patientId, BookingStatus status);

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
}
