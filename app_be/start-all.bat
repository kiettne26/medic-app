@echo off
echo ========================================
echo  MEDICAL BOOKING SYSTEM - START ALL
echo ========================================
echo.

REM Load environment variables from .env file if it exists
if exist "%~dp0.env" (
    echo Loading environment variables from .env...
    for /f "usebackq tokens=1* delims==" %%I in ("%~dp0.env") do (
        set "%%I=%%J"
    )
) else (
    echo [WARN] .env file not found. Using default environment variables.
    set SUPABASE_HOST=localhost
    set SUPABASE_PORT=5432
    set SUPABASE_USER=postgres
    set SUPABASE_PASSWORD=postgres
    set JWT_SECRET=YOUR_JWT_SECRET
    set GEMINI_API_KEY=YOUR_GEMINI_API_KEY
)

REM Gmail SMTP config is loaded from a local file so secrets are not committed.
if exist "%~dp0mail-env.bat" (
    call "%~dp0mail-env.bat"
) else (
    echo [WARN] mail-env.bat not found. Email verification will not send real Gmail.
    echo        Copy mail-env.example.bat to mail-env.bat and fill MAIL_USERNAME/MAIL_PASSWORD.
)

if "%MAIL_USERNAME%"=="" echo [WARN] MAIL_USERNAME is empty. Gmail verification emails will fail.
if "%MAIL_PASSWORD%"=="" echo [WARN] MAIL_PASSWORD is empty. Gmail verification emails will fail.
if /I "%MAIL_USERNAME%"=="your-sender@gmail.com" echo [WARN] MAIL_USERNAME is still the example value.
if /I "%MAIL_PASSWORD%"=="your-16-character-gmail-app-password" echo [WARN] MAIL_PASSWORD is still the example value.

REM ZaloPay config is loaded from a local file so secrets are not committed.
if exist "%~dp0payment-env.bat" (
    call "%~dp0payment-env.bat"
) else (
    echo [WARN] payment-env.bat not found. Online payment will not create real ZaloPay orders.
    echo        Copy payment-env.example.bat to payment-env.bat and fill ZALOPAY_APP_ID/ZALOPAY_KEY1/ZALOPAY_KEY2.
)

if "%ZALOPAY_APP_ID%"=="" echo [WARN] ZALOPAY_APP_ID is empty. ZaloPay payment will fail.
if "%ZALOPAY_APP_ID%"=="0" echo [WARN] ZALOPAY_APP_ID is 0. ZaloPay payment will fail until you set a real app id.
if "%ZALOPAY_KEY1%"=="" echo [WARN] ZALOPAY_KEY1 is empty. ZaloPay payment will fail.
if "%ZALOPAY_KEY2%"=="" echo [WARN] ZALOPAY_KEY2 is empty. ZaloPay callback verification will fail.
if /I "%ZALOPAY_APP_ID%"=="your-zalopay-app-id" echo [WARN] ZALOPAY_APP_ID is still the example value.
if /I "%ZALOPAY_KEY1%"=="your-zalopay-key1" echo [WARN] ZALOPAY_KEY1 is still the example value.
if /I "%ZALOPAY_KEY2%"=="your-zalopay-key2" echo [WARN] ZALOPAY_KEY2 is still the example value.

echo.
echo Installing shared modules...
call mvn -pl common install -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install shared modules. Services were not started.
    pause
    exit /b 1
)

echo Starting Eureka Server (Port 8761)...
start "Eureka Server" cmd /k "cd eureka-server && mvn spring-boot:run"
ping 127.0.0.1 -n 21 > nul

echo Starting API Gateway (Port 8080)...
start "API Gateway" cmd /k "cd api-gateway && mvn spring-boot:run"
ping 127.0.0.1 -n 11 > nul

echo Starting Auth Service (Port 8081)...
start "Auth Service" cmd /k "cd auth-service && mvn spring-boot:run"
ping 127.0.0.1 -n 11 > nul

echo Starting User Service (Port 8082)...
start "User Service" cmd /k "cd user-service && mvn spring-boot:run"
ping 127.0.0.1 -n 11 > nul

echo Starting Booking Service (Port 8083)...
start "Booking Service" cmd /k "cd booking-service && mvn spring-boot:run"
ping 127.0.0.1 -n 11 > nul

echo Starting Notification Service (Port 8084)...
start "Notification Service" cmd /k "cd notification-service && mvn spring-boot:run"
ping 127.0.0.1 -n 11 > nul

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
