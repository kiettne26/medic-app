-- Add payment fields to an existing Medic App database without dropping data.
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS total_amount NUMERIC(12, 2) DEFAULT 0;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'UNPAID';
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_method VARCHAR(30);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_reference VARCHAR(100);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS paid_at TIMESTAMP;

UPDATE bookings
SET payment_status = 'UNPAID'
WHERE payment_status IS NULL;

UPDATE bookings b
SET total_amount = COALESCE(ms.price, 0)
FROM medical_services ms
WHERE b.service_id = ms.id
  AND (b.total_amount IS NULL OR b.total_amount = 0);

ALTER TABLE bookings ALTER COLUMN total_amount SET DEFAULT 0;
ALTER TABLE bookings ALTER COLUMN total_amount SET NOT NULL;
ALTER TABLE bookings ALTER COLUMN payment_status SET DEFAULT 'UNPAID';
ALTER TABLE bookings ALTER COLUMN payment_status SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_bookings_payment_status ON bookings(payment_status);
CREATE INDEX IF NOT EXISTS idx_bookings_payment_reference ON bookings(payment_reference);
