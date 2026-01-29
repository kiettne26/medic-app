package com.medibook.analytics.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Doctor entity - Thông tin bác sĩ (Read-only)
 */
@Entity
@Table(name = "doctors")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Doctor {

    @Id
    private UUID id;

    @Column(name = "user_id", nullable = false, unique = true)
    private UUID userId;

    @Column(nullable = false)
    private String specialty;

    @Column(name = "full_name")
    private String fullName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column
    private String phone;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column
    private Double rating;

    @Column(name = "total_reviews")
    private Integer totalReviews;

    @Column(name = "is_available")
    private Boolean isAvailable;

    @Column(name = "consultation_fee")
    private Double consultationFee;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
