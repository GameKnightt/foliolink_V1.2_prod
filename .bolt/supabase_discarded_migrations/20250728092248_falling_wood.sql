/*
  # Add project categories and organization features

  1. New Tables
    - `project_categories`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to users)
      - `name` (text, category name)
      - `color` (text, category color)
      - `icon` (text, category icon)
      - `created_at` (timestamp)

  2. Changes
    - Add `category_id` column to `projets` table
    - Add foreign key constraint

  3. Security
    - Enable RLS on `project_categories` table
    - Add policies for authenticated users to manage their own categories
*/

-- Create project categories table
CREATE TABLE IF NOT EXISTS project_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name text NOT NULL,
  color text NOT NULL DEFAULT 'blue',
  icon text NOT NULL DEFAULT '📁',
  created_at timestamptz DEFAULT now()
);

-- Add category_id to projets table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projets' AND column_name = 'category_id'
  ) THEN
    ALTER TABLE projets ADD COLUMN category_id uuid REFERENCES project_categories(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_project_categories_user_id ON project_categories(user_id);
CREATE INDEX IF NOT EXISTS idx_projets_category_id ON projets(category_id);

-- Enable RLS
ALTER TABLE project_categories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read own project categories" ON project_categories;
DROP POLICY IF EXISTS "Users can insert own project categories" ON project_categories;
DROP POLICY IF EXISTS "Users can update own project categories" ON project_categories;
DROP POLICY IF EXISTS "Users can delete own project categories" ON project_categories;

-- Create policies for project categories
CREATE POLICY "Users can read own project categories"
  ON project_categories
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own project categories"
  ON project_categories
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own project categories"
  ON project_categories
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own project categories"
  ON project_categories
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Insert default categories for existing users
INSERT INTO project_categories (user_id, name, color, icon)
SELECT DISTINCT p.user_id, 'Général', 'blue', '📁'
FROM projets p
WHERE NOT EXISTS (
  SELECT 1 FROM project_categories pc 
  WHERE pc.user_id = p.user_id
)
ON CONFLICT DO NOTHING;