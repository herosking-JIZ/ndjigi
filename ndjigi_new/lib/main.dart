// ============================================================
// MAIN.DART — Point d'entrée de l'application N'DJIGI
// ============================================================
// Architecture :
//   - BlocProvider fourni à la racine de l'app
//   - Injection des dépendances (TokenStorage, ApiClient, Repository)
//   - Thème global via AppTheme
//   - Navigation via AppRouter
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/network/token_storage.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verrouiller l'orientation en portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Personnalisation de la barre de statut système
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const Ndjigi());
}

class Ndjigi extends StatelessWidget {
  const Ndjigi({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- Injection des dépendances ----
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: tokenStorage);
    final authRepo = AuthRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    return MultiProvider(
      tokenStorage: tokenStorage,
      authRepo: authRepo,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

/// Widget wrapper qui fournit le BLoC à toute l'arborescence
class MultiProvider extends StatelessWidget {
  final TokenStorage tokenStorage;
  final AuthRepository authRepo;
  final Widget child;

  const MultiProvider({
    super.key,
    required this.tokenStorage,
    required this.authRepo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(
        authRepository: authRepo,
        tokenStorage: tokenStorage,
      ),
      child: child,
    );
  }
}
