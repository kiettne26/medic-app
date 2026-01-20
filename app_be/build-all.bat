@echo off
echo ========================================
echo  BUILD ALL SERVICES
echo ========================================
echo.

echo Building parent pom...
call mvn clean install -DskipTests

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Build completed successfully!
echo  Run start-all.bat to start services
echo ========================================
pause
