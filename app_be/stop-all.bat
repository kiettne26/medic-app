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

echo Releasing backend ports...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ports = @(8761,8080,8081,8082,8083,8084,8085); $processIds = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $ports -contains $_.LocalPort } | Select-Object -ExpandProperty OwningProcess -Unique; foreach ($processId in $processIds) { try { Write-Host ('Stopping process on service port. PID=' + $processId); Stop-Process -Id $processId -Force -ErrorAction Stop } catch { Write-Host ('Could not stop PID=' + $processId + ': ' + $_.Exception.Message) } }"

echo.
echo All services stopped (or attempted to stop).
echo Note: If windows remain open, please close them manually.
pause
