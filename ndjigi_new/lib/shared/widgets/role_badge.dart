// ============================================================
// SHARED/WIDGETS/ROLE_BADGE.DART
// Badge coloré affichant le rôle d'un utilisateur
// ============================================================

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  final double fontSize;

  const RoleBadge({super.key, required this.role, this.fontSize = 11});

  Color get _color => switch (role) {
    AppConstants.roleChauffeur    => AppColors.chauffeurColor,
    AppConstants.roleProprietaire => AppColors.proprietaireColor,
    AppConstants.roleAdmin        => AppColors.adminColor,
    _                             => AppColors.passagerColor,
  };

  String get _label => switch (role) {
    AppConstants.roleChauffeur    => 'Chauffeur',
    AppConstants.roleProprietaire => 'Propriétaire',
    AppConstants.roleAdmin        => 'Administrateur',
    _                             => 'Passager',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(_label, style: TextStyle(color: _color, fontSize: fontSize, fontWeight: FontWeight.w600)),
    );
  }
}
