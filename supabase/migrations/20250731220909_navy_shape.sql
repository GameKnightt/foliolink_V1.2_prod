/*
  # Fix Competences Table RLS Policies

  1. Table Structure
    - Add `user_id` column to link competences to users
    - Add index for performance on user_id lookups

  2. Security Policies
    - SELECT: Users can read their own competences + public ones
    - INSERT: Users can create competences for themselves
    - UPDATE: Users can modify their own competences
    - DELETE: Users can delete their own competences

  3. Authentication
    - Uses auth.uid() for user identification
    - No dependency on public.users table
    - Compatible with Supabase auth.users system
*/

-- Add user_id column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'competences' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE competences ADD COLUMN user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Add index for performance
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE tablename = 'competences' AND indexname = 'idx_competences_user_id'
  ) THEN
    CREATE INDEX idx_competences_user_id ON competences(user_id);
  END IF;
END $$;

-- Drop existing policies to recreate them
DROP POLICY IF EXISTS "Anyone can read competences" ON competences;
DROP POLICY IF EXISTS "Users can read own competences" ON competences;
DROP POLICY IF EXISTS "Users can insert own competences" ON competences;
DROP POLICY IF EXISTS "Users can update own competences" ON competences;
DROP POLICY IF EXISTS "Users can delete own competences" ON competences;

-- SELECT Policies
CREATE POLICY "Users can read own competences"
  ON competences
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone can read public competences"
  ON competences
  FOR SELECT
  TO public
  USING (user_id IS NULL);

-- INSERT Policy
CREATE POLICY "Users can insert own competences"
  ON competences
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- UPDATE Policy
CREATE POLICY "Users can update own competences"
  ON competences
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- DELETE Policy
CREATE POLICY "Users can delete own competences"
  ON competences
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);