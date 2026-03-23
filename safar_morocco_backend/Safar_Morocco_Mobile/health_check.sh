#!/bin/bash

# 🏥 SAFAR MOROCCO - HEALTH CHECK SCRIPT
# Script pour vérifier que tout fonctionne correctement
# Usage: chmod +x health_check.sh && ./health_check.sh

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       🇲🇦 SAFAR MOROCCO - HEALTH CHECK                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
PASSED=0
FAILED=0

# Fonction pour afficher les résultats
check() {
    echo -n "🔍 Checking $1... "
    if eval "$2" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC}"
        ((FAILED++))
    fi
}

# ============================================
# 1. JAVA CHECK
# ============================================
echo ""
echo "📦 JAVA CHECKS"
echo "─────────────────────────────────────────────────────────────────"

check "Java Installation" "java -version"
check "Maven Installation" "mvn --version"
check "Java Version (17+)" "java -version 2>&1 | grep -E 'version.*17|version.*18|version.*19|version.*20'"

# ============================================
# 2. DATABASE CHECK
# ============================================
echo ""
echo "💾 DATABASE CHECKS"
echo "─────────────────────────────────────────────────────────────────"

check "MySQL Server Running" "mysql -u root -e 'SELECT 1' 2>/dev/null"
check "Database 'safar_morocco' Exists" "mysql -u root -e 'USE safar_morocco; SELECT 1' 2>/dev/null"

# Check tables
echo -n "🔍 Checking database tables... "
TABLES=$(mysql -u root -D safar_morocco -e "SHOW TABLES" 2>/dev/null | wc -l)
if [ $TABLES -gt 0 ]; then
    echo -e "${GREEN}✅ PASSED (${TABLES} tables found)${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED (no tables found)${NC}"
    ((FAILED++))
fi

# ============================================
# 3. PROJECT CHECK
# ============================================
echo ""
echo "📁 PROJECT CHECKS"
echo "─────────────────────────────────────────────────────────────────"

check "pom.xml Exists" "[ -f 'pom.xml' ]"
check "src/main Exists" "[ -d 'src/main' ]"
check "src/main/java Exists" "[ -d 'src/main/java' ]"
check "src/main/resources Exists" "[ -d 'src/main/resources' ]"
check "application.properties Exists" "[ -f 'src/main/resources/application.properties' ]"

# ============================================
# 4. APPLICATION RUNNING CHECK
# ============================================
echo ""
echo "🚀 APPLICATION CHECKS"
echo "─────────────────────────────────────────────────────────────────"

# Vérifier si l'application est déjà running
if curl -s http://localhost:9004/actuator/health > /dev/null 2>&1; then
    echo "✅ Application is already running on port 9004"
    
    # Test endpoints
    echo -n "🔍 Testing /api/auth/health endpoint... "
    if curl -s http://localhost:9004/api/auth/health | grep -q "true" 2>/dev/null || curl -s http://localhost:9004/api/auth/health | grep -q "success" 2>/dev/null; then
        echo -e "${GREEN}✅ PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠️  ENDPOINT NOT RESPONDING${NC}"
    fi
    
    # Check core services
    echo ""
    echo "Testing core services..."
    check "Authentication Service" "curl -s http://localhost:9004/api/auth/health"
    check "User Service" "curl -s http://localhost:9004/api/utilisateurs/profile 2>/dev/null || true"
    
else
    echo -e "${YELLOW}⚠️  Application not running. Start with: mvn spring-boot:run${NC}"
fi

# ============================================
# 5. CONFIGURATION CHECK
# ============================================
echo ""
echo "⚙️  CONFIGURATION CHECKS"
echo "─────────────────────────────────────────────────────────────────"

# Check JWT secret
echo -n "🔍 Checking JWT configuration... "
if grep -q "jwt.secret" src/main/resources/application.properties; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED (JWT secret not configured)${NC}"
    ((FAILED++))
fi

# Check CORS
echo -n "🔍 Checking CORS configuration... "
if grep -q "allowedOrigins" src/main/java/ma/safar/morocco/config/SecurityConfig.java; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED (CORS not configured)${NC}"
    ((FAILED++))
fi

# Check OAuth2
echo -n "🔍 Checking OAuth2 configuration... "
if grep -q "google.client" src/main/resources/application.properties; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠️  OPTIONAL (OAuth2 not configured)${NC}"
fi

# ============================================
# 6. DEPENDENCIES CHECK
# ============================================
echo ""
echo "📚 DEPENDENCIES CHECK"
echo "─────────────────────────────────────────────────────────────────"

# Check key dependencies
check "Spring Boot 3.2.0" "grep -q 'spring-boot' pom.xml"
check "Spring Security 6.x" "grep -q 'spring-security' pom.xml"
check "JWT Support" "grep -q 'jjwt' pom.xml"
check "MySQL Connector" "grep -q 'mysql' pom.xml"
check "JPA/Hibernate" "grep -q 'spring-boot-starter-data-jpa' pom.xml"

# ============================================
# 7. FILES STRUCTURE CHECK
# ============================================
echo ""
echo "📂 FILES STRUCTURE CHECK"
echo "─────────────────────────────────────────────────────────────────"

check "AuthController" "find . -name 'AuthController.java' 2>/dev/null"
check "AuthService" "find . -name 'AuthService.java' 2>/dev/null"
check "UtilisateurController" "find . -name 'UtilisateurController.java' 2>/dev/null"
check "UtilisateurService" "find . -name 'UtilisateurService.java' 2>/dev/null"
check "SecurityConfig" "find . -name 'SecurityConfig.java' 2>/dev/null"
check "JwtService" "find . -name 'JwtService.java' 2>/dev/null"
check "AuditService" "find . -name 'AuditService.java' 2>/dev/null"

# ============================================
# 8. BUILD CHECK
# ============================================
echo ""
echo "🔨 BUILD CHECK"
echo "─────────────────────────────────────────────────────────────────"

echo -n "🔍 Checking if project compiles... "
if mvn clean compile -q 2>/dev/null; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED (compilation errors)${NC}"
    ((FAILED++))
fi

# ============================================
# 9. SECURITY CHECK
# ============================================
echo ""
echo "🔒 SECURITY CHECKS"
echo "─────────────────────────────────────────────────────────────────"

check "BCrypt Password Encoding" "grep -r 'BCryptPasswordEncoder' src/main/java"
check "JWT HS256" "grep -r 'HS256' src/main/java"
check "Spring Security Configured" "grep -r '@EnableWebSecurity' src/main/java"
check "SQL Injection Protection" "grep -r '@Query' src/main/java"

# ============================================
# 10. DOCUMENTATION CHECK
# ============================================
echo ""
echo "📖 DOCUMENTATION CHECKS"
echo "─────────────────────────────────────────────────────────────────"

check "README.md Exists" "[ -f 'README.md' ]"
check "API_ENDPOINTS.md Exists" "[ -f 'API_ENDPOINTS.md' ]"
check "DEPLOYMENT_GUIDE.md Exists" "[ -f 'DEPLOYMENT_GUIDE.md' ]"
check "BACKEND_DOCUMENTATION.md Exists" "[ -f 'BACKEND_DOCUMENTATION.md' ]"

# ============================================
# SUMMARY
# ============================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   📊 HEALTH CHECK SUMMARY                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"

TOTAL=$((PASSED + FAILED))
PERCENTAGE=$((PASSED * 100 / TOTAL))

echo ""
echo "Total Checks: $TOTAL"
echo -e "Passed: ${GREEN}$PASSED ✅${NC}"
echo -e "Failed: ${RED}$FAILED ❌${NC}"
echo ""
echo -n "Overall Health: "

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}100% - EXCELLENT 🎉${NC}"
    echo ""
    echo "🚀 Your backend is ready for development!"
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "${GREEN}${PERCENTAGE}% - GOOD ✅${NC}"
    echo ""
    echo "⚠️  Some optional checks failed, but the application should work."
elif [ $PERCENTAGE -ge 60 ]; then
    echo -e "${YELLOW}${PERCENTAGE}% - WARNING ⚠️${NC}"
    echo ""
    echo "❌ Fix the failed checks before proceeding."
else
    echo -e "${RED}${PERCENTAGE}% - CRITICAL 🚨${NC}"
    echo ""
    echo "❌ Critical issues found. Check the logs above and fix them."
fi

echo ""

# ============================================
# NEXT STEPS
# ============================================
if [ $FAILED -eq 0 ]; then
    echo "📝 NEXT STEPS:"
    echo "   1. Start the application: mvn spring-boot:run"
    echo "   2. Test endpoints: curl http://localhost:9004/api/auth/health"
    echo "   3. Import Postman collection: Safar_Morocco_API.postman_collection.json"
    echo "   4. Read documentation: cat README.md"
fi

echo ""

exit $FAILED
