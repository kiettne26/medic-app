# Medical Booking System - Backend

Hệ thống đặt lịch khám và tư vấn trực tuyến đa nền tảng với kiến trúc Microservices.

## 📋 Yêu cầu

- Java 21+
- Maven 3.8+
- PostgreSQL (Supabase)

## 🏗️ Kiến trúc

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT APPS                               │
│    Flutter Mobile  │  Web Admin  │  Web Doctor               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   API GATEWAY (:8080)                        │
│                  Spring Cloud Gateway                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 EUREKA SERVER (:8761)                        │
│                  Service Discovery                           │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ Auth Service  │   │ User Service  │   │Booking Service│
│   (:8081)     │   │   (:8082)     │   │   (:8083)     │
│   JWT Auth    │   │ Doctor/Service│   │  🔐 Lock      │
└───────────────┘   └───────────────┘   └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐
│Notification   │   │Analytics      │
│Service (:8084)│   │Service (:8085)│
│  WebSocket    │   │  Dashboard    │
└───────────────┘   └───────────────┘
                              │
                              ▼
                    ┌───────────────┐
                    │   SUPABASE    │
                    │  PostgreSQL   │
                    └───────────────┘
```

## 🚀 Cách chạy

### 1. Cấu hình Supabase

Mở file `start-all.bat` và cập nhật:

```batch
set SUPABASE_HOST=db.YOUR_PROJECT.supabase.co
set SUPABASE_USER=postgres
set SUPABASE_PASSWORD=your-password
set JWT_SECRET=your-256-bit-secret-key-at-least-32-chars
```

### 2. Build project

```bash
# Build tất cả modules
.\build-all.bat

# Hoặc dùng Maven trực tiếp
mvn clean install -DskipTests
```

### 3. Chạy services

```bash
# Chạy tất cả services
.\start-all.bat
```

### 4. Kiểm tra

- **Eureka Dashboard**: http://localhost:8761
- **API Gateway**: http://localhost:8080
- **Swagger UIs**:
  - Auth: http://localhost:8081/swagger-ui.html
  - User: http://localhost:8082/swagger-ui.html
  - Booking: http://localhost:8083/swagger-ui.html
  - Notification: http://localhost:8084/swagger-ui.html
  - Analytics: http://localhost:8085/swagger-ui.html

## 📦 Services

| Service | Port | Chức năng |
|---------|------|-----------|
| eureka-server | 8761 | Service Discovery |
| api-gateway | 8080 | Routing, CORS, Load Balancing |
| auth-service | 8081 | JWT Auth, Register/Login |
| user-service | 8082 | Doctor, Medical Service |
| booking-service | 8083 | 🔐 Đặt lịch với Transaction + Lock |
| notification-service | 8084 | WebSocket, Email |
| analytics-service | 8085 | Dashboard, Reports |

## 🔐 Chống Double Booking

Booking Service sử dụng:
- **Transaction Isolation SERIALIZABLE**
- **Pessimistic Write Lock** trên TimeSlot
- Đảm bảo một bác sĩ - một thời điểm - chỉ một bệnh nhân

## 📡 API Endpoints

### Authentication
```
POST /api/auth/register - Đăng ký
POST /api/auth/login    - Đăng nhập
POST /api/auth/refresh  - Refresh token
```

### Doctors
```
GET  /api/doctors           - Danh sách bác sĩ
GET  /api/doctors/{id}      - Chi tiết bác sĩ
POST /api/doctors           - Tạo bác sĩ (Admin)
```

### Bookings
```
POST /api/bookings              - Đặt lịch
GET  /api/bookings/patient      - Lịch của bệnh nhân
GET  /api/bookings/doctor       - Lịch của bác sĩ
PUT  /api/bookings/{id}/confirm - Xác nhận (Bác sĩ)
PUT  /api/bookings/{id}/cancel  - Hủy lịch
```

### Slots
```
GET /api/slots/available?doctorId=...&date=... - Lịch trống
```

## 📝 Notes

- Email hiện tại được log ra console (không có SMTP)
- Có thể tích hợp Resend/Mailgun sau
- WebSocket endpoint: `ws://localhost:8084/ws`
