@echo off
echo ========================================
echo  MEDICAL BOOKING SYSTEM - START ALL
echo ========================================
echo.

REM Set environment variables - CẬP NHẬT PASSWORD CỦA BẠN
set SUPABASE_HOST=db.dslbtevbqmxlmulqxcqk.supabase.co
set SUPABASE_PORT=5432
set SUPABASE_USER=postgres
set SUPABASE_PASSWORD=chukiet2609
set JWT_SECRET=5367566B59703373367639792F423F4528482B4D6251655468576D5A71347437

echo Starting Eureka Server (Port 8761)...
start "Eureka Server" cmd /k "cd eureka-server && mvn spring-boot:run"
timeout /t 20

echo Starting API Gateway (Port 8080)...
start "API Gateway" cmd /k "cd api-gateway && mvn spring-boot:run"
timeout /t 10

echo Starting Auth Service (Port 8081)...
start "Auth Service" cmd /k "cd auth-service && mvn spring-boot:run"
timeout /t 10

echo Starting User Service (Port 8082)...
start "User Service" cmd /k "cd user-service && mvn spring-boot:run"
timeout /t 10

echo Starting Booking Service (Port 8083)...
start "Booking Service" cmd /k "cd booking-service && mvn spring-boot:run"
timeout /t 10

echo Starting Notification Service (Port 8084)...
start "Notification Service" cmd /k "cd notification-service && mvn spring-boot:run"
timeout /t 10

echo Starting Analytics Service (Port 8085)...
start "Analytics Service" cmd /k "cd analytics-service && mvn spring-boot:run"

echo.
echo ========================================
echo  All services starting...
echo.
echo  Eureka Dashboard: http://localhost:8761
echo  API Gateway: http://localhost:8080
echo  Swagger UIs:
echo    - Auth: http://localhost:8081/swagger-ui.html
echo    - User: http://localhost:8082/swagger-ui.html
echo    - Booking: http://localhost:8083/swagger-ui.html
echo    - Notification: http://localhost:8084/swagger-ui.html
echo    - Analytics: http://localhost:8085/swagger-ui.html
echo ========================================
pause
