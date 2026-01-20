package com.medibook.user.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.UUID;

/**
 * Doctor Schedule entity - Lịch làm việc của bác sĩ
 */
@Entity
@Table(name = "doctor_schedules")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DoctorSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "doctor_id", nullable = false)
    private Doctor doctor;

    @Enumerated(EnumType.STRING)
    @Column(name = "day_of_week", nullable = false)
    private DayOfWeek dayOfWeek; // THỨ trong tuần

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime; // Giờ bắt đầu

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime; // Giờ kết thúc

    @Column(name = "slot_duration_minutes")
    @Builder.Default
    private Integer slotDurationMinutes = 30; // Thời lượng mỗi slot (phút)

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;
}
