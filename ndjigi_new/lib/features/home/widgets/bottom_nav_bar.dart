// ============================================================
// FEATURES/HOME/WIDGETS/BOTTOM_NAV_BAR.DART
// Navigation bar personnalisée avec indicateur "pilule"
// L'élément actif a un fond en forme de pilule bleu clair
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NdjBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const NdjBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_outlined,      activeIcon: Icons.home_rounded,          label: 'Accueil'),
    _NavItem(icon: Icons.history_outlined,   activeIcon: Icons.history,               label: 'Trajets'),
    _NavItem(icon: Icons.search_outlined,    activeIcon: Icons.search,                label: 'Recherche'),
    _NavItem(icon: Icons.person_outline,     activeIcon: Icons.person,                label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_items.length, (i) => Expanded(
            child: _NavBarItem(
              item:      _items[i],
              isActive:  currentIndex == i,
              onTap:     () => onTap(i),
            ),
          )),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({required this.item, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicateur "pilule" derrière l'icône active
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width:   isActive ? 48 : 0,
            height:  isActive ? 32 : 0,
            decoration: BoxDecoration(
              color: isActive ? AppColors.navIndicator : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
                size: 22,
              ),
            ),
          ),
          if (!isActive) ...[
            Icon(item.icon, color: AppColors.navInactive, size: 22),
          ],
          const SizedBox(height: 2),
          Text(item.label,
            style: TextStyle(
              fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.navActive : AppColors.navInactive,
            ),
          ),
        ],
      ),
    );
  }
}
