package com.medibook.analytics.repository;

import com.medibook.analytics.entity.Doctor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * Repository cho Doctor - chỉ đọc dữ liệu để thống kê
 */
@Repository
public interface DoctorRepository extends JpaRepository<Doctor, UUID> {
    
    // count() được kế thừa từ JpaRepository
    
    // Lấy top doctors theo rating
    List<Doctor> findTop10ByOrderByRatingDesc();
    
    // Đếm doctors đang available
    long countByIsAvailableTrue();
}
