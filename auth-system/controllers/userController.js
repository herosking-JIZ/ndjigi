/**
 * CONTROLLERS/USERCONTROLLER.JS — Gestion des utilisateurs
 *
 * getProfile    : Lire son propre profil
 * updateProfile : Modifier son propre profil
 * getAllUsers   : (Admin) Lister tous les utilisateurs
 * getUserById   : (Admin) Lire un utilisateur par ID
 * updateUser    : (Admin) Modifier n'importe quel utilisateur
 * deleteUser    : (Admin) Supprimer un utilisateur
 * toggleActive  : (Admin) Activer / désactiver un compte
 * changeRole    : (Admin) Changer le rôle d'un utilisateur
 */
const UserModel         = require('../models/User');
const RefreshTokenModel = require('../models/RefreshToken');
const { ROLES }         = require('../config/roles');

const UserController = {

  /**
   * GET /api/users/profile
   * L'utilisateur consulte son propre profil.
   */
  getProfile(req, res) {
    return res.status(200).json({ success: true, data: { user: req.user } });
  },

  /**
   * PUT /api/users/profile
   * L'utilisateur met à jour ses propres informations (pas le rôle !).
   */
  async updateProfile(req, res) {
    try {
      // Champs autorisés pour une auto-modification (le rôle est exclu)
      const { nom, prenom, telephone, password } = req.body;
      const allowedUpdates = {};
      if (nom)       allowedUpdates.nom       = nom;
      if (prenom)    allowedUpdates.prenom    = prenom;
      if (telephone) allowedUpdates.telephone = telephone;
      if (password)  allowedUpdates.password  = password; // Sera rehâché dans le modèle

      const updatedUser = await UserModel.update(req.user.id, allowedUpdates);
      return res.status(200).json({ success: true, message: 'Profil mis à jour.', data: { user: updatedUser } });

    } catch (error) {
      console.error('[updateProfile]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors de la mise à jour du profil.' });
    }
  },

  // ============================================================
  // ROUTES ADMINISTRATEUR
  // ============================================================

  /**
   * GET /api/admin/users
   * Liste tous les utilisateurs. Filtrage optionnel par rôle.
   */
  getAllUsers(req, res) {
    try {
      const { role } = req.query;
      let users;

      if (role) {
        if (!Object.values(ROLES).includes(role)) {
          return res.status(400).json({ success: false, message: `Rôle invalide : ${role}` });
        }
        users = UserModel.findByRole(role);
      } else {
        users = UserModel.findAll();
      }

      return res.status(200).json({
        success: true,
        data: { total: users.length, users }
      });
    } catch (error) {
      console.error('[getAllUsers]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors de la récupération des utilisateurs.' });
    }
  },

  /**
   * GET /api/admin/users/:id
   * Récupère un utilisateur par son ID.
   */
  getUserById(req, res) {
    try {
      const user = UserModel.findById(req.params.id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'Utilisateur introuvable.' });
      }
      return res.status(200).json({ success: true, data: { user } });
    } catch (error) {
      console.error('[getUserById]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors de la récupération.' });
    }
  },

  /**
   * PUT /api/admin/users/:id
   * L'admin peut modifier tous les champs d'un utilisateur.
   */
  async updateUser(req, res) {
    try {
      const user = UserModel.findById(req.params.id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'Utilisateur introuvable.' });
      }

      // L'admin ne peut pas modifier son propre rôle via cette route
      if (req.params.id === req.user.id && req.body.role && req.body.role !== req.user.role) {
        return res.status(403).json({ success: false, message: 'Vous ne pouvez pas changer votre propre rôle.' });
      }

      const { nom, prenom, telephone, password, role, isActive } = req.body;
      const updates = {};
      if (nom      !== undefined) updates.nom      = nom;
      if (prenom   !== undefined) updates.prenom   = prenom;
      if (telephone!== undefined) updates.telephone= telephone;
      if (password !== undefined) updates.password = password;
      if (role     !== undefined) updates.role     = role;
      if (isActive !== undefined) updates.isActive = isActive;

      const updatedUser = await UserModel.update(req.params.id, updates);
      return res.status(200).json({ success: true, message: 'Utilisateur mis à jour.', data: { user: updatedUser } });

    } catch (error) {
      console.error('[updateUser]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors de la mise à jour.' });
    }
  },

  /**
   * DELETE /api/admin/users/:id
   * Supprime définitivement un utilisateur.
   */
  deleteUser(req, res) {
    try {
      // L'admin ne peut pas se supprimer lui-même
      if (req.params.id === req.user.id) {
        return res.status(403).json({ success: false, message: 'Vous ne pouvez pas supprimer votre propre compte.' });
      }

      const user = UserModel.findById(req.params.id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'Utilisateur introuvable.' });
      }

      // Révocation de tous les tokens avant suppression
      RefreshTokenModel.deleteAllByUserId(req.params.id);
      UserModel.delete(req.params.id);

      return res.status(200).json({ success: true, message: 'Utilisateur supprimé avec succès.' });
    } catch (error) {
      console.error('[deleteUser]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors de la suppression.' });
    }
  },

  /**
   * PATCH /api/admin/users/:id/toggle-active
   * Active ou désactive un compte utilisateur.
   */
  async toggleActive(req, res) {
    try {
      if (req.params.id === req.user.id) {
        return res.status(403).json({ success: false, message: 'Vous ne pouvez pas désactiver votre propre compte.' });
      }

      const user = UserModel.findById(req.params.id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'Utilisateur introuvable.' });
      }

      const newStatus   = !user.isActive;
      const updatedUser = await UserModel.update(req.params.id, { isActive: newStatus });

      // Si désactivé, révoquer tous les tokens actifs
      if (!newStatus) {
        RefreshTokenModel.deleteAllByUserId(req.params.id);
      }

      return res.status(200).json({
        success: true,
        message: `Compte ${newStatus ? 'activé' : 'désactivé'} avec succès.`,
        data: { user: updatedUser }
      });
    } catch (error) {
      console.error('[toggleActive]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors du changement de statut.' });
    }
  },

  /**
   * PATCH /api/admin/users/:id/role
   * Change le rôle d'un utilisateur.
   */
  async changeRole(req, res) {
    try {
      const { role } = req.body;

      if (!role || !Object.values(ROLES).includes(role)) {
        return res.status(400).json({ success: false, message: `Rôle invalide. Valeurs : ${Object.values(ROLES).join(', ')}` });
      }

      if (req.params.id === req.user.id) {
        return res.status(403).json({ success: false, message: 'Vous ne pouvez pas changer votre propre rôle.' });
      }

      const user = UserModel.findById(req.params.id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'Utilisateur introuvable.' });
      }

      const updatedUser = await UserModel.update(req.params.id, { role });

      // Forcer une reconnexion pour que le nouveau rôle prenne effet
      RefreshTokenModel.deleteAllByUserId(req.params.id);

      return res.status(200).json({
        success: true,
        message: `Rôle changé en "${role}". L'utilisateur devra se reconnecter.`,
        data: { user: updatedUser }
      });
    } catch (error) {
      console.error('[changeRole]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors du changement de rôle.' });
    }
  },

  /**
   * GET /api/admin/stats
   * Statistiques globales du système (admin uniquement).
   */
  getStats(req, res) {
    try {
      const allUsers = UserModel.findAll();
      const stats = {
        total:        allUsers.length,
        actifs:       allUsers.filter(u => u.isActive).length,
        inactifs:     allUsers.filter(u => !u.isActive).length,
        parRole: {
          passager:     allUsers.filter(u => u.role === ROLES.PASSAGER).length,
          chauffeur:    allUsers.filter(u => u.role === ROLES.CHAUFFEUR).length,
          proprietaire: allUsers.filter(u => u.role === ROLES.PROPRIETAIRE).length,
          admin:        allUsers.filter(u => u.role === ROLES.ADMIN).length
        }
      };
      return res.status(200).json({ success: true, data: stats });
    } catch (error) {
      console.error('[getStats]', error);
      return res.status(500).json({ success: false, message: 'Erreur lors de la récupération des statistiques.' });
    }
  }
};

module.exports = UserController;
