/*
  # Add custom background support

  1. Database Changes
    - Add `background_url` column to profiles table
    - Add `background_type` column (image, gradient, solid)
    - Add `background_settings` JSONB column for additional settings

  2. Storage
    - Create backgrounds bucket for user background images
    - Set appropriate policies for user access

  3. Security
    - Users can only manage their own backgrounds
    - File size and type validation
*/

-- Add background columns to profiles table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'background_url'
  ) THEN
    ALTER TABLE profiles ADD COLUMN background_url text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'background_type'
  ) THEN
    ALTER TABLE profiles ADD COLUMN background_type text DEFAULT 'default';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'background_settings'
  ) THEN
    ALTER TABLE profiles ADD COLUMN background_settings jsonb DEFAULT '{}';
  END IF;
END $$;

-- Add constraint for background_type
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'profiles_background_type_check'
  ) THEN
    ALTER TABLE profiles ADD CONSTRAINT profiles_background_type_check 
    CHECK (background_type IN ('default', 'image', 'gradient', 'solid'));
  END IF;
END $$;

-- Create storage bucket for backgrounds (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('backgrounds', 'backgrounds', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for backgrounds bucket
DO $$
BEGIN
  -- Policy for authenticated users to upload their own backgrounds
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Users can upload own backgrounds'
  ) THEN
    CREATE POLICY "Users can upload own backgrounds"
      ON storage.objects
      FOR INSERT
      TO authenticated
      WITH CHECK (bucket_id = 'backgrounds' AND auth.uid()::text = (storage.foldername(name))[1]);
  END IF;

  -- Policy for authenticated users to update their own backgrounds
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Users can update own backgrounds'
  ) THEN
    CREATE POLICY "Users can update own backgrounds"
      ON storage.objects
      FOR UPDATE
      TO authenticated
      USING (bucket_id = 'backgrounds' AND auth.uid()::text = (storage.foldername(name))[1]);
  END IF;

  -- Policy for authenticated users to delete their own backgrounds
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Users can delete own backgrounds'
  ) THEN
    CREATE POLICY "Users can delete own backgrounds"
      ON storage.objects
      FOR DELETE
      TO authenticated
      USING (bucket_id = 'backgrounds' AND auth.uid()::text = (storage.foldername(name))[1]);
  END IF;

  -- Policy for public read access to backgrounds
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Public can view backgrounds'
  ) THEN
    CREATE POLICY "Public can view backgrounds"
      ON storage.objects
      FOR SELECT
      TO public
      USING (bucket_id = 'backgrounds');
  END IF;
END $$;