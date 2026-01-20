@echo off
echo ========================================
echo  Starting Mobile Development Server
echo ========================================
echo.
echo [1/2] Setting up ADB reverse tunnel...
adb reverse tcp:8080 tcp:8080
echo      Port 8080 tunnel established!
echo.
echo [2/2] Starting Flutter app...
flutter run
