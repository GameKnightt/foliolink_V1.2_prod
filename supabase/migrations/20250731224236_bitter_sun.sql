/*
  # Enhanced Portfolio Sharing System

  1. Database Schema Updates
    - Update profiles table with portfolio sharing fields
    - Add validation for public slugs
    - Create indexes for performance
    - Add RLS policies for public portfolio access

  2. Security
    - Enable RLS on all relevant tables
    - Add policies for anonymous access to public portfolios
    - Protect private portfolios from unauthorized access

  3. Performance
    - Add indexes for slug lookups
    - Optimize queries for public portfolio views
*/

-- Update profiles table to support portfolio sharing
DO $$
BEGIN
  -- Add public_slug column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'public_slug'
  ) THEN
    ALTER TABLE profiles ADD COLUMN public_slug text UNIQUE;
  END IF;

  -- Add is_public column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'is_public'
  ) THEN
    ALTER TABLE profiles ADD COLUMN is_public boolean DEFAULT false;
  END IF;
END $$;

-- Create unique constraint on public_slug if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'profiles' AND constraint_name = 'profiles_public_slug_key'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT profiles_public_slug_key UNIQUE (public_slug);
  END IF;
END $$;

-- Create index for public slug lookups if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE tablename = 'profiles' AND indexname = 'idx_profiles_public_slug'
  ) THEN
    CREATE INDEX idx_profiles_public_slug ON profiles (public_slug) WHERE public_slug IS NOT NULL;
  END IF;
END $$;

-- Add some common reserved slugs to prevent conflicts
INSERT INTO reserved_slugs (slug, reason) VALUES
  ('admin', 'System reserved'),
  ('api', 'System reserved'),
  ('www', 'System reserved'),
  ('app', 'System reserved'),
  ('dashboard', 'System reserved'),
  ('portfolio', 'System reserved'),
  ('projets', 'System reserved'),
  ('pricing', 'System reserved'),
  ('support', 'System reserved'),
  ('help', 'System reserved'),
  ('about', 'System reserved'),
  ('contact', 'System reserved'),
  ('login', 'System reserved'),
  ('signup', 'System reserved'),
  ('auth', 'System reserved'),
  ('settings', 'System reserved'),
  ('profile', 'System reserved'),
  ('user', 'System reserved'),
  ('users', 'System reserved'),
  ('public', 'System reserved'),
  ('private', 'System reserved'),
  ('static', 'System reserved'),
  ('assets', 'System reserved'),
  ('images', 'System reserved'),
  ('files', 'System reserved'),
  ('download', 'System reserved'),
  ('upload', 'System reserved'),
  ('blog', 'System reserved'),
  ('news', 'System reserved'),
  ('docs', 'System reserved'),
  ('documentation', 'System reserved'),
  ('terms', 'System reserved'),
  ('privacy', 'System reserved'),
  ('legal', 'System reserved'),
  ('security', 'System reserved'),
  ('status', 'System reserved'),
  ('health', 'System reserved'),
  ('robots', 'System reserved'),
  ('sitemap', 'System reserved'),
  ('favicon', 'System reserved'),
  ('manifest', 'System reserved')
ON CONFLICT (slug) DO NOTHING;

-- Update RLS policies for public portfolio access

-- Policy for anonymous users to read public profiles
DROP POLICY IF EXISTS "Anonymous users can read public profiles" ON profiles;
CREATE POLICY "Anonymous users can read public profiles"
  ON profiles
  FOR SELECT
  TO anon
  USING (public_slug IS NOT NULL AND is_public = true);

-- Policy for anonymous users to read public apprentissages
DROP POLICY IF EXISTS "Anonymous users can read public apprentissages" ON apprentissages;
CREATE POLICY "Anonymous users can read public apprentissages"
  ON apprentissages
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = apprentissages.user_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );

-- Policy for anonymous users to read public projets
DROP POLICY IF EXISTS "Anonymous users can read public projets" ON projets;
CREATE POLICY "Anonymous users can read public projets"
  ON projets
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = projets.user_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );

-- Policy for anonymous users to read public preuves
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

-- Policy for anonymous users to read public fichiers_projets
DROP POLICY IF EXISTS "Anonymous users can read public fichiers_projets" ON fichiers_projets;
CREATE POLICY "Anonymous users can read public fichiers_projets"
  ON fichiers_projets
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM projets
      JOIN profiles ON profiles.id = projets.user_id
      WHERE projets.id = fichiers_projets.projet_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );

-- Policy for anonymous users to read public featured apprentissages
DROP POLICY IF EXISTS "Anonymous users can read public featured apprentissages" ON featured_apprentissages;
CREATE POLICY "Anonymous users can read public featured apprentissages"
  ON featured_apprentissages
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = featured_apprentissages.user_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );