/*
  # Create apprentissage categories system

  1. New Tables
    - `apprentissage_categories`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `competence_id` (text)
      - `level` (integer)
      - `title` (text)
      - `description` (text, default '')
      - `color` (text, default 'blue')
      - `icon` (text, default '📁')
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Table Updates
    - Add `category_id` column to `apprentissages` table

  3. Security
    - Enable RLS on `apprentissage_categories` table
    - Add policies for authenticated users to manage their own categories

  4. Performance
    - Add indexes for user_id, competence_id/level, and category_id
    - Add trigger for automatic updated_at handling
*/

-- Create apprentissage_categories table
CREATE TABLE IF NOT EXISTS apprentissage_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL, -- Relation avec auth.users
  competence_id text NOT NULL,
  level integer NOT NULL,
  title text NOT NULL,
  description text DEFAULT '',
  color text DEFAULT 'blue',
  icon text DEFAULT '📁',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add category_id column to apprentissages table if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'apprentissages' AND column_name = 'category_id'
  ) THEN
    ALTER TABLE apprentissages ADD COLUMN category_id uuid REFERENCES apprentissage_categories(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_apprentissage_categories_user_id ON apprentissage_categories(user_id);
CREATE INDEX IF NOT EXISTS idx_apprentissage_categories_competence_level ON apprentissage_categories(competence_id, level);
CREATE INDEX IF NOT EXISTS idx_apprentissages_category_id ON apprentissages(category_id);

-- Enable RLS
ALTER TABLE apprentissage_categories ENABLE ROW LEVEL SECURITY;

-- RLS Policies for apprentissage_categories
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

-- Create trigger for updated_at
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