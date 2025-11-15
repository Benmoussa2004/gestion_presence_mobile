# 🔍 Détection Automatique de l'IP du Serveur

## ✅ Solution Implémentée

Le système détecte **automatiquement** l'adresse IP du serveur backend, **sans configuration manuelle** !

### Comment ça fonctionne ?

1. **Endpoint de découverte** : Le serveur expose `/discover` qui retourne son IP locale
2. **Détection réseau** : L'application utilise `network_info_plus` pour obtenir l'IP du réseau WiFi
3. **Cache intelligent** : L'IP découverte est mise en cache pendant 24h
4. **Fallback automatique** : Si la détection échoue, utilisation des valeurs par défaut

### Méthodes de détection (par ordre de priorité)

1. ✅ **URL définie manuellement** : `--dart-define=API_BASE_URL=http://...` (priorité absolue)
2. ✅ **Cache local** : IP précédemment découverte (valide 24h)
3. ✅ **Endpoint /discover** : Contacte le serveur via plusieurs IPs candidates
4. ✅ **Scan réseau optimisé** : Teste les IPs les plus probables (routeur, IPs communes)
5. ✅ **Valeurs par défaut** : `10.0.2.2:3000` (émulateur) ou `localhost:3000` (iOS/Web)

### Avantages

- ✅ **Aucune configuration manuelle** nécessaire
- ✅ **Fonctionne avec différentes IPs** (changement de réseau automatique)
- ✅ **Cache pour performance** (évite les scans répétés)
- ✅ **Reconnexion automatique** si l'IP change
- ✅ **Compatible avec toutes les plateformes** (Android, iOS, Web)

## 🚀 Utilisation

### Pour les développeurs

**Aucune action requise !** L'application détecte automatiquement l'IP au premier lancement.

### Si vous voulez forcer une IP spécifique

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.26:3000
```

### Pour tester la découverte manuellement

1. Démarrer le serveur backend :
   ```bash
   cd server
   npm run start
   ```

2. Tester l'endpoint de découverte :
   ```bash
   curl http://VOTRE_IP:3000/discover
   ```

   Réponse attendue :
   ```json
   {
     "ip": "192.168.1.26",
     "port": 3000,
     "baseUrl": "http://192.168.1.26:3000",
     "timestamp": "2024-01-01T12:00:00.000Z"
   }
   ```

## 🔧 Dépannage

### L'application ne trouve pas le serveur

1. **Vérifier que le serveur est démarré** :
   ```bash
   cd server
   npm run start
   ```

2. **Vérifier que le serveur écoute sur toutes les interfaces** :
   Le serveur doit afficher : `API running on http://0.0.0.0:3000`

3. **Vérifier la connexion réseau** :
   - PC et téléphone sur le même WiFi
   - Pare-feu Windows autorise le port 3000

4. **Forcer une nouvelle découverte** :
   - Redémarrer l'application
   - Ou utiliser `--dart-define=API_BASE_URL=...` pour forcer une IP

### Réinitialiser le cache

Si l'IP a changé et l'application utilise toujours l'ancienne :

1. Désinstaller et réinstaller l'application
2. Ou utiliser `--dart-define=API_BASE_URL=...` pour forcer la nouvelle IP

## 📝 Notes techniques

- Le cache est stocké dans `SharedPreferences`
- La découverte se fait au premier appel API
- En cas d'échec de connexion, le système tente automatiquement une nouvelle découverte
- Le scan réseau est optimisé pour tester seulement les IPs les plus probables (évite les scans longs)

## 🎯 Cas d'usage

### Équipe avec différentes IPs

**Avant** : Chaque développeur devait modifier le code ou utiliser `--dart-define`

**Maintenant** : 
- ✅ Chaque développeur lance simplement `flutter run`
- ✅ L'application détecte automatiquement l'IP du serveur
- ✅ Fonctionne même si l'IP change (nouveau réseau WiFi)

### Déploiement en production

Pour la production, utilisez toujours `--dart-define=API_BASE_URL=...` pour garantir une URL fixe.

