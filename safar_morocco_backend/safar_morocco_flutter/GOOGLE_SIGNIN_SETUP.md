# Configuration Google Sign-In pour Android

L'erreur **ApiException: 10** (DEVELOPER_ERROR) indique que la configuration OAuth dans Google Cloud Console n'est pas correcte pour votre application Android.

## Vos informations (à copier)

| Paramètre | Valeur |
|-----------|--------|
| **Package name** | `com.example.safar_morocco` |
| **SHA-1 (debug)** | `7D:8C:6A:61:C6:6C:6A:77:0C:A7:89:FE:5F:E7:57:14:F9:3D:3A:D5` |

## Étapes à suivre

### 1. Récupérer l'empreinte SHA-1 de votre clé de signature

Dans le dossier du projet Flutter, exécutez :

```bash
cd android
./gradlew signingReport
```

Sur Windows PowerShell :

```powershell
cd android
.\gradlew signingReport
```

Dans la sortie, trouvez la section **Variant: debug** et copiez la valeur **SHA-1** (quelque chose comme `AA:BB:CC:DD:...`).

### 2. Configurer Google Cloud Console

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionnez votre projet (ou créez-en un)
3. Allez dans **APIs & Services** > **Credentials**
4. Cliquez sur **+ CREATE CREDENTIALS** > **OAuth client ID**
5. Choisissez **Application type**: **Android**
6. Renseignez :
   - **Name** : `Safar Morocco Android` (ou autre nom)
   - **Package name** : `com.example.safar_morocco` (doit correspondre à `applicationId` dans `build.gradle.kts`)
   - **SHA-1 certificate fingerprint** : collez le SHA-1 obtenu à l’étape 1
7. Cliquez sur **Create**

### 3. CRUCIAL - "No ID token" : Android et Web dans le MÊME projet

Votre `serverClientId` dans le code utilise le client ID **Web application** :
```
314402428944-haae25agh9vksla24s1aoef216alemuq.apps.googleusercontent.com
```

Ce client ID doit exister dans le même projet Google Cloud. Vérifiez dans **Credentials** qu’il y a bien un client **Web application** avec cet ID.

### 4. Pour les builds Release

Si vous publiez une version release, ajoutez aussi le SHA-1 de votre keystore release :

1. Obtenez le SHA-1 de la keystore release (via `signingReport` avec la config release)
2. Dans **Credentials** > votre client Android, cliquez sur **Add fingerprint** et ajoutez ce SHA-1

### 5. Délai de propagation

Les changements dans Google Cloud peuvent prendre quelques minutes. Si l’erreur persiste, attendez 5–10 minutes et réessayez.

---

## Vérifications rapides

| Élément | Valeur attendue |
|--------|------------------|
| Package name | `com.example.safar_morocco` |
| Client ID (server) | Web application type dans Google Cloud |
| SHA-1 | Doit être ajouté au client Android OAuth |

## Option : Utiliser Firebase

Si vous utilisez Firebase, vous pouvez ajouter un SHA-1 dans Firebase Console > Project Settings > Your apps > Android app > SHA certificate fingerprints. Téléchargez ensuite `google-services.json` et placez-le dans `android/app/`.
