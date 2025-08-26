/*
  # Système de catégories d'apprentissages

  1. Nouvelle Table
    - `apprentissage_categories`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key vers profiles)
      - `competence_id` (text, référence vers compétences)
      - `level` (integer, niveau de la compétence)
      - `title` (text, titre de la catégorie)
      - `description` (text, description optionnelle)
      - `color` (text, couleur pour l'affichage)
      - `icon` (text, icône pour l'affichage)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Modification Table Existante
    - Ajout de `category_id` à la table `apprentissages`

  3. Sécurité
    - Enable RLS sur `apprentissage_categories`
    - Politiques pour CRUD utilisateur
    - Index pour optimiser les requêtes

  4. Fonctions
    - Trigger pour updated_at automatique
*/

-- Créer la table des catégories d'apprentissages
CREATE TABLE IF NOT EXISTS apprentissage_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  competence_id text NOT NULL,
  level integer NOT NULL,
  title text NOT NULL,
  description text DEFAULT '',
  color text DEFAULT 'blue',
  icon text DEFAULT '📁',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Ajouter la colonne category_id à la table apprentissages si elle n'existe pas
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'apprentissages' AND column_name = 'category_id'
  ) THEN
    ALTER TABLE apprentissages ADD COLUMN category_id uuid;
  END IF;
END $$;

-- Activer RLS sur la table des catégories
ALTER TABLE apprentissage_categories ENABLE ROW LEVEL SECURITY;

-- Politiques RLS pour apprentissage_categories
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

-- Politiques pour les portfolios publics
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

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_apprentissage_categories_user_id 
  ON apprentissage_categories (user_id);

CREATE INDEX IF NOT EXISTS idx_apprentissage_categories_competence_level 
  ON apprentissage_categories (competence_id, level);

CREATE INDEX IF NOT EXISTS idx_apprentissage_categories_user_competence_level 
  ON apprentissage_categories (user_id, competence_id, level);

-- Index pour la colonne category_id dans apprentissages
CREATE INDEX IF NOT EXISTS idx_apprentissages_category_id 
  ON apprentissages (category_id);

-- Contrainte de clé étrangère pour category_id
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'apprentissages_category_id_fkey'
  ) THEN
    ALTER TABLE apprentissages 
    ADD CONSTRAINT apprentissages_category_id_fkey 
    FOREIGN KEY (category_id) REFERENCES apprentissage_categories(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Contrainte de clé étrangère pour user_id vers profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'apprentissage_categories_user_id_fkey'
  ) THEN
    ALTER TABLE apprentissage_categories 
    ADD CONSTRAINT apprentissage_categories_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Trigger pour updated_at automatique
CREATE OR REPLACE FUNCTION handle_updated_at_apprentissage_categories()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.triggers
    WHERE trigger_name = 'handle_updated_at_apprentissage_categories'
  ) THEN
    CREATE TRIGGER handle_updated_at_apprentissage_categories
      BEFORE UPDATE ON apprentissage_categories
      FOR EACH ROW
      EXECUTE FUNCTION handle_updated_at_apprentissage_categories();
  END IF;
END $$;