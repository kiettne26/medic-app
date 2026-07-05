-- ============================================
-- SEED DATA - DỮ LIỆU MÔ PHỎNG CHO MEDIC APP
-- Chạy sau khi đã chạy DB.sql
-- Tất cả tài khoản đều dùng mật khẩu: 123456
-- BCrypt hash của '123456': $2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG
-- ============================================

-- Xóa dữ liệu cũ (giữ lại cấu trúc bảng)
DELETE FROM messages;
DELETE FROM conversations;
DELETE FROM audit_logs;
DELETE FROM notifications;
DELETE FROM reviews;
DELETE FROM booking_status_history;
DELETE FROM bookings;
DELETE FROM time_slots;
DELETE FROM doctor_services;
DELETE FROM medical_services;
DELETE FROM doctor_schedules;
DELETE FROM doctors;
DELETE FROM refresh_tokens;
DELETE FROM profiles;
DELETE FROM users;
DELETE FROM roles;

-- ============================================
-- 1. ROLES
-- ============================================
INSERT INTO roles (id, name) VALUES
('0cb60fb8-af36-4d07-a2de-0570cde3cc0e', 'ADMIN'),
('2eae985b-50e0-495b-926f-13b29c2423be', 'DOCTOR'),
('37be9a46-8054-49a0-b7bd-4691e96e0ba1', 'PATIENT')
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- 2. USERS (Mật khẩu: 123456)
-- Hash BCrypt: $2a$10$lTS.VLVz6rdo2sIVU/hPI.U5CLXEDlvhIMo2QIqPsM4VNCQmemf3. (admin123 cho admin)
-- Hash BCrypt: $2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG (123456 cho còn lại)
-- ============================================

-- Admin
INSERT INTO users (id, email, password_hash, role, enabled, full_name, phone, avatar_url) VALUES
('42eb1bbf-349d-458e-b961-f00bf197f53e', 'admin@medic.com', '$2a$10$lTS.VLVz6rdo2sIVU/hPI.U5CLXEDlvhIMo2QIqPsM4VNCQmemf3.', 'ADMIN', true, 'Quản Trị Viên', '0901000000', NULL)
ON CONFLICT (email) DO NOTHING;

-- Bác sĩ (5 bác sĩ)
INSERT INTO users (id, email, password_hash, role, enabled, full_name, phone, avatar_url) VALUES
('a1b2c3d4-1111-4000-a000-000000000001', 'dr.nguyen@medic.com', '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'DOCTOR', true, 'BS. Nguyễn Văn An', '0901111001', NULL),
('a1b2c3d4-1111-4000-a000-000000000002', 'dr.tran@medic.com',   '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'DOCTOR', true, 'BS. Trần Thị Bích', '0901111002', NULL),
('a1b2c3d4-1111-4000-a000-000000000003', 'dr.le@medic.com',     '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'DOCTOR', true, 'BS. Lê Hoàng Cường', '0901111003', NULL),
('a1b2c3d4-1111-4000-a000-000000000004', 'dr.pham@medic.com',   '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'DOCTOR', true, 'BS. Phạm Minh Đức', '0901111004', NULL),
('a1b2c3d4-1111-4000-a000-000000000005', 'dr.vo@medic.com',     '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'DOCTOR', true, 'BS. Võ Thanh Hà', '0901111005', NULL)
ON CONFLICT (email) DO NOTHING;

-- Bệnh nhân (5 bệnh nhân)
INSERT INTO users (id, email, password_hash, role, enabled, full_name, phone, avatar_url) VALUES
('b2c3d4e5-2222-4000-b000-000000000001', 'patient1@gmail.com', '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'PATIENT', true, 'Nguyễn Thị Mai', '0902222001', NULL),
('b2c3d4e5-2222-4000-b000-000000000002', 'patient2@gmail.com', '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'PATIENT', true, 'Trần Văn Hùng', '0902222002', NULL),
('b2c3d4e5-2222-4000-b000-000000000003', 'patient3@gmail.com', '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'PATIENT', true, 'Lê Thị Hương', '0902222003', NULL),
('b2c3d4e5-2222-4000-b000-000000000004', 'patient4@gmail.com', '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'PATIENT', true, 'Phạm Quốc Bảo', '0902222004', NULL),
('b2c3d4e5-2222-4000-b000-000000000005', 'patient5@gmail.com', '$2a$10$n7gtn/6JUigJRBHiKQq8XehtBVXlsfX4yOHWgJFLeN1h/r8.SHzCG', 'PATIENT', true, 'Đỗ Thị Lan Anh', '0902222005', NULL)
ON CONFLICT (email) DO NOTHING;

UPDATE users SET email_verified = true;

-- ============================================
-- 3. PROFILES (Hồ sơ bệnh nhân)
-- ============================================
INSERT INTO profiles (id, user_id, full_name, phone, address, dob, gender) VALUES
('c3d4e5f6-3333-4000-c000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000001', 'Nguyễn Thị Mai',   '0902222001', '123 Nguyễn Huệ, Q.1, TP.HCM',    '1995-03-15', 'FEMALE'),
('c3d4e5f6-3333-4000-c000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000002', 'Trần Văn Hùng',    '0902222002', '456 Lê Lợi, Q.3, TP.HCM',         '1988-07-22', 'MALE'),
('c3d4e5f6-3333-4000-c000-000000000003', 'b2c3d4e5-2222-4000-b000-000000000003', 'Lê Thị Hương',     '0902222003', '789 Trần Hưng Đạo, Q.5, TP.HCM',  '1992-11-08', 'FEMALE'),
('c3d4e5f6-3333-4000-c000-000000000004', 'b2c3d4e5-2222-4000-b000-000000000004', 'Phạm Quốc Bảo',    '0902222004', '321 Điện Biên Phủ, Q.10, TP.HCM', '1990-01-30', 'MALE'),
('c3d4e5f6-3333-4000-c000-000000000005', 'b2c3d4e5-2222-4000-b000-000000000005', 'Đỗ Thị Lan Anh',   '0902222005', '654 Võ Văn Tần, Q.3, TP.HCM',     '1998-09-12', 'FEMALE');

-- ============================================
-- 4. DOCTORS (Hồ sơ bác sĩ)
-- ============================================
INSERT INTO doctors (id, user_id, full_name, specialty, description, rating, is_available, consultation_fee, phone, total_reviews) VALUES
('d4e5f6a7-4444-4000-d000-000000000001', 'a1b2c3d4-1111-4000-a000-000000000001', 'BS. Nguyễn Văn An',    'Tim mạch',      'Bác sĩ chuyên khoa Tim mạch với 15 năm kinh nghiệm. Tốt nghiệp Đại học Y Dược TP.HCM, tu nghiệp tại Bệnh viện Chợ Rẫy.', 4.7, true, 500000, '0901111001', 3),
('d4e5f6a7-4444-4000-d000-000000000002', 'a1b2c3d4-1111-4000-a000-000000000002', 'BS. Trần Thị Bích',    'Da liễu',       'Chuyên gia Da liễu - Thẩm mỹ da. 10 năm kinh nghiệm điều trị các bệnh về da, chăm sóc da chuyên sâu.', 4.6, true, 400000, '0901111002', 18),
('d4e5f6a7-4444-4000-d000-000000000003', 'a1b2c3d4-1111-4000-a000-000000000003', 'BS. Lê Hoàng Cường',   'Nội tổng quát', 'Bác sĩ Nội khoa tổng quát, giỏi chẩn đoán và điều trị các bệnh lý nội khoa phức tạp. 12 năm kinh nghiệm.', 4.7, true, 350000, '0901111003', 30),
('d4e5f6a7-4444-4000-d000-000000000004', 'a1b2c3d4-1111-4000-a000-000000000004', 'BS. Phạm Minh Đức',    'Nhi khoa',      'Chuyên gia Nhi khoa, tận tâm với trẻ em. Tốt nghiệp loại Giỏi ĐH Y Hà Nội, 8 năm kinh nghiệm tại BV Nhi Đồng 1.', 4.9, true, 450000, '0901111004', 42),
('d4e5f6a7-4444-4000-d000-000000000005', 'a1b2c3d4-1111-4000-a000-000000000005', 'BS. Võ Thanh Hà',      'Răng Hàm Mặt',  'Bác sĩ Răng Hàm Mặt chuyên điều trị nha khoa thẩm mỹ, chỉnh nha và cấy ghép Implant. 10 năm kinh nghiệm.', 4.5, true, 600000, '0901111005', 15);

-- ============================================
-- 5. MEDICAL SERVICES (Dịch vụ y tế)
-- ============================================
INSERT INTO medical_services (id, name, description, price, duration_minutes, category, is_active) VALUES
('e5f6a7b8-5555-4000-e000-000000000001', 'Khám tổng quát',         'Khám sức khỏe tổng quát, đo huyết áp, nghe tim phổi, tư vấn sức khỏe chung.', 300000, 30, 'Khám bệnh', true),
('e5f6a7b8-5555-4000-e000-000000000002', 'Khám chuyên khoa Tim',   'Khám và tư vấn chuyên sâu về tim mạch, đo điện tim ECG, siêu âm tim.', 500000, 45, 'Tim mạch', true),
('e5f6a7b8-5555-4000-e000-000000000003', 'Khám Da liễu',           'Khám, chẩn đoán và điều trị các bệnh lý về da: mụn, dị ứng, nấm da, vẩy nến.', 400000, 30, 'Da liễu', true),
('e5f6a7b8-5555-4000-e000-000000000004', 'Tư vấn dinh dưỡng',     'Tư vấn chế độ dinh dưỡng phù hợp với tình trạng sức khỏe và mục tiêu cá nhân.', 250000, 30, 'Dinh dưỡng', true),
('e5f6a7b8-5555-4000-e000-000000000005', 'Khám Nhi',              'Khám sức khỏe cho trẻ em, tư vấn tiêm chủng, theo dõi phát triển.', 350000, 30, 'Nhi khoa', true),
('e5f6a7b8-5555-4000-e000-000000000006', 'Răng thẩm mỹ',          'Tẩy trắng răng, bọc sứ, dán veneer thẩm mỹ.', 800000, 60, 'Nha khoa', true),
('e5f6a7b8-5555-4000-e000-000000000007', 'Nhổ răng khôn',          'Nhổ răng khôn mọc lệch, mọc ngầm bằng phương pháp an toàn.', 1500000, 60, 'Nha khoa', true),
('e5f6a7b8-5555-4000-e000-000000000008', 'Tư vấn trực tuyến',     'Tư vấn sức khỏe trực tuyến qua video call với bác sĩ chuyên khoa.', 200000, 20, 'Trực tuyến', true),
('e5f6a7b8-5555-4000-e000-000000000009', 'Xét nghiệm máu',        'Xét nghiệm công thức máu, sinh hóa máu, chức năng gan thận.', 500000, 15, 'Xét nghiệm', true),
('e5f6a7b8-5555-4000-e000-000000000010', 'Siêu âm tổng quát',     'Siêu âm ổ bụng, tuyến giáp, vú, tim mạch.', 400000, 30, 'Chẩn đoán hình ảnh', true);

-- ============================================
-- 6. DOCTOR_SERVICES (Bác sĩ - Dịch vụ)
-- ============================================
INSERT INTO doctor_services (id, doctor_id, service_id) VALUES
-- BS. Nguyễn Văn An (Tim mạch): Khám tổng quát, Khám Tim, Tư vấn trực tuyến
('f6a7b8c9-6666-4000-f000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000001'),
('f6a7b8c9-6666-4000-f000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000002'),
('f6a7b8c9-6666-4000-f000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000008'),
-- BS. Trần Thị Bích (Da liễu): Khám Da liễu, Tư vấn trực tuyến
('f6a7b8c9-6666-4000-f000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000002', 'e5f6a7b8-5555-4000-e000-000000000003'),
('f6a7b8c9-6666-4000-f000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000002', 'e5f6a7b8-5555-4000-e000-000000000008'),
-- BS. Lê Hoàng Cường (Nội tổng quát): Khám tổng quát, Tư vấn dinh dưỡng, Xét nghiệm máu, Siêu âm
('f6a7b8c9-6666-4000-f000-000000000006', 'd4e5f6a7-4444-4000-d000-000000000003', 'e5f6a7b8-5555-4000-e000-000000000001'),
('f6a7b8c9-6666-4000-f000-000000000007', 'd4e5f6a7-4444-4000-d000-000000000003', 'e5f6a7b8-5555-4000-e000-000000000004'),
('f6a7b8c9-6666-4000-f000-000000000008', 'd4e5f6a7-4444-4000-d000-000000000003', 'e5f6a7b8-5555-4000-e000-000000000009'),
('f6a7b8c9-6666-4000-f000-000000000009', 'd4e5f6a7-4444-4000-d000-000000000003', 'e5f6a7b8-5555-4000-e000-000000000010'),
-- BS. Phạm Minh Đức (Nhi khoa): Khám Nhi, Khám tổng quát, Tư vấn trực tuyến
('f6a7b8c9-6666-4000-f000-000000000010', 'd4e5f6a7-4444-4000-d000-000000000004', 'e5f6a7b8-5555-4000-e000-000000000005'),
('f6a7b8c9-6666-4000-f000-000000000011', 'd4e5f6a7-4444-4000-d000-000000000004', 'e5f6a7b8-5555-4000-e000-000000000001'),
('f6a7b8c9-6666-4000-f000-000000000012', 'd4e5f6a7-4444-4000-d000-000000000004', 'e5f6a7b8-5555-4000-e000-000000000008'),
-- BS. Võ Thanh Hà (Răng Hàm Mặt): Răng thẩm mỹ, Nhổ răng khôn
('f6a7b8c9-6666-4000-f000-000000000013', 'd4e5f6a7-4444-4000-d000-000000000005', 'e5f6a7b8-5555-4000-e000-000000000006'),
('f6a7b8c9-6666-4000-f000-000000000014', 'd4e5f6a7-4444-4000-d000-000000000005', 'e5f6a7b8-5555-4000-e000-000000000007');

-- ============================================
-- 7. DOCTOR_SCHEDULES (Lịch làm việc hàng tuần)
-- day_of_week: 0=Chủ nhật, 1=Thứ 2, ..., 6=Thứ 7
-- ============================================
-- BS. Nguyễn Văn An: Thứ 2-6, sáng + chiều
INSERT INTO doctor_schedules (id, doctor_id, day_of_week, start_time, end_time, is_active, slot_duration_minutes) VALUES
('11111111-aaaa-4000-a000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000001', 1, '08:00', '12:00', true, 30),
('11111111-aaaa-4000-a000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000001', 1, '13:30', '17:00', true, 30),
('11111111-aaaa-4000-a000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000001', 2, '08:00', '12:00', true, 30),
('11111111-aaaa-4000-a000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000001', 3, '08:00', '12:00', true, 30),
('11111111-aaaa-4000-a000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000001', 4, '08:00', '12:00', true, 30),
('11111111-aaaa-4000-a000-000000000006', 'd4e5f6a7-4444-4000-d000-000000000001', 5, '08:00', '12:00', true, 30);

-- BS. Trần Thị Bích: Thứ 2, 4, 6
INSERT INTO doctor_schedules (id, doctor_id, day_of_week, start_time, end_time, is_active, slot_duration_minutes) VALUES
('11111111-bbbb-4000-b000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000002', 1, '08:00', '12:00', true, 30),
('11111111-bbbb-4000-b000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000002', 3, '08:00', '12:00', true, 30),
('11111111-bbbb-4000-b000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000002', 5, '13:30', '17:00', true, 30);

-- BS. Lê Hoàng Cường: Thứ 2-7
INSERT INTO doctor_schedules (id, doctor_id, day_of_week, start_time, end_time, is_active, slot_duration_minutes) VALUES
('11111111-cccc-4000-c000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000003', 1, '07:30', '11:30', true, 30),
('11111111-cccc-4000-c000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000003', 2, '07:30', '11:30', true, 30),
('11111111-cccc-4000-c000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000003', 3, '13:00', '17:00', true, 30),
('11111111-cccc-4000-c000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000003', 4, '07:30', '11:30', true, 30),
('11111111-cccc-4000-c000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000003', 5, '07:30', '11:30', true, 30),
('11111111-cccc-4000-c000-000000000006', 'd4e5f6a7-4444-4000-d000-000000000003', 6, '08:00', '12:00', true, 30);

-- BS. Phạm Minh Đức: Thứ 2-6 chiều
INSERT INTO doctor_schedules (id, doctor_id, day_of_week, start_time, end_time, is_active, slot_duration_minutes) VALUES
('11111111-dddd-4000-d000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000004', 1, '13:00', '17:00', true, 30),
('11111111-dddd-4000-d000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000004', 2, '13:00', '17:00', true, 30),
('11111111-dddd-4000-d000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000004', 3, '13:00', '17:00', true, 30),
('11111111-dddd-4000-d000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000004', 4, '13:00', '17:00', true, 30),
('11111111-dddd-4000-d000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000004', 5, '13:00', '17:00', true, 30);

-- BS. Võ Thanh Hà: Thứ 3, 5, 7
INSERT INTO doctor_schedules (id, doctor_id, day_of_week, start_time, end_time, is_active, slot_duration_minutes) VALUES
('11111111-eeee-4000-e000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000005', 2, '08:00', '12:00', true, 60),
('11111111-eeee-4000-e000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000005', 4, '08:00', '12:00', true, 60),
('11111111-eeee-4000-e000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000005', 6, '08:00', '15:00', true, 60);

-- ============================================
-- 8. TIME_SLOTS (Khung giờ khám - Tuần hiện tại & tuần sau)
-- Tạo các slot cho ngày 2026-06-17 đến 2026-06-28
-- ============================================

-- BS. Nguyễn Văn An - Thứ 3, 17/06/2026 (sáng)
INSERT INTO time_slots (id, doctor_id, schedule_id, date, start_time, end_time, is_available, status) VALUES
('22222222-aaaa-4000-a000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000003', '2026-06-17', '08:00', '08:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000003', '2026-06-17', '08:30', '09:00', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000003', '2026-06-17', '09:00', '09:30', false, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000003', '2026-06-17', '09:30', '10:00', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000003', '2026-06-17', '10:00', '10:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000006', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000003', '2026-06-17', '10:30', '11:00', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000007', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000003', '2026-06-17', '11:00', '11:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000008', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000003', '2026-06-17', '11:30', '12:00', true, 'APPROVED');

-- BS. Nguyễn Văn An - Thứ 4, 18/06/2026
INSERT INTO time_slots (id, doctor_id, schedule_id, date, start_time, end_time, is_available, status) VALUES
('22222222-aaaa-4000-a000-000000000011', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000004', '2026-06-18', '08:00', '08:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000012', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000004', '2026-06-18', '08:30', '09:00', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000013', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000004', '2026-06-18', '09:00', '09:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000014', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000004', '2026-06-18', '09:30', '10:00', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000015', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000004', '2026-06-18', '10:00', '10:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000016', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000004', '2026-06-18', '10:30', '11:00', true, 'APPROVED');

-- BS. Trần Thị Bích - Thứ 4, 18/06/2026
INSERT INTO time_slots (id, doctor_id, schedule_id, date, start_time, end_time, is_available, status) VALUES
('22222222-bbbb-4000-b000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000002', '11111111-bbbb-4000-b000-000000000002', '2026-06-18', '08:00', '08:30', true, 'APPROVED'),
('22222222-bbbb-4000-b000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000002', '11111111-bbbb-4000-b000-000000000002', '2026-06-18', '08:30', '09:00', true, 'APPROVED'),
('22222222-bbbb-4000-b000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000002', '11111111-bbbb-4000-b000-000000000002', '2026-06-18', '09:00', '09:30', false, 'APPROVED'),
('22222222-bbbb-4000-b000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000002', '11111111-bbbb-4000-b000-000000000002', '2026-06-18', '09:30', '10:00', true, 'APPROVED'),
('22222222-bbbb-4000-b000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000002', '11111111-bbbb-4000-b000-000000000002', '2026-06-18', '10:00', '10:30', true, 'APPROVED'),
('22222222-bbbb-4000-b000-000000000006', 'd4e5f6a7-4444-4000-d000-000000000002', '11111111-bbbb-4000-b000-000000000002', '2026-06-18', '10:30', '11:00', true, 'APPROVED');

-- BS. Lê Hoàng Cường - Thứ 4, 18/06/2026 (chiều)
INSERT INTO time_slots (id, doctor_id, schedule_id, date, start_time, end_time, is_available, status) VALUES
('22222222-cccc-4000-c000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000003', '11111111-cccc-4000-c000-000000000003', '2026-06-18', '13:00', '13:30', true, 'APPROVED'),
('22222222-cccc-4000-c000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000003', '11111111-cccc-4000-c000-000000000003', '2026-06-18', '13:30', '14:00', true, 'APPROVED'),
('22222222-cccc-4000-c000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000003', '11111111-cccc-4000-c000-000000000003', '2026-06-18', '14:00', '14:30', true, 'APPROVED'),
('22222222-cccc-4000-c000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000003', '11111111-cccc-4000-c000-000000000003', '2026-06-18', '14:30', '15:00', true, 'APPROVED'),
('22222222-cccc-4000-c000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000003', '11111111-cccc-4000-c000-000000000003', '2026-06-18', '15:00', '15:30', false, 'APPROVED'),
('22222222-cccc-4000-c000-000000000006', 'd4e5f6a7-4444-4000-d000-000000000003', '11111111-cccc-4000-c000-000000000003', '2026-06-18', '15:30', '16:00', true, 'APPROVED'),
('22222222-cccc-4000-c000-000000000007', 'd4e5f6a7-4444-4000-d000-000000000003', '11111111-cccc-4000-c000-000000000003', '2026-06-18', '16:00', '16:30', true, 'APPROVED'),
('22222222-cccc-4000-c000-000000000008', 'd4e5f6a7-4444-4000-d000-000000000003', '11111111-cccc-4000-c000-000000000003', '2026-06-18', '16:30', '17:00', true, 'APPROVED');

-- BS. Phạm Minh Đức - Thứ 3, 17/06/2026 (chiều)
INSERT INTO time_slots (id, doctor_id, schedule_id, date, start_time, end_time, is_available, status) VALUES
('22222222-dddd-4000-d000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000004', '11111111-dddd-4000-d000-000000000002', '2026-06-17', '13:00', '13:30', true, 'APPROVED'),
('22222222-dddd-4000-d000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000004', '11111111-dddd-4000-d000-000000000002', '2026-06-17', '13:30', '14:00', false, 'APPROVED'),
('22222222-dddd-4000-d000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000004', '11111111-dddd-4000-d000-000000000002', '2026-06-17', '14:00', '14:30', true, 'APPROVED'),
('22222222-dddd-4000-d000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000004', '11111111-dddd-4000-d000-000000000002', '2026-06-17', '14:30', '15:00', true, 'APPROVED'),
('22222222-dddd-4000-d000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000004', '11111111-dddd-4000-d000-000000000002', '2026-06-17', '15:00', '15:30', true, 'APPROVED'),
('22222222-dddd-4000-d000-000000000006', 'd4e5f6a7-4444-4000-d000-000000000004', '11111111-dddd-4000-d000-000000000002', '2026-06-17', '15:30', '16:00', true, 'APPROVED'),
('22222222-dddd-4000-d000-000000000007', 'd4e5f6a7-4444-4000-d000-000000000004', '11111111-dddd-4000-d000-000000000002', '2026-06-17', '16:00', '16:30', true, 'APPROVED'),
('22222222-dddd-4000-d000-000000000008', 'd4e5f6a7-4444-4000-d000-000000000004', '11111111-dddd-4000-d000-000000000002', '2026-06-17', '16:30', '17:00', true, 'APPROVED');

-- BS. Võ Thanh Hà - Thứ 7, 21/06/2026
INSERT INTO time_slots (id, doctor_id, schedule_id, date, start_time, end_time, is_available, status) VALUES
('22222222-eeee-4000-e000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000005', '11111111-eeee-4000-e000-000000000003', '2026-06-21', '08:00', '09:00', true, 'APPROVED'),
('22222222-eeee-4000-e000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000005', '11111111-eeee-4000-e000-000000000003', '2026-06-21', '09:00', '10:00', true, 'APPROVED'),
('22222222-eeee-4000-e000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000005', '11111111-eeee-4000-e000-000000000003', '2026-06-21', '10:00', '11:00', true, 'APPROVED'),
('22222222-eeee-4000-e000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000005', '11111111-eeee-4000-e000-000000000003', '2026-06-21', '11:00', '12:00', true, 'APPROVED'),
('22222222-eeee-4000-e000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000005', '11111111-eeee-4000-e000-000000000003', '2026-06-21', '13:00', '14:00', true, 'APPROVED'),
('22222222-eeee-4000-e000-000000000006', 'd4e5f6a7-4444-4000-d000-000000000005', '11111111-eeee-4000-e000-000000000003', '2026-06-21', '14:00', '15:00', true, 'APPROVED');

-- Tuần sau - BS. Nguyễn Văn An - Thứ 2, 23/06/2026
INSERT INTO time_slots (id, doctor_id, schedule_id, date, start_time, end_time, is_available, status) VALUES
('22222222-aaaa-4000-a000-000000000021', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000001', '2026-06-23', '08:00', '08:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000022', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000001', '2026-06-23', '08:30', '09:00', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000023', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000001', '2026-06-23', '09:00', '09:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000024', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000001', '2026-06-23', '09:30', '10:00', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000025', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000001', '2026-06-23', '10:00', '10:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000026', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000001', '2026-06-23', '10:30', '11:00', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000027', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000001', '2026-06-23', '11:00', '11:30', true, 'APPROVED'),
('22222222-aaaa-4000-a000-000000000028', 'd4e5f6a7-4444-4000-d000-000000000001', '11111111-aaaa-4000-a000-000000000001', '2026-06-23', '11:30', '12:00', true, 'APPROVED');

-- ============================================
-- 9. BOOKINGS (Lịch đặt khám mẫu)
-- ============================================
-- Booking 1: Bệnh nhân Mai đặt khám Tim với BS. An - Đã xác nhận
INSERT INTO bookings (id, patient_id, doctor_id, service_id, time_slot_id, status, notes, created_at) VALUES
('33333333-aaaa-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000002', '22222222-aaaa-4000-a000-000000000003', 'CONFIRMED', 'Tôi hay bị đau ngực khi gắng sức, muốn được kiểm tra tim.', '2026-06-15 10:30:00');

-- Booking 2: Bệnh nhân Hùng đặt khám Da liễu với BS. Bích - Đang chờ
INSERT INTO bookings (id, patient_id, doctor_id, service_id, time_slot_id, status, notes, created_at) VALUES
('33333333-aaaa-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000002', 'e5f6a7b8-5555-4000-e000-000000000003', '22222222-bbbb-4000-b000-000000000003', 'PENDING', 'Bị nổi mẩn đỏ trên tay và lưng khoảng 2 tuần nay.', '2026-06-16 14:00:00');

-- Booking 3: Bệnh nhân Hương đặt khám Nhi cho con với BS. Đức - Đã xác nhận
INSERT INTO bookings (id, patient_id, doctor_id, service_id, time_slot_id, status, notes, created_at) VALUES
('33333333-aaaa-4000-a000-000000000003', 'b2c3d4e5-2222-4000-b000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000004', 'e5f6a7b8-5555-4000-e000-000000000005', '22222222-dddd-4000-d000-000000000002', 'CONFIRMED', 'Con tôi 3 tuổi, hay bị ho và sốt nhẹ.', '2026-06-15 09:00:00');

-- Booking 4: Bệnh nhân Bảo đặt khám tổng quát với BS. Cường - Đã hoàn thành
INSERT INTO bookings (id, patient_id, doctor_id, service_id, time_slot_id, status, notes, doctor_notes, created_at) VALUES
('33333333-aaaa-4000-a000-000000000004', 'b2c3d4e5-2222-4000-b000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000003', 'e5f6a7b8-5555-4000-e000-000000000001', '22222222-cccc-4000-c000-000000000005', 'COMPLETED', 'Muốn kiểm tra sức khỏe định kỳ.', 'Sức khỏe tổng quát tốt. Huyết áp bình thường 120/80. Nên tập thể dục đều đặn và giảm ăn mặn.', '2026-06-10 08:00:00');

-- Booking 5: Bệnh nhân Lan Anh đặt khám răng với BS. Hà - Đã hủy
INSERT INTO bookings (id, patient_id, doctor_id, service_id, time_slot_id, status, notes, cancellation_reason, cancelled_by, created_at) VALUES
('33333333-aaaa-4000-a000-000000000005', 'b2c3d4e5-2222-4000-b000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000005', 'e5f6a7b8-5555-4000-e000-000000000006', '22222222-eeee-4000-e000-000000000001', 'CANCELLED', 'Muốn tẩy trắng răng.', 'Bận công việc đột xuất, xin hẹn lại.', 'b2c3d4e5-2222-4000-b000-000000000005', '2026-06-12 15:00:00');

-- Booking 6: Bệnh nhân Mai đặt xét nghiệm máu với BS. Cường - Đã hoàn thành
INSERT INTO bookings (id, patient_id, doctor_id, service_id, time_slot_id, status, notes, doctor_notes, created_at) VALUES
('33333333-aaaa-4000-a000-000000000006', 'b2c3d4e5-2222-4000-b000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000003', 'e5f6a7b8-5555-4000-e000-000000000009', '22222222-cccc-4000-c000-000000000001', 'COMPLETED', 'Xét nghiệm máu tổng quát theo yêu cầu.', 'Kết quả xét nghiệm bình thường. Đường huyết 95mg/dL, cholesterol 180mg/dL. Không phát hiện bất thường.', '2026-06-08 07:30:00');

-- Các booking hoàn thành cho BS. An làm cơ sở đánh giá
INSERT INTO bookings (id, patient_id, doctor_id, service_id, time_slot_id, status, notes, created_at) VALUES
('33333333-bbbb-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000002', NULL, 'COMPLETED', 'Khám tim định kỳ.', '2026-05-10 09:00:00'),
('33333333-bbbb-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000002', NULL, 'COMPLETED', 'Tư vấn đau tức ngực.', '2026-06-02 14:00:00'),
('33333333-bbbb-4000-a000-000000000003', 'b2c3d4e5-2222-4000-b000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000002', NULL, 'COMPLETED', 'Kiểm tra huyết áp cao.', '2026-06-15 08:30:00');

-- ============================================
-- 10. BOOKING STATUS HISTORY
-- ============================================
INSERT INTO booking_status_history (id, booking_id, old_status, new_status, changed_by, reason, changed_at) VALUES
-- Booking 1: PENDING -> CONFIRMED
('44444444-aaaa-4000-a000-000000000001', '33333333-aaaa-4000-a000-000000000001', 'PENDING', 'CONFIRMED', 'a1b2c3d4-1111-4000-a000-000000000001', 'Bác sĩ xác nhận lịch hẹn.', '2026-06-15 11:00:00'),
-- Booking 3: PENDING -> CONFIRMED
('44444444-aaaa-4000-a000-000000000002', '33333333-aaaa-4000-a000-000000000003', 'PENDING', 'CONFIRMED', 'a1b2c3d4-1111-4000-a000-000000000004', 'Bác sĩ xác nhận lịch hẹn.', '2026-06-15 10:00:00'),
-- Booking 4: PENDING -> CONFIRMED -> COMPLETED
('44444444-aaaa-4000-a000-000000000003', '33333333-aaaa-4000-a000-000000000004', 'PENDING', 'CONFIRMED', 'a1b2c3d4-1111-4000-a000-000000000003', NULL, '2026-06-10 08:30:00'),
('44444444-aaaa-4000-a000-000000000004', '33333333-aaaa-4000-a000-000000000004', 'CONFIRMED', 'COMPLETED', 'a1b2c3d4-1111-4000-a000-000000000003', 'Khám xong, kết quả tốt.', '2026-06-10 09:15:00'),
-- Booking 5: PENDING -> CANCELLED
('44444444-aaaa-4000-a000-000000000005', '33333333-aaaa-4000-a000-000000000005', 'PENDING', 'CANCELLED', 'b2c3d4e5-2222-4000-b000-000000000005', 'Bận công việc đột xuất.', '2026-06-13 08:00:00'),
-- Booking 6: PENDING -> CONFIRMED -> COMPLETED
('44444444-aaaa-4000-a000-000000000006', '33333333-aaaa-4000-a000-000000000006', 'PENDING', 'CONFIRMED', 'a1b2c3d4-1111-4000-a000-000000000003', NULL, '2026-06-08 08:00:00'),
('44444444-aaaa-4000-a000-000000000007', '33333333-aaaa-4000-a000-000000000006', 'CONFIRMED', 'COMPLETED', 'a1b2c3d4-1111-4000-a000-000000000003', 'Hoàn tất xét nghiệm.', '2026-06-08 09:00:00');

-- ============================================
-- 11. REVIEWS (Đánh giá sau khám)
-- ============================================
INSERT INTO reviews (id, booking_id, patient_id, doctor_id, rating, comment, doctor_reply, doctor_reply_at, created_at) VALUES
-- Review cho Booking 4 (BS. Cường - Khám tổng quát)
('55555555-aaaa-4000-a000-000000000001', '33333333-aaaa-4000-a000-000000000004', 'b2c3d4e5-2222-4000-b000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000003', 5, 'Bác sĩ Cường rất tận tâm và chu đáo. Giải thích bệnh tình rất dễ hiểu. Rất hài lòng!', 'Cảm ơn bạn đã tin tưởng. Nhớ tái khám sau 6 tháng nhé!', '2026-06-11 10:00:00', '2026-06-10 15:00:00'),

-- Review cho Booking 6 (BS. Cường - Xét nghiệm)
('55555555-aaaa-4000-a000-000000000002', '33333333-aaaa-4000-a000-000000000006', 'b2c3d4e5-2222-4000-b000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000003', 4, 'Dịch vụ xét nghiệm nhanh gọn, bác sĩ giải thích kết quả rõ ràng. Phòng khám sạch sẽ.', 'Cảm ơn bạn, hẹn gặp lại lần sau!', '2026-06-09 14:00:00', '2026-06-09 10:00:00'),

-- Đánh giá (reviews) cho BS. An (dr.nguyen@medic.com)
('55555555-bbbb-4000-a000-000000000001', '33333333-bbbb-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000001', 4, 'Bác sĩ khám nhiệt tình, phòng khám sạch sẽ.', NULL, NULL, '2026-05-10 10:30:00'),
('55555555-bbbb-4000-a000-000000000002', '33333333-bbbb-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000001', 5, 'Bác sĩ tư vấn rất kỹ lưỡng, chuyên môn cao.', NULL, NULL, '2026-06-02 15:30:00'),
('55555555-bbbb-4000-a000-000000000003', '33333333-bbbb-4000-a000-000000000003', 'b2c3d4e5-2222-4000-b000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000001', 5, 'Rất hài lòng về thái độ phục vụ của bác sĩ An.', NULL, NULL, '2026-06-15 10:00:00');

-- ============================================
-- 12. NOTIFICATIONS (Thông báo)
-- ============================================
INSERT INTO notifications (id, user_id, title, message, type, is_read, created_at, related_id) VALUES
-- Thông báo cho bệnh nhân Mai
('66666666-aaaa-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000001', 'Xác nhận lịch hẹn', 'Lịch hẹn khám Tim mạch với BS. Nguyễn Văn An vào ngày 17/06/2026 lúc 09:00 đã được xác nhận.', 'BOOKING', true, '2026-06-15 11:00:00', '33333333-aaaa-4000-a000-000000000001'),
('66666666-aaaa-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000001', 'Nhắc lịch khám', 'Bạn có lịch khám Tim mạch với BS. Nguyễn Văn An vào ngày mai (17/06/2026) lúc 09:00. Vui lòng đến đúng giờ.', 'REMINDER', false, '2026-06-16 09:00:00', '33333333-aaaa-4000-a000-000000000001'),
('66666666-aaaa-4000-a000-000000000003', 'b2c3d4e5-2222-4000-b000-000000000001', 'Kết quả xét nghiệm', 'Kết quả xét nghiệm máu của bạn đã sẵn sàng. Mọi chỉ số đều bình thường.', 'SYSTEM', true, '2026-06-08 09:30:00', '33333333-aaaa-4000-a000-000000000006'),

-- Thông báo cho bệnh nhân Hùng
('66666666-aaaa-4000-a000-000000000004', 'b2c3d4e5-2222-4000-b000-000000000002', 'Đặt lịch thành công', 'Bạn đã đặt lịch khám Da liễu với BS. Trần Thị Bích vào ngày 18/06/2026. Vui lòng chờ bác sĩ xác nhận.', 'BOOKING', true, '2026-06-16 14:00:00', '33333333-aaaa-4000-a000-000000000002'),

-- Thông báo cho bệnh nhân Hương
('66666666-aaaa-4000-a000-000000000005', 'b2c3d4e5-2222-4000-b000-000000000003', 'Xác nhận lịch hẹn', 'Lịch hẹn khám Nhi với BS. Phạm Minh Đức vào ngày 17/06/2026 lúc 13:30 đã được xác nhận.', 'BOOKING', true, '2026-06-15 10:00:00', '33333333-aaaa-4000-a000-000000000003'),
('66666666-aaaa-4000-a000-000000000006', 'b2c3d4e5-2222-4000-b000-000000000003', 'Nhắc lịch khám', 'Bạn có lịch khám Nhi cho bé với BS. Phạm Minh Đức vào ngày mai (17/06/2026) lúc 13:30.', 'REMINDER', false, '2026-06-16 13:30:00', '33333333-aaaa-4000-a000-000000000003'),

-- Thông báo cho bệnh nhân Lan Anh
('66666666-aaaa-4000-a000-000000000007', 'b2c3d4e5-2222-4000-b000-000000000005', 'Lịch hẹn đã hủy', 'Lịch hẹn Răng thẩm mỹ với BS. Võ Thanh Hà đã được hủy theo yêu cầu của bạn.', 'BOOKING', true, '2026-06-13 08:00:00', '33333333-aaaa-4000-a000-000000000005'),

-- Thông báo cho Bác sĩ An
('66666666-aaaa-4000-a000-000000000008', 'a1b2c3d4-1111-4000-a000-000000000001', 'Lịch hẹn mới', 'Bệnh nhân Nguyễn Thị Mai đã đặt lịch khám Tim mạch vào ngày 17/06/2026 lúc 09:00.', 'BOOKING', true, '2026-06-15 10:30:00', '33333333-aaaa-4000-a000-000000000001'),

-- Thông báo cho Bác sĩ Đức
('66666666-aaaa-4000-a000-000000000009', 'a1b2c3d4-1111-4000-a000-000000000004', 'Lịch hẹn mới', 'Bệnh nhân Lê Thị Hương đã đặt lịch khám Nhi vào ngày 17/06/2026 lúc 13:30.', 'BOOKING', true, '2026-06-15 09:00:00', '33333333-aaaa-4000-a000-000000000003'),

-- Thông báo hệ thống
('66666666-aaaa-4000-a000-000000000010', 'b2c3d4e5-2222-4000-b000-000000000001', 'Chào mừng', 'Chào mừng bạn đến với Medic Booking! Hãy đặt lịch khám đầu tiên của bạn ngay hôm nay.', 'SYSTEM', true, '2026-06-01 00:00:00', NULL),
('66666666-aaaa-4000-a000-000000000011', 'b2c3d4e5-2222-4000-b000-000000000002', 'Chào mừng', 'Chào mừng bạn đến với Medic Booking! Hãy đặt lịch khám đầu tiên của bạn ngay hôm nay.', 'SYSTEM', true, '2026-06-01 00:00:00', NULL);

-- ============================================
-- 13. CONVERSATIONS & MESSAGES (Chat mẫu)
-- ============================================

-- 1. TẠO CÁC CUỘC HỘI THOẠI (Conversations)
-- Sử dụng đúng User ID của bác sĩ (a1b2c3d4-1111-4000-a000-000000000001 cho BS. An, a1b2c3d4-1111-4000-a000-000000000004 cho BS. Đức)
INSERT INTO conversations (id, doctor_id, user_id, updated_at) VALUES
-- Hội thoại 1: BS. An và Bệnh nhân 1 (Nguyễn Thị Mai)
('77777777-aaaa-4000-a000-000000000001', 'a1b2c3d4-1111-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000001', '2026-06-17 08:30:00'),
-- Hội thoại 2: BS. Đức và Bệnh nhân 3 (Lê Thị Hương)
('77777777-aaaa-4000-a000-000000000002', 'a1b2c3d4-1111-4000-a000-000000000004', 'b2c3d4e5-2222-4000-b000-000000000003', '2026-06-15 20:20:00'),
-- Hội thoại 3: BS. An và Bệnh nhân 2 (Trần Văn Hùng)
('77777777-aaaa-4000-a000-000000000003', 'a1b2c3d4-1111-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000002', '2026-06-16 15:15:00'),
-- Hội thoại 4: BS. An và Bệnh nhân 4 (Phạm Quốc Bảo)
('77777777-aaaa-4000-a000-000000000004', 'a1b2c3d4-1111-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000004', '2026-06-17 07:45:00');

-- 2. TẠO CÁC TIN NHẮN (Messages)

-- Chat BS. An & Bệnh nhân 1 (Nguyễn Thị Mai)
INSERT INTO messages (id, conversation_id, sender_id, content, type, is_read, created_at) VALUES
('88888888-aaaa-4000-a000-000000000001', '77777777-aaaa-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000001', 'Chào bác sĩ, tôi muốn hỏi trước khi đến khám. Tôi hay bị đau ngực khi leo cầu thang, có đáng lo không ạ?', 'TEXT', true, '2026-06-15 10:35:00'),
('88888888-aaaa-4000-a000-000000000002', '77777777-aaaa-4000-a000-000000000001', 'a1b2c3d4-1111-4000-a000-000000000001', 'Chào bạn! Đau ngực khi gắng sức có thể do nhiều nguyên nhân. Bạn nên đến khám để tôi kiểm tra kỹ hơn nhé. Nhớ không ăn sáng trước khi đến để có thể làm xét nghiệm máu nếu cần.', 'TEXT', true, '2026-06-15 11:05:00'),
('88888888-aaaa-4000-a000-000000000003', '77777777-aaaa-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000001', 'Vâng, cảm ơn bác sĩ ạ. Em sẽ đến đúng giờ.', 'TEXT', true, '2026-06-15 11:10:00'),
('88888888-aaaa-4000-a000-000000000007', '77777777-aaaa-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000001', 'Bác sĩ ơi, tôi đã uống thuốc theo đơn hôm trước khám và giờ thấy lồng ngực êm hơn nhiều rồi ạ.', 'TEXT', false, '2026-06-17 08:30:00');

-- Chat BS. Đức & Bệnh nhân 3 (Lê Thị Hương)
INSERT INTO messages (id, conversation_id, sender_id, content, type, is_read, created_at) VALUES
('88888888-aaaa-4000-a000-000000000004', '77777777-aaaa-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000003', 'Bác sĩ ơi, con em bị sốt 38.5 độ từ tối qua, có nên cho uống hạ sốt không ạ?', 'TEXT', true, '2026-06-15 20:00:00'),
('88888888-aaaa-4000-a000-000000000005', '77777777-aaaa-4000-a000-000000000002', 'a1b2c3d4-1111-4000-a000-000000000004', 'Chào chị! Nếu bé sốt trên 38.5 độ thì cho bé uống Paracetamol theo liều cân nặng. Cho bé mặc đồ thoáng, chườm ấm và uống nhiều nước. Ngày mai đưa bé đến khám theo lịch hẹn nhé.', 'TEXT', true, '2026-06-15 20:15:00'),
('88888888-aaaa-4000-a000-000000000006', '77777777-aaaa-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000003', 'Dạ vâng, em cảm ơn bác sĩ nhiều ạ! Ngày mai em sẽ đưa bé đến.', 'TEXT', true, '2026-06-15 20:20:00');

-- ============================================
-- HOÀN TẤT SEED DATA
-- ============================================
-- Tóm tắt dữ liệu đã tạo:
-- • 1 Admin:    admin@medic.com      / admin123
-- • 5 Bác sĩ:  dr.nguyen@medic.com  / 123456  (Tim mạch)
--              dr.tran@medic.com    / 123456  (Da liễu)
--              dr.le@medic.com      / 123456  (Nội tổng quát)
--              dr.pham@medic.com    / 123456  (Nhi khoa)
--              dr.vo@medic.com      / 123456  (Răng Hàm Mặt)
-- • 5 Bệnh nhân: patient1-5@gmail.com / 123456
-- • 10 Dịch vụ y tế
-- • Lịch làm việc cho 5 bác sĩ
-- • 50+ khung giờ khám (tuần này & tuần sau)
-- • 6 lịch đặt khám mẫu (đủ trạng thái)
-- • 2 đánh giá từ bệnh nhân
-- • 11 thông báo
-- • 2 cuộc trò chuyện với 6 tin nhắn
