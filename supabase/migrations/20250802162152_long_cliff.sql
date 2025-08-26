/*
  # Security Enhancement Tables

  1. New Tables
    - `user_rate_limits` - Track API rate limiting per user
    - `security_logs` - Log security events and suspicious activities
    - `reserved_slugs` - Prevent users from using reserved usernames

  2. Security Features
    - Rate limiting for AI requests
    - Security event logging
    - Reserved username protection
    - Enhanced audit trail

  3. Performance Optimizations
    - Indexes for fast lookups
    - Automatic cleanup of old logs
*/

-- Rate limiting table for API endpoints
CREATE TABLE IF NOT EXISTS user_rate_limits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  endpoint text NOT NULL,
  request_count integer DEFAULT 1,
  last_request timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, endpoint)
);

-- Security logs for audit trail
CREATE TABLE IF NOT EXISTS security_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  event_type text NOT NULL,
  event_data jsonb DEFAULT '{}',
  ip_address inet,
  user_agent text,
  created_at timestamptz DEFAULT now()
);

-- Reserved slugs to prevent conflicts
CREATE TABLE IF NOT EXISTS reserved_slugs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  reason text,
  created_at timestamptz DEFAULT now()
);

-- Insert common reserved slugs
INSERT INTO reserved_slugs (slug, reason) VALUES
  ('admin', 'System reserved'),
  ('root', 'System reserved'),
  ('api', 'System reserved'),
  ('www', 'System reserved'),
  ('mail', 'System reserved'),
  ('ftp', 'System reserved'),
  ('test', 'System reserved'),
  ('demo', 'System reserved'),
  ('support', 'System reserved'),
  ('help', 'System reserved'),
  ('foliolink', 'Brand reserved'),
  ('portfolio', 'System reserved'),
  ('dashboard', 'System reserved'),
  ('login', 'System reserved'),
  ('signup', 'System reserved'),
  ('auth', 'System reserved'),
  ('oauth', 'System reserved'),
  ('callback', 'System reserved'),
  ('webhook', 'System reserved'),
  ('stripe', 'System reserved'),
  ('supabase', 'System reserved')
ON CONFLICT (slug) DO NOTHING;

-- Enable RLS on all new tables
ALTER TABLE user_rate_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reserved_slugs ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_rate_limits
CREATE POLICY "Users can view own rate limits"
  ON user_rate_limits
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "System can manage rate limits"
  ON user_rate_limits
  FOR ALL
  TO service_role
  USING (true);

-- RLS Policies for security_logs
CREATE POLICY "Users can view own security logs"
  ON security_logs
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "System can manage security logs"
  ON security_logs
  FOR ALL
  TO service_role
  USING (true);

-- RLS Policies for reserved_slugs
CREATE POLICY "Anyone can read reserved slugs"
  ON reserved_slugs
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only service role can manage reserved slugs"
  ON reserved_slugs
  FOR ALL
  TO service_role
  USING (true);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_rate_limits_user_endpoint 
  ON user_rate_limits(user_id, endpoint);

CREATE INDEX IF NOT EXISTS idx_user_rate_limits_last_request 
  ON user_rate_limits(last_request);

CREATE INDEX IF NOT EXISTS idx_security_logs_user_id 
  ON security_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_security_logs_event_type 
  ON security_logs(event_type);

CREATE INDEX IF NOT EXISTS idx_security_logs_created_at 
  ON security_logs(created_at);

CREATE INDEX IF NOT EXISTS idx_reserved_slugs_slug 
  ON reserved_slugs(slug);

-- Function to clean up old rate limit records
CREATE OR REPLACE FUNCTION cleanup_old_rate_limits()
RETURNS void AS $$
BEGIN
  DELETE FROM user_rate_limits 
  WHERE last_request < now() - interval '24 hours';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean up old security logs (keep 90 days)
CREATE OR REPLACE FUNCTION cleanup_old_security_logs()
RETURNS void AS $$
BEGIN
  DELETE FROM security_logs 
  WHERE created_at < now() - interval '90 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to log security events
CREATE OR REPLACE FUNCTION log_security_event(
  p_user_id uuid,
  p_event_type text,
  p_event_data jsonb DEFAULT '{}',
  p_ip_address inet DEFAULT NULL,
  p_user_agent text DEFAULT NULL
)
RETURNS uuid AS $$
DECLARE
  log_id uuid;
BEGIN
  INSERT INTO security_logs (user_id, event_type, event_data, ip_address, user_agent)
  VALUES (p_user_id, p_event_type, p_event_data, p_ip_address, p_user_agent)
  RETURNING id INTO log_id;
  
  RETURN log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;