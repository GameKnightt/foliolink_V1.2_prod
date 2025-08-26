/*
  # Create user_account_info view

  1. New View
    - `user_account_info`
      - Combines user profile data with premium status
      - Shows if user has active premium subscription or one-time payment
      - Includes all necessary user information

  2. Security
    - Enable RLS on view
    - Users can only see their own account info
*/

-- Create the user_account_info view
CREATE OR REPLACE VIEW user_account_info AS
SELECT 
  p.id,
  p.email,
  p.full_name,
  p.formation,
  p.annee_etudes,
  p.etablissement,
  p.telephone,
  p.linkedin,
  p.github,
  p.bio,
  p.avatar_url,
  p.onboarding_completed,
  p.created_at,
  p.updated_at,
  -- Determine if user is premium based on subscription or order status
  CASE 
    WHEN ss.status IN ('active', 'trialing') THEN true
    WHEN so.status = 'completed' AND so.payment_status = 'paid' THEN true
    ELSE false
  END as is_premium,
  -- Premium details
  COALESCE(ss.current_period_end, EXTRACT(epoch FROM so.created_at)::bigint) as premium_expires_at,
  COALESCE(ss.status::text, so.status::text) as premium_status,
  CASE 
    WHEN ss.subscription_id IS NOT NULL THEN 'subscription'
    WHEN so.id IS NOT NULL THEN 'one_time'
    ELSE 'free'
  END as account_type
FROM profiles p
LEFT JOIN stripe_customers sc ON p.id = sc.user_id AND sc.deleted_at IS NULL
LEFT JOIN stripe_subscriptions ss ON sc.customer_id = ss.customer_id AND ss.deleted_at IS NULL
LEFT JOIN stripe_orders so ON sc.customer_id = so.customer_id AND so.deleted_at IS NULL AND so.status = 'completed';

-- Enable RLS on the view
ALTER VIEW user_account_info SET (security_invoker = true);

-- Create RLS policy for the view
CREATE POLICY "Users can view their own account info"
  ON user_account_info
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);