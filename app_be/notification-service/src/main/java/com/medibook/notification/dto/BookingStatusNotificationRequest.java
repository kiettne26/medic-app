package com.medibook.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingStatusNotificationRequest {
    private UUID patientId;
    private UUID bookingId;
    private String doctorName;
    private String date;
    private String startTime;
    private String endTime;
    private String reason;
}
