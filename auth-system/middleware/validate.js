/**
 * MIDDLEWARE/VALIDATE.JS — Validation des données entrantes
 *
 * Utilise express-validator pour valider et sanitiser
 * les données des requêtes avant traitement.
 */
const { body, validationResult } = require('express-validator');
const { ROLES } = require('../config/roles');

/**
 * Gère les erreurs de validation et retourne une réponse structurée.
 * À utiliser après les chaînes de validation.
 */
function handleValidationErrors(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({
      success: false,
      message: 'Données invalides',
      errors: errors.array().map(e => ({ field: e.path, message: e.msg }))
    });
  }
  next();
}

/** Règles de validation pour l'inscription */
const validateRegister = [
  body('nom')
    .trim().notEmpty().withMessage('Le nom est obligatoire')
    .isLength({ min: 2, max: 50 }).withMessage('Le nom doit contenir entre 2 et 50 caractères'),

  body('prenom')
    .trim().notEmpty().withMessage('Le prénom est obligatoire')
    .isLength({ min: 2, max: 50 }).withMessage('Le prénom doit contenir entre 2 et 50 caractères'),

  body('email')
    .trim().notEmpty().withMessage('L\'email est obligatoire')
    .isEmail().withMessage('Format d\'email invalide')
    .normalizeEmail(),

  body('password')
    .notEmpty().withMessage('Le mot de passe est obligatoire')
    .isLength({ min: 8 }).withMessage('Le mot de passe doit contenir au moins 8 caractères')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre'),

  body('role')
    .notEmpty().withMessage('Le rôle est obligatoire')
    .isIn(Object.values(ROLES)).withMessage(`Le rôle doit être l'un de : ${Object.values(ROLES).join(', ')}`),

  body('telephone')
    .optional()
    .isMobilePhone().withMessage('Numéro de téléphone invalide'),

  handleValidationErrors
];

/** Règles de validation pour la connexion */
const validateLogin = [
  body('email')
    .trim().notEmpty().withMessage('L\'email est obligatoire')
    .isEmail().withMessage('Format d\'email invalide')
    .normalizeEmail(),

  body('password')
    .notEmpty().withMessage('Le mot de passe est obligatoire'),

  handleValidationErrors
];

/** Règles de validation pour la mise à jour de profil */
const validateUpdateProfile = [
  body('nom')
    .optional().trim()
    .isLength({ min: 2, max: 50 }).withMessage('Le nom doit contenir entre 2 et 50 caractères'),

  body('prenom')
    .optional().trim()
    .isLength({ min: 2, max: 50 }).withMessage('Le prénom doit contenir entre 2 et 50 caractères'),

  body('telephone')
    .optional()
    .isMobilePhone().withMessage('Numéro de téléphone invalide'),

  body('password')
    .optional()
    .isLength({ min: 8 }).withMessage('Le mot de passe doit contenir au moins 8 caractères')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Le mot de passe doit contenir une majuscule, une minuscule et un chiffre'),

  handleValidationErrors
];

module.exports = { validateRegister, validateLogin, validateUpdateProfile, handleValidationErrors };
