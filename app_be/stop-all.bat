@echo off
echo ========================================
echo  STOPPING ALL MICROSERVICES
echo ========================================

echo Stopping Analytics Service...
taskkill /FI "WINDOWTITLE eq Analytics Service" /F

echo Stopping Notification Service...
taskkill /FI "WINDOWTITLE eq Notification Service" /F

echo Stopping Booking Service...
taskkill /FI "WINDOWTITLE eq Booking Service" /F

echo Stopping User Service...
taskkill /FI "WINDOWTITLE eq User Service" /F

echo Stopping Auth Service...
taskkill /FI "WINDOWTITLE eq Auth Service" /F

echo Stopping API Gateway...
taskkill /FI "WINDOWTITLE eq API Gateway" /F

echo Stopping Eureka Server...
taskkill /FI "WINDOWTITLE eq Eureka Server" /F

echo.
echo All services stopped (or attempted to stop).
echo Note: If windows remain open, please close them manually.
pause
