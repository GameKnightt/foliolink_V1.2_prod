/*
  # Fix profiles table RLS policies

  1. Security Updates
    - Drop existing problematic policies
    - Create proper INSERT policy for authenticated users
    - Create proper UPDATE policy for authenticated users
    - Ensure users can only manage their own profile data

  2. Policy Details
    - INSERT: Allow authenticated users to create profile with their own auth.uid()
    - UPDATE: Allow authenticated users to update only their own profile
    - SELECT: Maintain existing read policies for own data and public profiles
*/

-- Drop existing problematic policies if they exist
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- Create proper INSERT policy
CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Create proper UPDATE policy  
CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Ensure the existing SELECT policies remain intact
-- (These should already exist and work correctly)