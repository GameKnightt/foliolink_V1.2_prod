/*
  # Create user_competences table for custom user competences

  1. New Tables
    - `user_competences`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to users)
      - `competence_id` (text, unique identifier for the competence)
      - `title` (text, competence title)
      - `subtitle` (text, competence subtitle)
      - `description` (text, competence description)
      - `levels` (integer, number of levels)
      - `color` (text, color theme)
      - `icon` (text, emoji icon)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `user_competences` table
    - Add policies for authenticated users to manage their own competences

  3. Indexes
    - Index on user_id for performance
    - Unique constraint on user_id + competence_id
*/

CREATE TABLE IF NOT EXISTS user_competences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  competence_id text NOT NULL,
  title text NOT NULL,
  subtitle text NOT NULL,
  description text NOT NULL,
  levels integer NOT NULL DEFAULT 3,
  color text NOT NULL DEFAULT 'primary',
  icon text NOT NULL DEFAULT '🎯',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, competence_id)
);

-- Enable RLS
ALTER TABLE user_competences ENABLE ROW LEVEL SECURITY;

-- Policies for user_competences
CREATE POLICY "Users can read own competences"
  ON user_competences
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own competences"
  ON user_competences
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own competences"
  ON user_competences
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own competences"
  ON user_competences
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_competences_user_id ON user_competences(user_id);

-- Trigger for updated_at
CREATE TRIGGER handle_updated_at_user_competences
  BEFORE UPDATE ON user_competences
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at();