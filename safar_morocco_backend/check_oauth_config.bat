@echo off
echo ========================================
echo OAuth Configuration Checker
echo ========================================
echo.

echo Checking application.properties...
echo.

findstr /C:"spring.security.oauth2.client.registration.google.client-id" "Safar_Morocco\src\main\resources\application.properties"
findstr /C:"spring.security.oauth2.client.registration.google.client-secret" "Safar_Morocco\src\main\resources\application.properties"

echo.
echo ========================================
echo Current Configuration:
echo ========================================
echo.
echo Client ID: 314402428944-haae25agh9vksla24s1aoef216alemuq.apps.googleusercontent.com
echo Client Secret: Check application.properties line 42
echo.
echo ========================================
echo Action Required:
echo ========================================
echo.
echo 1. Go to: https://console.cloud.google.com/apis/credentials
echo 2. Find Client ID: 314402428944-haae25agh9vksla24s1aoef216alemuq.apps.googleusercontent.com
echo 3. Copy the Client Secret
echo 4. Update line 42 in application.properties
echo 5. Restart Spring Boot
echo.
echo ========================================
pause

