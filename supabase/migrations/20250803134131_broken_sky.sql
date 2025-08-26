/*
  # Add Pioneer Badge Visibility Control

  1. Schema Changes
    - Add `show_pioneer_badge` column to profiles table
    - Set default value to `true` (badge visible by default)
    - Add index for performance

  2. Security
    - RLS policies already exist for profiles table
    - Only users can update their own profile settings
*/

-- Add the show_pioneer_badge column to profiles table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'show_pioneer_badge'
  ) THEN
    ALTER TABLE profiles ADD COLUMN show_pioneer_badge boolean DEFAULT true;
  END IF;
END $$;

-- Add index for performance (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_profiles_show_pioneer_badge 
ON profiles (show_pioneer_badge) 
WHERE show_pioneer_badge IS NOT NULL;