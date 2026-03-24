// ============================================================
// FEATURES/AUTH/SCREENS/RESET_PASSWORD_SCREEN.DART
// Réinitialisation du mot de passe (étapes 1 et 2)
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_text_field.dart';

enum _ResetStep { enterEmail, enterCode, newPassword, success }

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  _ResetStep _step = _ResetStep.enterEmail;
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _sendCode() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulation API
    setState(() {
      _isLoading = false;
      _step = _ResetStep.enterCode;
    });
  }

  void _verifyCode() async {
    if (_codeCtrl.text.length < 6) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
      _step = _ResetStep.newPassword;
    });
  }

  void _resetPassword() async {
    if (_newPassCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Les mots de passe ne correspondent pas'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _step = _ResetStep.success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 8)
                ]),
            child: const Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      _ResetStep.enterEmail => _buildEmailStep(),
      _ResetStep.enterCode => _buildCodeStep(),
      _ResetStep.newPassword => _buildNewPasswordStep(),
      _ResetStep.success => _buildSuccessStep(),
    };
  }

  Widget _buildEmailStep() => _buildStepLayout(
        icon: '📧',
        title: 'Mot de passe oublié ?',
        subtitle:
            'Saisissez votre email pour recevoir un code de réinitialisation.',
        child: Column(children: [
          AuthTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'exemple@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 24),
          _buildButton('Envoyer le code', _sendCode),
        ]),
      );

  Widget _buildCodeStep() => _buildStepLayout(
        icon: '🔢',
        title: 'Vérification',
        subtitle: 'Saisissez le code à 6 chiffres envoyé à ${_emailCtrl.text}',
        child: Column(children: [
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 12,
                color: AppColors.textPrimary),
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              hintStyle: TextStyle(
                  letterSpacing: 12, color: AppColors.textHint, fontSize: 28),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2)),
              filled: true,
              fillColor: const Color(0xFFF5F8FF),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
          const SizedBox(height: 24),
          _buildButton('Vérifier le code', _verifyCode),
        ]),
      );

  Widget _buildNewPasswordStep() => _buildStepLayout(
        icon: '🔐',
        title: 'Nouveau mot de passe',
        subtitle: 'Choisissez un mot de passe sécurisé.',
        child: Column(children: [
          AuthTextField(
              controller: _newPassCtrl,
              label: 'Nouveau mot de passe',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscure,
              suffixIcon: IconButton(
                  icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure))),
          const SizedBox(height: 16),
          AuthTextField(
              controller: _confirmCtrl,
              label: 'Confirmer',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: true),
          const SizedBox(height: 24),
          _buildButton('Réinitialiser', _resetPassword),
        ]),
      );

  Widget _buildSuccessStep() => _buildStepLayout(
        icon: '✅',
        title: 'Mot de passe changé !',
        subtitle: 'Votre mot de passe a été réinitialisé avec succès.',
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54)),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
          child: const Text('Retour à la connexion',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      );

  Widget _buildStepLayout(
      {required String icon,
      required String title,
      required String subtitle,
      required Widget child}) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        Text(icon, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 20),
        Text(title,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 36),
        child,
      ]),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
