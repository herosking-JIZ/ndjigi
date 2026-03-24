# Système d'Authentification Node.js

## Démarrage rapide
```bash
npm install
node utils/seed.js   # Créer les comptes de démo
node index.js        # Démarrer le serveur sur :3000
```

## Comptes de démo
| Rôle         | Email                    | Mot de passe  |
|--------------|--------------------------|---------------|
| admin        | admin@system.com         | Admin@1234    |
| passager     | passager@demo.com        | Passager@1    |
| chauffeur    | chauffeur@demo.com       | Chauffeur@1   |
| proprietaire | proprietaire@demo.com    | Proprio@12    |

## Variables d'environnement (.env)
- `JWT_SECRET` — Clé secrète access token (CHANGER en production)
- `JWT_REFRESH_SECRET` — Clé secrète refresh token (CHANGER en production)
- `JWT_EXPIRES_IN` — Durée access token (défaut: 15m)
- `JWT_REFRESH_EXPIRES_IN` — Durée refresh token (défaut: 7d)
- `BCRYPT_ROUNDS` — Coût bcrypt (défaut: 10)
- `MAX_LOGIN_ATTEMPTS` — Tentatives avant blocage (défaut: 5)

Voir architecture.docx pour la documentation complète.
