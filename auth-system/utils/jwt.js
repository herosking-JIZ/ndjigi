/**
 * UTILS/JWT.JS — Utilitaires JSON Web Token
 *
 * Architecture à deux tokens :
 *   - Access Token  : courte durée (15 min), envoyé à chaque requête
 *   - Refresh Token : longue durée (7 jours), renouvelle l'access token
 */
const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET         = process.env.JWT_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;
const JWT_EXPIRES_IN     = process.env.JWT_EXPIRES_IN      || '15m';
const JWT_REFRESH_EXPIRES= process.env.JWT_REFRESH_EXPIRES_IN || '7d';

/** Génère un Access Token (courte durée) */
function generateAccessToken(user) {
  return jwt.sign(
    { sub: user.id, email: user.email, role: user.role, prenom: user.prenom, nom: user.nom, type: 'access' },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN, issuer: 'auth-system', audience: 'auth-system-client' }
  );
}

/** Génère un Refresh Token (longue durée) */
function generateRefreshToken(user) {
  return jwt.sign(
    { sub: user.id, type: 'refresh' },
    JWT_REFRESH_SECRET,
    { expiresIn: JWT_REFRESH_EXPIRES, issuer: 'auth-system', audience: 'auth-system-client' }
  );
}

/** Vérifie un Access Token et retourne le payload */
function verifyAccessToken(token) {
  return jwt.verify(token, JWT_SECRET, { issuer: 'auth-system', audience: 'auth-system-client' });
}

/** Vérifie un Refresh Token et retourne le payload */
function verifyRefreshToken(token) {
  return jwt.verify(token, JWT_REFRESH_SECRET, { issuer: 'auth-system', audience: 'auth-system-client' });
}

/** Calcule le timestamp d'expiration d'un refresh token */
function getRefreshTokenExpiry(duration) {
  duration = duration || JWT_REFRESH_EXPIRES;
  const units = { d: 86400000, h: 3600000, m: 60000, s: 1000 };
  const match = duration.match(/^(\d+)([dhms])$/);
  if (!match) return Date.now() + 7 * 86400000;
  return Date.now() + parseInt(match[1]) * units[match[2]];
}

module.exports = { generateAccessToken, generateRefreshToken, verifyAccessToken, verifyRefreshToken, getRefreshTokenExpiry };
