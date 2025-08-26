/*
  # Fix competences data persistence

  1. Database Structure
    - Ensure proper user_id relationships for competences table
    - Add RLS policies for data security and user isolation
    - Create migration function for localStorage data

  2. Security
    - Enable RLS on competences table
    - Add policies for authenticated users to manage their own competences
    - Add policies for anonymous users to read public competences

  3. Data Migration
    - Function to migrate localStorage competences to database
    - Preserve existing user data during transition
*/

-- Ensure the competences table has proper structure
DO $$
BEGIN
  -- Add user_id column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'competences' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE competences ADD COLUMN user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_competences_user_id ON competences(user_id);

-- Enable RLS on competences table
ALTER TABLE competences ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Anonymous users can read public competences" ON competences;
DROP POLICY IF EXISTS "Users can read own competences" ON competences;
DROP POLICY IF EXISTS "Users can insert own competences" ON competences;
DROP POLICY IF EXISTS "Users can update own competences" ON competences;
DROP POLICY IF EXISTS "Users can delete own competences" ON competences;

-- Create RLS policies with correct syntax
CREATE POLICY "Anonymous users can read public competences"
ON competences
FOR SELECT
TO anon
USING (user_id IS NULL);

CREATE POLICY "Users can read own competences"
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

-- Function to migrate localStorage competences to database
CREATE OR REPLACE FUNCTION migrate_user_competences_to_db(
  p_user_id uuid,
  p_competences jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  competence_record jsonb;
BEGIN
  -- Loop through each competence in the JSON array
  FOR competence_record IN SELECT * FROM jsonb_array_elements(p_competences)
  LOOP
    -- Insert competence if it doesn't already exist for this user
    INSERT INTO competences (
      id,
      title,
      subtitle,
      description,
      levels,
      color,
      icon,
      user_id,
      created_at
    )
    VALUES (
      (competence_record->>'id')::text,
      (competence_record->>'title')::text,
      (competence_record->>'subtitle')::text,
      (competence_record->>'description')::text,
      (competence_record->>'levels')::integer,
      (competence_record->>'color')::text,
      (competence_record->>'icon')::text,
      p_user_id,
      now()
    )
    ON CONFLICT (id) DO NOTHING; -- Avoid duplicates
  END LOOP;
END;
$$;