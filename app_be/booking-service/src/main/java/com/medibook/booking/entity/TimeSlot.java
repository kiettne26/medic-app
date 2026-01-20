package com.medibook.booking.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

/**
 * TimeSlot entity - Khung giờ khám của bác sĩ
 * Đây là entity quan trọng cho việc đặt lịch với pessimistic lock
 */
@Entity
@Table(name = "time_slots", indexes = {
        @Index(name = "idx_time_slots_doctor_date", columnList = "doctor_id, date"),
        @Index(name = "idx_time_slots_available", columnList = "is_available")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TimeSlot {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "doctor_id", nullable = false)
    private UUID doctorId;

    @Column(name = "schedule_id")
    private UUID scheduleId;

    @Column(nullable = false)
    private LocalDate date;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime;

    @Column(name = "is_available", nullable = false)
    @Builder.Default
    private Boolean isAvailable = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private java.time.LocalDateTime createdAt;

    @Version
    private Long version; // Optimistic locking fallback
}
