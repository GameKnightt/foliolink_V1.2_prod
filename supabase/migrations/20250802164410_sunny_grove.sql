/*
  # Fix RLS policies for apprentissage_categories table

  1. Security Updates
    - Drop existing policies if they exist
    - Add correct RLS policies using auth.uid() function
    - Ensure authenticated users can manage their own categories
    - Allow anonymous users to read public categories

  2. Policy Details
    - INSERT: Users can create categories for themselves
    - SELECT: Users can read their own categories + public ones
    - UPDATE: Users can update their own categories
    - DELETE: Users can delete their own categories
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can insert own categories" ON apprentissage_categories;
DROP POLICY IF EXISTS "Users can read own categories" ON apprentissage_categories;
DROP POLICY IF EXISTS "Users can update own categories" ON apprentissage_categories;
DROP POLICY IF EXISTS "Users can delete own categories" ON apprentissage_categories;
DROP POLICY IF EXISTS "Anonymous users can read public categories" ON apprentissage_categories;

-- Ensure RLS is enabled
ALTER TABLE apprentissage_categories ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Users can insert own categories"
  ON apprentissage_categories
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own categories"
  ON apprentissage_categories
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own categories"
  ON apprentissage_categories
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own categories"
  ON apprentissage_categories
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create policy for anonymous users to read public categories
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