package com.medibook.user.repository;

import com.medibook.user.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {

    List<Review> findByDoctorIdOrderByCreatedAtDesc(UUID doctorId);

    List<Review> findByPatientIdOrderByCreatedAtDesc(UUID patientId);

    long countByDoctorId(UUID doctorId);

    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.doctorId = :doctorId")
    Double getAverageRatingByDoctorId(@Param("doctorId") UUID doctorId);
}
