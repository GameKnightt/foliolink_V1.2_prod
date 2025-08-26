/*
  # Portfolio Sharing System - Database Schema

  1. New Columns for profiles table
    - `public_slug` (text, unique, nullable) - Custom username for public URLs
    - `is_public` (boolean, default false) - Portfolio visibility control
    
  2. New Tables
    - `reserved_slugs` - System reserved usernames to prevent conflicts
    
  3. Security
    - Enable RLS policies for anonymous access to public portfolios
    - Add unique index on public_slug for performance
    - Add policies for public portfolio data access
*/

-- Add new columns to existing profiles table (additive approach)
DO $$
BEGIN
  -- Add public_slug column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'public_slug'
  ) THEN
    ALTER TABLE profiles ADD COLUMN public_slug text;
  END IF;
  
  -- Add is_public column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'is_public'
  ) THEN
    ALTER TABLE profiles ADD COLUMN is_public boolean DEFAULT false;
  END IF;
END $$;

-- Create unique index on public_slug for performance
CREATE UNIQUE INDEX IF NOT EXISTS profiles_public_slug_key 
ON profiles (public_slug) 
WHERE public_slug IS NOT NULL;

-- Create index for public portfolio queries
CREATE INDEX IF NOT EXISTS idx_profiles_public_slug 
ON profiles (public_slug) 
WHERE public_slug IS NOT NULL;

-- Create reserved_slugs table
CREATE TABLE IF NOT EXISTS reserved_slugs (
  slug text PRIMARY KEY,
  reason text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Insert system reserved slugs
INSERT INTO reserved_slugs (slug, reason) VALUES
  ('dashboard', 'System route'),
  ('portfolio', 'System route'),
  ('projets', 'System route'),
  ('pricing', 'System route'),
  ('admin', 'System route'),
  ('api', 'System route'),
  ('auth', 'System route'),
  ('login', 'System route'),
  ('signup', 'System route'),
  ('logout', 'System route'),
  ('profile', 'System route'),
  ('settings', 'System route'),
  ('help', 'System route'),
  ('support', 'System route'),
  ('contact', 'System route'),
  ('about', 'System route'),
  ('terms', 'System route'),
  ('privacy', 'System route'),
  ('www', 'Subdomain'),
  ('mail', 'Subdomain'),
  ('ftp', 'Subdomain'),
  ('root', 'System user'),
  ('admin', 'System user'),
  ('test', 'System user'),
  ('demo', 'System user')
ON CONFLICT (slug) DO NOTHING;

-- Enable RLS on reserved_slugs
ALTER TABLE reserved_slugs ENABLE ROW LEVEL SECURITY;

-- Add RLS policy for public read access to reserved_slugs
CREATE POLICY "Anyone can read reserved slugs"
  ON reserved_slugs
  FOR SELECT
  TO public
  USING (true);

-- Add RLS policy for anonymous users to read public profiles
CREATE POLICY "Anonymous users can read public profiles"
  ON profiles
  FOR SELECT
  TO anon
  USING (public_slug IS NOT NULL AND is_public = true);

-- Add RLS policies for anonymous access to public portfolio data
CREATE POLICY "Anonymous users can read public competences"
  ON competences
  FOR SELECT
  TO anon
  USING (user_id IS NULL);

CREATE POLICY "Anyone can read public competences"
  ON competences
  FOR SELECT
  TO public
  USING (user_id IS NULL);

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