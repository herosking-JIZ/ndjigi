// ============================================================
// FEATURES/AUTH/WIDGETS/ROLE_SELECTOR.DART
// Sélecteur de rôle horizontal avec animation
// Rôle admin exclu de la liste (connexion uniquement via email)
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class _RoleOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _RoleOption(this.value, this.label, this.icon, this.color);
}

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final void Function(String) onRoleSelected;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  static const List<_RoleOption> _roles = [
    _RoleOption(AppConstants.rolePassager,     'Passager',     Icons.person_outline,    AppColors.passagerColor),
    _RoleOption(AppConstants.roleChauffeur,    'Chauffeur',    Icons.drive_eta_outlined, AppColors.chauffeurColor),
    _RoleOption(AppConstants.roleProprietaire, 'Propriétaire', Icons.directions_car,    AppColors.proprietaireColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _roles.map((role) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _RoleCard(
            option:    role,
            isSelected: selectedRole == role.value,
            onTap:     () => onRoleSelected(role.value),
          ),
        ),
      )).toList(),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final _RoleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({required this.option, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:        isSelected ? option.color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? option.color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: option.color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
          ] : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(option.icon, color: isSelected ? option.color : AppColors.textHint, size: 24),
            const SizedBox(height: 6),
            Text(option.label, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: isSelected ? option.color : AppColors.textSecondary,
            )),
          ],
        ),
      ),
    );
  }
}
