/*
  # Gamification System for FolioLink

  1. New Tables
    - `user_trophies`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to profiles)
      - `trophy_id` (text, trophy identifier)
      - `unlocked_at` (timestamp)
      - `points_earned` (integer)
    
    - `user_stats`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to profiles)
      - `total_points` (integer)
      - `level` (integer)
      - `portfolio_views` (integer)
      - `days_active` (integer)
      - `current_streak` (integer)
      - `last_activity` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for users to manage their own gamification data

  3. Indexes
    - Index on user_id for both tables
    - Index on trophy_id for user_trophies
    - Index on total_points for leaderboards
*/

-- Create user_trophies table
CREATE TABLE IF NOT EXISTS user_trophies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  trophy_id text NOT NULL,
  unlocked_at timestamptz DEFAULT now(),
  points_earned integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create user_stats table
CREATE TABLE IF NOT EXISTS user_stats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  total_points integer DEFAULT 0,
  level integer DEFAULT 1,
  portfolio_views integer DEFAULT 0,
  days_active integer DEFAULT 0,
  current_streak integer DEFAULT 0,
  last_activity timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE user_trophies ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_trophies_user_id ON user_trophies(user_id);
CREATE INDEX IF NOT EXISTS idx_user_trophies_trophy_id ON user_trophies(trophy_id);
CREATE INDEX IF NOT EXISTS idx_user_trophies_unlocked_at ON user_trophies(unlocked_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_user_stats_total_points ON user_stats(total_points DESC);
CREATE INDEX IF NOT EXISTS idx_user_stats_level ON user_stats(level DESC);

-- RLS Policies for user_trophies
CREATE POLICY "Users can view own trophies"
  ON user_trophies
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own trophies"
  ON user_trophies
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own trophies"
  ON user_trophies
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- RLS Policies for user_stats
CREATE POLICY "Users can view own stats"
  ON user_stats
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own stats"
  ON user_stats
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own stats"
  ON user_stats
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Create unique constraint to prevent duplicate trophies
ALTER TABLE user_trophies ADD CONSTRAINT unique_user_trophy UNIQUE (user_id, trophy_id);

-- Create unique constraint for user_stats (one record per user)
ALTER TABLE user_stats ADD CONSTRAINT unique_user_stats UNIQUE (user_id);

-- Create trigger to update user_stats.updated_at
CREATE OR REPLACE FUNCTION update_user_stats_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_stats_updated_at_trigger
  BEFORE UPDATE ON user_stats
  FOR EACH ROW
  EXECUTE FUNCTION update_user_stats_updated_at();

-- Function to calculate user level based on points
CREATE OR REPLACE FUNCTION calculate_user_level(points integer)
RETURNS integer AS $$
BEGIN
  IF points < 100 THEN RETURN 1;
  ELSIF points < 300 THEN RETURN 2;
  ELSIF points < 600 THEN RETURN 3;
  ELSIF points < 1000 THEN RETURN 4;
  ELSIF points < 1500 THEN RETURN 5;
  ELSIF points < 2500 THEN RETURN 6;
  ELSIF points < 4000 THEN RETURN 7;
  ELSIF points < 6000 THEN RETURN 8;
  ELSIF points < 9000 THEN RETURN 9;
  ELSE RETURN 10;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to update user stats when trophies are added
CREATE OR REPLACE FUNCTION update_user_stats_on_trophy()
RETURNS TRIGGER AS $$
BEGIN
  -- Calculate total points for the user
  INSERT INTO user_stats (user_id, total_points, level, updated_at)
  VALUES (
    NEW.user_id,
    NEW.points_earned,
    calculate_user_level(NEW.points_earned),
    now()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET
    total_points = user_stats.total_points + NEW.points_earned,
    level = calculate_user_level(user_stats.total_points + NEW.points_earned),
    updated_at = now();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update stats when trophies are earned
CREATE TRIGGER update_stats_on_trophy_trigger
  AFTER INSERT ON user_trophies
  FOR EACH ROW
  EXECUTE FUNCTION update_user_stats_on_trophy();