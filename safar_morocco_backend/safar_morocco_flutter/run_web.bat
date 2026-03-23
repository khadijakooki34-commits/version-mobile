@echo off
REM Run Flutter web on FIXED port 57977 for Google Sign-In
REM Google OAuth requires exact redirect URI match - random ports break it
REM Using html renderer and disabling CSP for better compatibility
flutter run -d chrome --web-port 57977 --web-hostname localhost --web-renderer html --no-web-resources-csp

