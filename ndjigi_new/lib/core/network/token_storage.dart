// ============================================================
// CORE/NETWORK/TOKEN_STORAGE.DART
// Stockage sécurisé des tokens JWT (chiffrement AES)
// Utilise flutter_secure_storage (Keychain iOS / Keystore Android)
// ============================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorage() : _storage = const FlutterSecureStorage(
    // Options Android : utilisation du KeyStore hardware
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    // Options iOS : accès uniquement quand l'app est au premier plan
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Sauvegarde les deux tokens après login ou refresh
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey,  value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  /// Récupère l'access token (peut être null si non connecté)
  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  /// Récupère le refresh token
  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  /// Sauvegarde les données utilisateur en JSON
  Future<void> saveUserData(String userJson) =>
      _storage.write(key: AppConstants.userDataKey, value: userJson);

  /// Récupère les données utilisateur sauvegardées
  Future<String?> getUserData() =>
      _storage.read(key: AppConstants.userDataKey);

  /// Supprime tous les tokens (déconnexion)
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.userDataKey),
    ]);
  }

  /// Vérifie si l'utilisateur a un token (potentiellement connecté)
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
