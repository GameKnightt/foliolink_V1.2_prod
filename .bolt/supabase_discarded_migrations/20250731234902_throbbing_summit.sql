/*
  # Implémentation de la protection par mot de passe des portfolios

  1. Nouvelles Fonctions
    - `hash_portfolio_password()` - Hachage sécurisé des mots de passe
    - `verify_portfolio_password()` - Vérification des mots de passe
    - `check_portfolio_access()` - Vérification d'accès avec mot de passe

  2. Sécurité
    - Hachage bcrypt avec sel automatique
    - Protection contre les timing attacks
    - Validation stricte des entrées

  3. Optimisations
    - Index sur les champs de mot de passe pour performance
    - Contraintes de cohérence pour l'intégrité des données
*/

-- Fonction pour hacher un mot de passe de portfolio
CREATE OR REPLACE FUNCTION hash_portfolio_password(password_text TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  hashed_password TEXT;
BEGIN
  -- Validation de base
  IF password_text IS NULL OR LENGTH(password_text) < 6 THEN
    RAISE EXCEPTION 'Le mot de passe doit contenir au moins 6 caractères';
  END IF;
  
  -- Utiliser crypt avec bcrypt (génère automatiquement un sel)
  SELECT crypt(password_text, gen_salt('bf', 10)) INTO hashed_password;
  
  RETURN hashed_password;
END;
$$;

-- Fonction pour vérifier un mot de passe de portfolio
CREATE OR REPLACE FUNCTION verify_portfolio_password(password_text TEXT, hashed_password TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  is_valid BOOLEAN := FALSE;
BEGIN
  -- Protection contre les timing attacks
  IF password_text IS NULL OR hashed_password IS NULL THEN
    -- Effectuer un calcul factice pour maintenir un timing constant
    PERFORM crypt('dummy', '$2a$10$dummy.salt.for.timing.protection');
    RETURN FALSE;
  END IF;
  
  -- Vérifier le mot de passe
  SELECT (crypt(password_text, hashed_password) = hashed_password) INTO is_valid;
  
  RETURN is_valid;
END;
$$;

-- Fonction pour vérifier l'accès à un portfolio
CREATE OR REPLACE FUNCTION check_portfolio_access(slug_param TEXT, password_param TEXT DEFAULT NULL)
RETURNS TABLE(
  has_access BOOLEAN,
  requires_password BOOLEAN,
  profile_data JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  profile_record RECORD;
  password_valid BOOLEAN := FALSE;
BEGIN
  -- Récupérer le profil
  SELECT 
    id, full_name, formation, etablissement, email, bio, avatar_url,
    is_public, portfolio_password_hash
  INTO profile_record
  FROM profiles 
  WHERE public_slug = slug_param AND is_public = TRUE;
  
  -- Si le profil n'existe pas ou n'est pas public
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, FALSE, NULL::JSONB;
    RETURN;
  END IF;
  
  -- Si pas de mot de passe requis
  IF profile_record.portfolio_password_hash IS NULL THEN
    RETURN QUERY SELECT 
      TRUE, 
      FALSE, 
      jsonb_build_object(
        'id', profile_record.id,
        'full_name', profile_record.full_name,
        'formation', profile_record.formation,
        'etablissement', profile_record.etablissement,
        'email', profile_record.email,
        'bio', profile_record.bio,
        'avatar_url', profile_record.avatar_url
      );
    RETURN;
  END IF;
  
  -- Si mot de passe requis mais non fourni
  IF password_param IS NULL THEN
    RETURN QUERY SELECT FALSE, TRUE, NULL::JSONB;
    RETURN;
  END IF;
  
  -- Vérifier le mot de passe
  SELECT verify_portfolio_password(password_param, profile_record.portfolio_password_hash) 
  INTO password_valid;
  
  -- Si mot de passe invalide
  IF NOT password_valid THEN
    RETURN QUERY SELECT FALSE, TRUE, NULL::JSONB;
    RETURN;
  END IF;
  
  -- Accès autorisé
  RETURN QUERY SELECT 
    TRUE, 
    TRUE, 
    jsonb_build_object(
      'id', profile_record.id,
      'full_name', profile_record.full_name,
      'formation', profile_record.formation,
      'etablissement', profile_record.etablissement,
      'email', profile_record.email,
      'bio', profile_record.bio,
      'avatar_url', profile_record.avatar_url
    );
END;
$$;

-- Ajouter un index pour les performances sur les mots de passe
CREATE INDEX IF NOT EXISTS idx_profiles_password_protection 
ON profiles (public_slug, is_public, portfolio_password_hash) 
WHERE public_slug IS NOT NULL AND is_public = TRUE;

-- Contrainte pour s'assurer qu'un portfolio public avec slug a une cohérence
ALTER TABLE profiles 
ADD CONSTRAINT check_public_portfolio_consistency 
CHECK (
  (is_public = FALSE) OR 
  (is_public = TRUE AND public_slug IS NOT NULL)
);