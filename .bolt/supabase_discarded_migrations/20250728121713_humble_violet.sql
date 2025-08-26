/*
  # Create user_account_info view

  1. New View
    - `user_account_info`
      - Combines user profile data with premium status
      - Determines if user is premium based on Stripe data
      - Includes account type and premium purchase date

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
  p.created_at,
  p.updated_at,
  p.onboarding_completed,
  CASE 
    WHEN so.payment_status = 'paid' AND so.status = 'completed' THEN 'premium'
    WHEN ss.status IN ('active', 'trialing') THEN 'premium'
    ELSE 'free'
  END as account_type,
  CASE 
    WHEN so.payment_status = 'paid' AND so.status = 'completed' THEN true
    WHEN ss.status IN ('active', 'trialing') THEN true
    ELSE false
  END as is_premium,
  COALESCE(so.created_at, ss.created_at) as premium_purchased_at,
  CASE 
    WHEN so.payment_status = 'paid' AND so.status = 'completed' THEN true
    WHEN ss.status IN ('active', 'trialing') THEN true
    ELSE false
  END as premium_features_enabled
FROM profiles p
LEFT JOIN stripe_customers sc ON p.id = sc.user_id AND sc.deleted_at IS NULL
LEFT JOIN stripe_subscriptions ss ON sc.customer_id = ss.customer_id AND ss.deleted_at IS NULL
LEFT JOIN stripe_orders so ON sc.customer_id = so.customer_id AND so.deleted_at IS NULL;

-- Enable RLS on the view
ALTER VIEW user_account_info SET (security_invoker = true);

-- Create RLS policy for the view
CREATE POLICY "Users can view their own account info"
  ON user_account_info
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);