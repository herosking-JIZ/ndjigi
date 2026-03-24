/**
 * MODELS/USER.JS — Modèle Utilisateur
 *
 * Fournit toutes les opérations CRUD sur la table "users".
 * Isole la logique d'accès aux données du reste de l'application.
 */
const { v4: uuidv4 } = require('uuid');
const bcrypt         = require('bcryptjs');
const { db }         = require('../config/database');
require('dotenv').config();

const BCRYPT_ROUNDS = parseInt(process.env.BCRYPT_ROUNDS) || 10;

const UserModel = {

  /**
   * Crée un nouvel utilisateur dans la base de données.
   * Le mot de passe est haché avec bcrypt avant stockage.
   */
  async create({ nom, prenom, email, password, role, telephone }) {
    // Hachage sécurisé du mot de passe (bcrypt + salt automatique)
    const hashedPassword = await bcrypt.hash(password, BCRYPT_ROUNDS);
    const now = new Date().toISOString();

    const newUser = {
      id:            uuidv4(),       // ID unique universel
      nom:           nom.trim(),
      prenom:        prenom.trim(),
      email:         email.toLowerCase().trim(),
      password:      hashedPassword,  // Jamais en clair !
      role:          role,
      telephone:     telephone || null,
      isActive:      true,            // Compte actif par défaut
      loginAttempts: 0,               // Compteur tentatives échouées
      lockedUntil:   null,            // Pas de blocage au départ
      createdAt:     now,
      updatedAt:     now,
      lastLogin:     null
    };

    db.get('users').push(newUser).write();
    // Retourner sans le mot de passe haché
    const { password: _, ...userWithoutPassword } = newUser;
    return userWithoutPassword;
  },

  /** Trouve un utilisateur par son ID */
  findById(id) {
    const user = db.get('users').find({ id }).value();
    if (!user) return null;
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword;
  },

  /** Trouve un utilisateur par email (inclut le mot de passe pour vérification) */
  findByEmailWithPassword(email) {
    return db.get('users').find({ email: email.toLowerCase().trim() }).value() || null;
  },

  /** Trouve un utilisateur par email (sans mot de passe) */
  findByEmail(email) {
    const user = db.get('users').find({ email: email.toLowerCase().trim() }).value();
    if (!user) return null;
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword;
  },

  /** Retourne tous les utilisateurs (sans mots de passe) */
  findAll() {
    return db.get('users').value().map(({ password: _, ...u }) => u);
  },

  /** Retourne tous les utilisateurs d'un rôle donné */
  findByRole(role) {
    return db.get('users').filter({ role }).value().map(({ password: _, ...u }) => u);
  },

  /**
   * Met à jour les champs d'un utilisateur.
   * Si le mot de passe est fourni, il est rehâché.
   */
  async update(id, updates) {
    // Ne jamais laisser passer un mot de passe en clair
    if (updates.password) {
      updates.password = await bcrypt.hash(updates.password, BCRYPT_ROUNDS);
    }
    updates.updatedAt = new Date().toISOString();

    db.get('users').find({ id }).assign(updates).write();
    return this.findById(id);
  },

  /** Supprime définitivement un utilisateur */
  delete(id) {
    db.get('users').remove({ id }).write();
    return true;
  },

  /** Vérifie si un email est déjà utilisé */
  emailExists(email) {
    return !!db.get('users').find({ email: email.toLowerCase().trim() }).value();
  },

  /**
   * Incrémente le compteur de tentatives échouées.
   * Bloque le compte si le maximum est atteint.
   */
  incrementLoginAttempts(id) {
    const MAX_ATTEMPTS  = parseInt(process.env.MAX_LOGIN_ATTEMPTS) || 5;
    const LOCKOUT_DURATION = parseInt(process.env.LOCKOUT_DURATION) || 900000;

    const user = db.get('users').find({ id }).value();
    if (!user) return;

    const attempts = (user.loginAttempts || 0) + 1;
    const updates  = { loginAttempts: attempts, updatedAt: new Date().toISOString() };

    // Blocage temporaire si trop de tentatives
    if (attempts >= MAX_ATTEMPTS) {
      updates.lockedUntil = Date.now() + LOCKOUT_DURATION;
    }

    db.get('users').find({ id }).assign(updates).write();
  },

  /** Réinitialise le compteur après une connexion réussie */
  resetLoginAttempts(id) {
    db.get('users').find({ id }).assign({
      loginAttempts: 0,
      lockedUntil:   null,
      lastLogin:     new Date().toISOString(),
      updatedAt:     new Date().toISOString()
    }).write();
  },

  /**
   * Vérifie si un compte est bloqué.
   * Si le délai est passé, débloque automatiquement.
   */
  isLocked(user) {
    if (!user.lockedUntil) return false;
    if (Date.now() > user.lockedUntil) {
      // Déblocage automatique après expiration
      db.get('users').find({ id: user.id }).assign({
        lockedUntil:   null,
        loginAttempts: 0,
        updatedAt:     new Date().toISOString()
      }).write();
      return false;
    }
    return true;
  }
};

module.exports = UserModel;
