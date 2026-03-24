/**
 * ============================================================
 * INDEX.JS — Point d'entrée du serveur Express
 * ============================================================
 * Configure et démarre le serveur HTTP avec :
 *   - Middlewares de sécurité (helmet, cors, rate-limit)
 *   - Parsing JSON
 *   - Logging des requêtes
 *   - Montage des routes
 *   - Gestion globale des erreurs
 * ============================================================
 */

require('dotenv').config();

const express    = require('express');
const helmet     = require('helmet');
const cors       = require('cors');
const rateLimit  = require('express-rate-limit');

const { initDatabase }  = require('./config/database');
const authRoutes         = require('./routes/auth.routes');
const userRoutes         = require('./routes/user.routes');

const app  = express();
const PORT = process.env.PORT || 3000;

// ============================================================
// MIDDLEWARES DE SÉCURITÉ
// ============================================================

// Helmet : ajoute des en-têtes HTTP de sécurité (XSS, clickjacking, etc.)
app.use(helmet());

// CORS : autorise les requêtes cross-origin (à restreindre en production)
app.use(cors({
  origin:      process.env.NODE_ENV === 'production' ? 'https://votre-domaine.com' : '*',
  methods:     ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Rate limiting global : max 100 requêtes par IP sur 15 minutes
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,
  max:      100,
  message:  { success: false, message: 'Trop de requêtes. Réessayez plus tard.' }
}));

// ============================================================
// PARSING DES REQUÊTES
// ============================================================

// Parser JSON (limite à 10kb pour éviter les gros payloads)
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true }));

// ============================================================
// LOGGING SIMPLE DES REQUÊTES
// ============================================================
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    const color = res.statusCode >= 400 ? '\x1b[31m' : '\x1b[32m';
    console.log(`${color}[${new Date().toISOString()}] ${req.method} ${req.originalUrl} => ${res.statusCode} (${duration}ms)\x1b[0m`);
  });
  next();
});

// ============================================================
// ROUTES
// ============================================================

// Route de santé : vérifier que le serveur fonctionne
app.get('/health', (req, res) => {
  res.status(200).json({ success: true, status: 'ok', timestamp: new Date().toISOString() });
});

// Routes d'authentification : /api/auth/...
app.use('/api/auth', authRoutes);

// Routes utilisateurs et admin : /api/users/... et /api/admin/...
app.use('/api', userRoutes);

// Route 404 pour les endpoints inexistants
app.use('/{*splat}', (req, res) => {
  res.status(404).json({ success: false, message: `Route introuvable : ${req.method} ${req.originalUrl}` });
});

// ============================================================
// GESTIONNAIRE D'ERREURS GLOBAL
// ============================================================
// Capture toutes les erreurs non gérées dans les routes
app.use((err, req, res, next) => {
  console.error('[ERROR GLOBAL]', err.stack || err);
  const statusCode = err.statusCode || 500;
  const message    = process.env.NODE_ENV === 'production' ? 'Une erreur interne s\'est produite.' : err.message;
  res.status(statusCode).json({ success: false, message });
});

// ============================================================
// DÉMARRAGE DU SERVEUR
// ============================================================
function startServer() {
  // Initialisation de la base de données au démarrage
  initDatabase();

  app.listen(PORT, () => {
    console.log('\n==================================================');
    console.log('  Systeme d\'authentification demarre');
    console.log('==================================================');
    console.log('  URL     : http://localhost:' + PORT);
    console.log('  Mode    : ' + (process.env.NODE_ENV || 'development'));
    console.log('--------------------------------------------------');
    console.log('  Routes disponibles :');
    console.log('  POST /api/auth/register');
    console.log('  POST /api/auth/login');
    console.log('  POST /api/auth/refresh');
    console.log('  POST /api/auth/logout');
    console.log('  GET  /api/auth/me');
    console.log('  GET  /api/users/profile');
    console.log('  PUT  /api/users/profile');
    console.log('  GET  /api/admin/users  (admin)');
    console.log('  GET  /api/admin/stats  (admin)');
    console.log('==================================================\n');
  });
}

startServer();

module.exports = app;
