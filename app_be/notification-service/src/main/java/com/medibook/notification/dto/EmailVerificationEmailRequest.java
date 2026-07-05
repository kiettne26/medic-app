package com.medibook.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmailVerificationEmailRequest {
    private String to;
    private String code;
    private Integer expiresInMinutes;
}
