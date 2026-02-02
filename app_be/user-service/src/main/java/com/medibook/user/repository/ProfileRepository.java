package com.medibook.user.repository;

import com.medibook.user.entity.Profile;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProfileRepository extends JpaRepository<Profile, UUID> {

    Optional<Profile> findByUserId(UUID userId);

    Optional<Profile> findByPhone(String phone);

    // Admin: Lấy tất cả profiles không phải bác sĩ (có phân trang)
    Page<Profile> findByUserIdNotIn(List<UUID> doctorUserIds, Pageable pageable);

    // Admin: Lấy tất cả profiles không phải bác sĩ (không phân trang)
    List<Profile> findByUserIdNotIn(List<UUID> doctorUserIds);

    // Admin: Tìm kiếm theo tên và loại bỏ bác sĩ (có phân trang)
    Page<Profile> findByFullNameContainingIgnoreCaseAndUserIdNotIn(String fullName, List<UUID> doctorUserIds, Pageable pageable);

    // Admin: Tìm kiếm theo tên và loại bỏ bác sĩ (không phân trang)
    List<Profile> findByFullNameContainingIgnoreCaseAndUserIdNotIn(String fullName, List<UUID> doctorUserIds);
}
