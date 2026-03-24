// ============================================================
// FEATURES/PROPRIETAIRE/SCREENS/PROPRIETAIRE_HOME_SCREEN.DART
// Tableau de bord Propriétaire de véhicule
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../home/widgets/bottom_nav_bar.dart';

class ProprietaireHomeScreen extends StatefulWidget {
  const ProprietaireHomeScreen({super.key});
  @override
  State<ProprietaireHomeScreen> createState() => _ProprietaireHomeScreenState();
}

class _ProprietaireHomeScreenState extends State<ProprietaireHomeScreen> {
  int _navIndex = 0;

  // Véhicules fictifs pour démonstration
  final List<Map<String, dynamic>> _vehicules = [
    {
      'marque': 'Toyota Corolla',
      'plaque': 'BF-1234-A',
      'statut': 'Disponible',
      'color': AppColors.success,
      'icon': Icons.directions_car
    },
    {
      'marque': 'Honda CB 125',
      'plaque': 'BF-5678-B',
      'statut': 'En course',
      'color': AppColors.warning,
      'icon': Icons.two_wheeler
    },
    {
      'marque': 'Renault Logan',
      'plaque': 'BF-9012-C',
      'statut': 'Maintenance',
      'color': AppColors.error,
      'icon': Icons.car_repair
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // Header
          _buildHeader(context, user),
          // Contenu
          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              // Stats globales
              _buildStatsRow(),
              const SizedBox(height: 24),
              // Section véhicules
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Mes véhicules',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                TextButton.icon(
                  icon:
                      const Icon(Icons.add, size: 18, color: AppColors.primary),
                  label: const Text('Ajouter',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  onPressed: () => _showAddVehicle(context),
                ),
              ]),
              const SizedBox(height: 12),
              ..._vehicules.map((v) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VehicleListTile(vehicle: v, onTap: () {}),
                  )),
              const SizedBox(height: 24),
              // Revenus récents
              const Text('Revenus récents',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildRevenueCard(),
              const SizedBox(height: 80),
            ]),
          )),
        ]),
      ),
      bottomNavigationBar: NdjBottomNavBar(
          currentIndex: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))
      ]),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bonjour, ${user.prenom} 👋',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.proprietaireColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: const Text('Propriétaire',
                style: TextStyle(
                    color: AppColors.proprietaireColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
        const Spacer(),
        // Avatar + déconnexion
        GestureDetector(
          onTap: () {
            context.read<AuthBloc>().add(AuthLogoutRequested());
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.proprietaireColor.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Center(
                child: Text(user.initials,
                    style: const TextStyle(
                        color: AppColors.proprietaireColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15))),
          ),
        ),
      ]),
    );
  }

  Widget _buildStatsRow() {
    return Row(children: [
      _buildStatTile(
          '3', 'Véhicules', Icons.directions_car_outlined, AppColors.primary),
      const SizedBox(width: 12),
      _buildStatTile('12 500 F', 'Ce mois',
          Icons.account_balance_wallet_outlined, AppColors.success),
      const SizedBox(width: 12),
      _buildStatTile(
          '4.7 ⭐', 'Note moy.', Icons.star_outline, AppColors.warning),
    ]);
  }

  Widget _buildStatTile(
      String value, String label, IconData icon, Color color) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    ));
  }

  Widget _buildRevenueCard() {
    final weeks = [
      {'label': 'Lun', 'val': 0.6},
      {'label': 'Mar', 'val': 0.8},
      {'label': 'Mer', 'val': 0.4},
      {'label': 'Jeu', 'val': 0.9},
      {'label': 'Ven', 'val': 1.0},
      {'label': 'Sam', 'val': 0.7},
      {'label': 'Dim', 'val': 0.3},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Cette semaine',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          Text('12 500 F',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeks
                .map((w) => Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 50 * (w['val'] as double),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(
                                    w['val'] == 1.0
                                        ? 1.0
                                        : 0.3 + (w['val'] as double) * 0.4),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(w['label'] as String,
                                style: const TextStyle(
                                    fontSize: 9, color: AppColors.textHint)),
                          ]),
                    )))
                .toList(),
          ),
        ),
      ]),
    );
  }

  void _showAddVehicle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajouter un véhicule',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextField(
                    decoration: InputDecoration(
                  labelText: 'Marque et modèle',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
                const SizedBox(height: 12),
                TextField(
                    decoration: InputDecoration(
                  labelText: 'Numéro de plaque',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Enregistrer le véhicule',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
              ]),
        ),
      ),
    );
  }
}

class _VehicleListTile extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onTap;
  const _VehicleListTile({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ],
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (vehicle['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(vehicle['icon'] as IconData,
                color: vehicle['color'] as Color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(vehicle['marque'],
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(vehicle['plaque'],
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (vehicle['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(vehicle['statut'],
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: vehicle['color'] as Color)),
          ),
        ]),
      ),
    );
  }
}
