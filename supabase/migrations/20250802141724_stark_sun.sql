/*
  # Add theme support to profiles

  1. New Columns
    - `theme` (text) - DaisyUI theme name for user portfolio customization
      - Default value: 'dark'
      - Allows users to personalize their portfolio appearance
      - Stored theme preference persists across sessions

  2. Security
    - Users can update their own theme preference
    - Theme setting is included in existing RLS policies

  3. Index
    - Add index on theme column for performance (where theme is not null)
*/

-- Add theme column to profiles table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'theme'
  ) THEN
    ALTER TABLE profiles ADD COLUMN theme text DEFAULT 'dark';
  END IF;
END $$;

-- Add index for theme column for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_theme ON profiles(theme) WHERE theme IS NOT NULL;

-- Add comment to the theme column
COMMENT ON COLUMN profiles.theme IS 'DaisyUI theme name for user portfolio customization';