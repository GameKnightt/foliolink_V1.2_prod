/*
  # Ajout de la gestion des comptes Premium

  1. Nouvelles colonnes dans profiles
    - `account_type` (enum: 'free', 'premium')
    - `premium_purchased_at` (timestamp)
    - `premium_features_enabled` (boolean)

  2. Sécurité
    - Mise à jour des politiques RLS existantes
    - Ajout de fonctions pour vérifier le statut premium

  3. Fonctions utilitaires
    - Fonction pour vérifier si un utilisateur est premium
    - Trigger pour activer les fonctionnalités premium après achat
*/

-- Créer le type enum pour les types de compte
DO $$ BEGIN
  CREATE TYPE account_type AS ENUM ('free', 'premium');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Ajouter les colonnes pour la gestion Premium
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'account_type'
  ) THEN
    ALTER TABLE profiles ADD COLUMN account_type account_type DEFAULT 'free';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'premium_purchased_at'
  ) THEN
    ALTER TABLE profiles ADD COLUMN premium_purchased_at timestamptz;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'premium_features_enabled'
  ) THEN
    ALTER TABLE profiles ADD COLUMN premium_features_enabled boolean DEFAULT false;
  END IF;
END $$;

-- Fonction pour vérifier si un utilisateur est premium
CREATE OR REPLACE FUNCTION is_premium_user(user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = user_id 
    AND account_type = 'premium' 
    AND premium_features_enabled = true
  );
END;
$$;

-- Fonction pour activer le premium après achat
CREATE OR REPLACE FUNCTION activate_premium_account(user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE profiles 
  SET 
    account_type = 'premium',
    premium_purchased_at = now(),
    premium_features_enabled = true,
    updated_at = now()
  WHERE id = user_id;
END;
$$;

-- Trigger pour activer automatiquement le premium après un paiement réussi
CREATE OR REPLACE FUNCTION handle_premium_purchase()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_id uuid;
BEGIN
  -- Récupérer l'ID utilisateur depuis le customer_id
  SELECT sc.user_id INTO user_id
  FROM stripe_customers sc
  WHERE sc.customer_id = NEW.customer_id;
  
  -- Si c'est un paiement réussi pour le produit premium
  IF NEW.payment_status = 'paid' AND NEW.status = 'completed' THEN
    -- Activer le compte premium
    PERFORM activate_premium_account(user_id);
  END IF;
  
  RETURN NEW;
END;
$$;

-- Créer le trigger sur les commandes Stripe
DROP TRIGGER IF EXISTS trigger_premium_purchase ON stripe_orders;
CREATE TRIGGER trigger_premium_purchase
  AFTER INSERT OR UPDATE ON stripe_orders
  FOR EACH ROW
  EXECUTE FUNCTION handle_premium_purchase();

-- Vue pour les informations de compte utilisateur
CREATE OR REPLACE VIEW user_account_info AS
SELECT 
  p.id,
  p.email,
  p.full_name,
  p.account_type,
  p.premium_purchased_at,
  p.premium_features_enabled,
  CASE 
    WHEN p.account_type = 'premium' AND p.premium_features_enabled = true THEN true
    ELSE false
  END as is_premium
FROM profiles p;

-- Politique RLS pour la vue
ALTER VIEW user_account_info OWNER TO postgres;
GRANT SELECT ON user_account_info TO authenticated;

-- RLS pour que les utilisateurs ne voient que leurs propres infos
CREATE POLICY "Users can view own account info"
  ON user_account_info
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);