-- ============================================
-- SYNC JULY 2026 TEST DATA TO EXISTING DOCTORS
-- Moves slots/bookings created for temporary july.* doctors to existing doctors,
-- removes duplicate july.* doctor accounts, and ensures doctor avatars exist.
-- Re-runnable after app_be/seed_july_2026_test_data.sql.
-- ============================================

BEGIN;

CREATE TEMP TABLE IF NOT EXISTS _july_doctor_map (
    old_doctor_id UUID PRIMARY KEY,
    new_doctor_id UUID NOT NULL,
    old_user_id UUID NOT NULL,
    new_user_id UUID NOT NULL,
    avatar_url TEXT NOT NULL
) ON COMMIT DROP;

TRUNCATE TABLE _july_doctor_map;

INSERT INTO _july_doctor_map (old_doctor_id, new_doctor_id, old_user_id, new_user_id, avatar_url) VALUES
('94000000-0000-4000-8000-000000000001', 'd4e5f6a7-4444-4000-d000-000000000001', '91000000-0000-4000-8000-000000000001', 'a1b2c3d4-1111-4000-a000-000000000001', 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=400&auto=format&fit=crop'),
('94000000-0000-4000-8000-000000000002', 'd4e5f6a7-4444-4000-d000-000000000002', '91000000-0000-4000-8000-000000000002', 'a1b2c3d4-1111-4000-a000-000000000002', 'https://images.unsplash.com/photo-1614608682850-e0d6ed316d47?q=80&w=400&auto=format&fit=crop'),
('94000000-0000-4000-8000-000000000003', 'd4e5f6a7-4444-4000-d000-000000000003', '91000000-0000-4000-8000-000000000003', 'a1b2c3d4-1111-4000-a000-000000000003', 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=400&auto=format&fit=crop'),
('94000000-0000-4000-8000-000000000004', 'd4e5f6a7-4444-4000-d000-000000000004', '91000000-0000-4000-8000-000000000004', 'a1b2c3d4-1111-4000-a000-000000000004', 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=400&auto=format&fit=crop'),
('94000000-0000-4000-8000-000000000005', 'd4e5f6a7-4444-4000-d000-000000000005', '91000000-0000-4000-8000-000000000005', 'a1b2c3d4-1111-4000-a000-000000000005', 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=400&auto=format&fit=crop');

UPDATE doctors d
SET avatar_url = COALESCE(NULLIF(d.avatar_url, ''), m.avatar_url),
    is_available = true,
    updated_at = now()
FROM _july_doctor_map m
WHERE d.id = m.new_doctor_id;

UPDATE users u
SET avatar_url = COALESCE(NULLIF(u.avatar_url, ''), m.avatar_url),
    updated_at = now()
FROM _july_doctor_map m
WHERE u.id = m.new_user_id;

UPDATE profiles p
SET avatar_url = COALESCE(NULLIF(p.avatar_url, ''), m.avatar_url)
FROM _july_doctor_map m
WHERE p.user_id = m.new_user_id;

UPDATE bookings b
SET doctor_id = m.new_doctor_id,
    updated_at = now()
FROM _july_doctor_map m
WHERE b.doctor_id = m.old_doctor_id;

UPDATE reviews r
SET doctor_id = m.new_doctor_id
FROM _july_doctor_map m
WHERE r.doctor_id = m.old_doctor_id;

UPDATE time_slots ts
SET doctor_id = m.new_doctor_id,
    schedule_id = NULL,
    updated_at = now()
FROM _july_doctor_map m
WHERE ts.doctor_id = m.old_doctor_id
  AND ts.date BETWEEN DATE '2026-07-01' AND DATE '2026-07-10';

UPDATE booking_status_history h
SET changed_by = m.new_user_id
FROM _july_doctor_map m
WHERE h.changed_by = m.old_user_id;

UPDATE notifications n
SET user_id = m.new_user_id
FROM _july_doctor_map m
WHERE n.user_id = m.old_user_id;

UPDATE conversations c
SET doctor_id = m.new_user_id,
    updated_at = now()
FROM _july_doctor_map m
WHERE c.doctor_id = m.old_user_id;

UPDATE messages msg
SET sender_id = m.new_user_id
FROM _july_doctor_map m
WHERE msg.sender_id = m.old_user_id;

DELETE FROM doctor_services
WHERE doctor_id IN (SELECT old_doctor_id FROM _july_doctor_map);

DELETE FROM doctor_schedules
WHERE doctor_id IN (SELECT old_doctor_id FROM _july_doctor_map);

DELETE FROM profiles
WHERE user_id IN (SELECT old_user_id FROM _july_doctor_map);

DELETE FROM doctors
WHERE id IN (SELECT old_doctor_id FROM _july_doctor_map);

DELETE FROM users
WHERE id IN (SELECT old_user_id FROM _july_doctor_map);

SELECT
    'sync_july_2026_existing_doctors' AS label,
    (SELECT COUNT(*) FROM doctors WHERE id IN (SELECT old_doctor_id FROM _july_doctor_map)) AS remaining_july_doctors,
    (SELECT COUNT(*) FROM time_slots WHERE doctor_id IN (SELECT new_doctor_id FROM _july_doctor_map) AND date BETWEEN DATE '2026-07-01' AND DATE '2026-07-10') AS synced_slots,
    (SELECT COUNT(*) FROM bookings WHERE doctor_id IN (SELECT new_doctor_id FROM _july_doctor_map) AND id::TEXT LIKE '98000000-0000-4000-8000-%') AS synced_bookings,
    (SELECT COUNT(*) FROM doctors WHERE id IN (SELECT new_doctor_id FROM _july_doctor_map) AND avatar_url IS NOT NULL AND avatar_url <> '') AS doctors_with_avatar;

COMMIT;