// ============================================================
// FEATURES/AUTH/SCREENS/LOGIN_SCREEN.DART
// Écran de connexion avec sélection de rôle
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/role_selector.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _formKey        = GlobalKey<FormState>();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  String _selectedRole  = AppConstants.rolePassager;
  bool   _obscurePass   = true;
  late AnimationController _animController;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(AuthLoginRequested(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateByRole(context, state.user.role);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // En-tête
                  _buildHeader(),
                  const SizedBox(height: 36),
                  // Formulaire
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _animController,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sélecteur de rôle
                            const Text('Je suis un...', style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            )),
                            const SizedBox(height: 12),
                            RoleSelector(
                              selectedRole: _selectedRole,
                              onRoleSelected: (role) => setState(() => _selectedRole = role),
                            ),
                            const SizedBox(height: 28),
                            // Email
                            AuthTextField(
                              controller:  _emailCtrl,
                              label:       'Adresse email',
                              hint:        'exemple@email.com',
                              icon:        Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email requis';
                                if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v))
                                  return 'Email invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Mot de passe
                            AuthTextField(
                              controller:  _passwordCtrl,
                              label:       'Mot de passe',
                              hint:        '••••••••',
                              icon:        Icons.lock_outline,
                              obscureText: _obscurePass,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary, size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
                            ),
                            const SizedBox(height: 12),
                            // Mot de passe oublié
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pushNamed('/reset-password'),
                                child: const Text('Mot de passe oublié ?',
                                  style: TextStyle(color: AppColors.primary, fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Bouton connexion
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                child: isLoading
                                    ? const SizedBox(width: 22, height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login, size: 20),
                                          SizedBox(width: 8),
                                          Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Lien inscription
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Pas encore de compte ?",
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pushNamed('/register'),
                                  child: const Text("S'inscrire",
                                    style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge nom app
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            AppConstants.appName,
            style: TextStyle(color: AppColors.primary, fontSize: 14,
              fontWeight: FontWeight.w700, letterSpacing: 2),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Bon retour !', style: TextStyle(
          fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text('Connectez-vous pour accéder à votre espace',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }

  void _navigateByRole(BuildContext context, String role) {
    final route = switch (role) {
      AppConstants.roleAdmin        => '/admin',
      AppConstants.roleChauffeur    => '/chauffeur',
      AppConstants.roleProprietaire => '/proprietaire',
      _                             => '/home',
    };
    Navigator.of(context).pushReplacementNamed(route);
  }
}
