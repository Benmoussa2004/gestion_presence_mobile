# 🔧 Instructions pour Résoudre le Problème de Connexion

## ✅ Modifications Effectuées

1. **Détection automatique de l'IP au démarrage** de l'application
2. **Scan réseau amélioré** qui teste plus d'IPs
3. **Cache intelligent** pour éviter les scans répétés
4. **Reconnexion automatique** en cas d'échec

## 🚀 Étapes pour Résoudre le Problème

### 1. Arrêter l'application actuelle

Dans le terminal où `flutter run` est actif, appuyez sur **`q`** pour quitter.

### 2. Vérifier que le serveur backend est démarré

```powershell
cd server
npm run start
```

Le serveur doit afficher :
```
API running on http://0.0.0.0:3000
Accessible via: http://localhost:3000 (local)
Accessible via: http://VOTRE_IP_LOCALE:3000 (réseau local)
```

**IMPORTANT** : Notez l'IP affichée (ex: `192.168.1.26`)

### 3. Recompiler et lancer l'application

**Option A - Détection automatique (recommandé)** :
```powershell
flutter run
```

L'application va automatiquement :
- Détecter l'IP du serveur au démarrage
- Scanner le réseau pour trouver le serveur
- Utiliser l'IP découverte pour toutes les requêtes

**Option B - Forcer une IP spécifique** :
```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.26:3000
```
(Remplacez `192.168.1.26` par votre IP locale)

### 4. Vérifier les logs

Au démarrage, vous devriez voir dans les logs :
```
✅ IP serveur détectée: 192.168.1.26
```

Si vous voyez :
```
⚠️ Aucune IP serveur détectée, utilisation des valeurs par défaut
```

Cela signifie que la détection n'a pas trouvé le serveur. Dans ce cas :
- Vérifiez que le serveur est démarré
- Vérifiez que le téléphone et le PC sont sur le même WiFi
- Utilisez l'Option B pour forcer l'IP

## 🔍 Dépannage

### L'application ne trouve toujours pas le serveur

1. **Vérifier la connexion réseau** :
   - PC et téléphone sur le même WiFi
   - Pare-feu Windows autorise le port 3000

2. **Tester manuellement** :
   Sur votre téléphone, ouvrez un navigateur et allez à :
   ```
   http://192.168.1.26:3000/health
   ```
   (Remplacez par votre IP)
   
   Vous devriez voir : `{"ok":true}`
   
   Si cela ne fonctionne pas, le problème est réseau (pare-feu, WiFi, etc.)

3. **Forcer l'IP manuellement** :
   ```powershell
   flutter run --dart-define=API_BASE_URL=http://VOTRE_IP:3000
   ```

### La détection prend trop de temps

La détection peut prendre 5-10 secondes au premier lancement. C'est normal. Les lancements suivants seront plus rapides grâce au cache.

### Réinitialiser le cache

Si l'IP a changé et l'application utilise toujours l'ancienne :
- Désinstallez et réinstallez l'application
- Ou utilisez `--dart-define=API_BASE_URL=...` pour forcer la nouvelle IP

## 📝 Notes

- La détection automatique fonctionne **seulement** si le serveur est démarré
- Le cache est valide pendant 24h
- En cas d'échec, l'application utilise les valeurs par défaut (10.0.2.2 pour émulateur, localhost pour iOS/Web)

