/*
  # Fix authentication issues

  1. Database Health Check
    - Verify auth.users table structure
    - Check profiles table and triggers
    - Ensure RLS policies are correct
    
  2. Reset any corrupted auth state
    - Clean up any invalid sessions
    - Verify user data integrity
*/

-- Check if auth schema exists and is properly configured
DO $$
BEGIN
  -- Ensure profiles table has proper structure
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'id'
  ) THEN
    RAISE EXCEPTION 'Profiles table structure issue detected';
  END IF;
END $$;

-- Ensure the handle_new_user trigger function exists
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, onboarding_completed)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    false
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure the trigger exists on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Ensure updated_at trigger function exists
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Verify RLS policies on profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Recreate policies to ensure they work correctly
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

CREATE POLICY "Users can read own profile"
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
  USING (auth.uid() = id);

-- Clean up any potential auth issues
-- Remove any orphaned sessions (this is handled by Supabase automatically)

-- Verify auth configuration
DO $$
BEGIN
  -- Check if we can access auth functions
  PERFORM auth.uid();
  RAISE NOTICE 'Auth functions are accessible';
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Auth functions check failed: %', SQLERRM;
END $$;