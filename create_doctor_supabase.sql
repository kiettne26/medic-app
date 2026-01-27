-- Script tạo tài khoản Bác sĩ cho Supabase (hoặc PostgreSQL)

-- Mật khẩu mặc định là: 123456
-- Hash này được tạo từ chuẩn BCrypt ($2a$10$...)
INSERT INTO users (
    id, 
    email, 
    password_hash, 
    full_name, 
    role, 
    enabled, 
    created_at, 
    updated_at
) 
VALUES (
    gen_random_uuid(), -- Tạo UUID ngẫu nhiên
    'doctor@example.com', -- Thay đổi email của bạn tại đây
    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOcd7qa8qX.2O', -- Hash của '123456'
    'Dr. John Doe', 
    'DOCTOR', 
    true, 
    NOW(), 
    NOW()
);