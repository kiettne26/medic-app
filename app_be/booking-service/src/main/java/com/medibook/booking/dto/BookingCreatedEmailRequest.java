package com.medibook.booking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingCreatedEmailRequest {
    private UUID patientId;
    private UUID bookingId;
    private String patientEmail;
    private String patientName;
    private String doctorName;
    private String serviceName;
    private String date;
    private String startTime;
    private String endTime;
    private String notes;
}
