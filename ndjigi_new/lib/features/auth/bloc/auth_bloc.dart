// ============================================================
// FEATURES/AUTH/BLOC/AUTH_BLOC.DART
// BLoC d'authentification — gère tous les états de session
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';
import '../../../core/network/auth_repository.dart';
import '../../../core/network/token_storage.dart';

// ---- EVENTS ----
abstract class AuthEvent extends Equatable {
  @override List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
  @override List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String nom, prenom, email, password, role;
  final String? telephone;
  AuthRegisterRequested({
    required this.nom, required this.prenom, required this.email,
    required this.password, required this.role, this.telephone,
  });
  @override List<Object?> get props => [email, role];
}

class AuthLogoutRequested extends AuthEvent {}

// ---- STATES ----
abstract class AuthState extends Equatable {
  @override List<Object?> get props => [];
}

class AuthInitial        extends AuthState {}
class AuthLoading        extends AuthState {}
class AuthCheckingSession extends AuthState {} // Vérification au démarrage

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
  @override List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override List<Object> get props => [message];
}

// ---- BLOC ----
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage   _tokenStorage;

  AuthBloc({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  })  : _authRepository = authRepository,
        _tokenStorage   = tokenStorage,
        super(AuthInitial()) {

    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  /// Vérifie si l'utilisateur a une session active au démarrage
  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthCheckingSession());
    try {
      final hasToken = await _tokenStorage.hasToken();
      if (!hasToken) {
        emit(AuthUnauthenticated());
        return;
      }
      // Essayer de récupérer le profil depuis l'API (token valide ?)
      try {
        final user = await _authRepository.getMe();
        emit(AuthAuthenticated(user));
      } catch (_) {
        // Token invalide ou expiré : utiliser le cache local
        final cachedUser = await _authRepository.getCachedUser();
        if (cachedUser != null) {
          emit(AuthAuthenticated(cachedUser));
        } else {
          await _tokenStorage.clearAll();
          emit(AuthUnauthenticated());
        }
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(
        email:    event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(
        nom:       event.nom,
        prenom:    event.prenom,
        email:     event.email,
        password:  event.password,
        role:      event.role,
        telephone: event.telephone,
      );
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
