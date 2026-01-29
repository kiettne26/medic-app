package com.medibook.analytics.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Profile entity - Hồ sơ người dùng (Read-only)
 */
@Entity
@Table(name = "profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Profile {

    @Id
    private UUID id;

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "full_name")
    private String fullName;

    @Column
    private String phone;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column
    private String address;

    @Column
    private String gender;

    @Column
    private LocalDate dob;
}
