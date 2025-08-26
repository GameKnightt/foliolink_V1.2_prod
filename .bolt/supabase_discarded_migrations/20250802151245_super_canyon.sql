/*
  # Ajout des catégories d'apprentissages critiques

  1. Nouvelle Table
    - `apprentissage_categories`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key vers users)
      - `competence_id` (text, foreign key vers competences)
      - `level` (integer, niveau de la compétence)
      - `title` (text, titre de la catégorie)
      - `description` (text, description optionnelle)
      - `order_index` (integer, ordre d'affichage)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Modification Table Apprentissages
    - Ajout de `category_id` (uuid, foreign key vers apprentissage_categories)

  3. Sécurité
    - Enable RLS sur `apprentissage_categories`
    - Politiques pour CRUD par utilisateur
    - Politiques de lecture publique pour portfolios partagés

  4. Index
    - Index sur user_id, competence_id, level pour performance
    - Index sur category_id dans apprentissages
*/

-- Créer la table des catégories d'apprentissages
CREATE TABLE IF NOT EXISTS apprentissage_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  competence_id text NOT NULL,
  level integer NOT NULL,
  title text NOT NULL,
  description text DEFAULT '',
  order_index integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Ajouter la colonne category_id à la table apprentissages
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'apprentissages' AND column_name = 'category_id'
  ) THEN
    ALTER TABLE apprentissages ADD COLUMN category_id uuid REFERENCES apprentissage_categories(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Enable RLS sur apprentissage_categories
ALTER TABLE apprentissage_categories ENABLE ROW LEVEL SECURITY;

-- Politiques pour apprentissage_categories
CREATE POLICY "Users can read own categories"
  ON apprentissage_categories
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own categories"
  ON apprentissage_categories
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own categories"
  ON apprentissage_categories
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own categories"
  ON apprentissage_categories
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Politique de lecture publique pour les portfolios partagés
CREATE POLICY "Anonymous users can read public categories"
  ON apprentissage_categories
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = apprentissage_categories.user_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );

-- Index pour les performances
CREATE INDEX IF NOT EXISTS idx_apprentissage_categories_user_competence_level
  ON apprentissage_categories (user_id, competence_id, level);

CREATE INDEX IF NOT EXISTS idx_apprentissage_categories_order
  ON apprentissage_categories (user_id, competence_id, level, order_index);

CREATE INDEX IF NOT EXISTS idx_apprentissages_category_id
  ON apprentissages (category_id);

-- Trigger pour updated_at
CREATE OR REPLACE FUNCTION handle_updated_at_apprentissage_categories()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_updated_at_apprentissage_categories
  BEFORE UPDATE ON apprentissage_categories
  FOR EACH ROW
  EXECUTE FUNCTION handle_updated_at_apprentissage_categories();

-- Contrainte pour éviter les doublons de titre par utilisateur/compétence/niveau
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_category_title_per_level
  ON apprentissage_categories (user_id, competence_id, level, title);