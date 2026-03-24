// ============================================================
// FEATURES/HOME/SCREENS/HOME_SCREEN.DART
// Écran principal Passager — Style Google Maps personnalisé
// avec Bottom Sheet persistant et carte en fond
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../widgets/fake_map_widget.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int    _currentNavIndex = 0;
  String _selectedVehicle = 'moto';

  static const List<Map<String, dynamic>> _vehicles = [
    {'id': 'moto',      'label': 'Moto',       'icon': Icons.two_wheeler,    'price': '500 F'},
    {'id': 'eco',       'label': 'Économique',  'icon': Icons.directions_car, 'price': '1200 F'},
    {'id': 'confort',   'label': 'Confort',     'icon': Icons.airline_seat_recline_extra, 'price': '2000 F'},
    {'id': 'premium',   'label': 'Premium',     'icon': Icons.star_outline,   'price': '3500 F'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state is AuthAuthenticated)
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // ---- 1. Fond : Carte personnalisée ----
          const FakeMapWidget(),

          // ---- 2. Header flottant ----
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Bouton retour (profil)
                  _FloatingCircleButton(
                    icon: Icons.person_outline,
                    onTap: () => _showProfileDrawer(context, user),
                  ),
                  const Spacer(),
                  // Badge N'DJIGI
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0,4))],
                    ),
                    child: const Text(
                      AppConstants.appName,
                      style: TextStyle(color: AppColors.primary, fontSize: 15,
                          fontWeight: FontWeight.w700, letterSpacing: 2),
                    ),
                  ),
                  const Spacer(),
                  // Bouton notification
                  _FloatingCircleButton(
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                    badge: true,
                  ),
                ],
              ),
            ),
          ),

          // ---- 3. Bottom Sheet persistant ----
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheet(context),
                // Navigation bar avec fond blanc incluse dans la sheet
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NdjBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur drag
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            // Titre
            const Text('Choisissez votre véhicule',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
            const SizedBox(height: 16),
            // Sélecteur horizontal de véhicules
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final v = _vehicles[i];
                  return VehicleCard(
                    label:      v['label'],
                    icon:       v['icon'],
                    price:      v['price'],
                    isSelected: _selectedVehicle == v['id'],
                    onTap:      () => setState(() => _selectedVehicle = v['id']),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Barre d'action
            Row(children: [
              // Bouton SOS
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Text('!', style: TextStyle(color: AppColors.error, fontSize: 22, fontWeight: FontWeight.w900)),
                  onPressed: () => _showSosDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              // Bouton principal
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.directions_car, size: 20),
                  label: const Text('Trouver un chauffeur',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  onPressed: () => _findDriver(context),
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _findDriver(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Recherche en cours...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          Text('Nous cherchons un chauffeur disponible\nnear you',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ]),
      ),
    );
  }

  void _showSosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
          SizedBox(width: 8),
          Text('SOS Urgence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.error)),
        ]),
        content: const Text('Voulez-vous contacter les secours d\'urgence ?',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context),
            child: const Text('Appeler', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProfileDrawer(BuildContext context, user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(user: user),
    );
  }
}

class _FloatingCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  const _FloatingCircleButton({required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0,4))],
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: AppColors.textPrimary, size: 20)),
            if (badge) Positioned(
              top: 8, right: 8,
              child: Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  final dynamic user;
  const _ProfileSheet({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Avatar
        Container(
          width: 72, height: 72,
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: Center(child: Text(user?.initials ?? '?',
              style: const TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(height: 12),
        Text(user?.fullName ?? 'Utilisateur',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
          child: Text(user?.roleLabel ?? 'Passager',
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.person_outline, color: AppColors.primary),
          title: const Text('Mon profil'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pop(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: AppColors.cardBg,
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.error),
          onTap: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(AuthLogoutRequested());
            Navigator.of(context).pushReplacementNamed('/login');
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: AppColors.error.withOpacity(0.05),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}
