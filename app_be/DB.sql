-- ==========================
-- EXTENSIONS (nếu cần)
-- ==========================
create extension if not exists "uuid-ossp";

-- ==========================
-- ENUM TYPES
-- ==========================
create type user_role as enum ('ADMIN', 'DOCTOR', 'PATIENT');
create type booking_status as enum ('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'CANCELED');
create type notification_type as enum ('BOOKING', 'SYSTEM', 'REMINDER');
CREATE TYPE gender_type AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- ==========================
-- CORE TABLES
-- ==========================
create table roles (
    id uuid primary key default uuid_generate_v4(),
    name user_role unique not null
);

create table users (
    id uuid primary key default uuid_generate_v4(),
    email text unique not null,
    password_hash text not null,
    role user_role not null,
    enabled boolean default true,
    created_at timestamp default now()
);

create table profiles (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references users(id) on delete cascade,
    full_name text,
    phone text,
    avatar_url text,
    address text,
    gender gender_type
    dob date
);

create table refresh_tokens (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references users(id) on delete cascade,
    token text not null,
    expires_at timestamp not null
);

-- ==========================
-- DOCTOR & SERVICES
-- ==========================
create table doctors (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references users(id) on delete cascade,
    specialty text,
    description text,
    avatar_url text,
    rating numeric(2,1) default 0,
    is_available boolean default true
);

create table medical_services (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    description text,
    price numeric not null,
    duration_minutes int not null,
    category text
);

create table doctor_services (
    id uuid primary key default uuid_generate_v4(),
    doctor_id uuid references doctors(id) on delete cascade,
    service_id uuid references medical_services(id) on delete cascade
);

-- ==========================
-- SCHEDULING
-- ==========================
create table doctor_schedules (
    id uuid primary key default uuid_generate_v4(),
    doctor_id uuid references doctors(id) on delete cascade,
    day_of_week int check (day_of_week between 0 and 6),
    start_time time not null,
    end_time time not null,
    is_active boolean default true
);

create table time_slots (
    id uuid primary key default uuid_generate_v4(),
    doctor_id uuid references doctors(id) on delete cascade,
    schedule_id uuid references doctor_schedules(id) on delete cascade,
    date date not null,
    start_time time not null,
    end_time time not null,
    is_available boolean default true,
    status varchar(20) not null default 'PENDING',  -- PENDING, APPROVED, REJECTED
    created_at timestamp default now(),
    updated_at timestamp with time zone,
    version bigint default 0
);

-- Index cho status (admin queries)
create index idx_time_slots_status on time_slots(status);

-- ==========================
-- BOOKING (CORE)
-- ==========================
create table bookings (
    id uuid primary key default uuid_generate_v4(),
    patient_id uuid references users(id),
    doctor_id uuid references doctors(id),
    service_id uuid references medical_services(id),
    time_slot_id uuid references time_slots(id),
    status booking_status default 'PENDING',
    notes text,
    doctor_notes text,
    cancellation_reason text,
    cancelled_by uuid,
    created_at timestamp default now(),
    updated_at timestamp default now()
);

create table booking_status_history (
    id uuid primary key default uuid_generate_v4(),
    booking_id uuid references bookings(id) on delete cascade,
    old_status booking_status,
    new_status booking_status,
    changed_by uuid references users(id),
    reason text,
    changed_at timestamp default now()
);

-- ==========================
-- REVIEWS & NOTIFICATIONS
-- ==========================
create table reviews (
    id uuid primary key default uuid_generate_v4(),
    booking_id uuid references bookings(id) on delete cascade,
    patient_id uuid references users(id),
    doctor_id uuid references doctors(id),
    rating int check (rating between 1 and 5),
    comment text,
    doctor_reply text,
    doctor_reply_at timestamp,
    created_at timestamp default now()
);

create table notifications (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references users(id) on delete cascade,
    title text,
    message text,
    type notification_type,
    is_read boolean default false,
    created_at timestamp default now()
);

create table audit_logs (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references users(id),
    action text,
    entity text,
    entity_id uuid,
    details jsonb,
    created_at timestamp default now()
);

-- Bảng hội thoại (quản lý ai chat với ai)
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id UUID NOT NULL,
    user_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(doctor_id, user_id) -- Mỗi cặp chỉ có 1 hội thoại
);
-- Bảng tin nhắn
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id),
    sender_id UUID NOT NULL, -- ID của người gửi (User hoặc Doctor)
    content TEXT,
    image_url TEXT,
    type VARCHAR(20) DEFAULT 'TEXT', -- 'TEXT', 'IMAGE'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);