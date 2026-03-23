# ⚡ SAFAR MOROCCO - QUICK COMMANDS (PowerShell)
# Commandes pour démarrer rapidement le projet

# ============================================
# 🚀 DÉMARRAGE RAPIDE
# ============================================

# 1. Installation et Build
mvn clean install

# 2. Démarrer l'application
mvn spring-boot:run

# 3. Test de santé (dans un autre PowerShell)
# Attendre que l'app soit running, puis:
$response = Invoke-WebRequest -Uri "http://localhost:9004/actuator/health"
$response.Content | ConvertFrom-Json | Format-Table

# ============================================
# 🔑 AUTHENTIFICATION
# ============================================

# Inscription
$registerData = @{
    nom = "Jean Dupont"
    email = "jean@example.com"
    motDePasse = "SecurePass123!"
    langue = "fr"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:9004/api/auth/register" `
    -Method POST `
    -ContentType "application/json" `
    -Body $registerData

# Login
$loginData = @{
    email = "jean@example.com"
    motDePasse = "SecurePass123!"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:9004/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $loginData

# Sauvegarder le token
$TOKEN = $response.accessToken
Write-Host "Token: $TOKEN"

# Récupérer le profil
Invoke-RestMethod -Uri "http://localhost:9004/api/auth/me" `
    -Method GET `
    -Headers @{"Authorization" = "Bearer $TOKEN"} | Format-Table

# ============================================
# 👥 GESTION UTILISATEURS
# ============================================

# Lister utilisateurs actifs
Invoke-RestMethod -Uri "http://localhost:9004/api/utilisateurs/active/list" `
    -Method GET `
    -Headers @{"Authorization" = "Bearer $TOKEN"}

# Récupérer utilisateur par email
Invoke-RestMethod -Uri "http://localhost:9004/api/utilisateurs/email/jean@example.com" `
    -Method GET `
    -Headers @{"Authorization" = "Bearer $TOKEN"}

# Mettre à jour le profil
$updateData = @{
    nom = "Nouveau Nom"
    telephone = "+212687654321"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:9004/api/utilisateurs/profile" `
    -Method PUT `
    -ContentType "application/json" `
    -Headers @{"Authorization" = "Bearer $TOKEN"} `
    -Body $updateData

# Changer le mot de passe
$passwordData = @{
    ancienMotDePasse = "SecurePass123!"
    nouveauMotDePasse = "NewPass456!"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:9004/api/utilisateurs/change-password" `
    -Method PUT `
    -ContentType "application/json" `
    -Headers @{"Authorization" = "Bearer $TOKEN"} `
    -Body $passwordData

# ============================================
# 💾 BASE DE DONNÉES
# ============================================

# Créer la base de données
# Ouvrir MySQL command line dans PowerShell:
# ou utiliser MySQL Workbench

# Via PowerShell (si mysql en PATH):
$createDB = @"
CREATE DATABASE safar_morocco CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
"@

# mysql -u root -e $createDB

# Vérifier les tables
# mysql -u root safar_morocco -e "SHOW TABLES;"

# Vérifier les utilisateurs
# mysql -u root safar_morocco -e "SELECT id, email, role, actif FROM utilisateurs;"

# ============================================
# 🔐 ADMIN - ENDPOINTS D'AUDIT
# ============================================

# Créer un utilisateur admin
# Via MySQL: UPDATE utilisateurs SET role='ADMIN' WHERE email='jean@example.com';

# Ou via PowerShell après avoir récupéré le token admin:
$ADMIN_TOKEN = "admin_token_here"

# Récupérer les logs d'audit
Invoke-RestMethod -Uri "http://localhost:9004/api/admin/audit/logs" `
    -Method GET `
    -Headers @{"Authorization" = "Bearer $ADMIN_TOKEN"} | Format-Table

# Récupérer les logs d'un utilisateur
Invoke-RestMethod -Uri "http://localhost:9004/api/admin/audit/user/1" `
    -Method GET `
    -Headers @{"Authorization" = "Bearer $ADMIN_TOKEN"} | Format-Table

# Récupérer les actions échouées
Invoke-RestMethod -Uri "http://localhost:9004/api/admin/audit/failed" `
    -Method GET `
    -Headers @{"Authorization" = "Bearer $ADMIN_TOKEN"} | Format-Table

# Statistiques d'audit
Invoke-RestMethod -Uri "http://localhost:9004/api/admin/audit/stats" `
    -Method GET `
    -Headers @{"Authorization" = "Bearer $ADMIN_TOKEN"} | Format-Table

# ============================================
# 🔧 CONFIGURATION
# ============================================

# Générer une clé JWT sécurisée
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RNGCryptoServiceProvider]::new().GetBytes($bytes)
$jwtSecret = [System.Convert]::ToBase64String($bytes)
Write-Host "JWT Secret: $jwtSecret"

# Définir des variables d'environnement
$env:JWT_SECRET = "votre_clé_secrète"
$env:SPRING_DATASOURCE_URL = "jdbc:mysql://localhost:3306/safar_morocco"
$env:SPRING_DATASOURCE_USERNAME = "root"
$env:SPRING_DATASOURCE_PASSWORD = "votre_mot_de_passe"

# Vérifier les variables
Write-Host "JWT Secret: $env:JWT_SECRET"
Write-Host "Database URL: $env:SPRING_DATASOURCE_URL"

# ============================================
# 🧪 TESTS
# ============================================

# Exécuter tous les tests
mvn test

# Exécuter un test spécifique
mvn test -Dtest=IntegrationTest

# Exécuter les tests avec couverture
mvn test jacoco:report

# ============================================
# 🔨 BUILD & DÉPLOIEMENT
# ============================================

# Build sans tests
mvn clean package -DskipTests

# Build avec tests
mvn clean package

# Exécuter le JAR directement
java -jar target/Safar_Morocco-0.0.1-SNAPSHOT.jar

# Exécuter avec paramètres
java -jar target/Safar_Morocco-0.0.1-SNAPSHOT.jar `
    --server.port=8080 `
    --spring.datasource.url=jdbc:mysql://localhost:3306/safar `
    --spring.datasource.username=root

# ============================================
# 📊 MONITORING
# ============================================

# Voir les logs en direct
Get-Content logs/application.log -Tail 100 -Wait

# Voir les 100 dernières lignes
Get-Content logs/application.log -Tail 100

# Rechercher les erreurs
Select-String -Path logs/application.log -Pattern "ERROR"

# Compter les erreurs
(Select-String -Path logs/application.log -Pattern "ERROR").Count

# Voir les logs d'authentification
Select-String -Path logs/application.log -Pattern "Auth" -CaseSensitive

# ============================================
# 🛠️ DÉVELOPPEMENT
# ============================================

# Vérifier les dépendances
mvn dependency:tree

# Voir la structure du projet
tree /F /A

# Exécuter avec debug mode
mvn spring-boot:run -Dspring-boot.run.arguments="--debug"

# ============================================
# 🧹 NETTOYAGE
# ============================================

# Nettoyer les fichiers compilés
mvn clean

# Supprimer les logs
Remove-Item logs/application.log -Force

# Réinitialiser complètement
mvn clean install

# ============================================
# 🔗 RACCOURCIS UTILES
# ============================================

# Health Check
Invoke-RestMethod -Uri "http://localhost:9004/actuator/health" | Format-Table

# Metrics
Invoke-RestMethod -Uri "http://localhost:9004/actuator/metrics" | Format-Table

# Ouvrir navigateur
Start-Process "http://localhost:9004/actuator/health"

# Ouvrir VS Code dans le répertoire courant
code .

# Ouvrir dossier dans l'Explorateur
explorer .

# ============================================
# 💡 FONCTIONS UTILES (À mettre dans $PROFILE)
# ============================================

# function safar-build { mvn clean install }
# function safar-run { mvn spring-boot:run }
# function safar-test { mvn test }
# function safar-health { Invoke-RestMethod -Uri "http://localhost:9004/actuator/health" | Format-Table }
# function safar-logs { Get-Content logs/application.log -Tail 50 -Wait }
# function safar-clean { mvn clean; Remove-Item logs -Recurse -Force }

# Utilisation après ajout au profil:
# safar-run
# safar-health
# safar-logs

# ============================================
# 📌 ENDPOINTS IMPORTANTS
# ============================================

# Health: http://localhost:9004/actuator/health
# Metrics: http://localhost:9004/actuator/metrics
# Register: POST http://localhost:9004/api/auth/register
# Login: POST http://localhost:9004/api/auth/login
# Profile: GET http://localhost:9004/api/auth/me
# Users List: GET http://localhost:9004/api/utilisateurs/all/list (Admin)
# Audit Logs: GET http://localhost:9004/api/admin/audit/logs (Admin)

# ============================================
# 📝 TIPS
# ============================================

Write-Host "✅ Quick commands ready to use!"
Write-Host "Copier et coller les commandes dans PowerShell"
Write-Host ""
Write-Host "Port par défaut: 9004"
Write-Host "Base de données: localhost:3306"
Write-Host "Utilisateur: root"
Write-Host "Logs: logs/application.log"
Write-Host ""
Write-Host "Démarrer l'app: mvn spring-boot:run"
Write-Host "Tester: http://localhost:9004/actuator/health"
