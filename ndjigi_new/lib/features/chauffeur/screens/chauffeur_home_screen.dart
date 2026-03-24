// ============================================================
// FEATURES/CHAUFFEUR/SCREENS/CHAUFFEUR_HOME_SCREEN.DART
// Tableau de bord Chauffeur
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../home/widgets/fake_map_widget.dart';
import '../../home/widgets/bottom_nav_bar.dart';

class ChauffeurHomeScreen extends StatefulWidget {
  const ChauffeurHomeScreen({super.key});
  @override
  State<ChauffeurHomeScreen> createState() => _ChauffeurHomeScreenState();
}

class _ChauffeurHomeScreenState extends State<ChauffeurHomeScreen> {
  bool _isOnline = false;
  int _navIndex = 0;
  int _todayTrips = 3;
  double _earnings = 4500;

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Fond carte
          const FakeMapWidget(),

          // Header flottant
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                // Avatar
                GestureDetector(
                  onTap: () => _showProfile(context, user),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ]),
                    child: Center(
                        child: Text(user.initials,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14))),
                  ),
                ),
                const Spacer(),
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: _isOnline ? AppColors.success : Colors.grey,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text(AppConstants.appName,
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2)),
                  ]),
                ),
                const Spacer(),
                // Notification
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]),
                  child: const Icon(Icons.notifications_outlined,
                      color: AppColors.textPrimary, size: 20),
                ),
              ]),
            ),
          ),

          // Bottom Sheet Chauffeur
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(context),
          ),
        ],
      ),
      bottomNavigationBar: NdjBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          // Statistiques du jour
          Row(children: [
            _StatCard(
                label: 'Trajets',
                value: '$_todayTrips',
                icon: Icons.route,
                color: AppColors.primary),
            const SizedBox(width: 12),
            _StatCard(
                label: 'Gains',
                value: '${_earnings.toInt()} F',
                icon: Icons.monetization_on_outlined,
                color: AppColors.warning),
            const SizedBox(width: 12),
            _StatCard(
                label: 'Note',
                value: '4.8 ⭐',
                icon: Icons.star_outline,
                color: AppColors.info),
          ]),
          const SizedBox(height: 16),

          // Toggle en ligne / hors ligne
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  _isOnline ? AppColors.primaryLight : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: _isOnline
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.divider),
            ),
            child: Row(children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _isOnline ? AppColors.success : Colors.grey,
                    shape: BoxShape.circle,
                    boxShadow: _isOnline
                        ? [
                            BoxShadow(
                                color: AppColors.success.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 2)
                          ]
                        : [],
                  )),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                _isOnline
                    ? 'Vous êtes en ligne — En attente de courses...'
                    : 'Vous êtes hors ligne',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isOnline
                        ? AppColors.primary
                        : AppColors.textSecondary),
              )),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _isOnline,
                  onChanged: (v) => setState(() => _isOnline = v),
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Bouton "Voir mes trajets"
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.list_alt, size: 20),
              label: const Text('Mes trajets du jour',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showProfile(BuildContext context, user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Center(
                  child: Text(user.initials,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700)))),
          const SizedBox(height: 12),
          Text(user.fullName,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.chauffeurColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: const Text('Chauffeur',
                style: TextStyle(
                    color: AppColors.chauffeurColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Se déconnecter',
                style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.of(context).pushReplacementNamed('/login');
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: AppColors.error.withOpacity(0.05),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    ));
  }
}
