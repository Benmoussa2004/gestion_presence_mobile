import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/ip_discovery_service.dart';
import 'data/api/api_client.dart';
// No Firebase initialization — using Node+Mongo API backend.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Détection automatique de l'IP du serveur au démarrage
  if (!kIsWeb) {
    debugPrint('🔍 Démarrage de la détection automatique de l\'IP du serveur...');
    try {
      final discoveredIP = await IpDiscoveryService.discoverServerIP(port: 3000);
      if (discoveredIP != null) {
        // Initialiser ApiClient avec l'IP découverte
          // await ApiClient.initializeFromCache(); // supprimé
        debugPrint('✅ IP serveur détectée et mise en cache: $discoveredIP');
        debugPrint('📱 L\'application utilisera: http://$discoveredIP:3000');
      } else {
        debugPrint('⚠️ Aucune IP serveur détectée');
        debugPrint('💡 Assurez-vous que le serveur Node.js est démarré (npm start dans le dossier server)');
        debugPrint('💡 L\'application utilisera les valeurs par défaut (peut ne pas fonctionner sur téléphone physique)');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la détection IP: $e');
      debugPrint('💡 Assurez-vous que le serveur Node.js est démarré');
    }
  }
  
  runApp(const ProviderScope(child: App()));
}
