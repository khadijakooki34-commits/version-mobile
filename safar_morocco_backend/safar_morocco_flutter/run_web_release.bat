@echo off
REM Run Flutter web in release mode (faster, no debug connection issues)
flutter run -d chrome --web-port 57977 --web-hostname localhost --release

