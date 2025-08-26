/*
  # Fix Profile Persistence Issues

  1. Security Policies
    - Update RLS policies for profiles table to ensure proper access
    - Add missing policies for profile creation and updates
  
  2. Data Integrity
    - Ensure email field is properly handled
    - Add proper constraints and defaults
  
  3. User Experience
    - Fix profile data persistence across page reloads
    - Ensure proper error handling
*/

-- First, let's check and fix the profiles table structure
DO $$
BEGIN
  -- Ensure the profiles table has proper structure
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'email'
  ) THEN
    ALTER TABLE profiles ADD COLUMN email text NOT NULL DEFAULT '';
  END IF;
END $$;

-- Drop existing policies to recreate them properly
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Anonymous users can read public profiles" ON profiles;

-- Create comprehensive RLS policies for profiles
CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can read own profile"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Anonymous users can read public profiles"
  ON profiles
  FOR SELECT
  TO anon
  USING (public_slug IS NOT NULL AND is_public = true);

-- Ensure RLS is enabled
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create or update the handle_new_user function to properly create profiles
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    formation,
    annee_etudes,
    onboarding_completed
  )
  VALUES (
    new.id,
    COALESCE(new.email, new.id || '@foliolink.noemail'),
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    'BUT GEII - Parcours AII',
    '3',
    false
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure the trigger exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Create function to handle profile updates with proper error handling
CREATE OR REPLACE FUNCTION safe_upsert_profile(
  user_id uuid,
  user_email text,
  user_full_name text DEFAULT '',
  user_formation text DEFAULT 'BUT GEII - Parcours AII',
  user_annee_etudes text DEFAULT '3',
  user_etablissement text DEFAULT '',
  user_telephone text DEFAULT '',
  user_linkedin text DEFAULT '',
  user_github text DEFAULT '',
  user_bio text DEFAULT '',
  user_avatar_url text DEFAULT '',
  user_theme text DEFAULT 'dark',
  user_background_type text DEFAULT 'default',
  user_background_url text DEFAULT '',
  user_background_settings jsonb DEFAULT '{}',
  user_onboarding_completed boolean DEFAULT false
)
RETURNS json AS $$
DECLARE
  result_profile json;
BEGIN
  -- Ensure email is never null
  IF user_email IS NULL OR user_email = '' THEN
    user_email := user_id || '@foliolink.noemail';
  END IF;

  -- Insert or update profile
  INSERT INTO profiles (
    id,
    email,
    full_name,
    formation,
    annee_etudes,
    etablissement,
    telephone,
    linkedin,
    github,
    bio,
    avatar_url,
    theme,
    background_type,
    background_url,
    background_settings,
    onboarding_completed,
    created_at,
    updated_at
  ) VALUES (
    user_id,
    user_email,
    user_full_name,
    user_formation,
    user_annee_etudes,
    user_etablissement,
    user_telephone,
    user_linkedin,
    user_github,
    user_bio,
    user_avatar_url,
    user_theme,
    user_background_type,
    user_background_url,
    user_background_settings,
    user_onboarding_completed,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    formation = EXCLUDED.formation,
    annee_etudes = EXCLUDED.annee_etudes,
    etablissement = EXCLUDED.etablissement,
    telephone = EXCLUDED.telephone,
    linkedin = EXCLUDED.linkedin,
    github = EXCLUDED.github,
    bio = EXCLUDED.bio,
    avatar_url = EXCLUDED.avatar_url,
    theme = EXCLUDED.theme,
    background_type = EXCLUDED.background_type,
    background_url = EXCLUDED.background_url,
    background_settings = EXCLUDED.background_settings,
    onboarding_completed = EXCLUDED.onboarding_completed,
    updated_at = NOW();

  -- Return the updated profile
  SELECT to_json(profiles.*) INTO result_profile
  FROM profiles
  WHERE id = user_id;

  RETURN result_profile;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION safe_upsert_profile TO authenticated;
GRANT EXECUTE ON FUNCTION handle_new_user TO service_role;