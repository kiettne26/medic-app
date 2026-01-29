package com.medibook.analytics.repository;

import com.medibook.analytics.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Repository cho Profile - chỉ đọc dữ liệu để thống kê
 */
@Repository
public interface ProfileRepository extends JpaRepository<Profile, UUID> {
    
    // count() được kế thừa từ JpaRepository
}
