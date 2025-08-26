/*
  # Ensure proper competences persistence

  1. Tables
    - Ensure `competences` table has proper user_id foreign key
    - Add indexes for performance
    - Update RLS policies

  2. Security
    - Enable RLS on competences table
    - Add policies for authenticated users to manage their own competences
    - Add policies for public competences (user_id IS NULL)

  3. Data Integrity
    - Ensure foreign key constraints
    - Add proper indexes
*/

-- Ensure competences table structure is correct
DO $$
BEGIN
  -- Add user_id column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'competences' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE competences ADD COLUMN user_id uuid REFERENCES users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Ensure RLS is enabled
ALTER TABLE competences ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to recreate them properly
DROP POLICY IF EXISTS "Users can read own competences" ON competences;
DROP POLICY IF EXISTS "Users can insert own competences" ON competences;
DROP POLICY IF EXISTS "Users can update own competences" ON competences;
DROP POLICY IF EXISTS "Users can delete own competences" ON competences;
DROP POLICY IF EXISTS "Anyone can read public competences" ON competences;
DROP POLICY IF EXISTS "Anonymous users can read public competences" ON competences;

-- Create comprehensive RLS policies
CREATE POLICY "Users can read own competences and public competences"
  ON competences
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert own competences"
  ON competences
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own competences"
  ON competences
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own competences"
  ON competences
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone can read public competences"
  ON competences
  FOR SELECT
  TO public
  USING (user_id IS NULL);

CREATE POLICY "Anonymous users can read public competences"
  ON competences
  FOR SELECT
  TO anon
  USING (user_id IS NULL);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_competences_user_id ON competences(user_id);
CREATE INDEX IF NOT EXISTS idx_competences_public ON competences(user_id) WHERE user_id IS NULL;