/*
  # Créer la table featured_apprentissages et le bucket avatars

  1. Nouvelle Table
    - `featured_apprentissages`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key vers profiles)
      - `apprentissage_id` (uuid, foreign key vers apprentissages)
      - `priority_order` (integer)
      - `created_at` (timestamp)

  2. Sécurité
    - Enable RLS sur `featured_apprentissages`
    - Politiques pour que les utilisateurs gèrent leurs propres apprentissages vedettes

  3. Bucket Storage
    - Créer le bucket `avatars` pour les photos de profil
    - Politiques RLS pour upload/lecture des avatars
*/

-- Créer la table featured_apprentissages
CREATE TABLE IF NOT EXISTS featured_apprentissages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  apprentissage_id uuid NOT NULL REFERENCES apprentissages(id) ON DELETE CASCADE,
  priority_order integer NOT NULL DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, apprentissage_id)
);

-- Contrainte pour limiter à 3 apprentissages vedettes par utilisateur
ALTER TABLE featured_apprentissages 
ADD CONSTRAINT max_featured_apprentissages 
CHECK (priority_order BETWEEN 1 AND 3);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_featured_apprentissages_user_id ON featured_apprentissages(user_id);
CREATE INDEX IF NOT EXISTS idx_featured_apprentissages_priority ON featured_apprentissages(user_id, priority_order);

-- Enable RLS
ALTER TABLE featured_apprentissages ENABLE ROW LEVEL SECURITY;

-- Politiques RLS pour featured_apprentissages
CREATE POLICY "Users can read own featured apprentissages"
  ON featured_apprentissages
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own featured apprentissages"
  ON featured_apprentissages
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own featured apprentissages"
  ON featured_apprentissages
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own featured apprentissages"
  ON featured_apprentissages
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Créer le bucket avatars s'il n'existe pas
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Politiques pour le bucket avatars
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own avatar"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own avatar"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Fonction pour maintenir l'ordre des priorités
CREATE OR REPLACE FUNCTION maintain_featured_priority_order()
RETURNS TRIGGER AS $$
BEGIN
  -- Lors d'un INSERT, réorganiser les priorités si nécessaire
  IF TG_OP = 'INSERT' THEN
    -- Si on dépasse 3 apprentissages, supprimer le plus ancien
    IF (SELECT COUNT(*) FROM featured_apprentissages WHERE user_id = NEW.user_id) > 3 THEN
      DELETE FROM featured_apprentissages 
      WHERE user_id = NEW.user_id 
      AND priority_order = (
        SELECT MAX(priority_order) 
        FROM featured_apprentissages 
        WHERE user_id = NEW.user_id
      );
    END IF;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger pour maintenir l'ordre
CREATE TRIGGER maintain_featured_priority_trigger
  AFTER INSERT OR UPDATE ON featured_apprentissages
  FOR EACH ROW EXECUTE FUNCTION maintain_featured_priority_order();