package com.medibook.booking.dto;

import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.UUID;

/**
 * DTO cho request đặt lịch
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateBookingRequest {

    @NotNull(message = "Doctor ID không được để trống")
    private UUID doctorId;

    @NotNull(message = "Service ID không được để trống")
    private UUID serviceId;

    @NotNull(message = "Time Slot ID không được để trống")
    private UUID timeSlotId;

    private String notes; // Ghi chú của bệnh nhân
}
