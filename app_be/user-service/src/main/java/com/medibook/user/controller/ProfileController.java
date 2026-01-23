package com.medibook.user.controller;

import com.medibook.common.dto.ApiResponse;
import com.medibook.user.dto.ProfileDto;
import com.medibook.user.dto.UpdateProfileRequest;
import com.medibook.user.service.ProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * Profile Controller - API endpoints cho hồ sơ người dùng
 */
@RestController
@RequestMapping("/profiles")
@RequiredArgsConstructor
@Tag(name = "Profiles", description = "API quản lý hồ sơ")
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/user/{userId}")
    @Operation(summary = "Lấy profile theo user ID")
    public ResponseEntity<ApiResponse<ProfileDto>> getProfileByUserId(@PathVariable UUID userId) {
        return profileService.getProfileByUserId(userId)
                .map(profile -> ResponseEntity.ok(ApiResponse.success(profile)))
                .orElse(ResponseEntity.ok(ApiResponse.success(null)));
    }

    @PutMapping("/user/{userId}")
    @Operation(summary = "Cập nhật profile")
    public ResponseEntity<ApiResponse<ProfileDto>> updateProfile(
            @PathVariable UUID userId,
            @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(ApiResponse.success(profileService.updateProfile(userId, request)));
    }
}
