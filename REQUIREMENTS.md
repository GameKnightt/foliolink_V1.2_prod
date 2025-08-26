# Requirements - FolioLink Portfolio Builder

## 📦 Dépendances de Production

### Framework Principal
```json
"vue": "^3.4.38"                    // Framework JavaScript progressif
"vue-router": "^4.2.5"              // Routage SPA pour Vue.js
```

### Utilitaires Vue
```json
"@vueuse/head": "^2.0.0"            // Gestion des meta tags et SEO
```

### Interface Utilisateur
```json
"@headlessui/vue": "^1.7.16"        // Composants UI accessibles
"@heroicons/vue": "^2.0.18"         // Icônes SVG optimisées
```

### Backend et Base de Données
```json
"@supabase/supabase-js": "^2.38.0"  // Client Supabase pour auth/database
```

### Export et Traitement de Données
```json
"xlsx": "^0.18.5"                   // Export Excel pour portfolios Premium
```

## 🛠️ Dépendances de Développement

### Build et Compilation
```json
"@vitejs/plugin-vue": "^5.1.3"      // Plugin Vite pour Vue.js
"vite": "^5.4.2"                    // Build tool moderne et rapide
"vue-tsc": "^2.1.4"                 // Compilateur TypeScript pour Vue
```

### TypeScript
```json
"typescript": "^5.5.3"              // Langage avec typage statique
```

### Styling
```json
"tailwindcss": "^3.3.5"             // Framework CSS utility-first
"autoprefixer": "^10.4.16"          // Préfixes CSS automatiques
"postcss": "^8.4.31"                // Processeur CSS
```

## 🌐 Services Externes

### Supabase (Backend-as-a-Service)
- **PostgreSQL** : Base de données relationnelle
- **Authentication** : Gestion des utilisateurs
- **Storage** : Stockage de fichiers (avatars)
- **Edge Functions** : Fonctions serverless
- **Row Level Security** : Sécurité au niveau des données

### Stripe (Paiements)
- **Checkout Sessions** : Paiements sécurisés
- **Webhooks** : Synchronisation des statuts
- **Customer Portal** : Gestion des abonnements

### Netlify (Déploiement)
- **Static Hosting** : Hébergement de l'application
- **Continuous Deployment** : Déploiement automatique
- **Edge Functions** : Fonctions serverless

## 💻 Prérequis Système

### Environnement de Développement
- **Node.js** >= 18.0.0
- **npm** >= 9.0.0 ou **yarn** >= 1.22.0
- **Git** >= 2.30.0

### Navigateurs Supportés
- **Chrome** >= 90
- **Firefox** >= 88
- **Safari** >= 14
- **Edge** >= 90

### Système d'Exploitation
- **Windows** 10/11
- **macOS** 10.15+
- **Linux** (Ubuntu 20.04+, Debian 11+)

## 🔧 Installation des Dépendances

### Installation Standard
```bash
# Installation de toutes les dépendances
npm install

# Ou avec Yarn
yarn install
```

### Installation Sélective
```bash
# Dépendances de production uniquement
npm install --production

# Dépendances de développement uniquement
npm install --only=dev
```

### Mise à Jour des Dépendances
```bash
# Vérifier les mises à jour disponibles
npm outdated

# Mettre à jour toutes les dépendances
npm update

# Mettre à jour une dépendance spécifique
npm install vue@latest
```

## 🏗️ Configuration Build

### Scripts NPM Disponibles
```bash
npm run dev      # Serveur de développement (port 5173)
npm run build    # Build de production
npm run preview  # Prévisualisation du build
```

### Variables d'Environnement Requises
```env
# Supabase (Obligatoire)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key

# Stripe (Optionnel - pour les paiements Premium)
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
```

## 🔒 Sécurité

### Authentification
- **JWT Tokens** : Sessions sécurisées avec refresh
- **OAuth 2.0** : Google et Discord
- **Password Hashing** : bcrypt avec salt

### Base de Données
- **Row Level Security** : Isolation des données utilisateur
- **Prepared Statements** : Protection contre l'injection SQL
- **Encryption at Rest** : Données chiffrées en base

### Frontend
- **CSP Headers** : Content Security Policy
- **HTTPS Only** : Connexions sécurisées uniquement
- **Input Validation** : Validation côté client et serveur

## 📊 Performance

### Optimisations
- **Code Splitting** : Chargement lazy des composants
- **Tree Shaking** : Élimination du code mort
- **Asset Optimization** : Compression des images et CSS
- **CDN** : Distribution via Netlify Edge

### Métriques Cibles
- **First Contentful Paint** : < 1.5s
- **Largest Contentful Paint** : < 2.5s
- **Cumulative Layout Shift** : < 0.1
- **Time to Interactive** : < 3s

## 🧪 Tests

### Framework de Tests (À Implémenter)
```bash
# Tests unitaires
npm run test:unit

# Tests d'intégration
npm run test:integration

# Tests end-to-end
npm run test:e2e

# Coverage
npm run test:coverage
```

### Types de Tests Prévus
- **Composants Vue** : Testing Library
- **Services** : Jest/Vitest
- **API** : Tests d'intégration Supabase
- **E2E** : Playwright ou Cypress

## 🚀 Déploiement

### Netlify (Recommandé)
```bash
# Build automatique via Git
# Configuration dans netlify.toml
```

### Autres Plateformes
- **Vercel** : Compatible avec configuration minimale
- **GitHub Pages** : Pour les démos statiques
- **Docker** : Containerisation possible

## 📈 Monitoring

### Analytics (À Implémenter)
- **Plausible** : Analytics respectueux de la vie privée
- **Sentry** : Monitoring des erreurs
- **Supabase Analytics** : Métriques base de données

### Logs
- **Console Logs** : Développement local
- **Supabase Logs** : Logs serveur et Edge Functions
- **Stripe Logs** : Événements de paiement

## 🔄 Versions et Compatibilité

### Versioning
- **Semantic Versioning** : MAJOR.MINOR.PATCH
- **Git Tags** : Releases taguées
- **Changelog** : Documentation des changements

### Rétrocompatibilité
- **API Versioning** : Versions d'API maintenues
- **Migration Guides** : Documentation des breaking changes
- **Deprecation Warnings** : Avertissements avant suppression

---

## 📞 Support Technique

Pour toute question technique concernant l'installation ou la configuration :

- **Documentation** : README.md (ce fichier)
- **Issues GitHub** : Problèmes et bugs
- **Email** : support@foliolink.fr
- **Discord** : Communauté développeurs

---

*Dernière mise à jour : Janvier 2025*