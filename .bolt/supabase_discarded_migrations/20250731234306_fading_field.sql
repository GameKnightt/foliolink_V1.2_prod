/*
  # Sécurité et Optimisations pour le Partage de Portfolio

  1. Sécurité
    - Fonction de validation des slugs
    - Fonction de hachage des mots de passe
    - Triggers de validation automatique
    - Index pour les performances

  2. Optimisations
    - Index sur public_slug pour recherches rapides
    - Index composites pour les requêtes publiques
    - Contraintes de validation strictes

  3. Données de Base
    - Slugs réservés pour protéger les routes système
*/

-- Fonction de validation des slugs (sécurité)
CREATE OR REPLACE FUNCTION validate_public_slug(slug TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  -- Vérifier le format : 3-30 caractères, lettres, chiffres, tirets et underscores uniquement
  IF slug !~ '^[a-zA-Z0-9_-]{3,30}$' THEN
    RETURN FALSE;
  END IF;
  
  -- Vérifier que le slug ne commence/finit pas par un tiret ou underscore
  IF slug ~ '^[-_]' OR slug ~ '[-_]$' THEN
    RETURN FALSE;
  END IF;
  
  -- Vérifier qu'il n'y a pas de caractères consécutifs spéciaux
  IF slug ~ '[-_]{2,}' THEN
    RETURN FALSE;
  END IF;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Fonction de hachage sécurisé pour les mots de passe de portfolio
CREATE OR REPLACE FUNCTION hash_portfolio_password(password TEXT)
RETURNS JSONB AS $$
DECLARE
  salt TEXT;
  hash TEXT;
BEGIN
  -- Générer un sel aléatoire
  salt := encode(gen_random_bytes(32), 'base64');
  
  -- Créer le hash avec le sel (simulation bcrypt - en production utiliser une vraie lib)
  hash := encode(digest(password || salt, 'sha256'), 'base64');
  
  RETURN jsonb_build_object('hash', hash, 'salt', salt);
END;
$$ LANGUAGE plpgsql;

-- Fonction de vérification des mots de passe
CREATE OR REPLACE FUNCTION verify_portfolio_password(password TEXT, stored_hash TEXT, stored_salt TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  computed_hash TEXT;
BEGIN
  -- Recalculer le hash avec le mot de passe fourni et le sel stocké
  computed_hash := encode(digest(password || stored_salt, 'sha256'), 'base64');
  
  -- Comparer avec le hash stocké
  RETURN computed_hash = stored_hash;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour valider automatiquement les slugs avant insertion/mise à jour
CREATE OR REPLACE FUNCTION validate_slug_trigger()
RETURNS TRIGGER AS $$
BEGIN
  -- Si un public_slug est fourni, le valider
  IF NEW.public_slug IS NOT NULL THEN
    IF NOT validate_public_slug(NEW.public_slug) THEN
      RAISE EXCEPTION 'Invalid public slug format. Must be 3-30 characters, letters, numbers, hyphens and underscores only.';
    END IF;
    
    -- Vérifier que le slug n'est pas réservé
    IF EXISTS (SELECT 1 FROM reserved_slugs WHERE slug = NEW.public_slug) THEN
      RAISE EXCEPTION 'This username is reserved and cannot be used.';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer le trigger sur la table profiles
DROP TRIGGER IF EXISTS validate_public_slug_trigger ON profiles;
CREATE TRIGGER validate_public_slug_trigger
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION validate_slug_trigger();

-- Index pour optimiser les recherches de slugs publics
CREATE INDEX IF NOT EXISTS idx_profiles_public_slug_performance 
ON profiles (public_slug) 
WHERE public_slug IS NOT NULL AND is_public = true;

-- Index composite pour les requêtes de portfolios publics
CREATE INDEX IF NOT EXISTS idx_profiles_public_portfolio 
ON profiles (is_public, public_slug) 
WHERE is_public = true AND public_slug IS NOT NULL;

-- Index pour optimiser les recherches d'apprentissages publics
CREATE INDEX IF NOT EXISTS idx_apprentissages_public_access 
ON apprentissages (user_id) 
WHERE user_id IN (
  SELECT id FROM profiles WHERE is_public = true AND public_slug IS NOT NULL
);

-- Index pour optimiser les recherches de projets publics
CREATE INDEX IF NOT EXISTS idx_projets_public_access 
ON projets (user_id) 
WHERE user_id IN (
  SELECT id FROM profiles WHERE is_public = true AND public_slug IS NOT NULL
);

-- Contrainte pour s'assurer qu'un portfolio public a un slug
ALTER TABLE profiles 
ADD CONSTRAINT check_public_portfolio_has_slug 
CHECK (
  (is_public = false) OR 
  (is_public = true AND public_slug IS NOT NULL)
);

-- Insérer les slugs réservés pour protéger les routes système
INSERT INTO reserved_slugs (slug, reason) VALUES
  ('admin', 'Route système'),
  ('api', 'Route API'),
  ('auth', 'Route authentification'),
  ('dashboard', 'Route application'),
  ('portfolio', 'Route application'),
  ('projets', 'Route application'),
  ('pricing', 'Route application'),
  ('login', 'Route authentification'),
  ('logout', 'Route authentification'),
  ('signup', 'Route authentification'),
  ('register', 'Route authentification'),
  ('reset-password', 'Route authentification'),
  ('callback', 'Route authentification'),
  ('success', 'Route application'),
  ('terms-of-service', 'Route légale'),
  ('privacy-policy', 'Route légale'),
  ('support', 'Route support'),
  ('help', 'Route support'),
  ('contact', 'Route contact'),
  ('about', 'Route à propos'),
  ('www', 'Sous-domaine réservé'),
  ('mail', 'Sous-domaine réservé'),
  ('ftp', 'Sous-domaine réservé'),
  ('blog', 'Sous-domaine réservé'),
  ('shop', 'Sous-domaine réservé'),
  ('store', 'Sous-domaine réservé'),
  ('app', 'Sous-domaine réservé'),
  ('mobile', 'Sous-domaine réservé'),
  ('test', 'Environnement de test'),
  ('dev', 'Environnement de développement'),
  ('staging', 'Environnement de staging'),
  ('prod', 'Environnement de production'),
  ('foliolink', 'Marque'),
  ('root', 'Utilisateur système'),
  ('admin', 'Utilisateur système'),
  ('administrator', 'Utilisateur système'),
  ('moderator', 'Utilisateur système'),
  ('support', 'Utilisateur système'),
  ('null', 'Valeur réservée'),
  ('undefined', 'Valeur réservée'),
  ('true', 'Valeur réservée'),
  ('false', 'Valeur réservée')
ON CONFLICT (slug) DO NOTHING;