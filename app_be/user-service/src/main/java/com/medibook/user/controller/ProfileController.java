package com.medibook.user.controller;

import com.medibook.common.dto.ApiResponse;
import com.medibook.common.dto.PageResponse;
import com.medibook.user.dto.ProfileDto;
import com.medibook.user.dto.UpdateProfileRequest;
import com.medibook.user.service.ProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
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

    // ===================== ADMIN ENDPOINTS =====================

    @GetMapping("/admin/patients")
    @Operation(summary = "Lấy danh sách tất cả bệnh nhân (Admin)")
    public ResponseEntity<ApiResponse<PageResponse<ProfileDto>>> getAllPatients(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search) {
        Page<ProfileDto> patients = profileService.getAllPatients(PageRequest.of(page, size), search);
        return ResponseEntity.ok(ApiResponse.success(
            PageResponse.of(patients.getContent(), patients.getNumber(), patients.getSize(), patients.getTotalElements())
        ));
    }

    @GetMapping("/admin/patients/all")
    @Operation(summary = "Lấy tất cả bệnh nhân không phân trang (Admin)")
    public ResponseEntity<ApiResponse<List<ProfileDto>>> getAllPatientsNoPaging(
            @RequestParam(required = false) String search) {
        List<ProfileDto> patients = profileService.getAllPatientsNoPaging(search);
        return ResponseEntity.ok(ApiResponse.success(patients));
    }

    @DeleteMapping("/admin/patients/{userId}")
    @Operation(summary = "Xóa bệnh nhân (Admin)")
    public ResponseEntity<ApiResponse<Void>> deletePatient(@PathVariable UUID userId) {
        profileService.deletePatient(userId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
