/**
 * CONTROLLERS/AUTHCONTROLLER.JS — Logique d'authentification
 *
 * register  : Inscription d'un nouvel utilisateur
 * login     : Connexion avec email/mot de passe
 * refresh   : Renouvellement du token via refresh token
 * logout    : Déconnexion (révocation du refresh token)
 * logoutAll : Déconnexion de toutes les sessions
 * me        : Profil de l'utilisateur connecté
 */
const bcrypt            = require('bcryptjs');
const UserModel         = require('../models/User');
const RefreshTokenModel = require('../models/RefreshToken');
const { generateAccessToken, generateRefreshToken, verifyRefreshToken } = require('../utils/jwt');
const { getPermissions } = require('../config/roles');

const AuthController = {

  /**
   * POST /api/auth/register
   * Crée un nouveau compte utilisateur.
   */
  async register(req, res) {
    try {
      const { nom, prenom, email, password, role, telephone } = req.body;

      // Vérification de l'unicité de l'email
      if (UserModel.emailExists(email)) {
        return res.status(409).json({
          success: false,
          message: 'Un compte avec cet email existe déjà.'
        });
      }

      // Création de l'utilisateur (mot de passe haché dans le modèle)
      const user = await UserModel.create({ nom, prenom, email, password, role, telephone });

      // Génération des tokens immédiatement après inscription
      const accessToken  = generateAccessToken(user);
      const refreshToken = generateRefreshToken(user);

      // Sauvegarde du refresh token en base
      RefreshTokenModel.save(user.id, refreshToken);

      return res.status(201).json({
        success: true,
        message: 'Compte créé avec succès.',
        data: {
          user,
          tokens: { accessToken, refreshToken }
        }
      });

    } catch (error) {
      console.error('[register]', error);
      return res.status(500).json({ success: false, message: 'Erreur serveur lors de l\'inscription.' });
    }
  },

  /**
   * POST /api/auth/login
   * Authentifie un utilisateur avec email + mot de passe.
   */
  async login(req, res) {
    try {
      const { email, password } = req.body;

      // Récupération avec le mot de passe (nécessaire pour bcrypt.compare)
      const user = UserModel.findByEmailWithPassword(email);

      // Message générique pour ne pas révéler si l'email existe
      if (!user) {
        return res.status(401).json({ success: false, message: 'Email ou mot de passe incorrect.' });
      }

      // Vérification du blocage du compte
      if (UserModel.isLocked(user)) {
        const remaining = Math.ceil((user.lockedUntil - Date.now()) / 60000);
        return res.status(423).json({
          success: false,
          message: `Compte temporairement bloqué. Réessayez dans ${remaining} minute(s).`
        });
      }

      // Vérification du compte actif
      if (!user.isActive) {
        return res.status(403).json({ success: false, message: 'Compte désactivé. Contactez l\'administrateur.' });
      }

      // Comparaison du mot de passe avec le hash bcrypt
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        UserModel.incrementLoginAttempts(user.id);
        return res.status(401).json({ success: false, message: 'Email ou mot de passe incorrect.' });
      }

      // Connexion réussie : réinitialisation du compteur et mise à jour lastLogin
      UserModel.resetLoginAttempts(user.id);

      const cleanUser    = UserModel.findById(user.id);
      const accessToken  = generateAccessToken(cleanUser);
      const refreshToken = generateRefreshToken(cleanUser);

      RefreshTokenModel.save(cleanUser.id, refreshToken);

      return res.status(200).json({
        success: true,
        message: 'Connexion réussie.',
        data: {
          user:        cleanUser,
          permissions: getPermissions(cleanUser.role),
          tokens:      { accessToken, refreshToken }
        }
      });

    } catch (error) {
      console.error('[login]', error);
      return res.status(500).json({ success: false, message: 'Erreur serveur lors de la connexion.' });
    }
  },

  /**
   * POST /api/auth/refresh
   * Génère un nouvel access token à partir du refresh token.
   */
  async refresh(req, res) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({ success: false, message: 'Refresh token manquant.' });
      }

      // Vérification en base (révocation possible)
      const tokenRecord = RefreshTokenModel.findByToken(refreshToken);
      if (!tokenRecord) {
        return res.status(401).json({ success: false, message: 'Refresh token invalide ou révoqué.' });
      }

      // Vérification de l'expiration en base
      if (!RefreshTokenModel.isValid(tokenRecord)) {
        RefreshTokenModel.deleteByToken(refreshToken);
        return res.status(401).json({ success: false, message: 'Refresh token expiré. Reconnectez-vous.' });
      }

      // Vérification de la signature JWT
      const decoded = verifyRefreshToken(refreshToken);

      if (decoded.type !== 'refresh') {
        return res.status(401).json({ success: false, message: 'Type de token invalide.' });
      }

      // Récupération de l'utilisateur
      const user = UserModel.findById(decoded.sub);
      if (!user || !user.isActive) {
        return res.status(401).json({ success: false, message: 'Utilisateur introuvable ou inactif.' });
      }

      // Rotation des tokens : l'ancien refresh token est révoqué
      RefreshTokenModel.deleteByToken(refreshToken);
      const newAccessToken  = generateAccessToken(user);
      const newRefreshToken = generateRefreshToken(user);
      RefreshTokenModel.save(user.id, newRefreshToken);

      return res.status(200).json({
        success: true,
        message: 'Tokens renouvelés avec succès.',
        data: { tokens: { accessToken: newAccessToken, refreshToken: newRefreshToken } }
      });

    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({ success: false, message: 'Refresh token expiré. Reconnectez-vous.', code: 'REFRESH_EXPIRED' });
      }
      console.error('[refresh]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors du renouvellement du token.' });
    }
  },

  /**
   * POST /api/auth/logout
   * Révoque le refresh token courant (déconnexion simple).
   */
  logout(req, res) {
    try {
      const { refreshToken } = req.body;
      if (refreshToken) {
        RefreshTokenModel.deleteByToken(refreshToken);
      }
      return res.status(200).json({ success: true, message: 'Déconnexion réussie.' });
    } catch (error) {
      console.error('[logout]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors de la déconnexion.' });
    }
  },

  /**
   * POST /api/auth/logout-all
   * Révoque TOUS les refresh tokens de l'utilisateur (déconnexion totale).
   * Requiert d'être authentifié.
   */
  logoutAll(req, res) {
    try {
      RefreshTokenModel.deleteAllByUserId(req.user.id);
      return res.status(200).json({ success: true, message: 'Déconnecté de toutes les sessions.' });
    } catch (error) {
      console.error('[logoutAll]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors de la déconnexion globale.' });
    }
  },

  /**
   * GET /api/auth/me
   * Retourne le profil de l'utilisateur actuellement connecté.
   */
  me(req, res) {
    return res.status(200).json({
      success: true,
      data: {
        user:        req.user,
        permissions: getPermissions(req.user.role)
      }
    });
  }
};

module.exports = AuthController;
