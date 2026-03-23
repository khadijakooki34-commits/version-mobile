# Safar Morocco - Plateforme Intelligente de Découverte Touristique

##  Description

Safar Morocco est une plateforme complète de découverte touristique interactive composée de :
- **Backend** : API REST Spring Boot avec authentification JWT et OAuth2 Google
- **Frontend Mobile** : Application Flutter multi-plateforme

##  Architecture du Projet

```
version mobile/
├── safar_morocco_backend/
│   ├── Safar_Morocco_Mobile/          # Backend Spring Boot
│   └── safar_morocco_flutter/         # Frontend Flutter
└── README.md                          # Ce fichier
```

---

##  Démarrage Rapide

### Prérequis

- **Java 17** ou supérieur
- **MySQL** (XAMPP recommandé)
- **Maven** 3.6+
- **Flutter** 3.0+
- **Node.js** (optionnel pour certains outils)

---

##  Backend (Spring Boot)

### 1. Configuration de la Base de Données

1. **Installer XAMPP** et démarrer MySQL
2. Configurer la connexion** dans `application.properties` :
   ```properties
   spring.datasource.url=jdbc:mysql://127.0.0.1:3306/safar_morocco_mobile?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
   spring.datasource.username=root
   spring.datasource.password=
   ```

### 2. Lancer le Backend

```bash
# Naviguer vers le dossier backend
cd safar_morocco_backend/Safar_Morocco_Mobile

# Compiler et lancer avec Maven
.\mvnw.cmd spring-boot:run

# Ou compiler puis lancer
mvn clean package
java -jar target/Safar_Morocco-0.0.1-SNAPSHOT.jar
```

### 3. Comptes de Test Pré-configurés 

Pour tester rapidement l'application, utilisez ces comptes :

####  **Utilisateur Standard**
- **Email** : `user@safar.com`
- **Mot de passe** : `SecureSafarMrc2026!Usr!`
- **Rôle** : USER
- **Accès** : Consultation des destinations, écriture d'avis, chatbot

#### 👨 **Administrateur**
- **Email** : `admin@safar.com`
- **Mot de passe** : `SecureSafarMrc2026!Adm!`
- **Rôle** : ADMIN
- **Accès** : Toutes les fonctionnalités + dashboard admin, gestion utilisateurs

####  **Notes importantes**
- Ces comptes sont créés automatiquement au premier démarrage de l'application
- Vous pouvez également créer votre propre compte via l'interface d'inscription
- Les mots de passe respectent les critères de sécurité : 8+ caractères, majuscule, minuscule, chiffre, caractère spécial

### 4. Vérifier le Backend

Le backend démarre sur : **http://localhost:8088**
---

##  Frontend (Flutter)

### 1. Installation des Dépendances

```bash
# Naviguer vers le dossier Flutter
cd safar_morocco_backend/safar_morocco_flutter

# Installer les dépendances
flutter doctor
flutter pub get
flutter run
```

### 2. Configuration de l'Adresse IP Backend  **IMPORTANT**

Pour connecter le frontend au backend, vous devez configurer l'adresse IP dans le fichier :

**Fichier à modifier** : `lib/utils/constants.dart`

```dart
class AppConstants {
  // Modifier cette ligne avec votre IP locale
  static const String baseUrl = 'http://VOTRE_IP_LOCALE:8088/api';
  
  // Exemples :
  // static const String baseUrl = 'http://192.168.1.100:8088/api';  // WiFi
  // static const String baseUrl = 'http://10.0.2.2:8088/api';       // Émulateur Android
  // static const String baseUrl = 'http://localhost:8088/api';      // Web/Debug
}
```

####  Comment Trouver Votre IP Locale

**Windows :**
```cmd
ipconfig
# Chercher "Adresse IPv4" sous votre adaptateur réseau
```

**Linux/Mac :**
```bash
ifconfig | grep inet
# ou
ip a
```

**Émulateur Android :**
- Utiliser `http://10.0.2.2:8088/api` (redirige vers localhost)

### 3. Lancer le Frontend

```bash
# Pour Android
flutter run -d android

# Pour iOS  
flutter run -d ios

# Pour Web
flutter run -d chrome

# Pour tous les appareils connectés
flutter run
```

---

##  Tests et Validation

1. **Lancer l'application Flutter**
2. **Tester les fonctionnalités** :
   - Création de compte
   - Connexion
   - Navigation entre écrans
   - Recherche de destinations
   - Écriture d'avis

---

## 🔧 Configuration Détaillée

### Variables d'Environnement Backend

Copier `.env.example` vers `.env` et modifier :

```bash
# Base de données
SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/safar_morocco_mobile
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=

# JWT
JWT_SECRET=votre-cle-secrete-32-caracteres-minimum
JWT_EXPIRATION=86400000

# OAuth2 Google (optionnel)
SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_CLIENT_ID=votre-client-id
SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_CLIENT_SECRET=votre-client-secret
```


##  Documentation API

### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `POST /api/auth/google-sign-in` - Connexion Google

### Destinations
- `GET /api/destinations` - Liste des destinations
- `GET /api/destinations/{id}` - Détails destination
- `GET /api/destinations/search` - Recherche

### Utilisateurs
- `GET /api/users/profile` - Profil utilisateur
- `PUT /api/users/profile` - Modifier profil

### Avis
- `POST /api/reviews` - Ajouter un avis
- `GET /api/reviews/destination/{id}` - Avis d'une destination

---

##  Dépannage

### Problèmes Communs

**"Connection refused"**
- Vérifier que le backend est bien démarré
- Confirmer l'IP dans `constants.dart`
- Vérifier le firewall

**"Database connection failed"**
- Démarrer MySQL/XAMPP
- Vérifier les identifiants BDD
- Créer la base de données

**"JWT token expired"**
- Reconnecter l'application
- Vérifier l'heure du système

**Google OAuth ne fonctionne pas**
- Configurer les credentials dans Google Cloud Console
- Ajouter l'URI de redirection autorisée

---

##  Équipe de Développement

Ce projet a été développé dans le cadre d'un projet académique sur les plateformes touristiques intelligentes.

---

** Bon test de l'application Safar Morocco !**
