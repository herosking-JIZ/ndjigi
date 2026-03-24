/**
 * MIDDLEWARE/AUTH.JS — Middlewares d'authentification et d'autorisation
 *
 * authenticate : vérifie le JWT dans l'en-tête Authorization
 * authorize    : vérifie que l'utilisateur a le(s) rôle(s) requis
 * hasPermission: vérifie une permission spécifique
 */
const { verifyAccessToken }            = require('../utils/jwt');
const { hasPermission, getPermissions} = require('../config/roles');
const UserModel                        = require('../models/User');

/**
 * Middleware d'authentification.
 * Extrait et valide le Bearer token dans Authorization.
 * Injecte req.user avec les infos décodées si valide.
 */
function authenticate(req, res, next) {
  const authHeader = req.headers['authorization'];

  // Vérification de la présence du header
  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: 'Token d\'authentification manquant. Incluez Authorization: Bearer <token>'
    });
  }

  // Format attendu : "Bearer <token>"
  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({
      success: false,
      message: 'Format du token invalide. Utilisez: Bearer <token>'
    });
  }

  const token = parts[1];

  try {
    // Décodage et vérification de la signature JWT
    const decoded = verifyAccessToken(token);

    // Vérification que c'est bien un access token (pas un refresh token)
    if (decoded.type !== 'access') {
      return res.status(401).json({ success: false, message: 'Type de token invalide' });
    }

    // Vérification que le compte existe toujours en base
    const user = UserModel.findById(decoded.sub);
    if (!user) {
      return res.status(401).json({ success: false, message: 'Utilisateur introuvable' });
    }

    // Vérification que le compte est actif
    if (!user.isActive) {
      return res.status(403).json({ success: false, message: 'Compte désactivé. Contactez l\'administrateur.' });
    }

    // Injection de l'utilisateur dans la requête pour les middlewares suivants
    req.user = user;
    next();

  } catch (error) {
    // Gestion des différentes erreurs JWT
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, message: 'Token expiré. Utilisez votre refresh token.', code: 'TOKEN_EXPIRED' });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ success: false, message: 'Token invalide ou corrompu.' });
    }
    return res.status(401).json({ success: false, message: 'Authentification échouée.' });
  }
}

/**
 * Middleware d'autorisation par rôle.
 * Usage : authorize('admin') ou authorize(['admin', 'proprietaire'])
 *
 * @param {string|string[]} roles — Rôle(s) autorisé(s)
 */
function authorize(...roles) {
  // Aplatir le tableau si roles est passé en array
  const allowedRoles = roles.flat();

  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Non authentifié' });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Accès refusé. Cette action requiert l'un des rôles : ${allowedRoles.join(', ')}`,
        yourRole: req.user.role
      });
    }

    next();
  };
}

/**
 * Middleware de vérification de permission fine.
 * Usage : checkPermission('create:vehicle')
 *
 * @param {string} permission — La permission requise
 */
function checkPermission(permission) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Non authentifié' });
    }

    if (!hasPermission(req.user.role, permission)) {
      return res.status(403).json({
        success: false,
        message: `Permission insuffisante. Requiert : ${permission}`,
        yourPermissions: getPermissions(req.user.role)
      });
    }

    next();
  };
}

module.exports = { authenticate, authorize, checkPermission };
