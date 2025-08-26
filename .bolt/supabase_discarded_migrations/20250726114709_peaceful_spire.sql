/*
  # Ajout des fonctionnalités avancées du portfolio

  1. Nouvelles colonnes pour les profils
    - `avatar_url` pour la photo de profil
    - Amélioration des champs existants

  2. Nouvelle table pour les apprentissages épinglés
    - `featured_apprentissages` avec ordre de priorité
    - Contrainte max 3 apprentissages par utilisateur

  3. Sécurité
    - RLS activé sur toutes les nouvelles tables
    - Politiques appropriées pour chaque opération
*/

-- Ajouter la colonne avatar_url si elle n'existe pas déjà
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'avatar_url'
  ) THEN
    ALTER TABLE profiles ADD COLUMN avatar_url text;
  END IF;
END $$;

-- Créer la table pour les apprentissages épinglés
CREATE TABLE IF NOT EXISTS featured_apprentissages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  apprentissage_id uuid NOT NULL REFERENCES apprentissages(id) ON DELETE CASCADE,
  priority_order integer NOT NULL DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, apprentissage_id),
  CONSTRAINT max_3_featured CHECK (priority_order BETWEEN 1 AND 3)
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_featured_apprentissages_user_id ON featured_apprentissages(user_id);
CREATE INDEX IF NOT EXISTS idx_featured_apprentissages_priority ON featured_apprentissages(user_id, priority_order);

-- Activer RLS
ALTER TABLE featured_apprentissages ENABLE ROW LEVEL SECURITY;

-- Politiques RLS pour featured_apprentissages
CREATE POLICY "Users can read own featured apprentissages"
  ON featured_apprentissages
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own featured apprentissages"
  ON featured_apprentissages
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own featured apprentissages"
  ON featured_apprentissages
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own featured apprentissages"
  ON featured_apprentissages
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Fonction pour maintenir l'ordre des priorités
CREATE OR REPLACE FUNCTION maintain_featured_priority_order()
RETURNS TRIGGER AS $$
BEGIN
  -- Vérifier qu'on ne dépasse pas 3 apprentissages épinglés
  IF (SELECT COUNT(*) FROM featured_apprentissages WHERE user_id = NEW.user_id) >= 3 
     AND TG_OP = 'INSERT' THEN
    RAISE EXCEPTION 'Maximum 3 apprentissages épinglés autorisés par utilisateur';
  END IF;
  
  -- Réorganiser les priorités si nécessaire
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    -- Décaler les autres apprentissages si la priorité existe déjà
    UPDATE featured_apprentissages 
    SET priority_order = priority_order + 1
    WHERE user_id = NEW.user_id 
      AND priority_order >= NEW.priority_order 
      AND id != NEW.id;
      
    -- Limiter à 3 maximum
    DELETE FROM featured_apprentissages 
    WHERE user_id = NEW.user_id 
      AND priority_order > 3;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour maintenir l'ordre
DROP TRIGGER IF EXISTS maintain_featured_priority_trigger ON featured_apprentissages;
CREATE TRIGGER maintain_featured_priority_trigger
  BEFORE INSERT OR UPDATE ON featured_apprentissages
  FOR EACH ROW EXECUTE FUNCTION maintain_featured_priority_order();