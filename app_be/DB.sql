-- ============================================
-- DATABASE SETUP SCRIPT FOR MEDIC_APP (public schema)
-- Tương thích 100% với Supabase SQL Editor & Java Spring Boot backend
-- Sửa lỗi cú pháp, tích hợp đầy đủ cột và Trigger nghiệp vụ tự động
-- ============================================

-- Khởi tạo extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. XÓA BẢNG VÀ PHÂN LOẠI CŨ (Nếu muốn cài đặt lại từ đầu)
-- ============================================

DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS booking_status_history CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS time_slots CASCADE;
DROP TABLE IF EXISTS doctor_services CASCADE;
DROP TABLE IF EXISTS medical_services CASCADE;
DROP TABLE IF EXISTS doctor_schedules CASCADE;
DROP TABLE IF EXISTS doctors CASCADE;
DROP TABLE IF EXISTS refresh_tokens CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS booking_status CASCADE;
DROP TYPE IF EXISTS notification_type CASCADE;
DROP TYPE IF EXISTS gender_type CASCADE;

-- ============================================
-- 2. TẠO CÁC KIỂU ENUM
-- ============================================
CREATE TYPE user_role AS ENUM ('ADMIN', 'DOCTOR', 'PATIENT');
CREATE TYPE booking_status AS ENUM ('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'CANCELED');
CREATE TYPE notification_type AS ENUM ('BOOKING', 'SYSTEM', 'REMINDER');
CREATE TYPE gender_type AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- ============================================
-- 3. TẠO CÁC BẢNG CORE
-- ============================================
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name user_role UNIQUE NOT NULL
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role user_role NOT NULL,
    enabled BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    avatar_url TEXT,
    full_name TEXT,
    phone TEXT,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    full_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    address TEXT,
    dob DATE,
    gender gender_type
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    revoked BOOLEAN DEFAULT false
);

-- ============================================
-- 4. BÁC SĨ & DỊCH VỤ Y TẾ
-- ============================================
CREATE TABLE doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    specialty TEXT,
    description TEXT,
    rating NUMERIC(2,1) DEFAULT 0.0,
    is_available BOOLEAN DEFAULT true,
    avatar_url TEXT,
    consultation_fee NUMERIC DEFAULT 0,
    phone TEXT,
    total_reviews INT DEFAULT 0,
    full_name TEXT,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE medical_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL,
    duration_minutes INT NOT NULL,
    category TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE doctor_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
    service_id UUID REFERENCES medical_services(id) ON DELETE CASCADE
);

-- ============================================
-- 5. LỊCH LÀM VIỆC & KHUNG GIỜ KHÁM
-- ============================================
CREATE TABLE doctor_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
    day_of_week INT CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT true,
    slot_duration_minutes INT DEFAULT 30
);

CREATE TABLE time_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
    schedule_id UUID REFERENCES doctor_schedules(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT true,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',  -- PENDING, APPROVED, REJECTED
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    version BIGINT DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_time_slots_status ON time_slots(status);

-- ============================================
-- 6. ĐẶT LỊCH KHÁM & LỊCH SỬ TRẠNG THÁI
-- ============================================
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID REFERENCES users(id),
    doctor_id UUID REFERENCES doctors(id),
    service_id UUID REFERENCES medical_services(id),
    time_slot_id UUID REFERENCES time_slots(id),
    status booking_status DEFAULT 'PENDING',
    notes TEXT,
    doctor_notes TEXT,
    cancellation_reason TEXT,
    cancelled_by UUID,
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'UNPAID',
    payment_method VARCHAR(30),
    payment_reference VARCHAR(100),
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_bookings_payment_status ON bookings(payment_status);
CREATE INDEX IF NOT EXISTS idx_bookings_payment_reference ON bookings(payment_reference);

CREATE TABLE booking_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    old_status booking_status,
    new_status booking_status,
    changed_by UUID REFERENCES users(id),
    reason TEXT,
    changed_at TIMESTAMP DEFAULT now()
);

-- ============================================
-- 7. ĐÁNH GIÁ, THÔNG BÁO & AUDIT LOG
-- ============================================
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES users(id),
    doctor_id UUID REFERENCES doctors(id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    doctor_reply TEXT,
    doctor_reply_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT,
    message TEXT,
    type notification_type,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT now(),
    read_at TIMESTAMP,
    related_id UUID
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action TEXT,
    entity TEXT,
    entity_id UUID,
    details JSONB,
    created_at TIMESTAMP DEFAULT now()
);

-- Bảng hội thoại chat
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id UUID NOT NULL,
    user_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    UNIQUE(doctor_id, user_id)
);

-- Bảng tin nhắn chat
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id),
    sender_id UUID NOT NULL,
    content TEXT,
    image_url TEXT,
    type VARCHAR(20) DEFAULT 'TEXT', -- 'TEXT', 'IMAGE'
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT now()
);

-- ============================================
-- 8. TẠO HÀM TRIGGER (FUNCTIONS)
-- ============================================

-- Hàm cập nhật tự động cột updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Hàm tự động ghi lịch sử thay đổi booking status
CREATE OR REPLACE FUNCTION public.log_booking_status()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO booking_status_history (booking_id, old_status, new_status, changed_at)
        VALUES (OLD.id, OLD.status, NEW.status, now());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 9. KHỞI TẠO TRIGGER TRÊN CÁC BẢNG
-- ============================================

-- Trigger log trạng thái đặt lịch
CREATE TRIGGER tr_log_booking_status
AFTER UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION log_booking_status();

-- Triggers tự động cập nhật thời gian updated_at
CREATE TRIGGER tr_update_booking_time
BEFORE UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER tr_update_users_time
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER tr_update_doctors_time
BEFORE UPDATE ON doctors
FOR EACH ROW
EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER tr_update_services_time
BEFORE UPDATE ON medical_services
FOR EACH ROW
EXECUTE FUNCTION handle_updated_at();

-- ============================================
-- 10. DỮ LIỆU MẪU CƠ BẢN (SEED DATA)
-- ============================================

-- Tạo Roles mặc định
INSERT INTO roles (id, name) VALUES
('0cb60fb8-af36-4d07-a2de-0570cde3cc0e', 'ADMIN'),
('2eae985b-50e0-495b-926f-13b29c2423be', 'DOCTOR'),
('37be9a46-8054-49a0-b7bd-4691e96e0ba1', 'PATIENT')
ON CONFLICT (name) DO NOTHING;

-- Tạo tài khoản Admin mặc định (Email: admin@medic.com / Mật khẩu: admin123)
INSERT INTO users (id, email, password_hash, role, enabled, full_name, phone) VALUES
('42eb1bbf-349d-458e-b961-f00bf197f53e', 'admin@medic.com', '$2a$10$lTS.VLVz6rdo2sIVU/hPI.U5CLXEDlvhIMo2QIqPsM4VNCQmemf3.', 'ADMIN', true, 'Admin User', '0123456789')
ON CONFLICT (email) DO NOTHING;
