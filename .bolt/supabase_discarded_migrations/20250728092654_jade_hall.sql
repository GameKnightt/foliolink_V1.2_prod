/*
  # Ajout des catégories de projets

  1. Nouvelles Tables
    - `project_categories`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key vers users)
      - `name` (text, nom de la catégorie)
      - `description` (text, description optionnelle)
      - `color` (text, couleur pour l'affichage)
      - `created_at` (timestamp)

  2. Modifications
    - Ajout de `category_id` dans la table `projets`

  3. Sécurité
    - Enable RLS sur `project_categories`
    - Politiques pour que les utilisateurs gèrent leurs propres catégories
*/

-- Créer la table des catégories de projets
CREATE TABLE IF NOT EXISTS project_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  color text NOT NULL DEFAULT 'blue',
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, name)
);

-- Ajouter la colonne category_id à la table projets
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projets' AND column_name = 'category_id'
  ) THEN
    ALTER TABLE projets ADD COLUMN category_id uuid REFERENCES project_categories(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_project_categories_user_id ON project_categories(user_id);
CREATE INDEX IF NOT EXISTS idx_projets_category_id ON projets(category_id);

-- Activer RLS
ALTER TABLE project_categories ENABLE ROW LEVEL SECURITY;

-- Politiques RLS pour project_categories
DROP POLICY IF EXISTS "Users can read own categories" ON project_categories;
CREATE POLICY "Users can read own categories"
  ON project_categories
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own categories" ON project_categories;
CREATE POLICY "Users can insert own categories"
  ON project_categories
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own categories" ON project_categories;
CREATE POLICY "Users can update own categories"
  ON project_categories
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own categories" ON project_categories;
CREATE POLICY "Users can delete own categories"
  ON project_categories
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Insérer quelques catégories par défaut (optionnel)
-- Ces catégories seront créées pour chaque nouvel utilisateur via l'application