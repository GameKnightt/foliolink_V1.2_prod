/*
  # Add Public Portfolio Sharing

  1. Database Changes
    - Add `public_slug` column to `profiles` table for custom usernames
    - Add `is_public` column to control portfolio visibility
    - Create unique index on `public_slug` for fast lookups
    - Add reserved slugs table to prevent conflicts with app routes

  2. Security
    - Enable RLS policies for anonymous users to read public portfolios
    - Add policies for all related tables (apprentissages, projets, etc.)
    - Ensure only public portfolios are accessible

  3. Performance
    - Index on `public_slug` for fast username lookups
    - Optimized queries for public portfolio data
*/

-- Add public sharing columns to profiles table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'public_slug'
  ) THEN
    ALTER TABLE profiles ADD COLUMN public_slug text UNIQUE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'is_public'
  ) THEN
    ALTER TABLE profiles ADD COLUMN is_public boolean DEFAULT false;
  END IF;
END $$;

-- Create index for fast public_slug lookups
CREATE INDEX IF NOT EXISTS idx_profiles_public_slug ON profiles(public_slug) WHERE public_slug IS NOT NULL;

-- Create reserved slugs table to prevent conflicts
CREATE TABLE IF NOT EXISTS reserved_slugs (
  slug text PRIMARY KEY,
  reason text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Insert reserved slugs (app routes and common words)
INSERT INTO reserved_slugs (slug, reason) VALUES
  ('admin', 'Admin route'),
  ('api', 'API route'),
  ('auth', 'Auth route'),
  ('dashboard', 'App route'),
  ('login', 'Auth route'),
  ('logout', 'Auth route'),
  ('signup', 'Auth route'),
  ('portfolio', 'App route'),
  ('projets', 'App route'),
  ('pricing', 'App route'),
  ('success', 'App route'),
  ('reset-password', 'App route'),
  ('terms-of-service', 'App route'),
  ('privacy-policy', 'App route'),
  ('functions', 'Supabase route'),
  ('storage', 'Supabase route'),
  ('rest', 'Supabase route'),
  ('realtime', 'Supabase route'),
  ('www', 'Subdomain'),
  ('mail', 'Subdomain'),
  ('ftp', 'Subdomain'),
  ('blog', 'Common subdomain'),
  ('shop', 'Common subdomain'),
  ('store', 'Common subdomain'),
  ('app', 'Common subdomain'),
  ('help', 'Common subdomain'),
  ('support', 'Common subdomain'),
  ('docs', 'Common subdomain'),
  ('about', 'Common route'),
  ('contact', 'Common route'),
  ('home', 'Common route'),
  ('index', 'Common route'),
  ('test', 'Reserved'),
  ('demo', 'Reserved'),
  ('example', 'Reserved'),
  ('sample', 'Reserved'),
  ('null', 'Reserved'),
  ('undefined', 'Reserved'),
  ('true', 'Reserved'),
  ('false', 'Reserved')
ON CONFLICT (slug) DO NOTHING;

-- Enable RLS on reserved_slugs
ALTER TABLE reserved_slugs ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read reserved slugs for validation
CREATE POLICY "Anyone can read reserved slugs"
  ON reserved_slugs
  FOR SELECT
  TO public
  USING (true);

-- Update RLS policies for public portfolio access

-- Allow anonymous users to read public profiles
CREATE POLICY "Anonymous users can read public profiles"
  ON profiles
  FOR SELECT
  TO anon
  USING (public_slug IS NOT NULL AND is_public = true);

-- Allow anonymous users to read apprentissages of public profiles
CREATE POLICY "Anonymous users can read public apprentissages"
  ON apprentissages
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE profiles.id = apprentissages.user_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );

-- Allow anonymous users to read projets of public profiles
CREATE POLICY "Anonymous users can read public projets"
  ON projets
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE profiles.id = projets.user_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );

-- Allow anonymous users to read preuves of public apprentissages
CREATE POLICY "Anonymous users can read public preuves"
  ON preuves
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1
      FROM apprentissages
      JOIN profiles ON profiles.id = apprentissages.user_id
      WHERE apprentissages.id = preuves.apprentissage_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );

-- Allow anonymous users to read fichiers_projets of public projets
CREATE POLICY "Anonymous users can read public fichiers_projets"
  ON fichiers_projets
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1
      FROM projets
      JOIN profiles ON profiles.id = projets.user_id
      WHERE projets.id = fichiers_projets.projet_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );

-- Allow anonymous users to read featured apprentissages of public profiles
CREATE POLICY "Anonymous users can read public featured apprentissages"
  ON featured_apprentissages
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE profiles.id = featured_apprentissages.user_id
      AND profiles.public_slug IS NOT NULL
      AND profiles.is_public = true
    )
  );