package com.medibook.user.repository;

import com.medibook.user.entity.Doctor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DoctorRepository extends JpaRepository<Doctor, UUID> {

    Optional<Doctor> findByUserId(UUID userId);

    List<Doctor> findByIsAvailableTrue();

    List<Doctor> findBySpecialtyContainingIgnoreCase(String specialty);

    @Query("SELECT d FROM Doctor d JOIN d.services s WHERE s.id = :serviceId")
    List<Doctor> findByServiceId(UUID serviceId);

    @Query("SELECT d FROM Doctor d WHERE d.isAvailable = true ORDER BY d.rating DESC")
    List<Doctor> findTopRatedDoctors();
}
