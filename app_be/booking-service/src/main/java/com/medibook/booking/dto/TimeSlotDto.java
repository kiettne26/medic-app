package com.medibook.booking.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.medibook.common.enums.SlotStatus;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

/**
 * DTO cho TimeSlot response
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TimeSlotDto {
    private UUID id;
    private UUID doctorId;
    
    // Thông tin bác sĩ (để hiển thị trên Admin)
    private String doctorName;
    private String doctorAvatar;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;

    @JsonFormat(pattern = "HH:mm:ss")
    private LocalTime startTime;

    @JsonFormat(pattern = "HH:mm:ss")
    private LocalTime endTime;

    private Boolean isAvailable;

    @Builder.Default
    private SlotStatus status = SlotStatus.PENDING;
}
