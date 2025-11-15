# Configuration pour Mobile (Android/iOS)

## Problème de connexion sur mobile

Sur mobile, l'application ne peut pas se connecter au backend si l'URL pointe vers `localhost`. Il faut utiliser l'adresse IP locale de votre ordinateur.

## Solution

### 1. Trouver l'adresse IP locale de votre ordinateur

**Windows:**
```cmd
ipconfig
```
Cherchez "Adresse IPv4" (ex: 192.168.1.10)

**Mac/Linux:**
```bash
ifconfig
# ou
ip addr
```

### 2. Démarrer le serveur backend

Assurez-vous que le serveur Node.js écoute sur toutes les interfaces (0.0.0.0) et non seulement localhost:

```javascript
// Dans server/src/index.js
app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:3000');
});
```

### 3. Lancer l'application Flutter avec l'IP correcte

**Pour un appareil Android physique:**
```bash
flutter run --dart-define=API_BASE_URL=http://VOTRE_IP_LOCALE:3000
```

**Exemple:**
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
```

**Pour l'émulateur Android:**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

**Pour iOS Simulator:**
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

### 4. Vérifier la connexion

Assurez-vous que:
- Le téléphone et l'ordinateur sont sur le même réseau WiFi
- Le pare-feu Windows/Mac autorise les connexions sur le port 3000
- Le serveur backend est bien démarré

### 5. Permissions Android

Vérifiez que `android/app/src/main/AndroidManifest.xml` contient:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

