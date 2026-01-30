package com.medibook.user.controller;

import com.medibook.common.dto.ApiResponse;
import com.medibook.user.dto.MedicalServiceDto;
import com.medibook.user.entity.MedicalService;
import com.medibook.user.repository.MedicalServiceRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Medical Service Controller - API endpoints cho dịch vụ khám
 */
@RestController
@RequestMapping("/services")
@RequiredArgsConstructor
@Tag(name = "Medical Services", description = "API quản lý dịch vụ khám")
public class MedicalServiceController {

    private final MedicalServiceRepository medicalServiceRepository;

    @GetMapping
    @Operation(summary = "Lấy danh sách tất cả dịch vụ")
    public ResponseEntity<ApiResponse<List<MedicalServiceDto>>> getAllServices(
            @RequestParam(required = false, defaultValue = "false") boolean includeInactive) {
        List<MedicalService> services;
        if (includeInactive) {
            services = medicalServiceRepository.findAll();
        } else {
            services = medicalServiceRepository.findByIsActiveTrue();
        }

        List<MedicalServiceDto> dtos = services.stream()
                .map(this::toDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(dtos));
    }

    @PostMapping
    @Operation(summary = "Tạo mới dịch vụ")
    public ResponseEntity<ApiResponse<MedicalServiceDto>> createService(@RequestBody MedicalServiceDto request) {
        MedicalService service = new MedicalService();
        service.setName(request.getName());
        service.setDescription(request.getDescription());
        service.setPrice(request.getPrice());
        service.setDurationMinutes(request.getDurationMinutes());
        service.setCategory(request.getCategory());
        service.setImageUrl(request.getImageUrl()); // Explicitly set imageUrl
        service.setIsActive(true);

        MedicalService saved = medicalServiceRepository.save(service);
        return ResponseEntity.ok(ApiResponse.success(toDto(saved)));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Cập nhật dịch vụ")
    public ResponseEntity<ApiResponse<MedicalServiceDto>> updateService(@PathVariable UUID id,
            @RequestBody MedicalServiceDto request) {
        return medicalServiceRepository.findById(id)
                .map(service -> {
                    service.setName(request.getName());
                    service.setDescription(request.getDescription());
                    service.setPrice(request.getPrice());
                    service.setDurationMinutes(request.getDurationMinutes());
                    service.setCategory(request.getCategory());
                    service.setImageUrl(request.getImageUrl());
                    if (request.getIsActive() != null) {
                        service.setIsActive(request.getIsActive());
                    }
                    return ResponseEntity.ok(ApiResponse.success(toDto(medicalServiceRepository.save(service))));
                })
                .orElse(ResponseEntity.ok(ApiResponse.error("Service not found")));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Xóa dịch vụ (Soft delete)")
    public ResponseEntity<ApiResponse<Void>> deleteService(@PathVariable UUID id) {
        return medicalServiceRepository.findById(id)
                .map(service -> {
                    service.setIsActive(false);
                    medicalServiceRepository.save(service);
                    return ResponseEntity.ok(ApiResponse.<Void>success(null));
                })
                .orElse(ResponseEntity.ok(ApiResponse.error("Service not found")));
    }

    @PatchMapping("/{id}/toggle-active")
    @Operation(summary = "Kích hoạt/Vô hiệu hóa dịch vụ")
    public ResponseEntity<ApiResponse<MedicalServiceDto>> toggleActive(@PathVariable UUID id) {
        return medicalServiceRepository.findById(id)
                .map(service -> {
                    service.setIsActive(!Boolean.TRUE.equals(service.getIsActive()));
                    return ResponseEntity.ok(ApiResponse.success(toDto(medicalServiceRepository.save(service))));
                })
                .orElse(ResponseEntity.ok(ApiResponse.error("Service not found")));
    }

    private MedicalServiceDto toDto(MedicalService entity) {
        return MedicalServiceDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .description(entity.getDescription())
                .price(entity.getPrice())
                .durationMinutes(entity.getDurationMinutes())
                .category(entity.getCategory())
                .isActive(entity.getIsActive())
                .imageUrl(entity.getImageUrl())
                .build();
    }
}
