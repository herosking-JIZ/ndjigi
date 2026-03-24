/**
 * ============================================================
 * CONFIG/ROLES.JS — Définition des rôles et permissions
 * ============================================================
 * Centralise toutes les règles d'autorisation du système.
 * Chaque rôle dispose d'un ensemble de permissions précis.
 * ============================================================
 */

// -----------------------------------------------------------
// Les 4 rôles disponibles dans le système
// -----------------------------------------------------------
const ROLES = {
  PASSAGER:     'passager',      // Utilisateur qui réserve des trajets
  CHAUFFEUR:    'chauffeur',     // Conducteur qui effectue les trajets
  PROPRIETAIRE: 'proprietaire', // Propriétaire de véhicule(s)
  ADMIN:        'admin'          // Administrateur avec tous les droits
};

// -----------------------------------------------------------
// Permissions disponibles dans l'application
// -----------------------------------------------------------
const PERMISSIONS = {
  // Gestion des utilisateurs
  READ_OWN_PROFILE:   'read:own_profile',
  UPDATE_OWN_PROFILE: 'update:own_profile',
  READ_ALL_USERS:     'read:all_users',
  UPDATE_ANY_USER:    'update:any_user',
  DELETE_ANY_USER:    'delete:any_user',
  CREATE_USER:        'create:user',

  // Gestion des véhicules
  READ_VEHICLES:      'read:vehicles',
  CREATE_VEHICLE:     'create:vehicle',
  UPDATE_OWN_VEHICLE: 'update:own_vehicle',
  DELETE_OWN_VEHICLE: 'delete:own_vehicle',
  MANAGE_ALL_VEHICLES:'manage:all_vehicles',

  // Gestion des trajets
  READ_TRIPS:         'read:trips',
  CREATE_TRIP:        'create:trip',
  BOOK_TRIP:          'book:trip',
  MANAGE_ALL_TRIPS:   'manage:all_trips',

  // Administration système
  VIEW_DASHBOARD:     'view:dashboard',
  MANAGE_ROLES:       'manage:roles',
  VIEW_LOGS:          'view:logs'
};

// -----------------------------------------------------------
// Matrice de permissions : rôle => liste de permissions
// -----------------------------------------------------------
const ROLE_PERMISSIONS = {

  [ROLES.PASSAGER]: [
    PERMISSIONS.READ_OWN_PROFILE,
    PERMISSIONS.UPDATE_OWN_PROFILE,
    PERMISSIONS.READ_VEHICLES,
    PERMISSIONS.READ_TRIPS,
    PERMISSIONS.BOOK_TRIP
  ],

  [ROLES.CHAUFFEUR]: [
    PERMISSIONS.READ_OWN_PROFILE,
    PERMISSIONS.UPDATE_OWN_PROFILE,
    PERMISSIONS.READ_VEHICLES,
    PERMISSIONS.READ_TRIPS,
    PERMISSIONS.CREATE_TRIP
  ],

  [ROLES.PROPRIETAIRE]: [
    PERMISSIONS.READ_OWN_PROFILE,
    PERMISSIONS.UPDATE_OWN_PROFILE,
    PERMISSIONS.READ_VEHICLES,
    PERMISSIONS.CREATE_VEHICLE,
    PERMISSIONS.UPDATE_OWN_VEHICLE,
    PERMISSIONS.DELETE_OWN_VEHICLE,
    PERMISSIONS.READ_TRIPS
  ],

  // L'administrateur hérite de TOUTES les permissions
  [ROLES.ADMIN]: Object.values(PERMISSIONS)
};

/**
 * Vérifie si un rôle possède une permission donnée.
 * @param {string} role       — Le rôle de l'utilisateur
 * @param {string} permission — La permission à vérifier
 * @returns {boolean}
 */
function hasPermission(role, permission) {
  const perms = ROLE_PERMISSIONS[role];
  return perms ? perms.includes(permission) : false;
}

/**
 * Retourne toutes les permissions d'un rôle.
 * @param {string} role
 * @returns {string[]}
 */
function getPermissions(role) {
  return ROLE_PERMISSIONS[role] || [];
}

module.exports = { ROLES, PERMISSIONS, ROLE_PERMISSIONS, hasPermission, getPermissions };
