/*
  # Fix apprentissages preuves storage

  1. Changes
    - Remove preuves JSONB column from apprentissages table
    - All preuves are now stored in the separate preuves table
    - Update RLS policies for proper access control
    - Ensure data consistency between apprentissages and preuves

  2. Security
    - Maintain existing RLS policies
    - Ensure preuves are properly linked to apprentissages
    - Users can only access their own preuves through apprentissages
*/

-- Remove the preuves JSONB column from apprentissages table since we use the separate preuves table
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'apprentissages' AND column_name = 'preuves'
  ) THEN
    ALTER TABLE apprentissages DROP COLUMN preuves;
  END IF;
END $$;

-- Ensure preuves table has proper structure (should already exist)
-- This is just a safety check
CREATE TABLE IF NOT EXISTS preuves (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  apprentissage_id uuid NOT NULL REFERENCES apprentissages(id) ON DELETE CASCADE,
  titre text NOT NULL,
  type text NOT NULL CHECK (type = ANY (ARRAY['Rapport'::text, 'Code'::text, 'Projet'::text, 'Présentation'::text, 'Documentation'::text, 'Autre'::text])),
  url text NOT NULL,
  projet_id uuid REFERENCES projets(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Ensure RLS is enabled on preuves table
ALTER TABLE preuves ENABLE ROW LEVEL SECURITY;

-- Update RLS policies for preuves table to match the working pattern
DROP POLICY IF EXISTS "Users can read preuves of own apprentissages" ON preuves;
DROP POLICY IF EXISTS "Users can insert preuves for own apprentissages" ON preuves;
DROP POLICY IF EXISTS "Users can update preuves of own apprentissages" ON preuves;
DROP POLICY IF EXISTS "Users can delete preuves of own apprentissages" ON preuves;
DROP POLICY IF EXISTS "Anonymous users can read public preuves" ON preuves;

-- Create comprehensive RLS policies for preuves
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

-- Ensure indexes exist for performance
CREATE INDEX IF NOT EXISTS idx_preuves_apprentissage_id ON preuves(apprentissage_id);
CREATE INDEX IF NOT EXISTS idx_preuves_projet_id ON preuves(projet_id);