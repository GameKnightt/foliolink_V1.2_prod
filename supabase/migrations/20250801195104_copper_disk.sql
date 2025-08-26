/*
  # Fix preuves structure for apprentissages

  1. Changes
    - Remove preuves JSONB column from apprentissages table
    - Ensure preuves table exists with proper structure
    - Update RLS policies for preuves table
    - Add indexes for performance

  2. Security
    - Enable RLS on preuves table
    - Add policies for authenticated users to manage their own preuves
    - Add policies for anonymous users to read public preuves
*/

-- Remove the preuves JSONB column from apprentissages if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'apprentissages' AND column_name = 'preuves'
  ) THEN
    ALTER TABLE apprentissages DROP COLUMN preuves;
  END IF;
END $$;

-- Ensure preuves table exists with correct structure
CREATE TABLE IF NOT EXISTS preuves (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apprentissage_id uuid NOT NULL REFERENCES apprentissages(id) ON DELETE CASCADE,
  titre text NOT NULL,
  type text NOT NULL CHECK (type = ANY (ARRAY['Rapport'::text, 'Code'::text, 'Projet'::text, 'Présentation'::text, 'Documentation'::text, 'Autre'::text])),
  url text NOT NULL,
  projet_id uuid REFERENCES projets(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE preuves ENABLE ROW LEVEL SECURITY;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_preuves_apprentissage_id ON preuves(apprentissage_id);
CREATE INDEX IF NOT EXISTS idx_preuves_projet_id ON preuves(projet_id);

-- RLS Policies for preuves
DROP POLICY IF EXISTS "Users can read preuves of own apprentissages" ON preuves;
CREATE POLICY "Users can read preuves of own apprentissages"
  ON preuves
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM apprentissages
      WHERE apprentissages.id = preuves.apprentissage_id
      AND apprentissages.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert preuves for own apprentissages" ON preuves;
CREATE POLICY "Users can insert preuves for own apprentissages"
  ON preuves
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM apprentissages
      WHERE apprentissages.id = preuves.apprentissage_id
      AND apprentissages.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update preuves of own apprentissages" ON preuves;
CREATE POLICY "Users can update preuves of own apprentissages"
  ON preuves
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM apprentissages
      WHERE apprentissages.id = preuves.apprentissage_id
      AND apprentissages.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM apprentissages
      WHERE apprentissages.id = preuves.apprentissage_id
      AND apprentissages.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete preuves of own apprentissages" ON preuves;
CREATE POLICY "Users can delete preuves of own apprentissages"
  ON preuves
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM apprentissages
      WHERE apprentissages.id = preuves.apprentissage_id
      AND apprentissages.user_id = auth.uid()
    )
  );

-- Anonymous users can read public preuves
DROP POLICY IF EXISTS "Anonymous users can read public preuves" ON preuves;
CREATE POLICY "Anonymous users can read public preuves"
  ON preuves
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM apprentissages
      JOIN profiles ON profiles.id = apprentissages.user_id
      WHERE apprentissages.id = preuves.apprentissage_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );