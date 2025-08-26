/*
  # Système de suivi des pionniers Premium

  1. Nouvelles fonctionnalités
    - Suivi de l'ordre d'achat Premium pour identifier les 100 premiers
    - Trigger automatique pour attribution du trophée Pionnier
    - Index optimisé pour les requêtes de classement

  2. Sécurité
    - RLS maintenu sur toutes les tables
    - Fonction sécurisée pour vérification du statut pionnier
*/

-- Fonction pour obtenir le numéro d'ordre d'achat Premium d'un utilisateur
CREATE OR REPLACE FUNCTION get_premium_order_number(user_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  order_number INTEGER := 0;
  user_order_date TIMESTAMPTZ;
BEGIN
  -- Récupérer la date de commande de l'utilisateur
  SELECT MIN(created_at) INTO user_order_date
  FROM stripe_orders so
  JOIN stripe_customers sc ON sc.customer_id = so.customer_id
  WHERE sc.user_id = user_uuid 
    AND so.status = 'completed';
  
  -- Si l'utilisateur n'a pas de commande, retourner 0
  IF user_order_date IS NULL THEN
    RETURN 0;
  END IF;
  
  -- Compter combien de commandes Premium ont été faites avant ou à cette date
  SELECT COUNT(*) INTO order_number
  FROM stripe_orders so
  JOIN stripe_customers sc ON sc.customer_id = so.customer_id
  WHERE so.status = 'completed'
    AND so.created_at <= user_order_date;
  
  RETURN order_number;
END;
$$;

-- Fonction pour vérifier automatiquement le trophée Pionnier après achat Premium
CREATE OR REPLACE FUNCTION check_pioneer_trophy()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_uuid UUID;
  order_number INTEGER;
BEGIN
  -- Récupérer l'ID utilisateur depuis la commande
  SELECT sc.user_id INTO user_uuid
  FROM stripe_customers sc
  WHERE sc.customer_id = NEW.customer_id;
  
  -- Si pas d'utilisateur trouvé, ignorer
  IF user_uuid IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Obtenir le numéro d'ordre de cet achat
  order_number := get_premium_order_number(user_uuid);
  
  -- Si parmi les 100 premiers et pas déjà le trophée
  IF order_number <= 100 AND order_number > 0 THEN
    INSERT INTO user_trophies (user_id, trophy_id, unlocked_at, points_earned)
    VALUES (user_uuid, 'early_adopter', NOW(), 2000)
    ON CONFLICT (user_id, trophy_id) DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Trigger pour attribution automatique du trophée Pionnier
DROP TRIGGER IF EXISTS auto_pioneer_trophy_trigger ON stripe_orders;
CREATE TRIGGER auto_pioneer_trophy_trigger
  AFTER INSERT OR UPDATE ON stripe_orders
  FOR EACH ROW
  WHEN (NEW.status = 'completed')
  EXECUTE FUNCTION check_pioneer_trophy();

-- Index pour optimiser les requêtes de classement Premium
CREATE INDEX IF NOT EXISTS idx_stripe_orders_completed_date 
ON stripe_orders (created_at) 
WHERE status = 'completed';

-- Fonction publique pour vérifier le statut pionnier (utilisée par le frontend)
CREATE OR REPLACE FUNCTION is_user_pioneer(user_uuid UUID)
RETURNS TABLE (
  is_pioneer BOOLEAN,
  pioneer_number INTEGER,
  total_pioneers INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  order_num INTEGER;
  total_count INTEGER;
BEGIN
  -- Obtenir le numéro d'ordre Premium
  order_num := get_premium_order_number(user_uuid);
  
  -- Compter le total de pionniers (max 100)
  SELECT COUNT(*) INTO total_count
  FROM (
    SELECT DISTINCT sc.user_id
    FROM stripe_orders so
    JOIN stripe_customers sc ON sc.customer_id = so.customer_id
    WHERE so.status = 'completed'
    ORDER BY MIN(so.created_at)
    LIMIT 100
  ) pioneers;
  
  RETURN QUERY SELECT 
    (order_num > 0 AND order_num <= 100)::BOOLEAN as is_pioneer,
    CASE WHEN order_num > 0 AND order_num <= 100 THEN order_num ELSE 0 END as pioneer_number,
    total_count as total_pioneers;
END;
$$;