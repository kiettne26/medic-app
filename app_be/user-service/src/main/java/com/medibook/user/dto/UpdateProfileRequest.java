package com.medibook.user.dto;

import lombok.*;
import java.time.LocalDate;

/**
 * DTO cho cập nhật Profile
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProfileRequest {
    private String fullName;
    private String phone;
    private String avatarUrl;
    private String address;
    private String gender;
    private LocalDate dob;
}
