/*
  # Ensure User Competences Persistence

  1. Database Structure
    - Ensure competences table supports user-specific competences
    - Add proper foreign key relationships
    - Set up RLS policies for data security

  2. Data Integrity
    - Ensure all user competences are stored in database
    - Remove dependency on localStorage for critical data
    - Add proper indexing for performance

  3. Migration Safety
    - Preserve existing data during migration
    - Add constraints to prevent data loss
*/

-- Ensure the competences table has proper user_id column and constraints
DO $$
BEGIN
  -- Check if user_id column exists and is properly configured
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'competences' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE competences ADD COLUMN user_id uuid REFERENCES users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Ensure proper indexing for performance
CREATE INDEX IF NOT EXISTS idx_competences_user_id_performance 
ON competences(user_id) WHERE user_id IS NOT NULL;

-- Ensure RLS policies are comprehensive
DROP POLICY IF EXISTS "Users can manage own competences" ON competences;

CREATE POLICY "Users can insert own competences"
  ON competences
  FOR INSERT
  TO authenticated
  WITH CHECK (uid() = user_id);

CREATE POLICY "Users can read own competences and public competences"
  ON competences
  FOR SELECT
  TO authenticated
  USING ((uid() = user_id) OR (user_id IS NULL));

CREATE POLICY "Users can update own competences"
  ON competences
  FOR UPDATE
  TO authenticated
  USING (uid() = user_id)
  WITH CHECK (uid() = user_id);

CREATE POLICY "Users can delete own competences"
  ON competences
  FOR DELETE
  TO authenticated
  USING (uid() = user_id);

-- Ensure anonymous users can still read public competences
CREATE POLICY IF NOT EXISTS "Anonymous users can read public competences"
  ON competences
  FOR SELECT
  TO anon
  USING (user_id IS NULL);

-- Add function to migrate localStorage competences to database
CREATE OR REPLACE FUNCTION migrate_user_competences_to_db(
  p_user_id uuid,
  p_competences jsonb
) RETURNS void AS $$
DECLARE
  competence_record jsonb;
BEGIN
  -- Loop through each competence in the JSON array
  FOR competence_record IN SELECT * FROM jsonb_array_elements(p_competences)
  LOOP
    -- Insert competence if it doesn't exist for this user
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
    ON CONFLICT (id) DO UPDATE SET
      title = EXCLUDED.title,
      subtitle = EXCLUDED.subtitle,
      description = EXCLUDED.description,
      levels = EXCLUDED.levels,
      color = EXCLUDED.color,
      icon = EXCLUDED.icon,
      updated_at = now()
    WHERE competences.user_id = p_user_id;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;