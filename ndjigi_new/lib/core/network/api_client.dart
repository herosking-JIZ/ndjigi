// ============================================================
// CORE/NETWORK/API_CLIENT.DART
// Client HTTP Dio — compatible avec le backend Node.js
//
// Gère automatiquement :
//   - Injection du Bearer token dans chaque requête
//   - Renouvellement transparent du token expiré (code 401)
//   - Déconnexion si le refresh token est aussi expiré
// ============================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'token_storage.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  // Singleton pour éviter de créer plusieurs instances
  static ApiClient? _instance;
  factory ApiClient({required TokenStorage tokenStorage}) {
    _instance ??= ApiClient._internal(tokenStorage: tokenStorage);
    return _instance!;
  }

  ApiClient._internal({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // ---- Injection du token dans chaque requête ----
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('→ ${options.method} ${options.path}');
          }
          return handler.next(options);
        },

        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
                '← ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },

        // ---- Gestion des erreurs et refresh automatique ----
        onError: (DioException error, handler) async {
          // Si 401 (token expiré), tenter un refresh automatique
          if (error.response?.statusCode == 401) {
            final code = error.response?.data['code'];
            if (code == 'TOKEN_EXPIRED') {
              try {
                final refreshed = await _refreshToken();
                if (refreshed) {
                  // Rejouer la requête originale avec le nouveau token
                  final token = await _tokenStorage.getAccessToken();
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $token';
                  final retryResponse = await _dio.fetch(opts);
                  return handler.resolve(retryResponse);
                }
              } catch (_) {
                // Refresh échoué : déconnexion forcée
                await _tokenStorage.clearAll();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Tente de renouveler l'access token via le refresh token
  Future<bool> _refreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      // Requête directe sans intercepteur pour éviter la récursion
      final response = await Dio().post(
        '${AppConstants.baseUrl}${AppConstants.refreshEndpoint}',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tokens = response.data['data']['tokens'];
        await _tokenStorage.saveTokens(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ---- Méthodes HTTP publiques ----

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}
