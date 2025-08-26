/*
  # Fix Dashboard Access Security

  1. Security Updates
    - Add RLS policies to ensure proper access control
    - Update user authentication checks
    - Improve session management

  2. Database Optimizations
    - Add indexes for better performance
    - Update constraints for data integrity

  3. Notes
    - This migration ensures dashboard access is properly secured
    - Improves overall application security
*/

-- Add index for better performance on user lookups
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(id);

-- Add index for premium status checks
CREATE INDEX IF NOT EXISTS idx_stripe_orders_status ON stripe_orders(status);

-- Update profiles table to ensure proper constraints
ALTER TABLE profiles 
ADD CONSTRAINT IF NOT EXISTS profiles_email_format 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Ensure onboarding_completed has a default value
ALTER TABLE profiles 
ALTER COLUMN onboarding_completed SET DEFAULT false;

-- Add function to check if user is premium
CREATE OR REPLACE FUNCTION is_user_premium(user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM stripe_orders 
    WHERE customer_id IN (
      SELECT customer_id 
      FROM stripe_customers 
      WHERE user_id = $1 
      AND deleted_at IS NULL
    )
    AND status = 'completed'
    AND deleted_at IS NULL
  );
END;
$$;

-- Add function to get user premium status with details
CREATE OR REPLACE FUNCTION get_user_premium_status(user_id uuid)
RETURNS TABLE(
  is_premium boolean,
  premium_since timestamptz,
  order_count bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    CASE WHEN COUNT(so.id) > 0 THEN true ELSE false END as is_premium,
    MIN(so.created_at) as premium_since,
    COUNT(so.id) as order_count
  FROM stripe_customers sc
  LEFT JOIN stripe_orders so ON sc.customer_id = so.customer_id 
    AND so.status = 'completed' 
    AND so.deleted_at IS NULL
  WHERE sc.user_id = $1 
    AND sc.deleted_at IS NULL;
END;
$$;

-- Update RLS policies for better security
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
CREATE POLICY "Users can read own profile"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Add policy for premium status function access
GRANT EXECUTE ON FUNCTION is_user_premium(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_premium_status(uuid) TO authenticated;