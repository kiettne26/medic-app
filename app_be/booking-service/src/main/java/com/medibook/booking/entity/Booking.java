package com.medibook.booking.entity;

import com.medibook.common.enums.BookingStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Booking entity - Lịch đặt khám
 */
@Entity
@Table(name = "bookings", indexes = {
        @Index(name = "idx_bookings_patient", columnList = "patient_id"),
        @Index(name = "idx_bookings_doctor", columnList = "doctor_id"),
        @Index(name = "idx_bookings_status", columnList = "status")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "patient_id", nullable = false)
    private UUID patientId;

    @Column(name = "doctor_id", nullable = false)
    private UUID doctorId;

    @Column(name = "service_id", nullable = false)
    private UUID serviceId;

    @OneToOne
    @JoinColumn(name = "time_slot_id", nullable = false)
    private TimeSlot timeSlot;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private BookingStatus status = BookingStatus.PENDING;

    @Column(columnDefinition = "TEXT")
    private String notes; // Ghi chú của bệnh nhân

    @Column(name = "doctor_notes", columnDefinition = "TEXT")
    private String doctorNotes; // Ghi chú của bác sĩ

    @Column(name = "cancellation_reason")
    private String cancellationReason;

    @Column(name = "cancelled_by")
    private UUID cancelledBy;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
