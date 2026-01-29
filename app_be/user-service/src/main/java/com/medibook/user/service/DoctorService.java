package com.medibook.user.service;

import com.medibook.common.exception.ResourceNotFoundException;
import com.medibook.user.dto.CreateDoctorRequest;
import com.medibook.user.dto.DoctorDto;
import com.medibook.user.dto.MedicalServiceDto;
import com.medibook.user.entity.Doctor;
import com.medibook.user.entity.MedicalService;
import com.medibook.user.repository.DoctorRepository;
import com.medibook.user.repository.MedicalServiceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Doctor Service - Quản lý bác sĩ
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DoctorService {

    private final DoctorRepository doctorRepository;
    private final MedicalServiceRepository medicalServiceRepository;

    /**
     * Lấy tất cả bác sĩ
     */
    public List<DoctorDto> getAllDoctors() {
        return doctorRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Lấy bác sĩ available
     */
    public List<DoctorDto> getAvailableDoctors() {
        return doctorRepository.findByIsAvailableTrue().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Lấy bác sĩ theo ID
     */
    public DoctorDto getDoctorById(UUID id) {
        Doctor doctor = doctorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Doctor", "id", id));
        return toDto(doctor);
    }

    /**
     * Lấy bác sĩ theo User ID
     */
    public java.util.Optional<DoctorDto> getDoctorByUserId(UUID userId) {
        return doctorRepository.findByUserId(userId)
                .map(this::toDto);
    }

    /**
     * Lấy Doctor ID từ User ID
     */
    public UUID findDoctorIdByUserId(UUID userId) {
        return doctorRepository.findByUserId(userId)
                .map(Doctor::getId)
                .orElse(null);
    }

    /**
     * Lấy bác sĩ theo chuyên khoa
     */
    public List<DoctorDto> getDoctorsBySpecialty(String specialty) {
        return doctorRepository.findBySpecialtyContainingIgnoreCase(specialty).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Lấy bác sĩ theo dịch vụ
     */
    public List<DoctorDto> getDoctorsByService(UUID serviceId) {
        return doctorRepository.findByServiceId(serviceId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Tạo bác sĩ mới (Admin)
     */
    @Transactional
    public DoctorDto createDoctor(CreateDoctorRequest request) {
        Doctor doctor = Doctor.builder()
                .userId(request.getUserId())
                .fullName(request.getFullName())
                .specialty(request.getSpecialty())
                .description(request.getDescription())
                .phone(request.getPhone())
                .avatarUrl(request.getAvatarUrl())
                .consultationFee(request.getConsultationFee())
                .isAvailable(true)
                .build();

        // Gán services nếu có
        if (request.getServiceIds() != null && !request.getServiceIds().isEmpty()) {
            List<MedicalService> services = medicalServiceRepository.findAllById(request.getServiceIds());
            doctor.setServices(services);
        }

        doctor = doctorRepository.save(doctor);
        log.info("Doctor created: {}", doctor.getId());
        return toDto(doctor);
    }

    /**
     * Cập nhật bác sĩ
     */
    @Transactional
    public DoctorDto updateDoctor(UUID id, CreateDoctorRequest request) {
        Doctor doctor = doctorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Doctor", "id", id));

        doctor.setSpecialty(request.getSpecialty());
        doctor.setDescription(request.getDescription());
        doctor.setPhone(request.getPhone());
        doctor.setAvatarUrl(request.getAvatarUrl());
        doctor.setConsultationFee(request.getConsultationFee());

        if (request.getServiceIds() != null) {
            List<MedicalService> services = medicalServiceRepository.findAllById(request.getServiceIds());
            doctor.setServices(services);
        }

        doctor = doctorRepository.save(doctor);
        log.info("Doctor updated: {}", doctor.getId());
        return toDto(doctor);
    }

    /**
     * Xóa bác sĩ
     */
    @Transactional
    public void deleteDoctor(UUID id) {
        if (!doctorRepository.existsById(id)) {
            throw new ResourceNotFoundException("Doctor", "id", id);
        }
        doctorRepository.deleteById(id);
        log.info("Doctor deleted: {}", id);
    }

    /**
     * Cập nhật rating và totalReviews của bác sĩ
     * Được gọi sau khi có review mới, cập nhật, hoặc xóa
     */
    @Transactional
    public void updateDoctorRating(UUID doctorId, Double averageRating, long totalReviews) {
        Doctor doctor = doctorRepository.findById(doctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Doctor", "id", doctorId));

        doctor.setRating(averageRating != null ? averageRating : 0.0);
        doctor.setTotalReviews((int) totalReviews);
        doctorRepository.save(doctor);
        log.info("Doctor rating updated: id={}, rating={}, totalReviews={}", doctorId, averageRating, totalReviews);
    }

    /**
     * Convert entity to DTO
     */
    private DoctorDto toDto(Doctor doctor) {
        List<MedicalServiceDto> serviceDtos = doctor.getServices().stream()
                .map(s -> MedicalServiceDto.builder()
                        .id(s.getId())
                        .name(s.getName())
                        .description(s.getDescription())
                        .price(s.getPrice())
                        .durationMinutes(s.getDurationMinutes())
                        .category(s.getCategory())
                        .isActive(s.getIsActive())
                        .imageUrl(s.getImageUrl())
                        .build())
                .collect(Collectors.toList());

        return DoctorDto.builder()
                .id(doctor.getId())
                .userId(doctor.getUserId())
                .fullName(doctor.getFullName())
                .specialty(doctor.getSpecialty())
                .description(doctor.getDescription())
                .phone(doctor.getPhone())
                .avatarUrl(doctor.getAvatarUrl())
                .rating(doctor.getRating())
                .totalReviews(doctor.getTotalReviews())
                .isAvailable(doctor.getIsAvailable())
                .consultationFee(doctor.getConsultationFee())
                .services(serviceDtos)
                .build();
    }
}
