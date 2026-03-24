// ============================================================
// CORE/CONSTANTS/APP_CONSTANTS.DART
// ============================================================

class AppConstants {
  AppConstants._();

  // ---- API (Backend Node.js) ----
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator -> localhost
  // Pour iOS simulator: 'http://localhost:3000/api'
  // Pour device physique: 'http://VOTRE_IP:3000/api'

  // Endpoints — correspondent exactement aux routes auth.routes.js et user.routes.js
  static const String loginEndpoint      = '/auth/login';
  static const String registerEndpoint   = '/auth/register';
  static const String refreshEndpoint    = '/auth/refresh';
  static const String logoutEndpoint     = '/auth/logout';
  static const String logoutAllEndpoint  = '/auth/logout-all';
  static const String meEndpoint         = '/auth/me';
  static const String profileEndpoint    = '/users/profile';
  static const String adminUsersEndpoint = '/admin/users';
  static const String adminStatsEndpoint = '/admin/stats';

  // ---- Stockage sécurisé (flutter_secure_storage) ----
  static const String accessTokenKey  = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey     = 'user_data';

  // ---- App ----
  static const String appName    = "N'DJIGI";
  static const String appTagline = 'Votre transport, simplifié';

  // ---- Timeouts ----
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ---- Rôles — identiques aux valeurs du backend Node.js ----
  static const String rolePassager     = 'passager';
  static const String roleChauffeur    = 'chauffeur';
  static const String roleProprietaire = 'proprietaire';
  static const String roleAdmin        = 'admin';

  // ---- Carte — Ouagadougou, Burkina Faso ----
  static const double mapDefaultLat  = 12.3569;
  static const double mapDefaultLng  = -1.5352;
  static const double mapDefaultZoom = 14.5;
}
