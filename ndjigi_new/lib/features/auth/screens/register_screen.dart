// ============================================================
// FEATURES/AUTH/SCREENS/REGISTER_SCREEN.DART
// Formulaire d'inscription multi-étapes
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/role_selector.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nomCtrl       = TextEditingController();
  final _prenomCtrl    = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  String _selectedRole = AppConstants.rolePassager;
  bool   _obscurePass  = true;
  bool   _obscureCfm   = true;

  @override
  void dispose() {
    for (final c in [_nomCtrl,_prenomCtrl,_emailCtrl,_phoneCtrl,_passwordCtrl,_confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(AuthRegisterRequested(
        nom:       _nomCtrl.text.trim(),
        prenom:    _prenomCtrl.text.trim(),
        email:     _emailCtrl.text.trim(),
        password:  _passwordCtrl.text,
        role:      _selectedRole,
        telephone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text.trim() : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final route = switch (state.user.role) {
            AppConstants.roleChauffeur    => '/chauffeur',
            AppConstants.roleProprietaire => '/proprietaire',
            _                             => '/home',
          };
          Navigator.of(context).pushReplacementNamed(route);
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
              child: const Text(AppConstants.appName, style: TextStyle(
                  color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2)),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Créer un compte', style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Rejoignez N\'DJIGI dès aujourd\'hui',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 28),

                  // Sélection rôle
                  const Text('Je suis un...', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  RoleSelector(selectedRole: _selectedRole, onRoleSelected: (r) => setState(() => _selectedRole = r)),
                  const SizedBox(height: 24),

                  // Nom & Prénom
                  Row(children: [
                    Expanded(child: AuthTextField(controller: _prenomCtrl, label: 'Prénom', hint: 'Ibrahim', icon: Icons.person_outline,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Requis' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: AuthTextField(controller: _nomCtrl, label: 'Nom', hint: 'Ouedraogo', icon: Icons.badge_outlined,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Requis' : null)),
                  ]),
                  const SizedBox(height: 16),

                  AuthTextField(controller: _emailCtrl, label: 'Email', hint: 'exemple@email.com',
                      icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Email requis';
                        if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v!)) return 'Email invalide';
                        return null;
                      }),
                  const SizedBox(height: 16),

                  AuthTextField(controller: _phoneCtrl, label: 'Téléphone (optionnel)', hint: '+226 70 00 00 00',
                      icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  AuthTextField(
                    controller: _passwordCtrl, label: 'Mot de passe', hint: '••••••••',
                    icon: Icons.lock_outline, obscureText: _obscurePass,
                    suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary, size: 20),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass)),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Mot de passe requis';
                      if (v!.length < 8) return 'Minimum 8 caractères';
                      if (!RegExp(r'(?=.*[A-Z])(?=.*[a-z])(?=.*\d)').hasMatch(v))
                        return '1 majuscule, 1 minuscule, 1 chiffre requis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    controller: _confirmCtrl, label: 'Confirmer le mot de passe', hint: '••••••••',
                    icon: Icons.lock_outline, obscureText: _obscureCfm,
                    suffixIcon: IconButton(
                        icon: Icon(_obscureCfm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary, size: 20),
                        onPressed: () => setState(() => _obscureCfm = !_obscureCfm)),
                    validator: (v) => v != _passwordCtrl.text ? 'Les mots de passe ne correspondent pas' : null,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity, height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text("Créer mon compte", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text("Déjà un compte ?", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Se connecter", style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}
