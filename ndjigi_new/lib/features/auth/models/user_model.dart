// ============================================================
// FEATURES/AUTH/MODELS/USER_MODEL.DART
// Modèle utilisateur — miroir exact du schéma backend Node.js
// ============================================================

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String? telephone;
  final bool isActive;
  final String? lastLogin;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.telephone,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
  });

  String get fullName => '$prenom $nom';

  /// Libellé d'affichage du rôle (en français)
  String get roleLabel {
    switch (role) {
      case 'passager':     return 'Passager';
      case 'chauffeur':    return 'Chauffeur';
      case 'proprietaire': return 'Propriétaire';
      case 'admin':        return 'Administrateur';
      default:             return role;
    }
  }

  /// Initiales pour l'avatar
  String get initials {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:         json['id']        ?? '',
      nom:        json['nom']       ?? '',
      prenom:     json['prenom']    ?? '',
      email:      json['email']     ?? '',
      role:       json['role']      ?? 'passager',
      telephone:  json['telephone'],
      isActive:   json['isActive']  ?? true,
      lastLogin:  json['lastLogin'],
      createdAt:  json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'nom': nom, 'prenom': prenom, 'email': email,
    'role': role, 'telephone': telephone, 'isActive': isActive,
    'lastLogin': lastLogin, 'createdAt': createdAt,
  };

  @override
  List<Object?> get props => [id, email, role, isActive];
}
