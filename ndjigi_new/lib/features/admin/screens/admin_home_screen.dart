// ============================================================
// FEATURES/ADMIN/SCREENS/ADMIN_HOME_SCREEN.DART
// Tableau de bord Administrateur
// Utilise l'API Node.js : GET /api/admin/stats + /api/admin/users
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/models/user_model.dart';
import '../../home/widgets/bottom_nav_bar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _navIndex = 0;
  // Stats chargées depuis le backend (simulées ici si pas de connexion)
  Map<String, dynamic> _stats = {
    'total': 4,
    'actifs': 4,
    'inactifs': 0,
    'parRole': {'passager': 1, 'chauffeur': 1, 'proprietaire': 1, 'admin': 1},
  };
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // En production, appeler le repository :
    // final repo = context.read<AuthRepository>();
    // final stats = await repo.getAdminStats();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _statsLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Column(children: [
        _buildHeader(context, user),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            // Alerte admin
            _buildAdminBanner(),
            const SizedBox(height: 20),
            // Statistiques
            const Text('Vue d\'ensemble',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _statsLoading ? _buildStatsShimmer() : _buildStatsGrid(),
            const SizedBox(height: 24),
            // Utilisateurs récents
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Utilisateurs récents',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              TextButton(
                onPressed: () {},
                child: const Text('Voir tout',
                    style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 12),
            _buildUsersList(),
            const SizedBox(height: 24),
            // Actions rapides admin
            const Text('Actions rapides',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 80),
          ]),
        )),
      ])),
      bottomNavigationBar: NdjBottomNavBar(
          currentIndex: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bonjour, ${user.prenom} 👑',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const Text('Panneau d\'administration',
              style: TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () {
            context.read<AuthBloc>().add(AuthLogoutRequested());
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(children: [
              Icon(Icons.logout, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('Quitter',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildAdminBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.adminColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adminColor.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.admin_panel_settings,
            color: AppColors.adminColor, size: 22),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Mode Administrateur',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.adminColor)),
          Text('Accès complet — ${_stats['total']} utilisateurs gérés',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: AppColors.success, shape: BoxShape.circle)),
      ]),
    );
  }

  Widget _buildStatsGrid() {
    final parRole = _stats['parRole'] as Map<String, dynamic>;
    final tiles = [
      _StatData('Total', '${_stats['total']}', Icons.people_outline,
          AppColors.primary),
      _StatData('Actifs', '${_stats['actifs']}', Icons.check_circle_outline,
          AppColors.success),
      _StatData('Passagers', '${parRole['passager']}', Icons.person_outline,
          AppColors.passagerColor),
      _StatData('Chauffeurs', '${parRole['chauffeur']}',
          Icons.drive_eta_outlined, AppColors.chauffeurColor),
      _StatData('Propriét.', '${parRole['proprietaire']}', Icons.directions_car,
          AppColors.proprietaireColor),
      _StatData('Admins', '${parRole['admin']}', Icons.admin_panel_settings,
          AppColors.adminColor),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: tiles.map((t) => _StatTile(data: t)).toList(),
    );
  }

  Widget _buildStatsShimmer() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: List.generate(
          6,
          (_) => Container(
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(14)),
              )),
    );
  }

  Widget _buildUsersList() {
    final fakeUsers = [
      {'prenom': 'Moussa', 'nom': 'Diallo', 'role': 'passager', 'active': true},
      {
        'prenom': 'Ibrahim',
        'nom': 'Ouedraogo',
        'role': 'chauffeur',
        'active': true
      },
      {
        'prenom': 'Adama',
        'nom': 'Zongo',
        'role': 'proprietaire',
        'active': false
      },
    ];
    return Column(
      children: fakeUsers.map((u) => _UserListTile(user: u)).toList(),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'label': 'Ajouter utilisateur',
        'icon': Icons.person_add_outlined,
        'color': AppColors.primary
      },
      {
        'label': 'Voir les logs',
        'icon': Icons.list_alt_outlined,
        'color': AppColors.info
      },
      {
        'label': 'Paramètres',
        'icon': Icons.settings_outlined,
        'color': AppColors.textSecondary
      },
      {
        'label': 'Signalements',
        'icon': Icons.flag_outlined,
        'color': AppColors.error
      },
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 3,
      children: actions
          .map((a) => GestureDetector(
                onTap: () {},
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(children: [
                    Icon(a['icon'] as IconData,
                        color: a['color'] as Color, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(a['label'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ))
          .toList(),
    );
  }
}

class _StatData {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

class _StatTile extends StatelessWidget {
  final _StatData data;
  const _StatTile({required this.data});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: data.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: data.color.withOpacity(0.15)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(data.icon, color: data.color, size: 20),
          const SizedBox(height: 4),
          Text(data.value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: data.color)),
          Text(data.label,
              style:
                  const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ]),
      );
}

class _UserListTile extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserListTile({required this.user});

  Color get _roleColor => switch (user['role']) {
        'chauffeur' => AppColors.chauffeurColor,
        'proprietaire' => AppColors.proprietaireColor,
        'admin' => AppColors.adminColor,
        _ => AppColors.passagerColor,
      };

  String get _roleLabel => switch (user['role']) {
        'chauffeur' => 'Chauffeur',
        'proprietaire' => 'Propriétaire',
        'admin' => 'Admin',
        _ => 'Passager',
      };

  @override
  Widget build(BuildContext context) {
    final initials = '${user['prenom'][0]}${user['nom'][0]}'.toUpperCase();
    final active = user['active'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: _roleColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(
              child: Text(initials,
                  style: TextStyle(
                      color: _roleColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13))),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${user['prenom']} ${user['nom']}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: _roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Text(_roleLabel,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _roleColor)),
          ),
        ])),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: active ? AppColors.success : AppColors.error,
              shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(active ? 'Actif' : 'Inactif',
            style: TextStyle(
                fontSize: 11,
                color: active ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
