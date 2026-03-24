// ============================================================
// FEATURES/AUTH/MODELS/AUTH_RESPONSE.DART
// Réponse d'authentification — wrapper autour de UserModel + tokens
// ============================================================

import 'user_model.dart';

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final List<String> permissions;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.permissions,
  });
}
