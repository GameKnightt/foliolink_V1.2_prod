/*
  # Add RLS policies for apprentissage_categories table

  1. Security Policies
    - Enable RLS on `apprentissage_categories` table (if not already enabled)
    - Add policy for authenticated users to insert their own categories
    - Add policy for authenticated users to select their own categories
    - Add policy for authenticated users to update their own categories
    - Add policy for authenticated users to delete their own categories
    - Add policy for anonymous users to read public categories (for public portfolios)

  2. Notes
    - Policies ensure users can only manage their own categories
    - Public access is provided for portfolio viewing
    - All operations are secured by user_id matching
*/

-- Enable RLS on apprentissage_categories table (if not already enabled)
ALTER TABLE apprentissage_categories ENABLE ROW LEVEL SECURITY;

-- Policy for authenticated users to insert their own categories
CREATE POLICY "Users can insert own categories"
  ON apprentissage_categories
  FOR INSERT
  TO authenticated
  WITH CHECK (uid() = user_id);

-- Policy for authenticated users to select their own categories
CREATE POLICY "Users can read own categories"
  ON apprentissage_categories
  FOR SELECT
  TO authenticated
  USING (uid() = user_id);

-- Policy for authenticated users to update their own categories
CREATE POLICY "Users can update own categories"
  ON apprentissage_categories
  FOR UPDATE
  TO authenticated
  USING (uid() = user_id)
  WITH CHECK (uid() = user_id);

-- Policy for authenticated users to delete their own categories
CREATE POLICY "Users can delete own categories"
  ON apprentissage_categories
  FOR DELETE
  TO authenticated
  USING (uid() = user_id);

-- Policy for anonymous users to read public categories (for public portfolios)
CREATE POLICY "Anonymous users can read public categories"
  ON apprentissage_categories
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 
      FROM profiles 
      WHERE profiles.id = apprentissage_categories.user_id 
        AND profiles.public_slug IS NOT NULL 
        AND profiles.is_public = true
    )
  );