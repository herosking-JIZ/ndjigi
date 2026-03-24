/**
 * ============================================================
 * CONFIG/DATABASE.JS — Gestionnaire de base de données
 * ============================================================
 * Utilise lowdb (base JSON) pour simuler une vraie base.
 * En production, remplacer par MySQL / PostgreSQL / MongoDB.
 * ============================================================
 */

const low      = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const path     = require('path');
require('dotenv').config();

// Chemin vers le fichier JSON qui stocke les données
const dbPath = path.resolve(process.env.DB_PATH || './data/database.json');

const adapter = new FileSync(dbPath);
const db      = low(adapter);

/**
 * Initialise la structure de la base de données avec des valeurs par défaut.
 *
 * TABLE users :
 *   id, nom, prenom, email, password (haché), role, telephone,
 *   isActive, loginAttempts, lockedUntil, createdAt, updatedAt, lastLogin
 *
 * TABLE refresh_tokens :
 *   id, userId, token, expiresAt, createdAt
 */
function initDatabase() {
  db.defaults({
    users:          [],  // Tous les utilisateurs (4 rôles)
    refresh_tokens: []   // Tokens de renouvellement de session
  }).write();

  console.log('Base de donnees initialisee :', dbPath);
}

module.exports = { db, initDatabase };
