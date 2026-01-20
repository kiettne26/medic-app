package com.medibook.user.repository;

import com.medibook.user.entity.Doctor;
import com.medibook.user.entity.DoctorSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.DayOfWeek;
import java.util.List;
import java.util.UUID;

@Repository
public interface DoctorScheduleRepository extends JpaRepository<DoctorSchedule, UUID> {

    List<DoctorSchedule> findByDoctor(Doctor doctor);

    List<DoctorSchedule> findByDoctorIdAndIsActiveTrue(UUID doctorId);

    List<DoctorSchedule> findByDoctorIdAndDayOfWeek(UUID doctorId, DayOfWeek dayOfWeek);
}
