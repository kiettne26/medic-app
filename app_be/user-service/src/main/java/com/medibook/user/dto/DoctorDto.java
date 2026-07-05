package com.medibook.user.dto;

import lombok.*;

import java.util.List;
import java.util.UUID;

/**
 * DTO cho Doctor response
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DoctorDto {
    private UUID id;
    private UUID userId;
    private String fullName;
    private String specialty;
    private String description;
    private String phone;
    private String avatarUrl;
    private Double rating;
    private Integer totalReviews;
    private Boolean isAvailable;
    private Double consultationFee;
    private List<MedicalServiceDto> services;
}
