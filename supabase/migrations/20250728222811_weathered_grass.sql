/*
  # Fix Featured Apprentissages Policy Conflict

  1. Problem Resolution
    - Drop existing conflicting policies on featured_apprentissages table
    - Recreate policies with proper IF NOT EXISTS handling
    - Ensure idempotent migration that can be run multiple times

  2. Security
    - Maintain proper RLS policies for featured apprentissages
    - Ensure users can only access their own featured apprentissages
    - Preserve data integrity and access control
*/

-- Drop existing policies that might conflict
DROP POLICY IF EXISTS "Users can read own featured apprentissages" ON public.featured_apprentissages;
DROP POLICY IF EXISTS "Users can insert own featured apprentissages" ON public.featured_apprentissages;
DROP POLICY IF EXISTS "Users can update own featured apprentissages" ON public.featured_apprentissages;
DROP POLICY IF EXISTS "Users can delete own featured apprentissages" ON public.featured_apprentissages;

-- Ensure RLS is enabled
ALTER TABLE public.featured_apprentissages ENABLE ROW LEVEL SECURITY;

-- Recreate policies with proper names and conditions
CREATE POLICY "Users can read own featured apprentissages"
  ON public.featured_apprentissages
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own featured apprentissages"
  ON public.featured_apprentissages
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own featured apprentissages"
  ON public.featured_apprentissages
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own featured apprentissages"
  ON public.featured_apprentissages
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Ensure the table has proper constraints and indexes
DO $$
BEGIN
  -- Add index for performance if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE tablename = 'featured_apprentissages' 
    AND indexname = 'idx_featured_apprentissages_user_priority'
  ) THEN
    CREATE INDEX idx_featured_apprentissages_user_priority 
    ON public.featured_apprentissages (user_id, priority_order);
  END IF;

  -- Ensure unique constraint exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'featured_apprentissages_user_id_apprentissage_id_key'
  ) THEN
    ALTER TABLE public.featured_apprentissages 
    ADD CONSTRAINT featured_apprentissages_user_id_apprentissage_id_key 
    UNIQUE (user_id, apprentissage_id);
  END IF;

  -- Ensure priority order constraint exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'max_featured_apprentissages'
  ) THEN
    ALTER TABLE public.featured_apprentissages 
    ADD CONSTRAINT max_featured_apprentissages 
    CHECK (priority_order >= 1 AND priority_order <= 3);
  END IF;
END $$;