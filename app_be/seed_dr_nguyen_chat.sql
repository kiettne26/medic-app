-- ============================================
-- SEED DỮ LIỆU TIN NHẮN CHO BS. NGUYỄN VĂN AN (dr.nguyen@medic.com)
-- Bác sĩ User ID: a1b2c3d4-1111-4000-a000-000000000001
-- ============================================

-- Xóa dữ liệu chat mẫu bị sai ID trước đó
DELETE FROM messages WHERE conversation_id IN ('77777777-aaaa-4000-a000-000000000001', '77777777-aaaa-4000-a000-000000000002', '77777777-aaaa-4000-a000-000000000003', '77777777-aaaa-4000-a000-000000000004');
DELETE FROM conversations WHERE id IN ('77777777-aaaa-4000-a000-000000000001', '77777777-aaaa-4000-a000-000000000002', '77777777-aaaa-4000-a000-000000000003', '77777777-aaaa-4000-a000-000000000004');

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

-- Chat BS. Đức & Bệnh nhân 3 (Lê Thị Hương) (Đã sửa sender_id và mapping)
INSERT INTO messages (id, conversation_id, sender_id, content, type, is_read, created_at) VALUES
('88888888-aaaa-4000-a000-000000000004', '77777777-aaaa-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000003', 'Bác sĩ ơi, con em bị sốt 38.5 độ từ tối qua, có nên cho uống hạ sốt không ạ?', 'TEXT', true, '2026-06-15 20:00:00'),
('88888888-aaaa-4000-a000-000000000005', '77777777-aaaa-4000-a000-000000000002', 'a1b2c3d4-1111-4000-a000-000000000004', 'Chào chị! Nếu bé sốt trên 38.5 độ thì cho bé uống Paracetamol theo liều cân nặng. Cho bé mặc đồ thoáng, chườm ấm và uống nhiều nước. Ngày mai đưa bé đến khám theo lịch hẹn nhé.', 'TEXT', true, '2026-06-15 20:15:00'),
('88888888-aaaa-4000-a000-000000000006', '77777777-aaaa-4000-a000-000000000002', 'b2c3d4e5-2222-4000-b000-000000000003', 'Dạ vâng, em cảm ơn bác sĩ nhiều ạ! Ngày mai em sẽ đưa bé đến.', 'TEXT', true, '2026-06-15 20:20:00');

-- Chat BS. An & Bệnh nhân 2 (Trần Văn Hùng)
INSERT INTO messages (id, conversation_id, sender_id, content, type, is_read, created_at) VALUES
('88888888-bbbb-4000-a000-000000000011', '77777777-aaaa-4000-a000-000000000003', 'b2c3d4e5-2222-4000-b000-000000000002', 'Chào bác sĩ An, tôi muốn hỏi lịch tái khám tim mạch của tôi vào tuần tới có cần làm xét nghiệm máu trước không?', 'TEXT', true, '2026-06-16 14:20:00'),
('88888888-bbbb-4000-a000-000000000012', '77777777-aaaa-4000-a000-000000000003', 'a1b2c3d4-1111-4000-a000-000000000001', 'Chào anh Hùng, trước khi tái khám anh nên nhịn ăn sáng để làm xét nghiệm sinh hóa máu và đo điện tâm đồ nhé.', 'TEXT', true, '2026-06-16 15:00:00'),
('88888888-bbbb-4000-a000-000000000013', '77777777-aaaa-4000-a000-000000000003', 'b2c3d4e5-2222-4000-b000-000000000002', 'Dạ vâng, cảm ơn bác sĩ. Tôi sẽ nhịn ăn sáng và đến sớm.', 'TEXT', true, '2026-06-16 15:15:00');

-- Chat BS. An & Bệnh nhân 4 (Phạm Quốc Bảo)
INSERT INTO messages (id, conversation_id, sender_id, content, type, is_read, created_at) VALUES
('88888888-cccc-4000-a000-000000000021', '77777777-aaaa-4000-a000-000000000004', 'b2c3d4e5-2222-4000-b000-000000000004', 'Chào bác sĩ, dạo này tôi hay bị chóng mặt vào sáng sớm khi vừa thức dậy, có phải biểu hiện của huyết áp thấp không?', 'TEXT', false, '2026-06-17 07:00:00'),
('88888888-cccc-4000-a000-000000000022', '77777777-aaaa-4000-a000-000000000004', 'a1b2c3d4-1111-4000-a000-000000000001', 'Chào anh, chóng mặt khi đổi tư thế đột ngột có thể do tụt huyết áp tư thế. Anh nên tránh ngồi dậy quá nhanh, uống đủ nước và đo huyết áp tại nhà để theo dõi thêm nhé.', 'TEXT', true, '2026-06-17 07:45:00');
