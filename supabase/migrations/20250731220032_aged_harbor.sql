/*
  # Fix Competences Table RLS Policies

  1. Current Issue
    - Only SELECT policy exists for competences table
    - Users cannot INSERT, UPDATE, or DELETE their own competences
    - Missing user_id column to track ownership

  2. Changes Made
    - Add user_id column to track competence ownership
    - Create INSERT policy for authenticated users
    - Create UPDATE policy for users to modify their own competences
    - Create DELETE policy for users to delete their own competences
    - Update existing SELECT policy to include user ownership

  3. Security
    - All policies use auth.uid() to ensure users can only access their own data
    - Anonymous users can still read public competences
    - Authenticated users can manage their own competences
*/

-- Add user_id column to competences table if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'competences' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE competences ADD COLUMN user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Create index for better performance on user_id queries
CREATE INDEX IF NOT EXISTS idx_competences_user_id ON competences(user_id);

-- Drop existing policies to recreate them with proper conditions
DROP POLICY IF EXISTS "Anyone can read competences" ON competences;

-- SELECT Policy: Allow users to read their own competences + public competences
CREATE POLICY "Users can read own competences and public competences"
  ON competences
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = user_id OR user_id IS NULL
  );

-- SELECT Policy: Allow anonymous users to read public competences (where user_id is NULL)
CREATE POLICY "Anonymous users can read public competences"
  ON competences
  FOR SELECT
  TO anon
  USING (user_id IS NULL);

-- INSERT Policy: Allow authenticated users to create their own competences
CREATE POLICY "Users can insert own competences"
  ON competences
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- UPDATE Policy: Allow users to update their own competences
CREATE POLICY "Users can update own competences"
  ON competences
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- DELETE Policy: Allow users to delete their own competences
CREATE POLICY "Users can delete own competences"
  ON competences
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);