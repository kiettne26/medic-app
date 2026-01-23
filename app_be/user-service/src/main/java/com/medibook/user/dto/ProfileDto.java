package com.medibook.user.dto;

import lombok.*;
import java.time.LocalDate;
import java.util.UUID;

/**
 * DTO cho Profile
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProfileDto {
    private UUID id;
    private UUID userId;
    private String fullName;
    private String phone;
    private String avatarUrl;
    private String address;
    private String gender;
    private LocalDate dob;
}
