// ============================================================
// FEATURES/HOME/WIDGETS/VEHICLE_CARD.DART
// Carte de sélection de véhicule dans le bottom sheet
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class VehicleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.label,
    required this.icon,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color:        isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 3))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : const Color(0xFF9CA3AF), size: 26),
            const SizedBox(height: 4),
            Text(label,
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(price,
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
