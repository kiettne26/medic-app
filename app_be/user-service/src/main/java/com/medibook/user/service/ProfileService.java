package com.medibook.user.service;

import com.medibook.user.dto.ProfileDto;
import com.medibook.user.dto.UpdateProfileRequest;
import com.medibook.user.entity.Profile;
import com.medibook.user.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

/**
 * Profile Service - Quản lý hồ sơ người dùng
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepository profileRepository;

    /**
     * Lấy profile theo user ID
     */
    public Optional<ProfileDto> getProfileByUserId(UUID userId) {
        return profileRepository.findByUserId(userId)
                .map(this::toDto);
    }

    /**
     * Cập nhật profile
     */
    @Transactional
    public ProfileDto updateProfile(UUID userId, UpdateProfileRequest request) {
        Profile profile = profileRepository.findByUserId(userId)
                .orElseGet(() -> Profile.builder().userId(userId).build());

        if (request.getFullName() != null) {
            profile.setFullName(request.getFullName());
        }
        if (request.getPhone() != null) {
            profile.setPhone(request.getPhone());
        }
        if (request.getAvatarUrl() != null) {
            profile.setAvatarUrl(request.getAvatarUrl());
        }
        if (request.getAddress() != null) {
            profile.setAddress(request.getAddress());
        }

        // Handle gender as String directly
        if (request.getGender() != null) {
            profile.setGender(request.getGender());
        }

        if (request.getDob() != null) {
            profile.setDob(request.getDob());
        }

        profile = profileRepository.save(profile);
        log.info("Profile updated for user: {}", userId);
        return toDto(profile);
    }

    /**
     * Convert entity to DTO with error handling
     */
    private ProfileDto toDto(Profile profile) {
        try {
            return ProfileDto.builder()
                    .id(profile.getId())
                    .userId(profile.getUserId())
                    .fullName(profile.getFullName())
                    .phone(profile.getPhone())
                    .avatarUrl(profile.getAvatarUrl())
                    .address(profile.getAddress())
                    // Gender is now String, no need to call .name()
                    .gender(profile.getGender())
                    .dob(profile.getDob())
                    .build();
        } catch (Exception e) {
            log.error("Error converting profile to DTO: {}", e.getMessage());
            // Safe fallback
            return ProfileDto.builder()
                    .id(profile.getId())
                    .userId(profile.getUserId())
                    .build();
        }
    }
}
