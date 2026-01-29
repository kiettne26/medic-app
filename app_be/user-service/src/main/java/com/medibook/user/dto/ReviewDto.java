package com.medibook.user.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * DTO cho Review response
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReviewDto {
    private UUID id;
    private UUID bookingId;
    private UUID patientId;
    private UUID doctorId;
    private String patientName;
    private String patientAvatar;
    private Integer rating;
    private String comment;
    private String doctorReply;
    private LocalDateTime doctorReplyAt;
    private LocalDateTime createdAt;
}
