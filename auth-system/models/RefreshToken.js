/**
 * MODELS/REFRESHTOKEN.JS — Modèle Refresh Token
 *
 * Gère le stockage et la révocation des refresh tokens.
 * Permet la déconnexion sécurisée et la gestion des sessions.
 */
const { v4: uuidv4 } = require('uuid');
const { db }         = require('../config/database');
const { getRefreshTokenExpiry } = require('../utils/jwt');

const RefreshTokenModel = {

  /** Sauvegarde un nouveau refresh token en base */
  save(userId, token) {
    const record = {
      id:        uuidv4(),
      userId:    userId,
      token:     token,
      expiresAt: new Date(getRefreshTokenExpiry()).toISOString(),
      createdAt: new Date().toISOString()
    };
    db.get('refresh_tokens').push(record).write();
    return record;
  },

  /** Trouve un refresh token par sa valeur */
  findByToken(token) {
    return db.get('refresh_tokens').find({ token }).value() || null;
  },

  /** Supprime un refresh token (déconnexion) */
  deleteByToken(token) {
    db.get('refresh_tokens').remove({ token }).write();
  },

  /** Supprime tous les tokens d'un utilisateur (déconnexion totale) */
  deleteAllByUserId(userId) {
    db.get('refresh_tokens').remove({ userId }).write();
  },

  /**
   * Nettoie les tokens expirés de la base.
   * À appeler périodiquement (cron job en production).
   */
  deleteExpired() {
    const now = new Date().toISOString();
    db.get('refresh_tokens').remove(t => t.expiresAt < now).write();
  },

  /** Vérifie si un token est encore valide (non expiré) */
  isValid(tokenRecord) {
    return new Date(tokenRecord.expiresAt) > new Date();
  }
};

module.exports = RefreshTokenModel;
