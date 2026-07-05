package com.medibook.booking.dto;

import com.medibook.common.enums.BookingStatus;
import com.medibook.common.enums.PaymentMethod;
import com.medibook.common.enums.PaymentStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

/**
 * DTO cho Booking response
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingDto {
    private UUID id;
    private UUID patientId;
    private UUID doctorId;
    private UUID serviceId;
    private TimeSlotDto timeSlot;
    private BookingStatus status;
    private String notes;
    private String doctorNotes;
    private String cancellationReason;
    private String patientName;
    private String patientAvatar;
    private String doctorName;
    private String doctorAvatar;
    private String serviceName;
    private BigDecimal totalAmount;
    private PaymentStatus paymentStatus;
    private PaymentMethod paymentMethod;
    private String paymentReference;
    private LocalDateTime paidAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TimeSlotDto {
        private UUID id;
        private LocalDate date;
        private LocalTime startTime;
        private LocalTime endTime;
    }
}
