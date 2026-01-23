package com.medibook.user;

import com.medibook.user.entity.Doctor;
import com.medibook.user.entity.MedicalService;
import com.medibook.user.repository.DoctorRepository;
import com.medibook.user.repository.MedicalServiceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder implements CommandLineRunner {

        private final MedicalServiceRepository medicalServiceRepository;
        private final DoctorRepository doctorRepository;
        private final JdbcTemplate jdbcTemplate;

        @Override
        public void run(String... args) throws Exception {
                try {
                        seedServices();
                        seedDoctor();
                } catch (Exception e) {
                        log.error("Data Seeding Failed: ", e);
                }
        }

        private void seedServices() {
                log.info("Seeding/Updating medical services with images...");

                List<MedicalService> servicesData = List.of(
                                MedicalService.builder()
                                                .name("Khám Nhi Tổng Quát")
                                                .description("Khám và tư vấn sức khỏe cho trẻ em")
                                                .price(200000.0)
                                                .durationMinutes(20)
                                                .category("Nhi khoa")
                                                .imageUrl("https://img.freepik.com/free-photo/pediatrician-examining-baby-clinic_23-2148131346.jpg")
                                                .isActive(true)
                                                .build(),
                                MedicalService.builder()
                                                .name("Khám Da Liễu")
                                                .description("Điều trị các bệnh về da")
                                                .price(300000.0)
                                                .durationMinutes(30)
                                                .category("Da liễu")
                                                .imageUrl("https://img.freepik.com/free-photo/dermatologist-examining-patient-s-birthmark_23-2148962299.jpg")
                                                .isActive(true)
                                                .build(),
                                MedicalService.builder()
                                                .name("Tư vấn Tâm lý")
                                                .description("Tư vấn sức khỏe tâm thần")
                                                .price(500000.0)
                                                .durationMinutes(60)
                                                .category("Tâm lý")
                                                .imageUrl("https://img.freepik.com/free-photo/psychologist-taking-notes-during-therapy-session_23-2148755716.jpg")
                                                .isActive(true)
                                                .build(),
                                MedicalService.builder()
                                                .name("Xét nghiệm Máu")
                                                .description("Xét nghiệm máu tổng quát")
                                                .price(150000.0)
                                                .durationMinutes(15)
                                                .category("Xét nghiệm")
                                                .imageUrl("https://img.freepik.com/free-photo/scientist-holding-sample-blood-test-tube_23-2148530737.jpg")
                                                .isActive(true)
                                                .build(),
                                MedicalService.builder()
                                                .name("Khám Tim Mạch")
                                                .description("Khám chuyên sâu về tim mạch")
                                                .price(500000.0)
                                                .durationMinutes(45)
                                                .category("Tim mạch")
                                                .imageUrl("https://img.freepik.com/free-photo/doctor-examining-patient-with-stethoscope_23-2148962287.jpg")
                                                .isActive(true)
                                                .build());

                for (MedicalService sDto : servicesData) {
                        List<MedicalService> existing = medicalServiceRepository
                                        .findByNameContainingIgnoreCase(sDto.getName());
                        if (existing.isEmpty()) {
                                medicalServiceRepository.save(sDto);
                                log.info("Created service: {}", sDto.getName());
                        } else {
                                MedicalService s = existing.get(0);
                                if (s.getImageUrl() == null || s.getImageUrl().isEmpty()) {
                                        s.setImageUrl(sDto.getImageUrl());
                                        medicalServiceRepository.save(s);
                                        log.info("Updated image for service: {}", s.getName());
                                }
                        }
                }
        }

        private void seedDoctor() {
                String email = "bacsi_nhi@medibook.com";
                Integer count = jdbcTemplate.queryForObject(
                                "SELECT count(*) FROM users WHERE email = ?", Integer.class, email);

                UUID userId;
                if (count == null || count == 0) {
                        String insertUserSql = "INSERT INTO users (email, password_hash, role, enabled, full_name, phone) "
                                        +
                                        "VALUES (?, ?, ?, ?, ?, ?) RETURNING id";
                        String passwordHash = "$2a$10$wPHx.kKx.9OQk.0j.0j.0.0j.0j.0j.0j.0j.0j.0j.0";
                        userId = jdbcTemplate.queryForObject(insertUserSql, UUID.class,
                                        email, passwordHash, "DOCTOR", true, "Dr. Tran Thi C", "0909000333");
                } else {
                        userId = jdbcTemplate.queryForObject("SELECT id FROM users WHERE email = ?", UUID.class, email);
                }

                if (doctorRepository.findByUserId(userId).isPresent()) {
                        linkDoctorToService(doctorRepository.findByUserId(userId).get(), "Khám Nhi Tổng Quát");
                        return;
                }

                Doctor doctor = Doctor.builder()
                                .userId(userId)
                                .fullName("Dr. Tran Thi C")
                                .specialty("Nhi khoa")
                                .description("Chuyên gia nhi khoa")
                                .rating(4.9)
                                .totalReviews(50)
                                .isAvailable(true)
                                .consultationFee(200000.0)
                                .avatarUrl("https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg")
                                .build();
                doctor = doctorRepository.save(doctor);
                linkDoctorToService(doctor, "Khám Nhi Tổng Quát");
        }

        private void linkDoctorToService(Doctor doctor, String serviceName) {
                List<MedicalService> services = medicalServiceRepository.findByNameContainingIgnoreCase(serviceName);
                if (services.isEmpty())
                        return;
                MedicalService service = services.get(0);

                boolean linked = doctor.getServices().stream().anyMatch(s -> s.getId().equals(service.getId()));
                if (!linked) {
                        doctor.getServices().add(service);
                        doctorRepository.save(doctor);
                }
        }
}
