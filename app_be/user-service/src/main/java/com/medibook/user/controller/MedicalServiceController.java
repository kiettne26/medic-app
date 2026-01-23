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
    public ResponseEntity<ApiResponse<List<MedicalServiceDto>>> getAllServices() {
        List<MedicalServiceDto> services = medicalServiceRepository.findByIsActiveTrue()
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(services));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Lấy chi tiết một dịch vụ")
    public ResponseEntity<ApiResponse<MedicalServiceDto>> getServiceById(@PathVariable UUID id) {
        return medicalServiceRepository.findById(id)
                .map(service -> ResponseEntity.ok(ApiResponse.success(toDto(service))))
                .orElse(ResponseEntity.ok(ApiResponse.error("Service not found")));
    }

    @GetMapping("/category/{category}")
    @Operation(summary = "Lấy dịch vụ theo danh mục")
    public ResponseEntity<ApiResponse<List<MedicalServiceDto>>> getServicesByCategory(@PathVariable String category) {
        List<MedicalServiceDto> services = medicalServiceRepository.findByCategoryAndIsActiveTrue(category)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(services));
    }

    private MedicalServiceDto toDto(MedicalService entity) {
        return MedicalServiceDto.builder()
                .id(entity.getId())
                .name(entity.getName())
                .description(entity.getDescription())
                .price(entity.getPrice())
                .durationMinutes(entity.getDurationMinutes())
                .category(entity.getCategory())
                .imageUrl(entity.getImageUrl())
                .build();
    }
}
