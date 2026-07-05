-- ============================================
-- SEED REVIEWS CHO BS. NGUYỄN VĂN AN (dr.nguyen@medic.com)
-- Bác sĩ ID: d4e5f6a7-4444-4000-d000-000000000001
-- ============================================

-- 1. Tạo các booking hoàn thành cho BS. An làm cơ sở đánh giá
INSERT INTO bookings (id, patient_id, doctor_id, service_id, time_slot_id, status, notes, created_at) VALUES
('33333333-bbbb-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000002', NULL, 'COMPLETED', 'Khám tim định kỳ.', '2026-05-10 09:00:00'),
('33333333-bbbb-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000002', NULL, 'COMPLETED', 'Tư vấn đau tức ngực.', '2026-06-02 14:00:00'),
('33333333-bbbb-4000-a000-000000000003', 'b2c3d4e5-2222-4000-b000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000001', 'e5f6a7b8-5555-4000-e000-000000000002', NULL, 'COMPLETED', 'Kiểm tra huyết áp cao.', '2026-06-15 08:30:00')
ON CONFLICT (id) DO NOTHING;

-- 2. Thêm các đánh giá (reviews) cho BS. An
-- 1 đánh giá vào tháng trước (Tháng 5/2026) -> 4 sao
-- 2 đánh giá vào tháng này (Tháng 6/2026) -> 5 sao
-- Tỉ lệ tăng trưởng đánh giá: ((2 - 1) / 1) * 100% = +100%
INSERT INTO reviews (id, booking_id, patient_id, doctor_id, rating, comment, created_at) VALUES
('55555555-bbbb-4000-a000-000000000001', '33333333-bbbb-4000-a000-000000000001', 'b2c3d4e5-2222-4000-b000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000001', 4, 'Bác sĩ khám nhiệt tình, phòng khám sạch sẽ.', '2026-05-10 10:30:00'),
('55555555-bbbb-4000-a000-000000000002', '33333333-bbbb-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000001', 5, 'Bác sĩ tư vấn rất kỹ lưỡng, chuyên môn cao.', '2026-06-02 15:30:00'),
('55555555-bbbb-4000-a000-000000000003', '33333333-bbbb-4000-a000-000000000003', 'b2c3d4e5-2222-4000-b000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000001', 5, 'Rất hài lòng về thái độ phục vụ của bác sĩ An.', '2026-06-15 10:00:00')
ON CONFLICT (id) DO NOTHING;

-- 3. Đồng bộ lại điểm số trung bình và tổng lượt đánh giá của BS. An trong bảng doctors
UPDATE doctors 
SET rating = 4.7, total_reviews = 3 
WHERE id = 'd4e5f6a7-4444-4000-d000-000000000001';
