package com.medibook.user.dto;

import lombok.*;

import java.util.UUID;

/**
 * DTO cho Medical Service response
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MedicalServiceDto {
    private UUID id;
    private String name;
    private String description;
    private Double price;
    private Integer durationMinutes;
    private String category;
    private Boolean isActive;
    private String imageUrl;
}
