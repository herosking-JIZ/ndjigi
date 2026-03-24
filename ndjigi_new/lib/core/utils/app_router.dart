// ============================================================
// CORE/UTILS/APP_ROUTER.DART
// Configuration des routes de l'application
// Redirection automatique selon l'état d'authentification
// ============================================================

import 'package:flutter/material.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/chauffeur/screens/chauffeur_home_screen.dart';
import '../../features/proprietaire/screens/proprietaire_home_screen.dart';
import '../../features/admin/screens/admin_home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _slide(const SplashScreen());
      case '/login':
        return _slide(const LoginScreen());
      case '/register':
        return _slide(const RegisterScreen());
      case '/reset-password':
        return _slide(const ResetPasswordScreen());
      case '/home':
        return _slide(const HomeScreen());
      case '/chauffeur':
        return _slide(const ChauffeurHomeScreen());
      case '/proprietaire':
        return _slide(const ProprietaireHomeScreen());
      case '/admin':
        return _slide(const AdminHomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route introuvable : ${settings.name}',
                  style: const TextStyle(fontSize: 16)),
            ),
          ),
        );
    }
  }

  /// Transition avec slide-up depuis le bas
  static PageRouteBuilder _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (ctx, anim, secAnim) => page,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (ctx, anim, secAnim, child) {
        const begin = Offset(0.0, 0.05);
        const end   = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: anim.drive(tween),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }
}
