@echo off
REM 🏥 SAFAR MOROCCO - HEALTH CHECK SCRIPT (Windows)
REM Script pour vérifier que tout fonctionne correctement
REM Usage: health_check.bat

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║       🇲🇦 SAFAR MOROCCO - HEALTH CHECK                       ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

setlocal enabledelayedexpansion

REM Compteurs
set PASSED=0
set FAILED=0

REM ============================================
REM 1. JAVA CHECK
REM ============================================
echo.
echo 📦 JAVA CHECKS
echo ─────────────────────────────────────────────────────────────────

REM Vérifier Java
echo Checking Java Installation...
java -version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Java is installed
    set /a PASSED+=1
) else (
    echo ❌ Java is NOT installed
    set /a FAILED+=1
)

REM Vérifier Maven
echo Checking Maven Installation...
mvn --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Maven is installed
    set /a PASSED+=1
) else (
    echo ❌ Maven is NOT installed
    set /a FAILED+=1
)

REM ============================================
REM 2. DATABASE CHECK
REM ============================================
echo.
echo 💾 DATABASE CHECKS
echo ─────────────────────────────────────────────────────────────────

REM Vérifier MySQL
echo Checking MySQL Server...
mysql -u root -e "SELECT 1" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ MySQL Server is running
    set /a PASSED+=1
) else (
    echo ❌ MySQL Server is NOT running
    echo    Start MySQL manually or via XAMPP Control Panel
    set /a FAILED+=1
)

REM Vérifier la base de données
echo Checking 'safar_morocco' database...
mysql -u root -e "USE safar_morocco; SELECT 1" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Database 'safar_morocco' exists
    set /a PASSED+=1
) else (
    echo ⚠️  Database 'safar_morocco' does NOT exist
    echo    Create it with: mysql -u root -e "CREATE DATABASE safar_morocco"
    set /a FAILED+=1
)

REM ============================================
REM 3. PROJECT CHECK
REM ============================================
echo.
echo 📁 PROJECT CHECKS
echo ─────────────────────────────────────────────────────────────────

REM Vérifier pom.xml
if exist "pom.xml" (
    echo ✅ pom.xml exists
    set /a PASSED+=1
) else (
    echo ❌ pom.xml NOT found
    set /a FAILED+=1
)

REM Vérifier src/main
if exist "src\main" (
    echo ✅ src\main directory exists
    set /a PASSED+=1
) else (
    echo ❌ src\main directory NOT found
    set /a FAILED+=1
)

REM Vérifier application.properties
if exist "src\main\resources\application.properties" (
    echo ✅ application.properties exists
    set /a PASSED+=1
) else (
    echo ❌ application.properties NOT found
    set /a FAILED+=1
)

REM ============================================
REM 4. APPLICATION RUNNING CHECK
REM ============================================
echo.
echo 🚀 APPLICATION CHECKS
echo ─────────────────────────────────────────────────────────────────

REM Vérifier si l'application est running
echo Checking if application is running on port 9004...
powershell -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $response = Invoke-WebRequest -Uri 'http://localhost:9004/actuator/health' -TimeoutSec 3 -ErrorAction Stop; exit 0 } catch { exit 1 }" >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo ✅ Application is running
    set /a PASSED+=1
) else (
    echo ⚠️  Application is NOT running
    echo    Start with: mvn spring-boot:run
    set /a FAILED+=1
)

REM ============================================
REM 5. FILES STRUCTURE CHECK
REM ============================================
echo.
echo 📂 FILES STRUCTURE CHECK
echo ─────────────────────────────────────────────────────────────────

REM Vérifier les fichiers Java principaux
if exist "src\main\java\ma\safar\morocco\auth\controller\AuthController.java" (
    echo ✅ AuthController.java found
    set /a PASSED+=1
) else (
    echo ❌ AuthController.java NOT found
    set /a FAILED+=1
)

if exist "src\main\java\ma\safar\morocco\user\controller\UtilisateurController.java" (
    echo ✅ UtilisateurController.java found
    set /a PASSED+=1
) else (
    echo ❌ UtilisateurController.java NOT found
    set /a FAILED+=1
)

if exist "src\main\java\ma\safar\morocco\config\SecurityConfig.java" (
    echo ✅ SecurityConfig.java found
    set /a PASSED+=1
) else (
    echo ❌ SecurityConfig.java NOT found
    set /a FAILED+=1
)

REM ============================================
REM 6. BUILD CHECK
REM ============================================
echo.
echo 🔨 BUILD CHECK
echo ─────────────────────────────────────────────────────────────────

echo Checking if project compiles...
REM Cette commande prend du temps, donc on la saute en dev rapide
REM mvn clean compile -q
REM if %ERRORLEVEL% EQU 0 (
REM     echo ✅ Project compiles successfully
REM     set /a PASSED+=1
REM ) else (
REM     echo ❌ Project has compilation errors
REM     set /a FAILED+=1
REM )
echo ⏭️  Skipped (takes time)

REM ============================================
REM 7. DOCUMENTATION CHECK
REM ============================================
echo.
echo 📖 DOCUMENTATION CHECKS
echo ─────────────────────────────────────────────────────────────────

if exist "README.md" (
    echo ✅ README.md exists
    set /a PASSED+=1
) else (
    echo ❌ README.md NOT found
    set /a FAILED+=1
)

if exist "API_ENDPOINTS.md" (
    echo ✅ API_ENDPOINTS.md exists
    set /a PASSED+=1
) else (
    echo ❌ API_ENDPOINTS.md NOT found
    set /a FAILED+=1
)

if exist "DEPLOYMENT_GUIDE.md" (
    echo ✅ DEPLOYMENT_GUIDE.md exists
    set /a PASSED+=1
) else (
    echo ❌ DEPLOYMENT_GUIDE.md NOT found
    set /a FAILED+=1
)

REM ============================================
REM SUMMARY
REM ============================================
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                   📊 HEALTH CHECK SUMMARY                     ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

set /a TOTAL=PASSED+FAILED

if %TOTAL% GTR 0 (
    set /a PERCENTAGE=PASSED*100/TOTAL
) else (
    set PERCENTAGE=0
)

echo Total Checks: %TOTAL%
echo Passed: %PASSED% ✅
echo Failed: %FAILED% ❌
echo.
echo Overall Health: %PERCENTAGE%%

if %FAILED% EQU 0 (
    echo ✅ EXCELLENT - Everything is ready!
    echo.
    echo 📝 NEXT STEPS:
    echo    1. Start XAMPP (Apache + MySQL) if not running
    echo    2. Start the application: mvn spring-boot:run
    echo    3. Test endpoints: curl http://localhost:9004/api/auth/health
    echo    4. Import Postman collection: Safar_Morocco_API.postman_collection.json
) else if %PERCENTAGE% GEQ 80 (
    echo ⚠️  WARNING - Some checks failed
    echo.
    echo 📝 RECOMMENDED:
    echo    1. Fix the failed checks above
    echo    2. Start MySQL if not running
    echo    3. Create the database if missing
) else if %PERCENTAGE% GEQ 60 (
    echo ❌ CRITICAL - Multiple issues found
    echo.
    echo 📝 REQUIRED:
    echo    1. Fix the failed checks above
    echo    2. Install missing software (Java, Maven, MySQL)
    echo    3. Review the documentation
) else (
    echo 🚨 SEVERE - Critical issues found
    echo.
    echo 📝 ACTION REQUIRED:
    echo    1. Fix all critical issues
    echo    2. Check MySQL and Java installations
    echo    3. Refer to README.md for setup instructions
)

echo.
echo ✅ Health check completed!
echo.

endlocal
pause
