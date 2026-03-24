// ============================================================
// FEATURES/AUTH/SCREENS/SPLASH_SCREEN.DART
// Écran de démarrage — vérifie la session et redirige
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim  = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)));
    _controller.forward();
    // Lancer la vérification de session
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Redirection selon le rôle
          _navigateToHome(context, state.user.role);
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo circulaire
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15),
                              blurRadius: 30, spreadRadius: 5),
                        ],
                      ),
                      child: const Center(
                        child: Text('🚗', style: TextStyle(fontSize: 44)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 36,
                        fontWeight: FontWeight.w700, color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 32, height: 32,
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.7),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context, String role) {
    final route = switch (role) {
      AppConstants.roleAdmin        => '/admin',
      AppConstants.roleChauffeur    => '/chauffeur',
      AppConstants.roleProprietaire => '/proprietaire',
      _                             => '/home', // passager par défaut
    };
    Navigator.of(context).pushReplacementNamed(route);
  }
}
