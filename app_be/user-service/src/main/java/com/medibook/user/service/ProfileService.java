package com.medibook.user.service;

import com.medibook.user.dto.ProfileDto;
import com.medibook.user.dto.UpdateProfileRequest;
import com.medibook.user.entity.Doctor;
import com.medibook.user.entity.Profile;
import com.medibook.user.repository.DoctorRepository;
import com.medibook.user.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Profile Service - Quản lý hồ sơ người dùng
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepository profileRepository;
    private final DoctorRepository doctorRepository;

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
        log.info("Updating profile for userId: {}, Phone: {}", userId, request.getPhone());

        Optional<Profile> existingProfileOpt = profileRepository.findByUserId(userId);
        Profile profile;
        if (existingProfileOpt.isPresent()) {
            profile = existingProfileOpt.get();
            log.info("Found existing profile with ID: {}", profile.getId());
        } else {
            log.info("Profile not found for userId: {}. Creates NEW one.", userId);
            profile = Profile.builder().userId(userId).build();
        }

        // Check Unique Phone
        if (request.getPhone() != null) {
            Optional<Profile> existingPhone = profileRepository.findByPhone(request.getPhone());
            if (existingPhone.isPresent() && !existingPhone.get().getUserId().equals(userId)) {
                // Phone belongs to another user
                throw new com.medibook.common.exception.BadRequestException(
                        "Số điện thoại đã được sử dụng bởi tài khoản khác.");
            }
            profile.setPhone(request.getPhone());
        }

        if (request.getFullName() != null) {
            profile.setFullName(request.getFullName());
        }

        if (request.getAvatarUrl() != null) {
            profile.setAvatarUrl(request.getAvatarUrl());
        }
        if (request.getAddress() != null) {
            profile.setAddress(request.getAddress());
        }

        // Handle gender mapping (VN -> EN Enum)
        if (request.getGender() != null) {
            String genderInput = request.getGender();
            String genderDbValue;
            if ("Nam".equalsIgnoreCase(genderInput) || "Male".equalsIgnoreCase(genderInput)) {
                genderDbValue = "MALE";
            } else if ("Nữ".equalsIgnoreCase(genderInput) || "Nu".equalsIgnoreCase(genderInput)
                    || "Female".equalsIgnoreCase(genderInput)) {
                genderDbValue = "FEMALE";
            } else {
                genderDbValue = "OTHER";
            }
            profile.setGender(genderDbValue);
        }

        if (request.getDob() != null) {
            profile.setDob(request.getDob());
        }

        try {
            profile = profileRepository.save(profile);
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            throw new com.medibook.common.exception.BadRequestException("Lỗi dữ liệu trùng lặp: " + e.getMessage());
        }
        log.info("Profile updated for user: {}", userId);

        // Đồng bộ sang bảng doctors nếu user là bác sĩ
        syncToDoctor(userId, profile);

        return toDto(profile);
    }

    /**
     * Convert entity to DTO with error handling
     */
    private ProfileDto toDto(Profile profile) {
        try {
            // Fetch specialty from doctor record if exists
            String specialty = null;
            Optional<Doctor> doctorOpt = doctorRepository.findByUserId(profile.getUserId());
            if (doctorOpt.isPresent()) {
                specialty = doctorOpt.get().getSpecialty();
            }

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
                    .specialty(specialty)
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

    /**
     * Đồng bộ thông tin từ Profile sang Doctor (nếu user là bác sĩ)
     */
    private void syncToDoctor(UUID userId, Profile profile) {
        doctorRepository.findByUserId(userId).ifPresent(doctor -> {
            boolean updated = false;

            if (profile.getFullName() != null && !profile.getFullName().equals(doctor.getFullName())) {
                doctor.setFullName(profile.getFullName());
                updated = true;
            }
            if (profile.getPhone() != null && !profile.getPhone().equals(doctor.getPhone())) {
                doctor.setPhone(profile.getPhone());
                updated = true;
            }
            if (profile.getAvatarUrl() != null && !profile.getAvatarUrl().equals(doctor.getAvatarUrl())) {
                doctor.setAvatarUrl(profile.getAvatarUrl());
                updated = true;
            }

            if (updated) {
                doctorRepository.save(doctor);
                log.info("Doctor info synced from Profile for userId: {}", userId);
            }
        });
    }

    // ===================== ADMIN METHODS =====================

    /**
     * Lấy danh sách tất cả bệnh nhân (có phân trang)
     * Loại bỏ những profile thuộc về bác sĩ
     */
    public Page<ProfileDto> getAllPatients(Pageable pageable, String search) {
        log.info("Fetching all patients with search: {}", search);
        
        // Lấy tất cả doctor userIds để loại bỏ
        List<UUID> doctorUserIds = doctorRepository.findAll().stream()
                .map(Doctor::getUserId)
                .collect(Collectors.toList());
        
        Page<Profile> profilePage;
        if (search != null && !search.trim().isEmpty()) {
            profilePage = profileRepository.findByFullNameContainingIgnoreCaseAndUserIdNotIn(
                    search.trim(), doctorUserIds, pageable);
        } else {
            profilePage = profileRepository.findByUserIdNotIn(doctorUserIds, pageable);
        }
        
        List<ProfileDto> dtos = profilePage.getContent().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
        
        return new PageImpl<>(dtos, pageable, profilePage.getTotalElements());
    }

    /**
     * Lấy tất cả bệnh nhân không phân trang
     */
    public List<ProfileDto> getAllPatientsNoPaging(String search) {
        log.info("Fetching all patients (no paging) with search: {}", search);
        
        // Lấy tất cả doctor userIds để loại bỏ
        List<UUID> doctorUserIds = doctorRepository.findAll().stream()
                .map(Doctor::getUserId)
                .collect(Collectors.toList());
        
        List<Profile> profiles;
        if (search != null && !search.trim().isEmpty()) {
            profiles = profileRepository.findByFullNameContainingIgnoreCaseAndUserIdNotIn(search.trim(), doctorUserIds);
        } else {
            profiles = profileRepository.findByUserIdNotIn(doctorUserIds);
        }
        
        return profiles.stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Xóa bệnh nhân (chỉ xóa profile, không xóa user auth)
     */
    @Transactional
    public void deletePatient(UUID userId) {
        log.info("Deleting patient profile for userId: {}", userId);
        
        // Kiểm tra không phải bác sĩ
        if (doctorRepository.findByUserId(userId).isPresent()) {
            throw new com.medibook.common.exception.BadRequestException(
                    "Không thể xóa profile của bác sĩ từ trang bệnh nhân");
        }
        
        profileRepository.findByUserId(userId).ifPresent(profile -> {
            profileRepository.delete(profile);
            log.info("Deleted patient profile for userId: {}", userId);
        });
    }
}
