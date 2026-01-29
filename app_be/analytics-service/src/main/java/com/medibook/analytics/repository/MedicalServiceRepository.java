package com.medibook.analytics.repository;

import com.medibook.analytics.entity.MedicalService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Repository cho MedicalService - chỉ đọc dữ liệu để thống kê
 */
@Repository
public interface MedicalServiceRepository extends JpaRepository<MedicalService, UUID> {
}
