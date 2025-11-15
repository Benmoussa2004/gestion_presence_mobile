@echo off
echo ========================================
echo Lancement de l'application sur mobile
echo ========================================
echo.
echo IP de votre PC: 192.168.1.26
echo.
echo IMPORTANT: Cette commande configure l'application pour utiliser
echo l'IP locale de votre PC au lieu de localhost.
echo.
echo Assurez-vous que:
echo 1. Le serveur backend est demarre (cd server ^&^& npm run start)
echo 2. Votre telephone et PC sont sur le meme reseau WiFi
echo 3. Le pare-feu autorise le port 3000
echo.
pause
echo.
echo Lancement de l'application avec l'IP 192.168.1.26...
flutter run --dart-define=API_BASE_URL=http://192.168.1.26:3000
pause

