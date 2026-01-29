-- ============================================
-- SUPABASE: Script tạo admin user để test login
-- Password: admin123 (BCrypt encoded)
-- ============================================

-- BƯỚC 1: Thêm các cột cần thiết cho entity Java (nếu chưa có)
-- Chạy từng lệnh một trong Supabase SQL Editor

ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at timestamp default now();

-- BƯỚC 2: Đổi role từ enum sang varchar (nếu đang là enum)
-- Uncomment nếu cần:
-- ALTER TABLE users ALTER COLUMN role TYPE varchar(20) USING role::text;

-- BƯỚC 3: Insert admin user
-- Password 'admin123' được encode bằng BCrypt
INSERT INTO users (id, email, password_hash, role, full_name, phone, enabled, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'admin@medic.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMy.MQDOiqBXXCPUdD5dpvMoMg3wXAJ0hYK',
    'ADMIN',
    'Admin User',
    '0123456789',
    true,
    now(),
    now()
)
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- KIỂM TRA:
-- SELECT * FROM users WHERE email = 'admin@medic.com';
-- ============================================

-- THÔNG TIN ĐĂNG NHẬP:
-- Email: admin@medic.com
-- Password: admin123
