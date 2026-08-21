-- Fix users table for Supabase Auth integration
-- Run this in Supabase SQL Editor

-- Make password_hash nullable since we use Supabase Auth
ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;

-- Add default value for password_hash
ALTER TABLE users ALTER COLUMN password_hash SET DEFAULT '';

-- Allow authenticated users to insert their own row
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own row" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can read own row" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own row" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Allow authenticated users to insert/update their own profile
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles can insert own" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Profiles can read own" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Profiles can update own" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);
