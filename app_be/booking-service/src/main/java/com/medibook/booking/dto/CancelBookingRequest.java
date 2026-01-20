package com.medibook.booking.dto;

import lombok.*;

import java.util.UUID;

/**
 * DTO cho request hủy booking
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CancelBookingRequest {
    private String reason;
}
