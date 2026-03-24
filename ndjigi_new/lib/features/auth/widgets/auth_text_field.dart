// ============================================================
// FEATURES/AUTH/WIDGETS/AUTH_TEXT_FIELD.DART
// Champ de texte réutilisable pour les formulaires d'auth
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:         controller,
      obscureText:        obscureText,
      keyboardType:       keyboardType,
      textInputAction:    textInputAction,
      onEditingComplete:  onEditingComplete,
      validator:          validator,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText:   label,
        hintText:    hint,
        prefixIcon:  Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon:  suffixIcon,
      ),
    );
  }
}
