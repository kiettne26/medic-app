package com.medibook.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

/**
 * DTO cho Admin tạo tài khoản bác sĩ (User + Doctor profile)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateDoctorAccountRequest {

    // ===== Thông tin đăng nhập =====
    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không hợp lệ")
    private String email;

    @NotBlank(message = "Mật khẩu không được để trống")
    @Size(min = 6, message = "Mật khẩu phải có ít nhất 6 ký tự")
    private String password;

    // ===== Thông tin bác sĩ =====
    @NotBlank(message = "Họ tên không được để trống")
    private String fullName;

    @NotBlank(message = "Chuyên khoa không được để trống")
    private String specialty;

    private String phone;
    private String description;
    private String avatarUrl;
    private Boolean isAvailable;
    private List<UUID> serviceIds;
}
