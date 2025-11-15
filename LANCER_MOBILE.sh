#!/bin/bash

echo "========================================"
echo "Lancement de l'application sur mobile"
echo "========================================"
echo ""
echo "IP de votre PC: 192.168.1.26"
echo ""
echo "Assurez-vous que:"
echo "1. Le serveur backend est démarré (cd server && npm run start)"
echo "2. Votre téléphone et PC sont sur le même réseau WiFi"
echo "3. Le pare-feu autorise le port 3000"
echo ""
read -p "Appuyez sur Entrée pour continuer..."

echo ""
echo "Lancement de l'application..."
flutter run --dart-define=API_BASE_URL=http://192.168.1.26:3000

