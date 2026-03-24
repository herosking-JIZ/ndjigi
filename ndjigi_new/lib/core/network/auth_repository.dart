// ============================================================
// CORE/NETWORK/AUTH_REPOSITORY.DART
// Repository d'authentification — couche d'abstraction entre
// les BLoCs et l'API. Mappe les réponses JSON vers des modèles.
// ============================================================

import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'api_client.dart';
import 'token_storage.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/models/auth_response.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Connexion — POST /api/auth/login
  /// Retourne un AuthResponse avec user + tokens
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      final user   = UserModel.fromJson(data['user']);
      final tokens = data['tokens'];

      // Stockage sécurisé immédiat des tokens
      await _tokenStorage.saveTokens(
        accessToken:  tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
      );
      await _tokenStorage.saveUserData(jsonEncode(data['user']));

      return AuthResponse(
        user:         user,
        accessToken:  tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
        permissions:  List<String>.from(data['permissions'] ?? []),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Inscription — POST /api/auth/register
  Future<AuthResponse> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String role,
    String? telephone,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.registerEndpoint,
        data: {
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'password': password,
          'role': role,
          if (telephone != null) 'telephone': telephone,
        },
      );

      final data   = response.data['data'];
      final user   = UserModel.fromJson(data['user']);
      final tokens = data['tokens'];

      await _tokenStorage.saveTokens(
        accessToken:  tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
      );
      await _tokenStorage.saveUserData(jsonEncode(data['user']));

      return AuthResponse(
        user:         user,
        accessToken:  tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
        permissions:  const [],
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Déconnexion — POST /api/auth/logout
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.post(
          AppConstants.logoutEndpoint,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Même si l'API échoue, on efface les tokens locaux
    } finally {
      await _tokenStorage.clearAll();
    }
  }

  /// Profil connecté — GET /api/auth/me
  Future<UserModel> getMe() async {
    try {
      final response = await _apiClient.get(AppConstants.meEndpoint);
      return UserModel.fromJson(response.data['data']['user']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Récupère l'utilisateur depuis le stockage local (hors ligne)
  Future<UserModel?> getCachedUser() async {
    final json = await _tokenStorage.getUserData();
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  /// Convertit les erreurs Dio en messages lisibles
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final msg = e.response?.data['message'];
      if (msg != null) return msg.toString();
      switch (e.response?.statusCode) {
        case 401: return 'Email ou mot de passe incorrect.';
        case 403: return 'Compte désactivé. Contactez l\'administrateur.';
        case 409: return 'Un compte avec cet email existe déjà.';
        case 422: return 'Données invalides. Vérifiez les champs.';
        case 423: return 'Compte temporairement bloqué. Réessayez plus tard.';
        case 429: return 'Trop de tentatives. Attendez quelques minutes.';
        case 500: return 'Erreur serveur. Réessayez plus tard.';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion.';
    }
    return 'Une erreur inattendue s\'est produite.';
  }
}
