/**
 * ROUTES/USER.ROUTES.JS — Routes de gestion des utilisateurs
 *
 * Routes utilisateur (authentifié) :
 *   GET  /api/users/profile      — Consulter son profil
 *   PUT  /api/users/profile      — Modifier son profil
 *
 * Routes administrateur (rôle admin requis) :
 *   GET    /api/admin/users              — Lister tous les utilisateurs
 *   GET    /api/admin/users/:id          — Détail d'un utilisateur
 *   PUT    /api/admin/users/:id          — Modifier un utilisateur
 *   DELETE /api/admin/users/:id          — Supprimer un utilisateur
 *   PATCH  /api/admin/users/:id/toggle-active — Activer/désactiver
 *   PATCH  /api/admin/users/:id/role     — Changer le rôle
 *   GET    /api/admin/stats              — Statistiques globales
 */
const express          = require('express');
const UserController   = require('../controllers/userController');
const { authenticate, authorize } = require('../middleware/auth');
const { validateUpdateProfile }   = require('../middleware/validate');
const { ROLES }        = require('../config/roles');

const router = express.Router();

// ============================================================
// ROUTES UTILISATEUR AUTHENTIFIÉ (tous rôles)
// ============================================================

// Profil personnel
router.get('/profile',  authenticate, UserController.getProfile);
router.put('/profile',  authenticate, validateUpdateProfile, UserController.updateProfile);

// ============================================================
// ROUTES ADMINISTRATEUR (rôle admin uniquement)
// ============================================================

// Toutes les routes /admin/* requièrent : authentification + rôle admin
const adminAuth = [authenticate, authorize(ROLES.ADMIN)];

router.get('/admin/stats',                    ...adminAuth, UserController.getStats);
router.get('/admin/users',                    ...adminAuth, UserController.getAllUsers);
router.get('/admin/users/:id',                ...adminAuth, UserController.getUserById);
router.put('/admin/users/:id',                ...adminAuth, UserController.updateUser);
router.delete('/admin/users/:id',             ...adminAuth, UserController.deleteUser);
router.patch('/admin/users/:id/toggle-active',...adminAuth, UserController.toggleActive);
router.patch('/admin/users/:id/role',         ...adminAuth, UserController.changeRole);

module.exports = router;
