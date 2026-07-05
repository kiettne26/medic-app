package com.medibook.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * Response sau khi tạo tài khoản bác sĩ
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateDoctorAccountResponse {
    private UUID userId;
    private UUID doctorId;
    private String email;
    private String fullName;
    private String specialty;
    private String message;
}
