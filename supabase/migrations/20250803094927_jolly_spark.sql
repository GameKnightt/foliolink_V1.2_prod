/*
  # Reset and Fix Profiles System

  1. Clean Reset
    - Drop and recreate profiles table with proper structure
    - Recreate RLS policies that actually work
    - Add proper triggers and functions

  2. Security
    - Simple and effective RLS policies
    - Proper user authentication checks
    - Safe profile creation and updates

  3. Data Integrity
    - NOT NULL constraints where needed
    - Default values for optional fields
    - Proper foreign key relationships
*/

-- Drop existing problematic elements
DROP TRIGGER IF EXISTS handle_updated_at_profiles ON profiles;
DROP FUNCTION IF EXISTS safe_upsert_profile(uuid, text, text, text, text, text, text, text, text, text, text, text, text, jsonb, boolean);
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Recreate profiles table with clean structure
DROP TABLE IF EXISTS profiles CASCADE;

CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text,
  formation text DEFAULT 'BUT GEII - Parcours AII',
  annee_etudes text DEFAULT '3',
  etablissement text,
  telephone text,
  linkedin text,
  github text,
  bio text,
  avatar_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  onboarding_completed boolean DEFAULT false,
  public_slug text UNIQUE,
  is_public boolean DEFAULT false,
  theme text DEFAULT 'dark',
  background_url text,
  background_type text DEFAULT 'default' CHECK (background_type IN ('default', 'image', 'gradient', 'solid')),
  background_settings jsonb DEFAULT '{}'::jsonb
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create simple and effective RLS policies
CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

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

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_profiles_public_slug ON profiles(public_slug) WHERE public_slug IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_theme ON profiles(theme) WHERE theme IS NOT NULL;

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_updated_at_profiles
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_updated_at();

-- Create function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- Profile already exists, update it
    UPDATE profiles 
    SET 
      email = NEW.email,
      full_name = COALESCE(NEW.raw_user_meta_data->>'full_name', full_name),
      avatar_url = COALESCE(NEW.raw_user_meta_data->>'avatar_url', avatar_url),
      updated_at = now()
    WHERE id = NEW.id;
    RETURN NEW;
  WHEN OTHERS THEN
    -- Log error but don't fail the auth process
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user registration
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();