package com.medibook.booking.repository;

import com.medibook.booking.entity.TimeSlot;
import com.medibook.common.enums.SlotStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * TimeSlot Repository với Pessimistic Lock cho việc chống double booking
 */
@Repository
public interface TimeSlotRepository extends JpaRepository<TimeSlot, UUID> {

    /**
     * PESSIMISTIC LOCK
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT t FROM TimeSlot t WHERE t.id = :id")
    Optional<TimeSlot> findByIdWithLock(@Param("id") UUID id);

    /**
     * Lấy tất cả slot trống của bác sĩ trong ngày
     */
    @Query("SELECT t FROM TimeSlot t WHERE t.doctorId = :doctorId AND t.date = :date AND t.isAvailable = true ORDER BY t.startTime")
    List<TimeSlot> findAvailableSlotsByDoctorAndDate(@Param("doctorId") UUID doctorId, @Param("date") LocalDate date);

    /**
     * Lấy tất cả slot của bác sĩ trong khoảng ngày
     */
    @Query("SELECT t FROM TimeSlot t WHERE t.doctorId = :doctorId AND t.date BETWEEN :startDate AND :endDate ORDER BY t.date, t.startTime")
    List<TimeSlot> findByDoctorIdAndDateBetween(@Param("doctorId") UUID doctorId,
            @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    /**
     * Kiểm tra slot có tồn tại và available không
     */
    boolean existsByIdAndIsAvailableTrue(UUID id);

    /**
     * Đếm số slot trống của bác sĩ trong ngày
     */
    @Query("SELECT COUNT(t) FROM TimeSlot t WHERE t.doctorId = :doctorId AND t.date = :date AND t.isAvailable = true")
    long countAvailableSlots(@Param("doctorId") UUID doctorId, @Param("date") LocalDate date);

    /**
     * Lấy slots theo trạng thái (Admin)
     */
    List<TimeSlot> findByStatus(SlotStatus status);

    /**
     * Lấy slots ĐÃ DUYỆT của bác sĩ - dùng cho bệnh nhân
     */
    @Query("SELECT t FROM TimeSlot t WHERE t.doctorId = :doctorId AND t.date = :date " +
            "AND t.isAvailable = true AND t.status = 'APPROVED' ORDER BY t.startTime")
    List<TimeSlot> findApprovedAvailableSlotsByDoctorAndDate(@Param("doctorId") UUID doctorId,
            @Param("date") LocalDate date);
}
