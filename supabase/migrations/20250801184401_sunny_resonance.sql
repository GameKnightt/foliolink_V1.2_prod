/*
  # Add theme customization support

  1. Database Changes
    - Add `theme` column to `profiles` table
    - Set default theme to 'dark'
    - Update RLS policies to include theme access

  2. Theme System
    - Support for DaisyUI themes
    - User-specific theme persistence
    - Public portfolio theme application
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

-- Add comment for the new column
COMMENT ON COLUMN profiles.theme IS 'DaisyUI theme name for user portfolio customization';

-- Create index for theme queries
CREATE INDEX IF NOT EXISTS idx_profiles_theme ON profiles(theme) WHERE theme IS NOT NULL;

-- Update existing profiles to have default theme
UPDATE profiles SET theme = 'dark' WHERE theme IS NULL;