package com.medibook.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SocialLoginRequest {
    @Email(message = "Email không hợp lệ")
    @NotBlank(message = "Email không được để trống")
    private String email;

    private String name;

    private String avatar;

    @NotBlank(message = "Provider không được để trống")
    private String provider; // "google" or "facebook"

    private String token; // ID Token (Google) or Access Token (Facebook)
}
