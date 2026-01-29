package com.medibook.analytics.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

/**
 * MedicalService entity - Dịch vụ y tế (Read-only)
 */
@Entity
@Table(name = "medical_services")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MedicalService {

    @Id
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column
    private Double price;

    @Column(name = "duration_minutes")
    private Integer durationMinutes;

    @Column
    private String category;
}
