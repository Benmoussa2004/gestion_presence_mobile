# Gestion Présence — Flutter + Node.js + MongoDB

Application Flutter (enseignant/étudiant) avec un backend Node.js/Express et MongoDB. Aucune dépendance Firebase.

## Structure

```
lib/
 ├─ app/ (router, theme)
 ├─ core/ (constants, widgets communs)
 ├─ data/ (Model + Repos): accès API REST Node.js
 ├─ mvc/
 │   ├─ controllers/ (orchestration Auth/Users/Classes/Sessions)
 │   └─ providers.dart (injection Riverpod)
 ├─ features/ (View): écrans/widgets
 │   ├─ auth/
 │   ├─ classes/
 │   ├─ sessions/
 │   ├─ attendance/
 │   └─ stats/
 └─ main.dart
```

## Démarrage rapide

### Backend (Node.js/Express + MongoDB)
1) Créer `server/.env`:
   - `MONGO_URI=mongodb://localhost:27017/gestion_presence`
   - `JWT_SECRET=votre_chaine_secrete`
2) Depuis `server/` :
   - `npm install`
   - `npm run start`
3) Vérifier: `GET http://localhost:3000/health` → `{ ok: true }`

### Frontend (Flutter)
1) `flutter pub get`
2) Lancer l’app en pointant l’API:
   - Desktop/Web: `flutter run --dart-define=BACKEND=api --dart-define=API_BASE_URL=http://localhost:3000`
   - Android émulateur: `flutter run --dart-define=BACKEND=api --dart-define=API_BASE_URL=http://10.0.2.2:3000`

### Architecture UI
- Model: `lib/data/models/*` (+ repositories qui consomment l’API REST)
- View: `lib/features/**` (UI)
- Controller: `lib/mvc/controllers/*` (orchestration et appels repos)

Exemples:
- Auth: `AuthController` (inscription/connexion/déconnexion) consommé par `LoginScreen`/`SignupScreen`.
- Classes: `ClassesController` (watch/create/update/delete) consommé par `ClassesScreen` et `ClassEditorDialog`.
- Users: `UsersController` (compteurs par rôle, flux d’utilisateurs) consommé par `UsersCounters` et `StatsScreen`.

## Sécurité API
Le backend émet un JWT lors du login (`/auth/login`). Pour protéger des routes, ajoutez un middleware de vérification du token côté Express et appliquez-le aux routes nécessaires.

## Board de tâches

Un CSV importable (Trello/Notion) est fourni: `project_board.csv`.

## Prochaines étapes suggérées

- Middleware JWT sur routes sensibles
- CRUD complet Classes/Sessions/Présences côté UI
- Scanner QR côté mobile (déjà présent en squelette UI)
- Stats (fl_chart) basées sur données MongoDB

## Remarque
Le dossier `functions/` (Firebase) n’est plus utilisé dans cette version. Vous pouvez l’ignorer ou le supprimer si vous n’en avez pas besoin.
