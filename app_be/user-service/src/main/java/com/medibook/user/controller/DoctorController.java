package com.medibook.user.controller;

import com.medibook.common.dto.ApiResponse;
import com.medibook.user.dto.CreateDoctorRequest;
import com.medibook.user.dto.DoctorDto;
import com.medibook.user.service.DoctorService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * Doctor Controller - API endpoints cho bác sĩ
 */
@RestController
@RequestMapping("/doctors")
@RequiredArgsConstructor
@Tag(name = "Doctors", description = "API quản lý bác sĩ")
public class DoctorController {

    private final DoctorService doctorService;

    @GetMapping
    @Operation(summary = "Lấy danh sách tất cả bác sĩ")
    public ResponseEntity<ApiResponse<List<DoctorDto>>> getAllDoctors() {
        return ResponseEntity.ok(ApiResponse.success(doctorService.getAllDoctors()));
    }

    @GetMapping("/available")
    @Operation(summary = "Lấy danh sách bác sĩ đang available")
    public ResponseEntity<ApiResponse<List<DoctorDto>>> getAvailableDoctors() {
        return ResponseEntity.ok(ApiResponse.success(doctorService.getAvailableDoctors()));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Lấy thông tin bác sĩ theo ID")
    public ResponseEntity<ApiResponse<DoctorDto>> getDoctorById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success(doctorService.getDoctorById(id)));
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Lấy thông tin bác sĩ theo User ID")
    public ResponseEntity<ApiResponse<DoctorDto>> getDoctorByUserId(@PathVariable UUID userId) {
        return doctorService.getDoctorByUserId(userId)
                .map(doctor -> ResponseEntity.ok(ApiResponse.success(doctor)))
                .orElse(ResponseEntity.ok(ApiResponse.success(null)));
    }

    @GetMapping("/specialty/{specialty}")
    @Operation(summary = "Lấy bác sĩ theo chuyên khoa")
    public ResponseEntity<ApiResponse<List<DoctorDto>>> getDoctorsBySpecialty(@PathVariable String specialty) {
        return ResponseEntity.ok(ApiResponse.success(doctorService.getDoctorsBySpecialty(specialty)));
    }

    @GetMapping("/service/{serviceId}")
    @Operation(summary = "Lấy bác sĩ theo dịch vụ")
    public ResponseEntity<ApiResponse<List<DoctorDto>>> getDoctorsByService(@PathVariable UUID serviceId) {
        return ResponseEntity.ok(ApiResponse.success(doctorService.getDoctorsByService(serviceId)));
    }

    @PostMapping
    @Operation(summary = "Tạo bác sĩ mới (Admin)")
    public ResponseEntity<ApiResponse<DoctorDto>> createDoctor(@Valid @RequestBody CreateDoctorRequest request) {
        DoctorDto doctor = doctorService.createDoctor(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Tạo bác sĩ thành công", doctor));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Cập nhật bác sĩ (Admin)")
    public ResponseEntity<ApiResponse<DoctorDto>> updateDoctor(
            @PathVariable UUID id,
            @Valid @RequestBody CreateDoctorRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Cập nhật thành công", doctorService.updateDoctor(id, request)));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Xóa bác sĩ (Admin)")
    public ResponseEntity<ApiResponse<Void>> deleteDoctor(@PathVariable UUID id) {
        doctorService.deleteDoctor(id);
        return ResponseEntity.ok(ApiResponse.success("Xóa thành công", null));
    }
}
