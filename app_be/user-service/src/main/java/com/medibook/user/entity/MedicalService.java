package com.medibook.user.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Medical Service entity - Dịch vụ khám
 */
@Entity
@Table(name = "medical_services")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MedicalService {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name; // Tên dịch vụ

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column
    private Double price; // Giá dịch vụ

    @Column(name = "duration_minutes")
    private Integer durationMinutes; // Thời lượng (phút)

    @Column
    private String category; // Danh mục: GENERAL, NUTRITION, PSYCHOLOGY

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "image_url")
    private String imageUrl;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
