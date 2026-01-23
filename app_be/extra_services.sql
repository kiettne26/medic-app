-- Add more medical services
INSERT INTO medical_services (name, description, price, duration_minutes, category, is_active)
VALUES 
('Khám Nhi Tổng Quát', 'Khám và tư vấn sức khỏe cho trẻ em', 200000, 20, 'Nhi khoa', true),
('Khám Da Liễu', 'Điều trị các bệnh về da', 300000, 30, 'Da liễu', true),
('Tư vấn Tâm lý', 'Tư vấn sức khỏe tâm thần', 500000, 60, 'Tâm lý', true),
('Xét nghiệm Máu', 'Xét nghiệm máu tổng quát', 150000, 15, 'Xét nghiệm', true);

-- Add a new doctor (Pediatrician)
-- User
WITH new_doc_user AS (
    INSERT INTO users (email, password_hash, role, enabled, full_name, phone)
    VALUES ('bacsi_nhi@medibook.com', '$2a$10$wPHx.kKx.9OQk.0j.0j.0.0j.0j.0j.0j.0j.0j.0', 'DOCTOR', true, 'Dr. Tran Thi C', '0909000333')
    RETURNING id
)
-- Doctor Profile
INSERT INTO doctors (user_id, specialty, full_name, description, rating, total_reviews, is_available, consultation_fee, avatar_url)
SELECT id, 'Nhi khoa', 'Dr. Tran Thi C', 'Chuyên gia nhi khoa tận tâm', 4.9, 50, true, 200000, 'https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg'
FROM new_doc_user;

-- Link Doctor to Service (Pediatrician -> Khám Nhi)
INSERT INTO doctor_services (doctor_id, service_id)
SELECT d.id, s.id
FROM doctors d, medical_services s
WHERE d.full_name = 'Dr. Tran Thi C' AND s.name = 'Khám Nhi Tổng Quát';

-- Link existing Doctor (Dr. Nguyen Van A) to another service? (Already linked to Tim Mach in seed.sql)
