#!/bin/bash

# ⚡ SAFAR MOROCCO - QUICK COMMANDS
# Commandes pour démarrer rapidement le projet

# ============================================
# 🚀 DÉMARRAGE RAPIDE (Copy & Paste)
# ============================================

# 1. Installation et Build
mvn clean install

# 2. Démarrer l'application
mvn spring-boot:run

# 3. Test de santé (dans un autre terminal)
curl http://localhost:9004/actuator/health

# ============================================
# 🔑 AUTHENTIFICATION
# ============================================

# Inscription
curl -X POST http://localhost:9004/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Jean Dupont",
    "email": "jean@example.com",
    "motDePasse": "SecurePass123!",
    "langue": "fr"
  }'

# Login
curl -X POST http://localhost:9004/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jean@example.com",
    "motDePasse": "SecurePass123!"
  }'

# Récupérer le profil (remplacer TOKEN par votre token)
TOKEN="your_token_here"
curl http://localhost:9004/api/auth/me \
  -H "Authorization: Bearer $TOKEN"

# ============================================
# 👥 GESTION UTILISATEURS
# ============================================

# Lister utilisateurs actifs
curl http://localhost:9004/api/utilisateurs/active/list \
  -H "Authorization: Bearer $TOKEN"

# Récupérer utilisateur par email
curl "http://localhost:9004/api/utilisateurs/email/jean@example.com" \
  -H "Authorization: Bearer $TOKEN"

# Mettre à jour le profil
curl -X PUT http://localhost:9004/api/utilisateurs/profile \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Nouveau Nom",
    "telephone": "+212687654321"
  }'

# Changer le mot de passe
curl -X PUT http://localhost:9004/api/utilisateurs/change-password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "ancienMotDePasse": "SecurePass123!",
    "nouveauMotDePasse": "NewPass456!"
  }'

# ============================================
# 💾 BASE DE DONNÉES
# ============================================

# Créer la base de données
mysql -u root -p -e "CREATE DATABASE safar_morocco CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Vérifier les tables
mysql -u root -p safar_morocco -e "SHOW TABLES;"

# Vérifier les utilisateurs
mysql -u root -p safar_morocco -e "SELECT id, email, role, actif FROM utilisateurs;"

# Vérifier les logs d'audit
mysql -u root -p safar_morocco -e "SELECT action, status, createdDate FROM audit_logs LIMIT 10;"

# Sauvegarder la base de données
mysqldump -u root -p safar_morocco > backup.sql

# Restaurer depuis une sauvegarde
mysql -u root -p safar_morocco < backup.sql

# ============================================
# 🔐 ADMIN - ENDPOINTS D'AUDIT
# ============================================

# Créer un utilisateur admin (via SQL)
mysql -u root -p safar_morocco -e "UPDATE utilisateurs SET role='ADMIN' WHERE email='jean@example.com';"

# Obtenir un token admin
# 1. Login avec l'admin
# 2. Copier le token

ADMIN_TOKEN="admin_token_here"

# Récupérer les logs d'audit
curl http://localhost:9004/api/admin/audit/logs \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Récupérer les logs d'un utilisateur
curl "http://localhost:9004/api/admin/audit/user/1" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Récupérer les actions échouées
curl http://localhost:9004/api/admin/audit/failed \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Détecter les activités suspectes
curl "http://localhost:9004/api/admin/audit/suspicious/1" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Statistiques d'audit
curl http://localhost:9004/api/admin/audit/stats \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# ============================================
# 🔧 CONFIGURATION & VARIABLES
# ============================================

# Générer une clé JWT sécurisée (Linux/Mac)
openssl rand -base64 32

# Générer une clé JWT sécurisée (Windows PowerShell)
# $bytes = New-Object byte[] 32; [System.Security.Cryptography.RNGCryptoServiceProvider]::new().GetBytes($bytes); [System.Convert]::ToBase64String($bytes)

# Définir des variables d'environnement (Linux/Mac)
export JWT_SECRET="votre_clé_secrète"
export SPRING_DATASOURCE_URL="jdbc:mysql://localhost:3306/safar_morocco"
export SPRING_DATASOURCE_USERNAME="root"
export SPRING_DATASOURCE_PASSWORD="votre_mot_de_passe"

# Vérifier les variables (Linux/Mac)
echo $JWT_SECRET
echo $SPRING_DATASOURCE_URL

# ============================================
# 🧪 TESTS
# ============================================

# Exécuter tous les tests
mvn test

# Exécuter un test spécifique
mvn test -Dtest=IntegrationTest

# Exécuter les tests avec couverture
mvn test jacoco:report

# Vérifier les résultats de couverture
open target/site/jacoco/index.html

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
java -jar target/Safar_Morocco-0.0.1-SNAPSHOT.jar \
  --server.port=8080 \
  --spring.datasource.url=jdbc:mysql://localhost:3306/safar \
  --spring.datasource.username=root

# ============================================
# 📊 MONITORING & LOGS
# ============================================

# Voir les logs en direct
tail -f logs/application.log

# Voir les 100 dernières lignes
tail -100 logs/application.log

# Rechercher les erreurs
grep ERROR logs/application.log

# Compter les erreurs
grep -c ERROR logs/application.log

# Voir les logs d'authentification
grep -i "auth" logs/application.log

# Voir les logs d'audit
grep -i "audit" logs/application.log

# ============================================
# 🛠️ DÉVELOPPEMENT
# ============================================

# Formater le code Java
mvn spotless:apply

# Vérifier le style du code
mvn spotless:check

# Analyser la qualité du code
mvn sonar:sonar

# Vérifier les dépendances
mvn dependency:tree

# Mettre à jour les dépendances
mvn versions:update-child-modules

# ============================================
# 🐛 DEBUGGING
# ============================================

# Exécuter avec debug mode
mvn spring-boot:run -Dspring-boot.run.arguments="--debug"

# Démarrer avec debugger activé (attend attachement)
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 \
  -jar target/Safar_Morocco-0.0.1-SNAPSHOT.jar

# ============================================
# 🧹 NETTOYAGE
# ============================================

# Nettoyer les fichiers compilés
mvn clean

# Supprimer les logs
rm logs/application.log

# Supprimer les fichiers temporaires
mvn clean install -DskipTests

# Réinitialiser la base de données (ATTENTION!)
mysql -u root -p safar_morocco -e "DROP TABLE audit_logs; DROP TABLE utilisateurs;"
# Puis relancer l'app pour recréer les tables

# ============================================
# 📝 HELPFUL ALIASES (mettre dans .bashrc ou .zshrc)
# ============================================

# alias safar-build="mvn clean install"
# alias safar-run="mvn spring-boot:run"
# alias safar-test="mvn test"
# alias safar-logs="tail -f logs/application.log"
# alias safar-health="curl http://localhost:9004/actuator/health"
# alias safar-clean="mvn clean && rm -rf logs/"

# Utilisation: safar-run

# ============================================
# 📌 IMPORTANT ENDPOINTS
# ============================================

# Health
GET http://localhost:9004/actuator/health

# Metrics
GET http://localhost:9004/actuator/metrics

# Environment
GET http://localhost:9004/actuator/env

# Register
POST http://localhost:9004/api/auth/register

# Login
POST http://localhost:9004/api/auth/login

# Profile
GET http://localhost:9004/api/auth/me

# List Users (Admin)
GET http://localhost:9004/api/utilisateurs/all/list

# Audit Logs (Admin)
GET http://localhost:9004/api/admin/audit/logs

# ============================================
# 🔐 SECURITY TIPS
# ============================================

# NEVER commit these to git:
# - .env (credentials)
# - jwt.secret values
# - Google OAuth2 secrets
# - Database passwords

# Always use:
# - HTTPS in production
# - Strong JWT secret (32+ characters)
# - Parameterized SQL queries (JPA does this)
# - Input validation (@NotBlank, @Email, etc.)
# - Rate limiting (if high traffic)

# ============================================
# 📞 QUICK REFERENCE
# ============================================

# Port: 9004
# Database: localhost:3306
# Application URL: http://localhost:9004
# Health Check: http://localhost:9004/actuator/health
# Logs Location: logs/application.log
# Config File: src/main/resources/application.properties
# Database: safar_morocco
# User: root (default, change in production)

echo "✅ Quick commands ready to use!"
echo "Copy and paste the commands above into your terminal"
