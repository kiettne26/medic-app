@echo off
echo ========================================
echo  Starting Mobile Development Server
echo ========================================
echo.
echo [1/2] Setting up ADB reverse tunnel...
adb reverse tcp:8080 tcp:8080
adb reverse tcp:8082 tcp:8082
echo      Port 8080 and 8082 tunnels established!
echo.
echo [2/2] Starting Flutter app...
flutter run
