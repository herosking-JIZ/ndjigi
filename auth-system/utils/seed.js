/**
 * UTILS/SEED.JS — Peuplement initial de la base de données
 *
 * Crée un compte administrateur par défaut au premier démarrage.
 * Ajoute aussi des comptes de démonstration pour chaque rôle.
 *
 * Usage : node utils/seed.js
 */
require('dotenv').config();
const { db, initDatabase } = require('../config/database');
const UserModel            = require('../models/User');
const { ROLES }            = require('../config/roles');

async function seed() {
  initDatabase();

  const users = db.get('users').value();
  if (users.length > 0) {
    console.log('Base deja peuplee (' + users.length + ' utilisateurs). Seed ignore.');
    return;
  }

  console.log('Peuplement initial de la base de donnees...');

  // Comptes de démonstration pour chaque rôle
  const seedUsers = [
    { nom: 'Admin',      prenom: 'Super',   email: 'admin@system.com',       password: 'Admin@1234',  role: ROLES.ADMIN },
    { nom: 'Diallo',     prenom: 'Moussa',  email: 'passager@demo.com',      password: 'Passager@1',  role: ROLES.PASSAGER,     telephone: '+22670000001' },
    { nom: 'Ouedraogo',  prenom: 'Ibrahim', email: 'chauffeur@demo.com',     password: 'Chauffeur@1', role: ROLES.CHAUFFEUR,    telephone: '+22670000002' },
    { nom: 'Zongo',      prenom: 'Adama',   email: 'proprietaire@demo.com',  password: 'Proprio@12',  role: ROLES.PROPRIETAIRE, telephone: '+22670000003' }
  ];

  for (const u of seedUsers) {
    const created = await UserModel.create(u);
    console.log('  Cree : [' + u.role + '] ' + u.email);
  }

  console.log('Seed termine. ' + seedUsers.length + ' utilisateurs crees.');
}

seed().catch(console.error);
