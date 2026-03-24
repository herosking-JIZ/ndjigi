/**
 * ROUTES/AUTH.ROUTES.JS — Routes d'authentification
 *
 * POST /api/auth/register   — Inscription
 * POST /api/auth/login      — Connexion
 * POST /api/auth/refresh    — Renouvellement de token
 * POST /api/auth/logout     — Déconnexion
 * POST /api/auth/logout-all — Déconnexion de toutes les sessions
 * GET  /api/auth/me         — Profil de l'utilisateur connecté
 */
const express        = require('express');
const rateLimit      = require('express-rate-limit');
const AuthController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');
const { validateRegister, validateLogin } = require('../middleware/validate');

const router = express.Router();

// ---- Rate limiting : protection contre le brute-force ----
// Maximum 10 tentatives de connexion par IP sur 15 minutes
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max:      10,
  message:  { success: false, message: 'Trop de tentatives. Réessayez dans 15 minutes.' },
  standardHeaders: true,
  legacyHeaders:   false
});

// Maximum 5 inscriptions par IP sur 1 heure
const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max:      5,
  message:  { success: false, message: 'Trop d\'inscriptions. Réessayez dans 1 heure.' }
});

// ---- Définition des routes ----

// Inscription : validation + rate limit
router.post('/register', registerLimiter, validateRegister, AuthController.register);

// Connexion : validation + rate limit
router.post('/login', loginLimiter, validateLogin, AuthController.login);

// Renouvellement de token (pas de rate limit agressif car refresh tokens sont déjà sécurisés)
router.post('/refresh', AuthController.refresh);

// Déconnexion (pas besoin d'être authentifié, on révoque juste le token)
router.post('/logout', AuthController.logout);

// Déconnexion totale (requiert d'être authentifié)
router.post('/logout-all', authenticate, AuthController.logoutAll);

// Profil courant (requiert authentification)
router.get('/me', authenticate, AuthController.me);

module.exports = router;
