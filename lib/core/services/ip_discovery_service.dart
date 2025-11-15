import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Service de découverte automatique de l'IP du serveur backend
/// Utilise plusieurs méthodes pour trouver l'IP automatiquement
class IpDiscoveryService {
  static const String _prefsKey = 'cached_server_ip';
  static const String _prefsKeyPort = 'cached_server_port';
  static const Duration _cacheValidity = Duration(hours: 24);
  static const Duration _requestTimeout = Duration(seconds: 2);

  /// Découvre l'IP du serveur en utilisant plusieurs méthodes
  static Future<String?> discoverServerIP({int port = 3000}) async {
    // 1. Vérifier le cache (si récent)
    final cached = await _getCachedIP();
    if (cached != null) {
      if (await _testConnection(cached, port)) {
        return cached;
      }
    }

    // 2. Essayer l'endpoint de découverte du serveur
    final discovered = await _discoverFromServer(port);
    if (discovered != null) {
      await _cacheIP(discovered, port);
      return discovered;
    }

    // 3. Scanner les IPs locales communes
    final scanned = await _scanLocalIPs(port);
    if (scanned != null) {
      await _cacheIP(scanned, port);
      return scanned;
    }

    // 4. Utiliser network_info_plus pour obtenir l'IP du réseau
    final networkIP = await _getNetworkIP();
    if (networkIP != null && await _testConnection(networkIP, port)) {
      await _cacheIP(networkIP, port);
      return networkIP;
    }

    return null;
  }

  /// Récupère l'IP depuis l'endpoint /discover du serveur
  static Future<String?> _discoverFromServer(int port) async {
    // Liste d'IPs à essayer pour contacter le serveur de découverte
    final candidates = await _getDiscoveryCandidates();

    // Essayer en parallèle pour être plus rapide
    final futures = candidates.map((candidate) async {
      try {
        final uri = Uri.parse('http://$candidate:$port/discover');
        final response = await http.get(uri).timeout(_requestTimeout);
        
        if (response.statusCode == 200) {
          final data = response.body;
          // Parser la réponse JSON simple
          if (data.contains('"ip"')) {
            final ipMatch = RegExp(r'"ip"\s*:\s*"([^"]+)"').firstMatch(data);
            if (ipMatch != null) {
              return ipMatch.group(1);
            }
          }
        }
      } catch (e) {
        // Ignorer les erreurs
      }
      return null;
    });

    final results = await Future.wait(futures);
    return results.firstWhere((ip) => ip != null, orElse: () => null);
  }

  /// Obtient les candidats pour la découverte
  static Future<List<String>> _getDiscoveryCandidates() async {
    final candidates = <String>[];

    // Ajouter localhost (pour web/émulateur)
    if (kIsWeb) {
      candidates.add('localhost');
    } else if (Platform.isAndroid) {
      // Pour Android, essayer l'émulateur d'abord
      candidates.add('10.0.2.2');
    } else if (Platform.isIOS) {
      candidates.add('localhost');
    }

    // Ajouter l'IP du réseau local si disponible (priorité haute)
    final networkIP = await _getNetworkIP();
    if (networkIP != null) {
      // Ajouter l'IP du téléphone en premier
      candidates.insert(0, networkIP);
      
      // Générer des IPs communes du réseau local
      final parts = networkIP.split('.');
      if (parts.length == 4) {
        final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
        // Essayer plusieurs IPs communes (routeur, IPs typiques)
        for (final lastOctet in ['1', '26', '100', '101', '102', '103', '254']) {
          final ip = '$subnet.$lastOctet';
          if (ip != networkIP && !candidates.contains(ip)) {
            candidates.add(ip);
          }
        }
      }
    }

    // Ajouter les IPs du cache (priorité haute aussi)
    final cached = await _getCachedIP();
    if (cached != null && !candidates.contains(cached)) {
      candidates.insert(0, cached);
    }

    return candidates;
  }

  /// Scanne les IPs locales pour trouver le serveur (version optimisée)
  static Future<String?> _scanLocalIPs(int port) async {
    final networkIP = await _getNetworkIP();
    if (networkIP == null) return null;

    final parts = networkIP.split('.');
    if (parts.length != 4) return null;

    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
    final phoneLastOctet = int.tryParse(parts[3]) ?? 0;
    
    // Tester les IPs les plus probables
    final testIPs = <String>[
      '$subnet.1',   // Routeur typique
      '$subnet.26',  // IP de l'utilisateur actuel (d'après ipconfig)
      '$subnet.100', // IPs communes
      '$subnet.101',
      '$subnet.102',
      '$subnet.103',
      '$subnet.254', // Routeur alternatif
    ];
    
    // Ajouter des IPs autour de l'IP du téléphone (±10)
    for (int i = -10; i <= 10; i++) {
      final testOctet = phoneLastOctet + i;
      if (testOctet > 0 && testOctet < 255) {
        final testIP = '$subnet.$testOctet';
        if (!testIPs.contains(testIP)) {
          testIPs.add(testIP);
        }
      }
    }

    // Tester en parallèle (limité à 20 simultanées pour éviter de surcharger)
    final results = <String?>[];
    for (int i = 0; i < testIPs.length; i += 20) {
      final batch = testIPs.skip(i).take(20);
      final batchResults = await Future.wait(
        batch.map((ip) => _testConnection(ip, port).then((success) => success ? ip : null))
      );
      results.addAll(batchResults);
      
      // Si on a trouvé une IP, arrêter
      final found = results.firstWhere((ip) => ip != null, orElse: () => null);
      if (found != null) return found;
    }

    return results.firstWhere((ip) => ip != null, orElse: () => null);
  }

  /// Teste si une connexion au serveur fonctionne
  static Future<bool> _testConnection(String ip, int port) async {
    try {
      final uri = Uri.parse('http://$ip:$port/health');
      final response = await http.get(uri).timeout(_requestTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Obtient l'IP du réseau local via network_info_plus
  static Future<String?> _getNetworkIP() async {
    if (kIsWeb) return null;
    
    try {
      final networkInfo = NetworkInfo();
      final wifiIP = await networkInfo.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty && wifiIP != '0.0.0.0') {
        return wifiIP;
      }
    } catch (e) {
      // Ignorer les erreurs
    }
    return null;
  }

  /// Cache l'IP découverte
  static Future<void> _cacheIP(String ip, int port) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, ip);
      await prefs.setInt(_prefsKeyPort, port);
      await prefs.setString('${_prefsKey}_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      // Ignorer les erreurs de cache
    }
  }

  /// Récupère l'IP depuis le cache si elle est encore valide
  static Future<String?> _getCachedIP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedIP = prefs.getString(_prefsKey);
      final timestampStr = prefs.getString('${_prefsKey}_timestamp');
      
      if (cachedIP == null || timestampStr == null) return null;

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      
      if (now.difference(timestamp) > _cacheValidity) {
        // Cache expiré
        return null;
      }

      return cachedIP;
    } catch (e) {
      return null;
    }
  }

  /// Efface le cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      await prefs.remove(_prefsKeyPort);
      await prefs.remove('${_prefsKey}_timestamp');
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  /// Force la découverte (ignore le cache)
  static Future<String?> forceDiscover({int port = 3000}) async {
    await clearCache();
    return discoverServerIP(port: port);
  }
}

