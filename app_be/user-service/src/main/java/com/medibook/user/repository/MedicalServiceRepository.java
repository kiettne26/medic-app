package com.medibook.user.repository;

import com.medibook.user.entity.MedicalService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface MedicalServiceRepository extends JpaRepository<MedicalService, UUID> {

    List<MedicalService> findByIsActiveTrue();

    List<MedicalService> findByCategory(String category);

    List<MedicalService> findByCategoryAndIsActiveTrue(String category);

    List<MedicalService> findByNameContainingIgnoreCase(String name);
}
