package com.medibook.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.List;
import java.util.UUID;

/**
 * DTO cho tạo/cập nhật Doctor
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateDoctorRequest {

    @NotNull(message = "User ID không được để trống")
    private UUID userId;

    @NotBlank(message = "Chuyên khoa không được để trống")
    private String specialty;

    private String description;
    private String phone;
    private String avatarUrl;
    private Double consultationFee;
    private List<UUID> serviceIds;
}
